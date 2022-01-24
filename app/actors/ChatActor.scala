package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage

object ChatActor {
  // Incoming messages
  case class ListenerRegistration(listener: ActorRef)

  // Incoming and Outgoing messages
  case class New(chatMessage: ChatMessage)

  val props: Props = Props(new ChatActor)
}
private class ChatActor extends Actor with ActorLogging {
  import ChatActor._

  private def running(listeners: Set[ActorRef]): Receive = {
    case event @ New(chatMessage: ChatMessage) =>
      log.info(s"Received chat message - ${chatMessage}")
      for (listener: ActorRef <- listeners) {
        listener ! event
      }

    case ListenerRegistration(listener: ActorRef) =>
      context.watch(listener)
      context.become(
        running(listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      context.become(
        running(listeners - listener)
      )
  }

  override val receive: Receive = running(Set())
}
