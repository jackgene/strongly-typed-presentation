module Deck.Slide.Common exposing (..)

import Css exposing
  ( Color, Style, property
  -- Container
  , boxShadow4, display, float, height, inset, left, margin2, marginRight
  , width
  -- Content
  , backgroundColor, before, fontFamilies, fontSize, fontStyle
  -- Sizes
  , em, vw, zero
  -- Positions
  -- Other values
  , block, italic, rgb, rgba, transparent
  )
import Deck.Common exposing (Model, Msg, SlideModel)
import Html.Styled as Html exposing (Attribute, Html, div, h1, h2, text)
import Html.Styled.Attributes exposing (css)


-- Constants
transitionDurationMs : Float
transitionDurationMs = 500


baseSlideModel : SlideModel
baseSlideModel =
  { active = always True
  , update = ( \_ model -> (model, Cmd.none) )
  , view = ( \_ -> text "(Placeholder)" )
  , eventsWsPath = Nothing
  }


-- Styles
-- GoodRx colors https://www.dropbox.com/s/j6uf6di5m97j0b1/GoodRx_Digital%20Palette.pdf?dl=0
goodRxOffWhite : Color
goodRxOffWhite = rgb 255 255 251


goodRxBlack : Color
goodRxBlack = rgb 32 31 27


goodRxBlackTranslucent : Color
goodRxBlackTranslucent = rgba 32 31 27 0.15


goodRxYellow : Color
goodRxYellow = rgb 253 219 0


goodRxLightYellow3 : Color
goodRxLightYellow3 = rgb 253 241 144


goodRxLightYellow5 : Color
goodRxLightYellow5 = rgb 255 250 220


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
    , backgroundColor goodRxYellow
    ]
  ]


subHeaderStyle : Style
subHeaderStyle =
  Css.batch [ headerFontFamily, fontSize (vw 2.7) ]


contentContainerStyle : Style
contentContainerStyle =
  margin2 zero (vw 7)


-- View
blockquote : List (Attribute msg) -> List (Html msg) -> Html msg
blockquote attributes = Html.blockquote (css [ fontStyle italic ] :: attributes)


mark : List (Attribute msg) -> List (Html msg) -> Html msg
mark attributes =
  Html.mark
  ( css [ backgroundColor transparent, boxShadow4 inset zero (em -0.6) goodRxYellow ]
  ::attributes
  )


standardSlideView : String -> String -> Html Msg -> Html Msg
standardSlideView heading subheading content =
  div []
  [ h1 [ css [ headerStyle ] ] [ text heading ]
  , div [ css [ contentContainerStyle ] ]
    [ h2 [ css [ subHeaderStyle ] ] [ text subheading ]
    , content
    ]
  ]
