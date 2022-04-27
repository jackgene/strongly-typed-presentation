module Deck exposing (main)

import AnimationFrame
import Array exposing (Array)
import Deck.Common exposing (Model, Msg(..), Navigation, Slide(Slide), SlideModel)
import Deck.Slide exposing (activeNavigationOf, slideFromLocationHash, slideView)
import Dict exposing (Dict)
import Html.Styled exposing (Html)
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
  ( let
      incompleteModel : Model
      incompleteModel =
        { eventsWsUrl =
          ( Maybe.map
            ( \baseUrl -> baseUrl ++ "/event" )
            ( webSocketBaseUrl location )
          )
        , activeNavigation = Array.empty
        , currentSlide = slideFromLocationHash location.hash
        , languagesAndCounts = []
        , typeScriptVsJavaScript =
          { typeScriptFraction = 0.0
          , lastVoteTypeScript = False
          }
        }

      activeNavigation : Array Navigation
      activeNavigation = activeNavigationOf incompleteModel
    in
    { incompleteModel
    | activeNavigation = activeNavigation
    }
  , Cmd.none
  )


-- Update
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Next ->
      ( model
      , let
          curSlideIdx : Int
          curSlideIdx =
            case model.currentSlide of
              Slide slideModel -> slideModel.index

          newSlideIdx : Int
          newSlideIdx =
            Maybe.withDefault curSlideIdx
            ( Maybe.map
              .nextSlideIndex
              ( Array.get curSlideIdx model.activeNavigation )
            )
        in
          if newSlideIdx == curSlideIdx then Cmd.none
          else Navigation.newUrl ("#slide-" ++ toString newSlideIdx)
      )

    Last ->
      ( model
      , let
          curSlideIdx : Int
          curSlideIdx =
            case model.currentSlide of
              Slide slideModel -> slideModel.index

          newSlideIdx : Int
          newSlideIdx =
            Maybe.withDefault curSlideIdx
            ( Maybe.map
              .lastSlideIndex
              ( Array.get curSlideIdx model.activeNavigation )
            )
        in
          if newSlideIdx == curSlideIdx then Cmd.none
          else
            Navigation.newUrl
            ( if newSlideIdx == 0 then "."
              else "#slide-" ++ toString newSlideIdx
            )
      )

    NewLocation location ->
      ( let
          newSlide : Slide
          newSlide = slideFromLocationHash location.hash
        in
        { model | currentSlide = newSlide }
      , Cmd.none
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

            statsUpdatedModel : Model
            statsUpdatedModel =
              { model
              | languagesAndCounts = langsAndCounts
              , typeScriptVsJavaScript =
                { typeScriptFraction = tsFrac
                , lastVoteTypeScript =
                  tsFrac > model.typeScriptVsJavaScript.typeScriptFraction
                }
              }

            activeNavigation : Array Navigation
            activeNavigation = activeNavigationOf statsUpdatedModel
          in
          ( { statsUpdatedModel | activeNavigation = activeNavigation }
          , Cmd.none
          )
        Err jsonErr ->
          let
            _ = Debug.log ("Error parsing JSON: " ++ jsonErr ++ " for input") body
          in (model, Cmd.none)

    AnimationTick ->
      ( case model.currentSlide of
          Slide slideModel ->
            { model
            | currentSlide =
              Slide { slideModel | animationFrames = slideModel.animationFrames - 1 }
            }
      , Cmd.none
      )

    NoOp -> (model, Cmd.none)


-- View
view : Model -> Html Msg
view model =
  case model.currentSlide of
    Slide slideModel -> slideView model slideModel


-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ let
      eventsWsPath : Maybe String
      eventsWsPath =
        case model.currentSlide of
          Slide slideModel -> slideModel.eventsWsPath
    in
    case (model.eventsWsUrl, eventsWsPath) of
      (Just url, Just path) ->
        WebSocket.listen (url ++ "/" ++ path) Event
      _ -> Sub.none
  , case model.currentSlide of
      Slide slideModel ->
        if slideModel.animationFrames <= 0 then Sub.none
        else AnimationFrame.times (always AnimationTick)
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
  Navigation.program NewLocation
  { init = init
  , update = update
  , view = Html.Styled.toUnstyled << view
  , subscriptions = subscriptions
  }
