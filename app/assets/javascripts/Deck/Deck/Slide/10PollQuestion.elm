module Deck.Slide.PollQuestion exposing (slide)

import Css exposing
  -- Container
  ( display, height, left, margin, margin2
  , width, overflow, position, right, top
  -- Content
  , backgroundColor, color, fontSize, fontWeight
  , lineHeight, opacity, textAlign
  -- Sizes
  , em, int, num, pct, vw, zero
  -- Positions
  , absolute, relative
  -- Other values
  , block, center, hidden, none
  )
import Css.Transitions exposing (easeInOut, transition)
import Deck.Common exposing (Msg, Slide(Slide))
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (logosByLanguage)
import Deck.Slide.Template exposing (standardSlideView)
import Dict exposing (Dict)
import Html.Styled exposing (Html, div, li, p, text, ul)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Keyed as Keyed


-- Constants
maxDisplayCount : Int
maxDisplayCount = 8


-- View
horizontalBarView : Int -> Int -> Html Msg
horizontalBarView value maxValue =
  div
  [ css
    [ left zero
    , width (pct (100 * (toFloat value / toFloat maxValue)))
    , height (vw 2.5)
    , color goodRxBlackTranslucent
    , backgroundColor goodRxLightYellow3
    , textAlign center
    , fontWeight (int 900)
    , transition [ Css.Transitions.width3 transitionDurationMs 0 easeInOut ]
    ]
  ]
  [ text (toString value) ]


slide : UnindexedSlideModel
slide =
  { baseSlideModel
  | view =
    ( \page model ->
      standardSlideView page
      "Audience Poll"
      "What is your preferred programming language?"
      ( div []
        [ div
          [ css
            [ opacity (num (if List.isEmpty model.languagesAndCounts then 1.0 else 0))
            , height (vw (if List.isEmpty model.languagesAndCounts then 20 else 0))
            , overflow hidden
            , transition
              [ Css.Transitions.opacity3 transitionDurationMs 0 easeInOut
              , Css.Transitions.height3 transitionDurationMs 0 easeInOut
              ]
            ]
          ]
          [ p
            [ css [ margin zero ] ]
            [ text "Think of the language you:"
            , ul []
              [ li [] [ text "Are most familiar with" ]
              , li [] [ text "Would use for personal projects" ]
              , li [] [ text "Would want to be quizzed on in a technical interview" ]
              ]
            ]
          ]
        , div [ css [ if List.isEmpty model.languagesAndCounts then display none else display block ] ]
          [ p
            [ css [ margin2 zero zero ] ]
            [ text
              ( let
                  topLanguages : Int
                  topLanguages = min maxDisplayCount (List.length model.languagesAndCounts)
                in
                "The Top "
                ++(if topLanguages > 1 then toString topLanguages ++ " " else "")
                ++"Programming Language"
                ++(if topLanguages > 1 then "s" else "")
                ++" at GoodRx:"
              )
            ]
          , ( Keyed.node "div" [ css [ position relative ] ]
              ( let
                  maxCount : Int
                  maxCount =
                    Maybe.withDefault 0
                    ( Maybe.map Tuple.second (List.head model.languagesAndCounts) )
                in
                List.sortBy Tuple.first
                ( List.indexedMap
                  ( \idx (language, count) ->
                    ( language
                    , div
                      [ css
                        [ opacity (num (if idx < maxDisplayCount then 1.0 else 0.0))
                        , position absolute
                        , top (em (toFloat (1 + (idx * 2))))
                        , width (pct 90)
                        , fontSize (vw 1.6)
                        , lineHeight (em 1.6)
                        , transition
                          [ Css.Transitions.opacity3 transitionDurationMs 0 easeInOut
                          , Css.Transitions.top3 transitionDurationMs 0 easeInOut
                          , Css.Transitions.marginLeft3 transitionDurationMs 0 easeInOut
                          ]
                        ]
                      ]
                      [ div
                        [ css
                          [ position absolute, top zero, left zero, width (pct 16)
                          , textAlign right
                          ]
                        ]
                        [ Maybe.withDefault
                          ( text language )
                          ( Dict.get language logosByLanguage )
                        ]
                      , div
                        [ css [ position absolute, top zero, left (pct 17), right zero ] ]
                        [ horizontalBarView count maxCount ]
                      ]
                    )
                  )
                  model.languagesAndCounts
                )
              )
            )
          ]
        ]
      )
    )
  , eventsWsPath = Just "language-poll"
  }
