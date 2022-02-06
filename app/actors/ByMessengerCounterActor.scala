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

  private def running(
      countsByMessenger: Map[String,Int], messengersByCount: Map[Int,Seq[String]],
      listeners: Set[ActorRef]): Receive = {
    case ChatActor.New(msg: ChatMessage) =>
      val messenger: String = msg.sender
      val oldCount: Int = countsByMessenger.getOrElse(messenger, 0)
      val newCount: Int = oldCount + 1
      val newCountsBySender: Map[String,Int] = {
        countsByMessenger.updated(messenger, newCount)
      }
      val newMessengersByCount: Map[Int,Seq[String]] =
        messengersByCount.
          updated(
            oldCount,
            messengersByCount.getOrElse(oldCount, IndexedSeq()).diff(Seq(messenger))
          ).
          updated(
            newCount,
            messengersByCount.getOrElse(newCount, IndexedSeq()).appended(messenger)
          ).
          filter {
            case (_, messengers: Seq[String]) => messengers.nonEmpty
          }
      for (listener: ActorRef <- listeners) {
        listener ! Counts(newMessengersByCount)
      }
      context.become(
        running(newCountsBySender, newMessengersByCount, listeners)
      )

    case ListenerRegistration(listener: ActorRef) =>
      listener ! Counts(messengersByCount)
      context.watch(listener)
      context.become(
        running(countsByMessenger, messengersByCount, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      context.become(
        running(countsByMessenger, messengersByCount, listeners - listener)
      )
  }

  override def receive: Receive = running(Map(), Map(), Set())
}
