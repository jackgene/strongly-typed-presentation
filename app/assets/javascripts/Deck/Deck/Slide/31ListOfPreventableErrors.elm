module Deck.Slide.ListOfPreventableErrors exposing (slide)

import Css exposing
  (
  -- Container
    display, margin2, transform, width
  -- Content
  , opacity, verticalAlign
  -- Size
  , em, vw, zero
  -- Positions
  , middle
  -- Transforms
  , translateY
  -- Other values
  , inlineBlock, num
  )
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (numberedGoodRxPoint)
import Deck.Slide.Template exposing (standardSlideView)
import Html.Styled exposing (Html, div, text)
import Svg.Styled.Attributes exposing (css)


errorKinds : List String
errorKinds =
  [ "Memory Leak"
  , "Buffer Overflow"
  , "Type Mismatch"
  , "Null Pointer Dereference"
  , "Type Conversion Error"
  , "Out Of Bounds Array Access"
  , "Inexhaustive Match"
  , "User Defined Error"
  , "Arithmetic Error"
  , "Data Race"
  ]


slide : Maybe Int -> UnindexedSlideModel
slide maybeHighlightedIndex =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page
      "Type-Checker Preventable Errors"
      "Kinds of Errors That Can Be Detected Before Runtime"
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
              [ css [ width (vw 5.4), margin2 (em 0.2) (em 0.5), verticalAlign middle ] ]
            , text errorKind
            ]
          )
          errorKinds
        )
      )
    )
  }
