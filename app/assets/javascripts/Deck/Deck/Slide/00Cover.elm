module Deck.Slide.Cover exposing (cover)

import Css exposing
  -- Container
  ( left, position, top, width, margin, margin2
  -- Content
  , backgroundColor, fontSize, fontWeight
  -- Units
  , em, vw, zero
  -- Alignments & Positions
  , absolute
  -- Other values
  , normal
  )
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (goodRxPoint)
import Html.Styled exposing (Html, br, div, h1, h2, p, text)
import Html.Styled.Attributes exposing (css)


cover : UnindexedSlideModel
cover =
  { baseSlideModel
  | view =
    ( \_ _ ->
      div [ css [ backgroundColor goodRxLightYellow2 ] ]
      [ goodRxPoint
      , div
        [ css
          [ position absolute
          , top (vw 15), left (vw 35), width (vw 58)
          ]
        ]
        [ h1 [ css [ margin zero, headerFontFamily, fontSize (vw 4.5) ] ]
          [ text "What Does It Mean for"
          , br [] []
          , text "a Programming Language to Be Strongly Typed?"
          ]
        , h2
          [ css [ margin2 (em 0.5) zero, headerFontFamily, fontWeight (normal), fontSize (vw 2.5) ] ]
          [ text "How Does it Help Me Produce Reliable Software?" ]
        , p
          [ css [ margin2 (em 2.5) zero, fontSize (em 0.875) ] ]
          [ text "Jack Leow"
          , br [] []
          , text "August 1, 2022"]
        ]
      ]
    )
  }
