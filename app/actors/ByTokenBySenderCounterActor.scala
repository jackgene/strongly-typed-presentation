package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage
import play.api.libs.json.Json


object ByTokenBySenderCounterActor {
  // Incoming messages
  case class Register(listener: ActorRef)
  case object Reset

  // Outgoing messages
  case class Counts(tokensByCount: Map[Int,Seq[String]])

  def props(
      extractToken: String => Option[String],
      chatMessageActor: ActorRef, rejectedMessageActor: ActorRef):
      Props =
    Props(
      new ByTokenBySenderCounterActor(
        extractToken, chatMessageActor, rejectedMessageActor
      )
    )

  // WebSocket actor
  object WebSocketActor {
    def props(webSocketClient: ActorRef, counts: ActorRef): Props =
      Props(new WebSocketActor(webSocketClient, counts))
  }
  class WebSocketActor(webSocketClient: ActorRef, counts: ActorRef)
    extends Actor with ActorLogging {
    log.info("connection opened")
    counts ! ByTokenBySenderCounterActor.Register(listener = self)

    override def receive: Receive = {
      case ByTokenBySenderCounterActor.Counts(sendersByCount: Map[Int,Seq[String]]) =>
        webSocketClient ! Json.toJson(sendersByCount.toSeq) // JSON keys must be strings
    }

    override def postStop(): Unit = {
      log.info("connection closed")
    }
  }
}
private class ByTokenBySenderCounterActor(
    extractToken: String => Option[String],
    chatMessageActor: ActorRef, rejectedMessageActor: ActorRef)
    extends Actor with ActorLogging {
  import ByTokenBySenderCounterActor._

  private def paused(
      tokensByMessenger: Map[String,String], tokenCount: ItemCount, meCount: Int):
      Receive = {
    case Reset =>
      context.become(paused(Map(), ItemCount(), 0))

    case Register(listener: ActorRef) =>
      chatMessageActor ! ChatMessageActor.Register(self)
      listener ! Counts(tokenCount.itemsByCount)
      context.watch(listener)
      context.become(
        running(tokensByMessenger, tokenCount, meCount, Set(listener))
      )
  }

  private def running(
      tokensByMessenger: Map[String,String], tokenCount: ItemCount, meCount: Int,
      listeners: Set[ActorRef]): Receive = {
    case event @ ChatMessageActor.New(msg: ChatMessage) =>
      val (messenger: String, newMeCount:Int) =
        if (msg.sender != "Me") (msg.sender, meCount)
        else (s"Me@${meCount}", meCount + 1)
      val oldTokenOpt: Option[String] = tokensByMessenger.get(messenger)
      val newTokenOpt: Option[String] = extractToken(msg.text)

      newTokenOpt match {
        case Some(newToken: String) =>
          log.info(s"Extracted token \"${newToken}\"")
          val newTokensByMessenger: Map[String,String] =
            tokensByMessenger.updated(messenger, newToken)
          val newTokenCount: ItemCount = oldTokenOpt.
            // Only remove old token if there's a valid new token replacing it
            foldLeft(tokenCount) { (tokenCount: ItemCount, oldToken: String) =>
              tokenCount.updated(oldToken, -1)
            }.
            updated(newToken, 1)

          for (listener: ActorRef <- listeners) {
            listener ! Counts(newTokenCount.itemsByCount)
          }
          context.become(
            running(newTokensByMessenger, newTokenCount, newMeCount, listeners)
          )

        case None =>
          log.info(s"No token extracted")
          rejectedMessageActor ! event
      }

    case Reset =>
      for (listener: ActorRef <- listeners) {
        listener ! Counts(Map())
      }
      context.become(
        running(Map(), ItemCount(), 0, listeners)
      )

    case Register(listener: ActorRef) =>
      listener ! Counts(tokenCount.itemsByCount)
      context.watch(listener)
      context.become(
        running(tokensByMessenger, tokenCount, meCount, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      val remainingListeners: Set[ActorRef] = listeners - listener
      if (remainingListeners.nonEmpty) {
        context.become(
          running(tokensByMessenger, tokenCount, meCount, remainingListeners)
        )
      } else {
        chatMessageActor ! ChatMessageActor.Unregister(self)
        context.become(paused(tokensByMessenger, tokenCount, meCount))
      }
  }

  override def receive: Receive = paused(Map(), ItemCount(), 0)
}
