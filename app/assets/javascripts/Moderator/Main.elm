module Moderator exposing (..)

import Html.Styled as Html exposing (Html)
import Json.Decode as Decode
import Navigation exposing (Location)
import WebSocket

-- Types
type Msg
  = Event String
  | NoOp


type alias ChatMessage =
  { sender : String
  , recipient : String
  , text : String
  }


type alias Model =
  { eventsWsUrl : String
  , chatMessages : List ChatMessage
  , errors : List String
  }


-- Init
webSocketBaseUrl : Location -> String
webSocketBaseUrl location =
  "ws" ++ (String.dropLeft 4 location.protocol) ++ "//" ++ location.host


init : Location -> (Model, Cmd Msg)
init location =
  ( { eventsWsUrl = webSocketBaseUrl location ++ "/moderator/event"
    , chatMessages = []
    , errors = []
    }
  , Cmd.none
  )


-- Update
chatMessageDecoder : Decode.Decoder ChatMessage
chatMessageDecoder =
  Decode.map3 ChatMessage
  ( Decode.field "s" Decode.string )
  ( Decode.field "r" Decode.string )
  ( Decode.field "t" Decode.string )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  ( case msg of
    Event json ->
      case Decode.decodeString chatMessageDecoder json of
        Ok chatMessage ->
          { model | chatMessages = chatMessage :: model.chatMessages }

        Err error ->
          { model | errors = error :: model.errors }

    NoOp -> model
  , Cmd.none
  )


-- View
view : Model -> Html Msg
view model = Html.text ("Number of rejected messages: " ++ (toString (List.length model.chatMessages)))


-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model = WebSocket.listen model.eventsWsUrl Event


main : Program Never Model Msg
main =
  Navigation.program
  ( always NoOp )
  { init = init
  , update = update
  , view = Html.toUnstyled << view
  , subscriptions = subscriptions
  }
