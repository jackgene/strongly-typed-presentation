package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props}
import play.api.libs.json.Json

object WebSocketActor {
  def props(webSocketClient: ActorRef, counts: ActorRef): Props =
    Props(new WebSocketActor(webSocketClient, counts))
}
class WebSocketActor(webSocketClient: ActorRef, counts: ActorRef) extends Actor with ActorLogging {
  log.info("WebSocket connection opened")
  counts ! ByMessengerCounterActor.ListenerRegistration(self)

  override def receive: Receive = {
    case ByMessengerCounterActor.Counts(sendersByCount: Map[Int,Seq[String]]) =>
      webSocketClient ! Json.toJson(sendersByCount.toSeq) // JSON keys must be strings
  }

  override def postStop(): Unit = {
    log.info("WebSocket connection closed")
  }
}
