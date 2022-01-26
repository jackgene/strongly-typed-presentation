name := "strongly-typed-presentation"
organization := "com.goodrx"

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.13.8"

libraryDependencies += guice
libraryDependencies += ws
libraryDependencies += "org.scalatestplus.play" %% "scalatestplus-play" % "5.0.0" % Test

//val elmMakeAdmin = taskKey[Seq[File]]("elm-make-admin")
//
//elmMakeAdmin := {
//  import scala.sys.process._
//  import com.typesafe.sbt.web.LineBasedProblem
//  import play.sbt.PlayExceptions.CompilationException
//
//  val outputPath: String = "public/html/admin.html"
//  val debugFlag: String =
//    if (sys.props.getOrElse("elm.debug", "false").toLowerCase != "true") ""
//    else "--debug"
//  var outErrLines: List[String] = Nil
//  var srcFilePath: Option[String] = None
//  var lineNum: Option[String] = None
//  var offset: Option[String] = None
//  Seq(
//    "bash", "-c",
//    "elm-make " +
//    (file("app/assets/javascripts/Admin") ** "*.elm").get.mkString(" ") +
//    s" --output ${outputPath} " +
//    s"--yes ${debugFlag} --warn"
//  ).!(
//    new ProcessLogger {
//      override def out(s: => String): Unit = {
//        streams.value.log.info(s)
//        outErrLines = s :: outErrLines
//      }
//
//      override def err(s: => String): Unit = {
//        streams.value.log.warn(s)
//        val SrcFilePathExtractor = """-- [A-Z ]+ -+ (app/assets/javascripts/.+\.elm)""".r
//        val LineNumExtractor = """([0-9]+)\|.*""".r
//        val PosExtractor = """ *\^+ *""".r
//        s match {
//          case SrcFilePathExtractor(path: String) =>
//            srcFilePath = srcFilePath orElse Some(path)
//          case LineNumExtractor(num: String) =>
//            lineNum = lineNum orElse Some(num)
//          case PosExtractor() =>
//            offset = offset orElse Some(s)
//          case _ =>
//        }
//        outErrLines = s :: outErrLines
//      }
//
//      override def buffer[T](f: => T): T = f
//    }
//  ) match {
//    case 0 =>
//      streams.value.log.success("elm-make (for Admin) completed.")
//      Seq(file(outputPath))
//
//    case 127 =>
//      streams.value.log.warn("elm-make not found in PATH. Skipping Elm build.")
//      Nil
//
//    case _ =>
//      throw CompilationException(
//        new LineBasedProblem(
//          message = outErrLines.reverse.mkString("\n"),
//          severity = null,
//          lineNumber = lineNum.map(_.toInt).getOrElse(0),
//          characterOffset = offset.map(_.indexOf('^') - 2 - lineNum.map(_.length).getOrElse(0)).getOrElse(0),
//          lineContent = "",
//          source = file(srcFilePath.getOrElse(""))
//        )
//      )
//  }
//}
//
//sourceGenerators in Assets += elmMakeAdmin.taskValue
//
val elmMakeDeck = taskKey[Seq[File]]("elm-make-deck")

elmMakeDeck := {
  import scala.sys.process._
  import com.typesafe.sbt.web.LineBasedProblem
  import play.sbt.PlayExceptions.CompilationException

  val outputPath: String = "public/html/deck.html"
  val debugFlag: String = "--debug"
  var outErrLines: List[String] = Nil
  var srcFilePath: Option[String] = None
  var lineNum: Option[String] = None
  var offset: Option[String] = None
  Seq(
    "bash", "-c",
    "elm-make " +
    (file("app/assets/javascripts/Deck") ** "*.elm").get.mkString(" ") +
    s" --output ${outputPath} " +
    s"--yes ${debugFlag} --warn"
  ).!(
    new ProcessLogger {
      override def out(s: => String): Unit = {
        streams.value.log.info(s)
        outErrLines = s :: outErrLines
      }

      override def err(s: => String): Unit = {
        streams.value.log.warn(s)
        val SrcFilePathExtractor = """-- [A-Z ]+ -+ (app/assets/javascripts/.+\.elm)""".r
        val LineNumExtractor = """([0-9]+)\|.*""".r
        val PosExtractor = """ *\^+ *""".r
        s match {
          case SrcFilePathExtractor(path: String) =>
            srcFilePath = srcFilePath orElse Some(path)
          case LineNumExtractor(num: String) =>
            lineNum = lineNum orElse Some(num)
          case PosExtractor() =>
            offset = offset orElse Some(s)
          case _ =>
        }
        outErrLines = s :: outErrLines
      }

      override def buffer[T](f: => T): T = f
    }
  ) match {
    case 0 =>
      streams.value.log.success("elm-make (for Deck) completed.")
      Seq(file(outputPath))

    case 127 =>
      streams.value.log.warn("elm-make not found in PATH. Skipping Elm build.")
      Nil

    case _ =>
      throw CompilationException(
        new LineBasedProblem(
          message = outErrLines.reverse.mkString("\n"),
          severity = null,
          lineNumber = lineNum.map(_.toInt).getOrElse(0),
          characterOffset = offset.map(_.indexOf('^') - 2 - lineNum.map(_.length).getOrElse(0)).getOrElse(0),
          lineContent = "",
          source = file(srcFilePath.getOrElse(""))
        )
      )
  }
}

sourceGenerators in Assets += elmMakeDeck.taskValue
