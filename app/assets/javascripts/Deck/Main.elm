module Deck exposing (..)

import Css exposing (..)
import Css.Transitions exposing (easeInOut, transition)
import Dict
import Html.Styled exposing (Html, div, h2, text)
import Html.Styled.Attributes exposing (id, css, title)
import Html.Styled.Keyed as Keyed
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
idEscape : String -> String
idEscape input =
  String.toLower
  ( String.join "-"
    ( String.words input )
  )


horizontalBarView : Int -> Int -> Html Msg
horizontalBarView value maxValue =
  div
  [ css
    [ width (pct (100 * (toFloat value / toFloat maxValue)))
    , height (em 1)
    , border3 (px 1) solid (rgb 160 160 160)
    , backgroundColor (rgb 200 200 200)
    , textAlign center
    , transition [ Css.Transitions.width3 500 0 easeInOut ]
    ]
  , title (toString value)
  ]
  [ text (toString value) ]


view : Model -> Html Msg
view model =
  div [ css [ (padding (em 1)) ] ]
  [ h2 [] [ text ("Top " ++ (toString maxDisplayCount) ++ " Chattiest") ]
  , ( Keyed.node "div" [ css [ position relative ] ]
      ( let
          maxCount : Int
          maxCount =
            Maybe.withDefault 0
            ( Maybe.map Tuple.second (List.head model.sendersAndCounts) )
        in
        List.sortBy Tuple.first
        ( List.indexedMap
          ( \idx (sender, count) ->
            ( sender
            , div
              [ id (idEscape sender)
              , css
                [ position absolute
                , top (px (toFloat idx * 24))
                , width (px 640)
                , transition [ Css.Transitions.top3 500 0 easeInOut ]
                ]
              ]
              [ div
                [ css
                  [ position absolute
                  , top zero
                  , width (px 200)
                  ]
                ]
                [ text sender ]
              , div
                [ css
                  [ position absolute
                  , top zero
                  , left (px 200)
                  , right zero
                  ]
                ]
                [ horizontalBarView count maxCount ]
              ]
            )
          )
          model.sendersAndCounts
        )
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
  , view = Html.Styled.toUnstyled << view
  , subscriptions = subscriptions
  }
