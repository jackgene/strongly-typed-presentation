package model

object Token {
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
    "rust" -> "ML",
    // Perl
    "perl" -> "Perl",
    // PHP
    "php" -> "PHP",
    // Ruby
    "ruby" -> "Ruby",
    "rb" -> "Ruby",
    // Scala
    "scala" -> "Scala",
  )

  def languageFromFirstWord(text: String): Option[String] = {
    val normalizedFirstWordOpt: Option[String] = text.trim.
      split("""[\s/]""").headOption.
      map { _.toLowerCase }
    normalizedFirstWordOpt.flatMap { TokensByString.get }
  }

  private val TokensByLetter: Map[Char,String] = Map(
    'e' -> "Python",
    't' -> "Swift",
    'a' -> "Kotlin",
    'o' -> "JavaScript",
    'i' -> "TypeScript",
    'n' -> "Go",
    's' -> "C",
    'h' -> "C#",
    'r' -> "Java",
    'd' -> "Lisp",
    'l' -> "ML",
    'c' -> "Perl",
    'u' -> "PHP",
    'm' -> "Ruby",
    'w' -> "Scala",
    'f' -> "Python",
    'g' -> "Swift",
    'y' -> "Kotlin",
    'p' -> "JavaScript",
    'b' -> "TypeScript",
    'v' -> "Go",
    'k' -> "C",
    'j' -> "C#",
    'x' -> "Java",
    'q' -> "Lisp",
    'z' -> "ML",
  )

  def languageFromFirstLetter(text: String): Option[String] = {
    val normalizedFirstLetterOpt: Option[Char] = text.trim.toLowerCase.headOption
    normalizedFirstLetterOpt.
      flatMap { TokensByLetter.get }.
      orElse(Some("Swift"))
  }
}
