module Deck.Slide.TypeSystemProperties exposing
  ( title, tableOfContent, methodology, languageReport )

import Css exposing
  -- Container
  ( borderBottom3, borderCollapse, borderLeft3, display, height
  , margin2, position, right, top, transform, width
  -- Content
  , backgroundColor, color, fontSize, opacity, textAlign, verticalAlign
  -- Units
  , em, pct, vw, zero
  -- Alignments & Positions
  , absolute, center, middle, relative
  -- Transforms
  , translateY
  -- Other values
  , auto, collapse, inlineBlock, left, num, solid
  )
import Css.Transitions exposing (easeInOut, transition)
import Deck.Common exposing (Slide(Slide), SlideModel)
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (logosByLanguage, numberedGoodRxPoint)
import Deck.Slide.Template exposing (standardSlideView)
import Dict exposing (Dict)
import Html.Styled exposing (Html, text, div, p, table, td, th, tr)
import Svg.Styled.Attributes exposing (css)


-- Type
type alias Score =
  { upper : Float
  , range : Float
  , rank : Int
  }


type alias CumulativeScore =
  { previous : Score
  , current : Score
  }

type alias TypeSystemProperty =
  { name : String
  , cumulativeScores : Dict String CumulativeScore
  }


-- Constants
title : String
title = "Type System Properties"


-- 1.0 - 1.0
scoreRequired : Score
scoreRequired = { range = 0.0, upper = 1.0, rank = -1 }


-- 0.5 - 1.0
scoreDefeatable : Score
scoreDefeatable = { range = 0.5, upper = 1.0, rank = -1 }


-- 0.0 - 1.0
scoreOptional : Score
scoreOptional = { range = 1.0, upper = 1.0, rank = -1 }


-- 0.0 - 0.5
scoreImplementable : Score
scoreImplementable = { range = 0.5, upper = 0.5, rank = -1 }


-- 0.0 - 0.0
scoreUnsupported : Score
scoreUnsupported = { range = 0.0, upper = 0.0, rank = -1 }


