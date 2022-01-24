package actors

import actors.ChatActor
import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage

object BySenderCounterActor {
  // Incoming messages
  case class ListenerRegistration(listener: ActorRef)

  // Outgoing messages
  case class Counts(countsBySender: Map[String,Int])

  def props(chatActor: ActorRef): Props = Props(new BySenderCounterActor(chatActor))
}
private class BySenderCounterActor(chatActor: ActorRef) extends Actor with ActorLogging {
  import BySenderCounterActor._

  chatActor ! ChatActor.ListenerRegistration(self)

  private def running(countsBySender: Map[String,Int], listeners: Set[ActorRef]): Receive = {
    case ChatActor.New(msg: ChatMessage) =>
      val newCountsBySender: Map[String,Int] = countsBySender.updated(
        msg.sender, countsBySender.getOrElse(msg.sender, 0) + 1
      )
      for (listener: ActorRef <- listeners) {
        listener ! Counts(newCountsBySender)
      }
      context.become(
        running(newCountsBySender, listeners)
      )

    case ListenerRegistration(listener: ActorRef) =>
      context.watch(listener)
      context.become(
        running(countsBySender, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      context.become(
        running(countsBySender, listeners - listener)
      )
  }

  override def receive: Receive = running(Map(), Set())
}
