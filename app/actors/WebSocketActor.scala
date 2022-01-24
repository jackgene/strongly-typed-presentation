package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props}
import play.api.libs.json.Json

object WebSocketActor {
  def props(webSocketClient: ActorRef, counts: ActorRef): Props =
    Props(new WebSocketActor(webSocketClient, counts))
}
class WebSocketActor(webSocketClient: ActorRef, counts: ActorRef) extends Actor with ActorLogging {
  counts ! BySenderCounterActor.ListenerRegistration(self)

  override def receive: Receive = {
    case BySenderCounterActor.Counts(countsBySender: Map[String,Int]) =>
      webSocketClient ! Json.toJson(countsBySender)
  }
}
