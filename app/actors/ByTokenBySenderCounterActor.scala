package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage


object ByTokenBySenderCounterActor {
  // Incoming messages
  case class ListenerRegistration(listener: ActorRef)

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
}
private class ByTokenBySenderCounterActor(
    extractToken: String => Option[String],
    chatMessageActor: ActorRef, rejectedMessageActor: ActorRef)
    extends Actor with ActorLogging {
  import ByTokenBySenderCounterActor._

  chatMessageActor ! ChatMessageActor.ListenerRegistration(self)

  private def running(
      tokensByMessenger: Map[String,String], tokenCount: ItemCount,
      meCount: Int, listeners: Set[ActorRef]): Receive = {
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

    case ListenerRegistration(listener: ActorRef) =>
      listener ! Counts(tokenCount.itemsByCount)
      context.watch(listener)
      context.become(
        running(tokensByMessenger, tokenCount, meCount, listeners + listener)
      )

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      context.become(
        running(tokensByMessenger, tokenCount, meCount, listeners - listener)
      )
  }

  override def receive: Receive = running(Map(), ItemCount(), 0, Set())
}
