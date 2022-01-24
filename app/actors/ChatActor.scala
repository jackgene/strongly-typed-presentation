package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props}
import model.ChatMessage
import play.api.Configuration

object ChatActor {
  // Incoming messages
  case class ListenerRegistration(listener: ActorRef)
  case class New(chatMessage: ChatMessage)

  // Outgoing messages

  // Internal messages

  def props(cfg: Configuration): Props = Props(new ChatActor(cfg))
}
private class ChatActor(cfg: Configuration) extends Actor with ActorLogging {
  import ChatActor._

  private def running(listeners: Set[ActorRef]): Receive = {
    case ListenerRegistration(listener: ActorRef) =>
      context.watch(listener)
      context.become(
        running(listeners + listener)
      )

    case event @ New(chatMessage: ChatMessage) =>
      log.info(s"Received chat message: ${chatMessage}")
      for (listener: ActorRef <- listeners) {
        listener ! event
      }

    case other => unhandled(other)
  }

  override val receive: Receive = running(Set())
}
