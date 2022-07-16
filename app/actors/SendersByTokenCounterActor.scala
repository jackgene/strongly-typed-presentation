package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage
import play.api.libs.json.Json


object SendersByTokenCounterActor {
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
      new SendersByTokenCounterActor(
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
    counts ! SendersByTokenCounterActor.Register(listener = self)

    override def receive: Receive = {
      case SendersByTokenCounterActor.Counts(tokensByCount: Map[Int,Seq[String]]) =>
        webSocketClient ! Json.toJson(tokensByCount.toSeq) // JSON keys must be strings
    }

    override def postStop(): Unit = {
      log.info("connection closed")
    }
  }
}
private class SendersByTokenCounterActor(
    extractToken: String => Option[String],
    chatMessageActor: ActorRef, rejectedMessageActor: ActorRef)
    extends Actor with ActorLogging {
  import SendersByTokenCounterActor._

  private def paused(
      tokensBySender: Map[String,String], tokenCount: ItemCount, meCount: Int):
      Receive = {
    case Reset =>
      context.become(paused(Map(), ItemCount(), 0))

    case Register(listener: ActorRef) =>
      chatMessageActor ! ChatMessageActor.Register(self)
      listener ! Counts(tokenCount.itemsByCount)
      context.watch(listener)
      context.become(
        running(tokensBySender, tokenCount, meCount, Set(listener))
      )
  }

  private def running(
      tokensBySender: Map[String,String], tokenCount: ItemCount, meCount: Int,
      listeners: Set[ActorRef]): Receive = {
    case event @ ChatMessageActor.New(msg: ChatMessage) =>
      val (sender: String, newMeCount:Int) =
        if (msg.sender != "Me") (msg.sender, meCount)
        else (s"Me@${meCount}", meCount + 1)
      val oldTokenOpt: Option[String] = tokensBySender.get(sender)
      val newTokenOpt: Option[String] = extractToken(msg.text)

      newTokenOpt match {
        case Some(newToken: String) =>
          log.info(s"Extracted token \"${newToken}\"")
          val newTokensBySender: Map[String,String] =
            tokensBySender.updated(sender, newToken)
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
            running(newTokensBySender, newTokenCount, newMeCount, listeners)
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
        running(tokensBySender, tokenCount, meCount, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      val remainingListeners: Set[ActorRef] = listeners - listener
      if (remainingListeners.nonEmpty) {
        context.become(
          running(tokensBySender, tokenCount, meCount, remainingListeners)
        )
      } else {
        chatMessageActor ! ChatMessageActor.Unregister(self)
        context.become(paused(tokensBySender, tokenCount, meCount))
      }
  }

  override def receive: Receive = paused(Map(), ItemCount(), 0)
}
