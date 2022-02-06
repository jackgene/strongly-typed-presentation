package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage

object ByMessengerCounterActor {
  // Incoming messages
  case class ListenerRegistration(listener: ActorRef)

  // Outgoing messages
  case class Counts(sendersByCount: Map[Int,Seq[String]])

  def props(chatActor: ActorRef): Props = Props(new ByMessengerCounterActor(chatActor))
}
private class ByMessengerCounterActor(chatActor: ActorRef) extends Actor with ActorLogging {
  import ByMessengerCounterActor._

  chatActor ! ChatActor.ListenerRegistration(self)

  private def running(messengerCount: ItemCount, listeners: Set[ActorRef]): Receive = {
    case ChatActor.New(msg: ChatMessage) =>
      val messenger: String = msg.sender
      val newMessengerCount: ItemCount = messengerCount.updated(messenger, 1)
      for (listener: ActorRef <- listeners) {
        listener ! Counts(newMessengerCount.itemsByCount)
      }
      context.become(
        running(newMessengerCount, listeners)
      )

    case ListenerRegistration(listener: ActorRef) =>
      listener ! Counts(messengerCount.itemsByCount)
      context.watch(listener)
      context.become(
        running(messengerCount, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      context.become(
        running(messengerCount, listeners - listener)
      )
  }

  override def receive: Receive = running(ItemCount(), Set())
}
