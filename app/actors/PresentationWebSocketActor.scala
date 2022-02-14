package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props}
import play.api.libs.json.Json

object PresentationWebSocketActor {
  def props(webSocketClient: ActorRef, counts: ActorRef): Props =
    Props(new PresentationWebSocketActor(webSocketClient, counts))
}
class PresentationWebSocketActor(webSocketClient: ActorRef, counts: ActorRef)
    extends Actor with ActorLogging {
  log.info("Presentation WebSocket connection opened")
  counts ! ByTokenBySenderCounterActor.ListenerRegistration(self)

  override def receive: Receive = {
    case ByTokenBySenderCounterActor.Counts(sendersByCount: Map[Int,Seq[String]]) =>
      webSocketClient ! Json.toJson(sendersByCount.toSeq) // JSON keys must be strings
  }

  override def postStop(): Unit = {
    log.info("Presentation WebSocket connection closed")
  }
}
