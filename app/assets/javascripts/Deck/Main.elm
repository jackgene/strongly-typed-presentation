module Deck exposing (..)

import Array exposing (Array)
import Css exposing (..)
import Css.Transitions exposing (easeInOut, transition)
import Dict
import Html.Styled exposing (Html, div, h2, text)
import Html.Styled.Attributes exposing (id, css, title)
import Html.Styled.Keyed as Keyed
import Json.Decode as Decode exposing (Decoder)
import Keyboard
import Navigation exposing (Location)
import WebSocket


-- Messages
type Msg
  = Next
  | Last
  | Event String
  | NoOp


-- Model
type alias SlideModel =
  { init : Model -> (Model, Cmd Msg)
  , update : Msg -> Model -> (Model, Cmd Msg)
  , view : Model -> Html Msg
  }


type Slide = Slide SlideModel


type alias Model =
  { eventsWsUrl : Maybe String
  , slides : Array Slide
  , slideIndex: Int
  , sendersAndCounts : List (String, Int)
  }


-- Constants
maxDisplayCount : Int
maxDisplayCount = 10


-- Init
webSocketBaseUrl : Location -> Maybe String
webSocketBaseUrl location =
  if location.protocol /= "http:" && location.protocol /= "https:" then Nothing
  else Just ("ws" ++ (String.dropLeft 4 location.protocol) ++ "//" ++ location.host)


slideTemplate : SlideModel
slideTemplate =
  { init = ( \model -> (model, Cmd.none) )
  , update = ( \_ model -> (model, Cmd.none) )
  , view = ( \_ -> text "(Placeholder)" )
  }

init : Location -> (Model, Cmd Msg)
init location =
  ( Model
    ( Maybe.map
      ( \baseUrl -> baseUrl ++ "/events" )
      ( webSocketBaseUrl location )
    )
    ( Array.fromList
      [ Slide
        { slideTemplate
        | view = ( \model -> text ("Slide " ++ (toString model.slideIndex)) )
        }
      , Slide
        { slideTemplate
        | view =
          ( \model ->
            div []
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
          )
        }
      , Slide
        { slideTemplate
        | view = ( \model -> text ("Slide " ++ (toString model.slideIndex)) )
        }
      ]
    )
    0
    []
  , Cmd.none
  )


-- Update
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Next ->
      ( { model | slideIndex = min ((Array.length model.slides) - 1) (model.slideIndex + 1) }
      , Cmd.none
      )

    Last ->
      ( { model | slideIndex = max 0 (model.slideIndex - 1) }
      , Cmd.none
      )

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
    , border3 (px 1) solid (rgb 128 128 128)
    , color (rgb 128 128 128)
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
  [ case Array.get model.slideIndex model.slides of
    Just (Slide slide) ->
      slide.view model
    Nothing -> text "Something's Wrong"
  ]

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ case model.eventsWsUrl of
    Just url -> WebSocket.listen url Event
    Nothing -> Sub.none
  , Keyboard.ups
    ( \keyCode ->
      case keyCode of
        37 -> Last
        38 -> Last
        39 -> Next
        40 -> Next
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
