module Deck exposing (..)

import Dict
import Html exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Navigation exposing (Location)
import WebSocket


type alias Model =
  { eventsWsUrl : Maybe String
  , sendersAndCounts : List (String, Int)
  }


type Msg
  = Event String
  | NoOp


-- Constants
maxDisplayCount : Int
maxDisplayCount = 10


-- Init
webSocketBaseUrl : Location -> Maybe String
webSocketBaseUrl location =
  if location.protocol /= "http:" && location.protocol /= "https:" then Nothing
  else Just ("ws" ++ (String.dropLeft 4 location.protocol) ++ "//" ++ location.host)


init : Location -> (Model, Cmd Msg)
init location =
  ( Model
    ( Maybe.map
      ( \baseUrl -> baseUrl ++ "/events" )
      ( webSocketBaseUrl location )
    )
    []
  , Cmd.none
  )


-- Update
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Event body ->
      let
        sendersByCountRes : Result String (List (Int, (List String)))
        sendersByCountRes =
          Decode.decodeString
          ( Decode.list
            ( Decode.map2 (\l r -> (l, r))
              (Decode.index 0 Decode.int)
              (Decode.index 1 (Decode.list Decode.string))
            )
          )
          body

        sendersAndCountsRes : Result String (List (String, Int))
        sendersAndCountsRes =
          Result.map
          ( \sendersByCount ->
            ( Dict.foldr
              ( \count senders accum ->
                if List.length accum >= maxDisplayCount then accum
                else
                  List.take maxDisplayCount
                  ( accum ++ (
                      List.map
                      ( \sender -> (sender, count) )
                      senders
                    )
                  )
              )
              []
              ( Dict.fromList sendersByCount ) -- Sorts by count
            )
          )
          sendersByCountRes
      in
      case sendersAndCountsRes of
        Ok sendersAndCounts ->
          ( { model | sendersAndCounts = sendersAndCounts}
          , Cmd.none
          )
        Err jsonErr ->
          let
            _ = Debug.log ("Error parsing JSON: " ++ jsonErr ++ " for input") body
          in (model, Cmd.none)

    NoOp -> (model, Cmd.none)


-- View
view : Model -> Html Msg
view model =
  div []
  [ h2 [] [ text ("Top " ++ toString(maxDisplayCount) ++ " Chattiest") ]
  , ( ul []
      ( List.map
        ( \(sender, count) ->
          li [] [ text (sender ++ ": " ++ (toString count)) ]
        )
        model.sendersAndCounts
      )
    )
  ]


-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  case model.eventsWsUrl of
    Just url -> WebSocket.listen url Event
    Nothing -> Sub.none


main : Program Never Model Msg
main =
  Navigation.program
  ( always NoOp )
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }
