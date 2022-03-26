module Deck.Slide.PollJSvsTS exposing (slide)

import Css exposing
  ( property
  -- Container
  , borderRadius, display, height, left, margin, margin2
  , width, overflow, position, right, top, zIndex
  -- Content
  , backgroundColor, color, fontSize, fontWeight
  , lineHeight, opacity, textAlign
  -- Units
  , deg, em, int, num, pct, vw, zero
  -- Positions
  , absolute, relative
  -- Transform
  , rotate, transform
  -- Other values
  , auto, center, hidden, inherit, none, rgb
  )
import Css.Transitions exposing (easeIn, easeInOut, easeOut, transition)
import Deck.Common exposing (Msg, Slide(Slide))
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (logosByLanguage)
import Deck.Slide.Template exposing (standardSlideView)
import Dict exposing (Dict)
import Html.Styled exposing (Html, div, p, text)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Keyed as Keyed


-- View
horizontalBarView : Int -> Int -> Html Msg
horizontalBarView value maxValue =
  div
  [ css
    [ width (pct (100 * (toFloat value / toFloat maxValue)))
    , height (vw 2.5)
    , color (rgb 215 194 93)
    , backgroundColor (rgb 247 231 146)
    , textAlign center
    , fontWeight (int 900)
    ]
  ]
  [ text (toString value) ]


slide : UnindexedSlideModel
slide =
  { baseSlideModel
  | active =
    ( \model ->
      let
        tsFrac : Float
        tsFrac = model.typeScriptVsJavaScript.typeScriptFraction
      in tsFrac > 0.0 && tsFrac < 1.0
    )
  , view =
    ( \page model ->
      standardSlideView page
      "Audience Poll"
      "What is your preferred programming language?"
      ( div []
        [ div [ css [ display none ] ] []
        , div []
          [ p
            [ css [ margin zero ] ]
            [ text "Comparing JavaScript and TypeScript:"
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
                    , let
                        isJs : Bool
                        isJs = language == "JavaScript"

                        isTs : Bool
                        isTs = language == "TypeScript"

                        tsFrac : Float
                        tsFrac = model.typeScriptVsJavaScript.typeScriptFraction
                      in
                      if isJs || isTs then
                        div
                        [ css
                          [ opacity (num 1.0)
                          , position absolute, top zero, height (vw 30), width (vw 30)
                          , borderRadius (pct 50), margin2 (vw 1) (vw 28)
                          , overflow hidden
                          , transition
                            [ Css.Transitions.opacity3 transitionDurationMs 0 easeInOut
                            , Css.Transitions.top3 transitionDurationMs 0 easeInOut
                            , Css.Transitions.width3 transitionDurationMs 0 easeInOut
                            , Css.Transitions.borderRadius3 transitionDurationMs 0 easeInOut
                            , Css.Transitions.marginLeft3 transitionDurationMs 0 easeInOut
                            ]
                          ]
                        ]
                        [ div
                          [ css
                            [ position absolute, top (pct 46), left (pct (if isTs then 8 else 85))
                            , zIndex (int 20)
                            , transition
                              [ Css.Transitions.left3 (transitionDurationMs*1.2) 0 easeIn
                              , Css.Transitions.top3 (transitionDurationMs*1.2) 0 easeOut
                              ]
                            ]
                          ]
                          [ Maybe.withDefault
                            ( text language )
                            ( Dict.get language logosByLanguage )
                          ]
                        , div []
                          [ div
                            [ css
                              [ position absolute, top zero, left (pct 50)
                              , width (pct 50), height (pct 100)
                              , if tsFrac > 0.5 && isTs
                                  || tsFrac < 0.5 && isJs
                                  -- Makes animation smoother when JS majority becomes JS == TS
                                  || tsFrac == 0.5 && isJs && model.typeScriptVsJavaScript.lastVoteTypeScript
                                then
                                  zIndex (int 10)
                                else zIndex auto
                              , color (if isTs then rgb 50 75 160 else rgb 215 194 93)
                              , backgroundColor (if isTs then rgb 118 149 196 else rgb 247 231 146)
                              , paragraphFontFamily, fontSize (vw 1.6)
                              , transform (rotate (deg (180 * (if isTs then tsFrac + 0.5 else tsFrac - 0.5))))
                              , property "transform-origin" "left"
                              , transition
                                [ Css.Transitions.left3 transitionDurationMs 0 easeInOut
                                , Css.Transitions.width3 transitionDurationMs 0 easeInOut
                                , Css.Transitions.height3 transitionDurationMs 0 easeInOut
                                , Css.Transitions.backgroundColor3 transitionDurationMs 0 easeInOut
                                , Css.Transitions.transform3 transitionDurationMs 0 easeInOut
                                ]
                              ]
                            ]
                            ( if (isTs && tsFrac < 0.5) || (isJs && tsFrac > 0.5) then []
                              else
                                [ div
                                  [ css
                                    [ width (pct 100), height (pct 100)
                                    , backgroundColor inherit
                                    , transform (rotate (deg (360 * (if isTs then 0.5 - tsFrac else 0.5 - tsFrac))))
                                    , property "transform-origin" "left"
                                    , transition
                                      [ Css.Transitions.width3 transitionDurationMs 0 easeInOut
                                      , Css.Transitions.height3 transitionDurationMs 0 easeInOut
                                      , Css.Transitions.transform3 transitionDurationMs 0 easeInOut
                                      ]
                                    ]
                                  ]
                                  []
                                ]
                            )
                          ]
                        ]
                      else
                        div
                        [ css
                          [ opacity (num 0.0)
                          , position absolute
                          , top (em (toFloat (1 + (idx * 2))))
                          , width (pct 90)
                          , paragraphFontFamily, fontSize (vw 1.6)
                          , lineHeight (em 1.6)
                          , transition
                            [ Css.Transitions.opacity3 transitionDurationMs 0 easeInOut
                            , Css.Transitions.top3 transitionDurationMs 0 easeInOut
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
      )
    )
  , eventsWsPath = Just "language-poll"
  }
