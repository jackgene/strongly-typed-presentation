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
    counts ! SendersByTokenCounterActor.Register(listener = self)

    override def receive: Receive = {
      case SendersByTokenCounterActor.Counts(tokensByCount: Map[Int,Seq[String]]) =>
        webSocketClient ! Json.toJson(tokensByCount.toSeq) // JSON keys must be strings
    }
  }
}
private class SendersByTokenCounterActor(
    extractToken: String => Option[String],
    chatMessageActor: ActorRef, rejectedMessageActor: ActorRef)
    extends Actor with ActorLogging {
  import SendersByTokenCounterActor._

  private def paused(
      tokensBySender: Map[String,String], tokenCount: Frequencies):
      Receive = {
    case Reset =>
      context.become(paused(Map(), Frequencies()))

    case Register(listener: ActorRef) =>
      chatMessageActor ! ChatMessageActor.Register(self)
      listener ! Counts(tokenCount.itemsByCount)
      context.watch(listener)
      context.become(
        running(tokensBySender, tokenCount, Set(listener))
      )
  }

  private def running(
      tokensBySender: Map[String,String], tokenFrequencies: Frequencies,
      listeners: Set[ActorRef]): Receive = {
    case event @ ChatMessageActor.New(msg: ChatMessage) =>
      val senderOpt: Option[String] = Option(msg.sender).filter { _ != "Me" }
      val oldTokenOpt: Option[String] = senderOpt.flatMap(tokensBySender.get)
      val newTokenOpt: Option[String] = extractToken(msg.text)

      newTokenOpt match {
        case Some(newToken: String) =>
          log.info(s"Extracted token \"${newToken}\"")
          val newTokenFrequencies: Frequencies = oldTokenOpt.
            // Only remove old token if there's a valid new token replacing it
            foldLeft(tokenFrequencies) { (freqs: Frequencies, oldToken: String) =>
              freqs.updated(oldToken, -1)
            }.
            updated(newToken, 1)

          for (listener: ActorRef <- listeners) {
            listener ! Counts(newTokenFrequencies.itemsByCount)
          }
          context.become(
            running(
              senderOpt match {
                case Some(sender: String) => tokensBySender.updated(sender, newToken)
                case None => tokensBySender
              },
              newTokenFrequencies,
              listeners
            )
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
        running(Map(), Frequencies(), listeners)
      )

    case Register(listener: ActorRef) =>
      listener ! Counts(tokenFrequencies.itemsByCount)
      context.watch(listener)
      context.become(
        running(tokensBySender, tokenFrequencies, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      val remainingListeners: Set[ActorRef] = listeners - listener
      if (remainingListeners.nonEmpty) {
        context.become(
          running(tokensBySender, tokenFrequencies, remainingListeners)
        )
      } else {
        chatMessageActor ! ChatMessageActor.Unregister(self)
        context.become(paused(tokensBySender, tokenFrequencies))
      }
  }

  override def receive: Receive = paused(Map(), Frequencies())
}
