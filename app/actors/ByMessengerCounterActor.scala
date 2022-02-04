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
      countsByMessenger: Map[String,Int], sendersByCount: Map[Int,Seq[String]],
      listeners: Set[ActorRef]): Receive = {
    case ChatActor.New(msg: ChatMessage) =>
      val messenger: String = msg.sender
      val oldCount: Int = countsByMessenger.getOrElse(messenger, 0)
      val newCount: Int = oldCount + 1
      val newCountsBySender: Map[String,Int] = {
        countsByMessenger.updated(messenger, newCount)
      }
      val newSendersByCount: Map[Int,Seq[String]] =
        sendersByCount.
          updated(
            oldCount,
            sendersByCount.getOrElse(oldCount, IndexedSeq()).diff(Seq(messenger))
          ).
          updated(
            newCount,
            sendersByCount.getOrElse(newCount, IndexedSeq()).appended(messenger)
          ).
          filter {
            case (_, senders: Seq[String]) => senders.nonEmpty
          }
      for (listener: ActorRef <- listeners) {
        listener ! Counts(newSendersByCount)
      }
      context.become(
        running(newCountsBySender, newSendersByCount, listeners)
      )

    case ListenerRegistration(listener: ActorRef) =>
      listener ! Counts(sendersByCount)
      context.watch(listener)
      context.become(
        running(countsByMessenger, sendersByCount, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      context.become(
        running(countsByMessenger, sendersByCount, listeners - listener)
      )
  }

  override def receive: Receive = running(Map(), Map(), Set())
}
