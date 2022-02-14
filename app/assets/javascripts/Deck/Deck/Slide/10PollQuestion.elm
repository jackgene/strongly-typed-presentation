module Deck.Slide.PollQuestion exposing (slide)

import Css exposing
  -- Container
  ( display, height, left, margin2
  , width, overflow, position, right, top
  -- Content
  , backgroundColor, color, fontSize, fontWeight
  , lineHeight, opacity, textAlign
  -- Sizes
  , em, int, num, pct, vw, zero
  -- Positions
  , absolute, relative
  -- Other values
  , block, center, hidden, none, rgb
  )
import Css.Transitions exposing (easeInOut, transition)
import Deck.Common exposing (Msg, Slide(Slide))
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (logosByLanguage)
import Dict exposing (Dict)
import Html.Styled exposing (Html, div, h1, h2, li, p, text, ul)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Keyed as Keyed


-- Constants
maxDisplayCount : Int
maxDisplayCount = 10


-- View
horizontalBarView : Int -> Int -> Html Msg
horizontalBarView value maxValue =
  div
  [ css
    [ width (pct (100 * (toFloat value / toFloat maxValue)))
    , height (vw 2.5)
    , color (rgb 215 194 93)
    , backgroundColor (rgb 251 230 133)
    , textAlign center
    , fontWeight (int 900)
    , transition [ Css.Transitions.width3 500 0 easeInOut ]
    ]
  ]
  [ text (toString value) ]


slide : Slide
slide =
  Slide
  { slideTemplate
  | view =
    ( \model ->
      div []
      [ h1 [ css [ headerStyle ] ] [ text "Audience Poll" ]
      , div [ css [ margin2 zero (vw 7) ] ]
        [ h2
          [ css [ subHeaderStyle ] ]
          [ text "What is your preferred programming language?" ]
        , div
          [ css
            [ opacity (num (if List.isEmpty model.languagesAndCounts then 1.0 else 0))
            , height (vw (if List.isEmpty model.languagesAndCounts then 20 else 0))
            , overflow hidden
            , transition
              [ Css.Transitions.opacity3 500 0 easeInOut
              , Css.Transitions.height3 500 0 easeInOut
              ]
            ]
          ]
          [ p
            [ css [ margin2 zero zero, paragraphFontFamily ] ]
            [ text "Think of this as the language you:"
            , ul []
              [ li [] [ text "Are most familiar with" ]
              , li [] [ text "Would use for personal projects" ]
              , li [] [ text "Would want to be quizzed on in a technical interview" ]
              ]
            ]
          ]
        , div [ css [ if List.isEmpty model.languagesAndCounts then display none else display block ] ]
          [ p
            [ css [ margin2 zero zero, paragraphFontFamily ] ]
            [ text
              ("The Top "
              ++(toString (min maxDisplayCount (List.length model.languagesAndCounts)))
              ++" Programming Languages at GoodRx:"
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
                        , paragraphFontFamily, fontSize (vw 1.6)
                        , lineHeight (em 1.6)
                        , transition
                          [ Css.Transitions.opacity3 500 0 easeInOut
                          , Css.Transitions.top3 500 0 easeInOut
                          , Css.Transitions.marginLeft3 500 0 easeInOut
                          ]
                        ]
                      ]
                      [ div
                        [ css
                          [ position absolute, top zero, width (pct 16)
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
      ]
    )
  , liveUpdate = True
  }
