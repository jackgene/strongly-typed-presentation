package actors

import akka.actor.{Actor, ActorLogging, ActorRef, Props, Terminated}
import model.ChatMessage


object ByTokenBySenderCounterActor {
  // Incoming messages
  case class ListenerRegistration(listener: ActorRef)

  // Outgoing messages
  case class Counts(tokensByCount: Map[Int,Seq[String]])

  def props(chatMessageActor: ActorRef, rejectedMessageActor: ActorRef): Props =
    Props(new ByTokenBySenderCounterActor(chatMessageActor, rejectedMessageActor))

  private val TokensByString: Map[String,String] = Map(
    // GoodRx Languages
    // Go
    "go" -> "Go",
    "golang" -> "Go",
    // Kotlin
    "kotlin" -> "Kotlin",
    "kt" -> "Kotlin",
    // Python
    "py" -> "Python",
    "python" -> "Python",
    // Swift
    "swift" -> "Swift",
    // TypeScript
    "ts" -> "TypeScript",
    "typescript" -> "TypeScript",

    // Others
    // C/C++
    "c" -> "C",
    "c++" -> "C",
    // C#
    "c#" -> "C#",
    "csharp" -> "C#",
    // Java
    "java" -> "Java",
    // Javascript
    "js" -> "JavaScript",
    "javascript" -> "JavaScript",
    // Lisp
    "lisp" -> "Lisp",
    "clojure" -> "Lisp",
    "racket" -> "Lisp",
    "scheme" -> "Lisp",
    // ML
    "ml" -> "ML",
    "haskell" -> "ML",
    "caml" -> "ML",
    "elm" -> "ML",
    "f#" -> "ML",
    "ocaml" -> "ML",
    // Perl
    "perl" -> "Perl",
    // PHP
    "php" -> "PHP",
    // Ruby
    "ruby" -> "Ruby",
    "rb" -> "Ruby",
    // Rust
    "rust" -> "Rust",
    // Scala
    "scala" -> "Scala",
  )
}
private class ByTokenBySenderCounterActor(
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
      val normalizedFirstWordOpt: Option[String] = msg.text.trim.
        split("""[\s/]""").headOption.
        map { _.toLowerCase }
      val oldTokenOpt: Option[String] = tokensByMessenger.get(messenger)
      val newTokenOpt: Option[String] = normalizedFirstWordOpt.flatMap { TokensByString.get }

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
