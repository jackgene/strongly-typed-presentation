module Deck.Slide.Cover exposing (slide)

import Css exposing (absolute, fontSize, left, position, top, vw, width)
import Deck.Common exposing (Slide(Slide), Msg)
import Deck.Slide.Common exposing (headerFontFamily, baseSlideModel)
import Deck.Slide.Graphics exposing (backgroundHalfCircles)
import Html.Styled exposing (Html, br, div, h1, text)
import Html.Styled.Attributes exposing (css)


slide : Slide
slide =
  Slide
  { baseSlideModel
  | view =
    ( \_ ->
      div []
      [ backgroundHalfCircles
      , h1
        [ css
          [ position absolute
          , top (vw 18), left (vw 36), width (vw 55)
          , headerFontFamily
          , fontSize (vw 4.6)
          ]
        ]
        [ text "What Does It Mean for"
        , br [] []
        , text "a Programming Language to Be Strongly Typed?"
        ]
      ]
    )
  }
