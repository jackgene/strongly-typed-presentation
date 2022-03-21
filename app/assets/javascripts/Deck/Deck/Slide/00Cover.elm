module Deck.Slide.Cover exposing (slide)

import Css exposing
  (
  -- Container
    left, position, top, width, margin, margin2
  -- Content
  , color, fontSize
  -- Sizes
  , em, vw, zero
  -- Positions
  , absolute
  -- Other values
  )
import Deck.Common exposing (Slide(Slide), Msg)
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (goodRxRipple)
import Html.Styled exposing (Html, br, div, h1, h2, p, text)
import Html.Styled.Attributes exposing (css)


slide : Slide
slide =
  Slide
  { baseSlideModel
  | view =
    ( \_ ->
      div []
      [ goodRxRipple
      , div
        [ css
          [ position absolute
          , top (vw 16), left (vw 36), width (vw 55)
          ]
        ]
        [ h1 [ css [ margin zero, headerFontFamily, fontSize (vw 4.5) ] ]
          [ text "What Does It Mean for"
          , br [] []
          , text "a Programming Language to Be Strongly Typed?"
          ]
        , h2
          [ css
            [ margin2 (em 0.25) zero
            , color goodRxLightGray2, headerFontFamily, fontSize (vw 3.2)
            ]
          ]
          [ text "And How Does it Help Me Produce Quality Software?" ]
        , p
          [ css [ margin2 (em 3) zero, color goodRxLightGray3, fontSize (em 0.8) ] ]
          [ text "Jack Leow"
          , br [] []
          , text "April 1, 2022"]
        ]
      ]
    )
  }