typeSystemProperties : List TypeSystemProperty
typeSystemProperties =
  let
    nameAndScores : List (String, Dict String Score)
    nameAndScores =
      --[ ( "Memory Safety" -- "Memory Leaks, Buffer Overlow"
      --  , Dict.fromList
      --    [ ( "Go", scoreDefeatable )
      --    , ( "Python", scoreRequired )
      --    , ( "TypeScript", scoreRequired )
      --    , ( "Kotlin", scoreRequired )
      --    , ( "Swift", scoreDefeatable )
      --    ]
      --  )
      [ ( "Type Safety" -- "Errors Related to Type Mismatches"
        , Dict.fromList
          [ ( "Go", scoreRequired )
          , ( "Python", scoreOptional )
          , ( "TypeScript", scoreOptional )
          , ( "Kotlin", scoreRequired )
          , ( "Swift", scoreRequired )
          ]
        )
      , ( "Null Safety"-- "Null Pointer Dereference"
        , Dict.fromList
          [ ( "Go", scoreUnsupported )
          , ( "Python", scoreOptional )
          , ( "TypeScript", scoreOptional )
          , ( "Kotlin", scoreDefeatable )
          , ( "Swift", scoreDefeatable )
          ]
        )
      , ( "Checked Error Handling" -- "Unhandled General Errors"
        , Dict.fromList
          [ ( "Go", scoreUnsupported )
          , ( "Python", scoreImplementable )
          , ( "TypeScript", scoreImplementable )
          , ( "Kotlin", scoreImplementable )
          , ( "Swift", scoreDefeatable )
          ]
        )
      , ( "Safe Type Cast" -- "Type Conversion Errors"
        , Dict.fromList
          [ ( "Go", scoreUnsupported )
          , ( "Python", scoreUnsupported )
          , ( "TypeScript", scoreUnsupported )
          , ( "Kotlin", scoreDefeatable )
          , ( "Swift", scoreDefeatable )
          ]
        )
      , ( "Safe Array Access" -- "Out Of Bounds Array Access"
        , Dict.fromList
          [ ( "Go", scoreUnsupported )
          , ( "Python", scoreUnsupported )
          , ( "TypeScript", scoreUnsupported )
          , ( "Kotlin", scoreOptional )
          , ( "Swift", scoreImplementable )
          ]
        )
      , ( "Exhaustiveness Checking" -- "Bugs related to default behavior occurring when they shouldn't" -- TODO
        , Dict.fromList
          [ ( "Go", scoreUnsupported )
          , ( "Python", scoreOptional )
          , ( "TypeScript", scoreOptional )
          , ( "Kotlin", scoreOptional )
          , ( "Swift", scoreOptional )
          ]
        )
      , ( "Immutability" -- "Unintended State Mutation"
        , Dict.fromList
          [ ( "Go", scoreImplementable )
          , ( "Python", scoreUnsupported )
          , ( "TypeScript", scoreOptional )
          , ( "Kotlin", scoreOptional )
          , ( "Swift", scoreOptional )
          ]
        )
      , ( "Encapsulation" -- "Private/Unexported Data"
        , Dict.fromList
          [ ( "Go", scoreOptional )
          , ( "Python", scoreUnsupported )
          , ( "TypeScript", scoreOptional )
          , ( "Kotlin", scoreOptional )
          , ( "Swift", scoreOptional )
          ]
        )
      --, ( "Data Race Free" -- "Race Condition"
      --  , Dict.fromList
      --    [ ( "Go", scoreUnsupported )
      --    , ( "Python", scoreUnsupported )
      --    , ( "TypeScript", scoreRequired )
      --    , ( "Kotlin", scoreUnsupported )
      --    , ( "Swift", scoreUnsupported )
      --    ]
      --  )
      ]
      --[ "Memory Leak & Buffer Overflow"
      --, "Type Mismatch"
      --, "Null Pointer Dereference"
      --, "I/O and Custom Failure"
      --, "Inexhaustive Match"
      --, "Type Conversion Failure"
      --, "Out Of Bounds Array Access"
      --, "Arithmetic Error"
      --, "Data Race"
      --]

    initialCumulativeScores : Dict String Score -> Dict String CumulativeScore
    initialCumulativeScores scores =
      let
        rankedScores : Dict String Score
        rankedScores =
          Dict.fromList
          ( List.indexedMap
            ( \rank (langKey, score) ->
              ( langKey
              , { score | rank = rank }
              )
            )
            ( List.sortBy
              ( \(_, score) -> (-score.upper, score.range) )
              ( Dict.toList scores)
            )
          )
      in
      Dict.map
      ( \_ score ->
        { current = score
        , previous = { scoreUnsupported | rank = score.rank }
        }
      )
      rankedScores

    nameAndCumulativeScores : List (String, Dict String CumulativeScore)
    nameAndCumulativeScores =
      List.foldl
      ( \(name, scores) accum ->
        case accum of
          [] -> [ (name, initialCumulativeScores scores) ]

          (_, prevCumScores) :: _ ->
            let
              curCumScoresUnranked : Dict String CumulativeScore
              curCumScoresUnranked =
                Dict.merge
                ( \_ _ scoresAccum -> scoresAccum )
                ( \langKey curScore prevCumScore scoresAccum ->
                  Dict.insert langKey
                  { current =
                    { upper = curScore.upper + prevCumScore.current.upper
                    , range = curScore.range + prevCumScore.current.range
                    , rank = -1
                    }
                  , previous = prevCumScore.current
                  }
                  scoresAccum
                )
                Dict.insert
                scores prevCumScores Dict.empty

              curCumScores : Dict String CumulativeScore
              curCumScores =
                Dict.fromList
                ( List.indexedMap
                  ( \rank (langKey, cumScore) ->
                    ( langKey
                    , { cumScore
                      | current =
                        let
                          curCumScoreUnranked : Score
                          curCumScoreUnranked = cumScore.current
                        in
                        { curCumScoreUnranked | rank = rank }
                      }
                    )
                  )
                  ( List.sortBy
                    ( \(_, cumScore) ->
                      (-cumScore.current.upper, cumScore.current.range, cumScore.previous.rank)
                    )
                    ( Dict.toList curCumScoresUnranked)
                  )
                )
            in
            (name, curCumScores) :: accum
      )
      []
      nameAndScores
  in
  List.reverse
  ( List.map
    ( \(name, cumulativeScores) ->
      { name = name
      , cumulativeScores = cumulativeScores
      }
    )
    nameAndCumulativeScores
  )


numTypeSystemProperties : Int
numTypeSystemProperties = List.length typeSystemProperties


-- Slides
tableOfContent : Maybe Int -> UnindexedSlideModel
tableOfContent maybePropertyIndex =
  { baseSlideModel
  | view =
    let
      maybeTypeSystemProperty : Maybe TypeSystemProperty
      maybeTypeSystemProperty =
        Maybe.andThen
        ( \propertyIndex ->
          List.head ( List.drop propertyIndex typeSystemProperties )
        )
        maybePropertyIndex

      slideTitle : String
      slideTitle =
        case maybeTypeSystemProperty of
          Just property -> title ++ ": " ++ property.name
          Nothing -> title
    in
    ( \page _ ->
      standardSlideView page slideTitle
      "Characteristics of a Type System That Make It Strong"
      ( div [ css [ margin2 zero (em 1) ] ]
        ( List.indexedMap
          ( \idx { name } ->
            div
            [ css
              [ display inlineBlock, width (vw 40)
              , transform (translateY (vw (if idx % 2 == 0 then 0 else 0.5)))
              , opacity
                ( num
                  ( case maybePropertyIndex of
                    Just hlIdx -> if idx == hlIdx then 1.0 else 0.2
                    Nothing -> 1.0
                  )
                )
              ]
            ]
            [ numberedGoodRxPoint (toString (idx + 1)) 64
              [ css [ width (vw 5), margin2 (em 0.2) (em 0.5), verticalAlign middle ] ]
            , text name
            ]
          )
          typeSystemProperties
        )
      )
    )
  }


scoreNumberView : String -> Html msg
scoreNumberView score =
  numberedGoodRxPoint score 48 [ css [ width (vw 4), margin2 (em 0.2) (em 0.5), verticalAlign middle ] ]


methodology : UnindexedSlideModel
methodology =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Analysis of Languages Used at GoodRx"
      ( div []
        [ p []
          [ text "This talk goes through each of the type system properties "
          , text "and evaluates if they apply to the languages used at GoodRx. "
          , text "For each language & property, a lower and upper-bound score is assigned as follows:"
          ]
        , table [ css [ width (pct 96), margin2 zero auto, borderCollapse collapse ] ]
          [ tr [ css [ subHeaderStyle ] ]
            [ th [ css [ width (pct 12), borderBottom3 (vw 0.1) solid goodRxBlack ] ] [ text "Score" ]
            , th
              [ css [ width (pct 44), borderBottom3 (vw 0.1) solid goodRxBlack, textAlign left ] ]
              [ text "Upper" ]
            , th
              [ css [ width (pct 44), borderBottom3 (vw 0.1) solid goodRxBlack, textAlign left ] ]
              [ text "Lower" ]
            ]
          , tr []
            [ th [] [ scoreNumberView "1.0" ]
            , td [] [ text "Built-in" ]
            , td [] [ text "Impossible to Defeat" ]
            ]
          , tr []
            [ th [] [ scoreNumberView "0.5" ]
            , td [] [ text "Can Be Implemented" ]
            , td [] [ text "Difficult to Defeat" ]
            ]
          , tr []
            [ th [] [ scoreNumberView "0.0" ]
            , td [] [ text "Impossible to Implement" ]
            , td [] [ text "Easy to Defeat" ]
            ]
          ]
        ]
      )
    )
  }


