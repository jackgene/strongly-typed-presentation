module Deck.Slide.Common exposing (..)

import Css exposing
  ( Style, property
  -- Container
  , display, float, height, left, margin, margin2, marginRight
  , width, overflow, paddingTop, position, right, top
  -- Content
  , backgroundColor, before, color, fontFamilies, fontSize, fontWeight
  , lineHeight, opacity, textAlign, visibility
  -- Sizes
  , auto, em, int, num, pct, vw, zero
  -- Positions
  , absolute, relative, static
  -- Other values
  , block, center, hidden, none, rgb, visible
  )
import Deck.Common exposing (SlideModel)
import Html.Styled exposing (text)


slideTemplate : SlideModel
slideTemplate =
  { init = ( \model -> (model, Cmd.none) )
  , update = ( \_ model -> (model, Cmd.none) )
  , view = ( \_ -> text "(Placeholder)" )
  , liveUpdate = False
  }


-- Styles
headerFontFamily : Style
headerFontFamily = fontFamilies [ "GoodRx Moon" ]


paragraphFontFamily : Style
paragraphFontFamily =
  Css.batch
  [ fontFamilies [ "GoodRx Bolton" ]
  , fontSize (vw 2.2)
  ]


headerStyle : Style
headerStyle =
  Css.batch
  [ headerFontFamily, fontSize (vw 4)
  , before
    [ property "content" "''"
    , display block, float left
    , width (em 0.2), height (em 1.2)
    , marginRight (em 1.4)
    , backgroundColor (rgb 245 218 121)
    ]
  ]


subHeaderStyle : Style
subHeaderStyle =
  Css.batch [ headerFontFamily, fontSize (vw 2.7) ]
