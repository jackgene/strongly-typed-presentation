package model

case class ChatMessage(
  sender: String,
  recipient: String,
  text: String
)