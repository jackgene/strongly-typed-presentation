module Deck.Slide.TypeSystemProperties exposing (title, tableOfContent, methodology)

import Css exposing
  -- Container
  ( display, margin2, transform, width
  -- Content
  , opacity, verticalAlign
  -- Units
  , em, vw, zero
  -- Alignments & Positions
  , middle
  -- Transforms
  , translateY
  -- Other values
  , inlineBlock, num
  )
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (numberedGoodRxPoint)
import Deck.Slide.Template exposing (standardSlideView)
import Html.Styled exposing (Html, br, div, text)
import Svg.Styled.Attributes exposing (css)


-- Constants
title : String
title = "Type System Properties"


-- TODO Encapsulation
errorKinds : List String
errorKinds =
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
            [ numberedGoodRxPoint (idx + 1) 64
              [ css [ width (vw 5), margin2 (em 0.2) (em 0.5), verticalAlign middle ] ]
            , text errorKind
            ]
          )
          errorKinds
        )
      )
    )
  }


methodology : UnindexedSlideModel
methodology =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Analysis of Languages Used at GoodRx"
      ( div [] [] )
    )
  }
