module Deck exposing (main)

import Array exposing (Array)
import Deck.Common exposing (Model, Msg(..), Slide(Slide))
import Deck.Slide exposing (slides, slideView)
import Dict exposing (Dict)
import Html.Styled exposing (Html, text)
import Json.Decode as Decode exposing (Decoder)
import Keyboard
import Navigation exposing (Location)
import WebSocket


-- Init
webSocketBaseUrl : Location -> Maybe String
webSocketBaseUrl location =
  if location.protocol /= "http:" || location.hostname /= "localhost" then Nothing
  else Just ("ws" ++ (String.dropLeft 4 location.protocol) ++ "//" ++ location.host)


init : Location -> (Model, Cmd Msg)
init location =
  ( { eventsWsUrl =
      ( Maybe.map
        ( \baseUrl -> baseUrl ++ "/event" )
        ( webSocketBaseUrl location )
      )
    , slides = slides
    , slideIndex =
      ( min ( ( Array.length slides ) - 1 )
        ( max 0
          ( Maybe.withDefault 0
            ( Result.toMaybe
              ( String.toInt ( String.dropLeft 7 location.hash ) )
            )
          )
        )
      )
    , languagesAndCounts = []
    , typeScriptVsJavaScript =
      { typeScriptFraction = 0.0
      , lastVoteTypeScript = False
      }
    }
  , Cmd.none
  )


-- Update
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Next ->
      let
        slideIndex : Int
        slideIndex = min ((Array.length model.slides) - 1) (model.slideIndex + 1)
      in
      ( { model | slideIndex = slideIndex }
      , Navigation.newUrl ("#slide-" ++ toString slideIndex)
      )

    Last ->
      let
        slideIndex : Int
        slideIndex = max 0 (model.slideIndex - 1)
      in
      ( { model | slideIndex = slideIndex }
      , Navigation.newUrl
        ( if slideIndex == 0 then "."
          else "#slide-" ++ toString slideIndex
        )
      )

    Event body ->
      let
        langsByCountRes : Result String (List (Int, (List String)))
        langsByCountRes =
          Decode.decodeString
          ( Decode.list
            ( Decode.map2 (\l r -> (l, r))
              (Decode.index 0 Decode.int)
              (Decode.index 1 (Decode.list Decode.string))
            )
          )
          body

        langsAndCountsRes : Result String (List (String, Int))
        langsAndCountsRes =
          Result.map
          ( \langsByCount ->
            ( Dict.foldr
              ( \count langs accum ->
                accum ++ (
                  List.map
                  ( \lang -> (lang, count) )
                  langs
                )
              )
              []
              ( Dict.fromList langsByCount ) -- Sorts by count
            )
          )
          langsByCountRes
      in
      case langsAndCountsRes of
        Ok langsAndCounts ->
          let
            (jsCount, tsCount) =
              List.foldl
              ( \(lang, count) (jsCountAcc, tsCountAcc) ->
                case lang of
                  "JavaScript" -> (toFloat count, tsCountAcc)
                  "TypeScript" -> (jsCountAcc, toFloat count)
                  _ -> (jsCountAcc, tsCountAcc)
              )
              (0.0, 0.0)
              langsAndCounts

            tsFrac : Float
            tsFrac = tsCount / (tsCount + jsCount)
          in
          ( { model
            | languagesAndCounts = langsAndCounts
            , typeScriptVsJavaScript =
              { typeScriptFraction = tsFrac
              , lastVoteTypeScript = tsFrac > model.typeScriptVsJavaScript.typeScriptFraction
              }
            }
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
  case Array.get model.slideIndex model.slides of
    Just (Slide slide) -> slideView model slide
    Nothing -> text "No Slides Defined"


-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ let
      connectWebSocket : Bool
      connectWebSocket =
        Maybe.withDefault False
        ( Maybe.map
          ( \(Slide slide) -> slide.liveUpdate )
          ( Array.get model.slideIndex model.slides )
        )
    in
    case (model.eventsWsUrl, connectWebSocket) of
      (Just url, True) ->
        WebSocket.listen url Event
      _ -> Sub.none
  , Keyboard.ups
    ( \keyCode ->
      case keyCode of
        13 -> Next -- Enter
        32 -> Next -- Space
        37 -> Last -- Left
        38 -> Last -- Up
        39 -> Next -- Right
        40 -> Next -- Down
        _ -> NoOp
    )
  ]


main : Program Never Model Msg
main =
  Navigation.program
  ( always NoOp )
  { init = init
  , update = update
  , view = Html.Styled.toUnstyled << view
  , subscriptions = subscriptions
  }
