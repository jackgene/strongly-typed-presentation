module Deck.Slide.TypeSystemProperties exposing (title, tableOfContent, methodology)

import Css exposing
  -- Container
  ( borderBottom3, borderCollapse, display, margin2, transform, width
  -- Content
  , opacity, textAlign, verticalAlign
  -- Units
  , em, pct, vw, zero
  -- Alignments & Positions
  , middle
  -- Transforms
  , translateY
  -- Other values
  , auto, collapse, inlineBlock, left, num, solid
  )
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (numberedGoodRxPoint)
import Deck.Slide.Template exposing (standardSlideView)
import Html.Styled exposing (Html, text, div, p, table, td, th, tr)
import Svg.Styled.Attributes exposing (css)


-- Constants
title : String
title = "Type System Properties"


typeSystemProperties : List String
typeSystemProperties =
  [ "Memory Safety" -- "Memory Leaks, Buffer Overlow"
  , "Type Safety" -- "Errors Related to Type Mismatches"
  , "Null Safety"-- "Null Pointer Dereference"
  , "Checked Error Handling" -- "Unhandled General Errors"
  , "Safe Type Casts" -- "Type Conversion Errors"
  , "Safe Array Access" -- "Out Of Bounds Array Access"
  , "Exhaustive Matches" -- "Bugs related to default behavior occurring when they shouldn't" -- TODO
  , "Immutability" -- "Unintended State Mutation"
  , "Encapsulation" -- "Private/Unexported Data"
  --, "Safe Arithmetic Operations" -- "Arithmetic Over/Underflow, Division by Zero"
  , "Data Race Free" -- "Race Condition"
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


-- Slides
tableOfContent : Maybe Int -> UnindexedSlideModel
tableOfContent maybeHighlightedIndex =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Characteristics of a Type System That Make It Strong"
      ( div [ css [ margin2 zero (em 1) ] ]
        ( List.indexedMap
          ( \idx errorKind ->
            div
            [ css
              [ display inlineBlock, width (vw 40)
              , transform (translateY (vw (if idx % 2 == 0 then 0 else 0.5)))
              , opacity
                ( num
                  ( case maybeHighlightedIndex of
                    Just hlIdx -> if idx == hlIdx then 1.0 else 0.2
                    Nothing -> 1.0
                  )
                )
              ]
            ]
            [ numberedGoodRxPoint (toString (idx + 1)) 64
              [ css [ width (vw 5), margin2 (em 0.2) (em 0.5), verticalAlign middle ] ]
            , text errorKind
            ]
          )
          typeSystemProperties
        )
      )
    )
  }


scoreView : String -> Html msg
scoreView score =
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
            [ th [] [ scoreView "1.0" ]
            , td [] [ text "Built-in" ]
            , td [] [ text "Impossible to Defeat" ]
            ]
          , tr []
            [ th [] [ scoreView "0.5" ]
            , td [] [ text "Can Be Implemented" ]
            , td [] [ text "Difficult to Defeat" ]
            ]
          , tr []
            [ th [] [ scoreView "0.0" ]
            , td [] [ text "Impossible to Implement" ]
            , td [] [ text "Easy to Defeat" ]
            ]
          ]
        ]
      )
    )
  }
