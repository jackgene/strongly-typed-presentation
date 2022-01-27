package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage

object BySenderCounterActor {
  // Incoming messages
  case class ListenerRegistration(listener: ActorRef)

  // Outgoing messages
  case class Counts(sendersByCount: Map[Int,Seq[String]])

  def props(chatActor: ActorRef): Props = Props(new BySenderCounterActor(chatActor))
}
private class BySenderCounterActor(chatActor: ActorRef) extends Actor with ActorLogging {
  import BySenderCounterActor._

  chatActor ! ChatActor.ListenerRegistration(self)

  private def running(
      countsBySender: Map[String,Int], sendersByCount: Map[Int,Seq[String]],
      listeners: Set[ActorRef]): Receive = {
    case ChatActor.New(msg: ChatMessage) =>
      val key: String = msg.sender
      val oldCount: Int = countsBySender.getOrElse(key, 0)
      val newCount: Int = oldCount + 1
      val newCountsBySender: Map[String,Int] = {
        countsBySender.updated(key, newCount)
      }
      val newSendersByCount: Map[Int,Seq[String]] =
        sendersByCount.
          updated(
            oldCount,
            sendersByCount.getOrElse(oldCount, IndexedSeq()).diff(Seq(key))
          ).
          updated(
            newCount,
            sendersByCount.getOrElse(newCount, IndexedSeq()).appended(key)
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
        running(countsBySender, sendersByCount, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      context.become(
        running(countsBySender, sendersByCount, listeners - listener)
      )
  }

  override def receive: Receive = running(Map(), Map(), Set())
}