labelWidthPct : Float
labelWidthPct = 7.5

languageReport : Int -> UnindexedSlideModel
languageReport propertyIndex =
  { baseSlideModel
  | animationFrames = 1
  , view =
    let
      property : TypeSystemProperty
      property =
        Tuple.first
        ( List.foldl
          ( \next (acc, idx) ->
            ( if propertyIndex < 0 || propertyIndex >= idx then next else acc
            , idx + 1
            )
          )
          ( { name = "", cumulativeScores = Dict.empty }, 0 )
          typeSystemProperties
        )

      slideTitle : String
      slideTitle =
        if propertyIndex < 0 || propertyIndex >= List.length typeSystemProperties then title
        else title ++ ": " ++ property.name
    in
    ( \page model ->
      standardSlideView page slideTitle
      "Strong Typing Score Card"
      ( div []
        [ p [] [ text "Type system strengths of the languages we are evaluating:" ]
        , div [ css [ width (pct 90), margin2 zero auto ] ]
          [ div [ css [ position relative, height (em 10) ] ]
            ( -- Vertical lines
              List.map
              ( \score ->
                div
                [ css
                  [ position absolute
                  , left (pct (labelWidthPct - 0.05 + toFloat score * (100 - labelWidthPct) / toFloat numTypeSystemProperties))
                  , height (pct 96)
                  , borderLeft3 (vw 0.1) solid goodRxLightGray5
                  ]
                ]
                []
              )
              ( List.range 0 numTypeSystemProperties )
            ++ -- Score bars
              List.map
              ( \(language, cumScore) ->
                let
                  score : Score
                  score =
                    case model.currentSlide of
                      Slide slideModel ->
                        if slideModel.animationFrames == 0 then
                          cumScore.current
                        else cumScore.previous
                in
                div
                [ css
                  [ position absolute
                  , top (em (0.25 + toFloat (score.rank * 2)))
                  , width (pct 100)
                  , transition [ Css.Transitions.top3 (transitionDurationMs * 2) 0 easeInOut ]
                  ]
                ]
                [ div
                  [ css
                    [ position absolute, top zero, left zero, width (pct 5)
                    , textAlign right
                    ]
                  ]
                  [ Maybe.withDefault
                    ( text language )
                    ( Dict.get language logosByLanguage )
                  ]
                , div
                  [ css [ position absolute, top zero, left (pct labelWidthPct), right zero ] ]
                  [ div
                    [ css
                      [ position absolute
                      , right (pct (-0.375 + 100 * (toFloat numTypeSystemProperties - score.upper) / toFloat numTypeSystemProperties))
                      , width (pct (0.75 + 100 * (score.range / toFloat numTypeSystemProperties)))
                      , height (vw 2.5)
                      , backgroundColor goodRxLightYellow3
                      , transition
                        [ Css.Transitions.right3 (transitionDurationMs * 2) 0 easeInOut
                        , Css.Transitions.width3 (transitionDurationMs * 2) 0 easeInOut
                        ]
                      ]
                    ]
                    []
                  ]
                ]
              )
              ( Dict.toList property.cumulativeScores )
            )
          , -- Score labels
            div [ css [ position relative ] ]
            ( List.map
              ( \score ->
                div
                [ css
                  [ position absolute
                  , left (pct (labelWidthPct - 0.625 + toFloat score * (100 - labelWidthPct) / toFloat numTypeSystemProperties))
                  , width (vw 1)
                  , color goodRxLightGray3, fontSize (em 0.625)
                  , textAlign center
                  ]
                ]
                [ text (toString score) ]
              )
              ( List.range 0 numTypeSystemProperties )
            )
          ]
        ]
      )
    )
  }