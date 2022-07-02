package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage
import play.api.libs.json._

object FromMeMessageActor {
  // Incoming messages
  case class Register(listener: ActorRef)
  case object Reset

  // Outgoing messages
  case class ChatMessages(text: Seq[String])

  // JSON
  private implicit val chatMessagesWrites: Writes[ChatMessages] =
    (chatMessages: ChatMessages) => Json.obj("chatText" -> chatMessages.text)

  def props(chatMessageActor: ActorRef, rejectedMessageActor: ActorRef): Props =
    Props(new FromMeMessageActor(chatMessageActor, rejectedMessageActor: ActorRef))

  // WebSocket actor
  object WebSocketActor {
    def props(webSocketClient: ActorRef, messages: ActorRef): Props =
      Props(new WebSocketActor(webSocketClient, messages))
  }
  class WebSocketActor(webSocketClient: ActorRef, messages: ActorRef)
      extends Actor with ActorLogging {
    log.info("connection opened")
    messages ! FromMeMessageActor.Register(listener = self)

    override def receive: Receive = {
      case chatMsgs: FromMeMessageActor.ChatMessages =>
        webSocketClient ! Json.toJson(chatMsgs)
    }

    override def postStop(): Unit = {
      log.info("connection closed")
    }
  }
}
private class FromMeMessageActor(
    chatMessageActor: ActorRef, rejectedMessageActor: ActorRef)
    extends Actor with ActorLogging {
  import FromMeMessageActor._

  private def paused(text: List[String]): Receive = {
    case Reset =>
      context.become(paused(Nil))

    case Register(listener: ActorRef) =>
      chatMessageActor ! ChatMessageActor.Register(self)
      listener ! ChatMessages(text)
      context.watch(listener)
      context.become(
        running(text, Set(listener))
      )
  }

  private def running(text: List[String], listeners: Set[ActorRef]): Receive = {
    case event @ ChatMessageActor.New(msg: ChatMessage) =>
      if (msg.sender != "Me") {
        rejectedMessageActor ! event
      } else {
        val newText: List[String] = msg.text :: text
        for (listener: ActorRef <- listeners) {
          listener ! ChatMessages(newText)
        }
        context.become(running(newText, listeners))
      }

    case Reset =>
      for (listener: ActorRef <- listeners) {
        listener ! ChatMessages(Nil)
      }
      context.become(running(Nil, listeners))

    case Register(listener: ActorRef) =>
      listener ! ChatMessages(text)
      context.watch(listener)
      context.become(running(text, listeners + listener))

    case Terminated(listener: ActorRef) if listeners.contains(listener) =>
      val remainingListeners: Set[ActorRef] = listeners - listener
      if (remainingListeners.nonEmpty) {
        context.become(running(text, remainingListeners))
      } else {
        chatMessageActor ! ChatMessageActor.Unregister(self)
        context.become(paused(text))
      }
  }

  override def receive: Receive = paused(Nil)
}
