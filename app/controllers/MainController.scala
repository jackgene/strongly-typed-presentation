package controllers

import actors.{ByTokenBySenderCounterActor, ChatMessageActor, WebSocketActor}
import akka.actor.{ActorRef, ActorSystem}
import akka.stream.Materializer
import model.{ChatMessage, Token}
import play.api.libs.json.JsValue
import play.api.libs.streams.ActorFlow
import play.api.mvc._
import javax.inject._

/**
 * This controller creates an `Action` to handle HTTP requests to the
 * application's home page.
 */
@Singleton
class MainController @Inject() (cc: ControllerComponents)
    (implicit system: ActorSystem, mat: Materializer)
    extends AbstractController(cc) {
  private val RoutePattern = "(.*) to (Everyone|Me)".r
  private val chatMsgActor: ActorRef =
    system.actorOf(ChatMessageActor.props, "chat")
  private val rejectedMsgActor: ActorRef =
    system.actorOf(ChatMessageActor.props, "rejected")
  private val bySenderCounterActor: ActorRef =
    system.actorOf(
      ByTokenBySenderCounterActor.props(
        Token.languageFromFirstLetter, chatMsgActor, rejectedMsgActor
      ),
      "bySenderCounter"
    )

  def chat(): Action[Unit] = Action(parse.empty) { implicit request: Request[Unit] =>
    val chatMessageOpt: Option[ChatMessage] =
      for {
        (sender: String, recipient: String) <- request.getQueryString("route").collect {
          case RoutePattern(sender, recipient) => sender -> recipient
        }
        text: String <- request.getQueryString("text")
      } yield ChatMessage(sender, recipient, text)

    chatMessageOpt match {
      case Some(chatMessage: ChatMessage) =>
        chatMsgActor ! ChatMessageActor.New(chatMessage)
        NoContent
      case None => BadRequest
    }
  }

  def events(): WebSocket = WebSocket.accept[JsValue,JsValue] { _: RequestHeader =>
    ActorFlow.actorRef { webSocketClient: ActorRef =>
      WebSocketActor.props(webSocketClient, bySenderCounterActor)
    }
  }
}
