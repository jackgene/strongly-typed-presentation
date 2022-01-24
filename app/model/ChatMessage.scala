package model

case class ChatMessage(
  sender: String,
  recipient: String,
  text: String
) {
  override def toString: String = s"${sender} to ${recipient}: ${text}"
}