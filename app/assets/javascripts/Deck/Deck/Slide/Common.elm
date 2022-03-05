module Deck.Slide.Common exposing (..)

import Css exposing
  ( Style, property
  -- Container
  , display, float, height, left, margin2, marginRight
  , width
  -- Content
  , backgroundColor, before, fontFamilies, fontSize
  -- Sizes
  , em, vw, zero
  -- Positions
  -- Other values
  , block, rgb
  )
import Deck.Common exposing (Model, Msg, SlideModel)
import Html.Styled exposing (Html, div, h1, h2, text)
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
-- TODO restructure - introduce header/subheader functions to make h1/h2?
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


contentContainerStyle : Style
contentContainerStyle =
  margin2 zero (vw 7)


-- View
standardSlideView : String -> String -> Html Msg -> Html Msg
standardSlideView heading subheading content =
  div []
  [ h1 [ css [ headerStyle ] ] [ text heading ]
  , div [ css [ contentContainerStyle ] ]
    [ h2 [ css [ subHeaderStyle ] ] [ text subheading ]
    , content
    ]
  ]
