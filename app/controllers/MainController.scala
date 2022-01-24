package controllers

import actors.ChatActor
import akka.actor.{ActorRef, ActorSystem}
import akka.stream.Materializer
import model.ChatMessage
import play.api._
import play.api.mvc._

import javax.inject._

/**
 * This controller creates an `Action` to handle HTTP requests to the
 * application's home page.
 */
@Singleton
class MainController @Inject()
    (cc: ControllerComponents, cfg: Configuration)
    (implicit system: ActorSystem, mat: Materializer)
    extends AbstractController(cc) {
  private val RoutePattern = "(.*) to (Everyone|Me)".r
  private val chatActor: ActorRef =
    system.actorOf(ChatActor.props(cfg), "chat")

  def chat(): Action[Unit] = Action(parse.empty) { implicit request: Request[Unit] =>
    val chatMessageOpt: Option[ChatMessage] =
      for {
        (from: String, to: String) <- request.getQueryString("route").collect {
          case RoutePattern(from: String, to: String) => from -> to
        }
        text: String <- request.getQueryString("text")
      } yield ChatMessage(from, to, text)

    chatMessageOpt match {
      case Some(chatMessage: ChatMessage) =>
        chatActor ! ChatActor.New(chatMessage)
        NoContent
      case None => BadRequest
    }
  }
}
