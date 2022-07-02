package controllers

import actors._
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
  private val languagePollActor: ActorRef =
    system.actorOf(
      ByTokenBySenderCounterActor.props(
        Token.languageFromFirstWord, chatMsgActor, rejectedMsgActor
      ),
      "languagePoll"
    )
  private val questionActor: ActorRef =
    system.actorOf(
      FromMeMessageActor.props(chatMsgActor, rejectedMsgActor),
      "question"
    )
  private val transcriptionActor: ActorRef =
    system.actorOf(TranscriptionActor.props, "transcriptions")

  def languagePollEvent(): WebSocket = WebSocket.accept[JsValue,JsValue] { _: RequestHeader =>
    ActorFlow.actorRef { webSocketClient: ActorRef =>
      ByTokenBySenderCounterActor.WebSocketActor.props(webSocketClient, languagePollActor)
    }
  }

  def questionEvent(): WebSocket = WebSocket.accept[JsValue,JsValue] { _: RequestHeader =>
    ActorFlow.actorRef { webSocketClient: ActorRef =>
      FromMeMessageActor.WebSocketActor.props(webSocketClient, questionActor)
    }
  }

  def transcriptionEvent(): WebSocket = WebSocket.accept[JsValue,JsValue] { _: RequestHeader =>
    ActorFlow.actorRef { webSocketClient: ActorRef =>
      TranscriptionActor.WebSocketActor.props(webSocketClient, transcriptionActor)
    }
  }

  def moderationEvent(): WebSocket = WebSocket.accept[JsValue,JsValue] { _: RequestHeader =>
    ActorFlow.actorRef { webSocketClient: ActorRef =>
      ModerationWebSocketActor.props(webSocketClient, rejectedMsgActor)
    }
  }

  def chat(route: String, text: String): Action[Unit] = Action(parse.empty) { _: Request[Unit] =>
    route match {
      case RoutePattern(sender, recipient) =>
        chatMsgActor ! ChatMessageActor.New(ChatMessage(sender, recipient, text))
        NoContent
      case _ => BadRequest
    }
  }

  def reset(): Action[Unit] = Action(parse.empty) { _: Request[Unit] =>
    languagePollActor ! ByTokenBySenderCounterActor.Reset
    questionActor ! FromMeMessageActor.Reset
    NoContent
  }

  def transcription(text: String): Action[Unit] = Action(parse.empty) { _: Request[Unit] =>
    transcriptionActor ! TranscriptionActor.NewTranscriptionText(text)
    NoContent
  }
}
