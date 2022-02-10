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
        Token.languageFromFirstWord, chatMsgActor, rejectedMsgActor
      ),
      "byLanguageBySenderCounter"
    )

  def chat(route: String, text: String): Action[Unit] = Action(parse.empty) {
    implicit request: Request[Unit] =>

    route match {
      case RoutePattern(sender, recipient) =>
        chatMsgActor ! ChatMessageActor.New(ChatMessage(sender, recipient, text))
        NoContent
      case _ => BadRequest
    }
  }

  def events(): WebSocket = WebSocket.accept[JsValue,JsValue] { _: RequestHeader =>
    ActorFlow.actorRef { webSocketClient: ActorRef =>
      WebSocketActor.props(webSocketClient, bySenderCounterActor)
    }
  }

  def reset(): Action[Unit] = Action(parse.empty) { implicit request: Request[Unit] =>
    bySenderCounterActor ! ByTokenBySenderCounterActor.Reset
    NoContent
  }
}
