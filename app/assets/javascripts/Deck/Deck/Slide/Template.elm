module Deck.Slide.Template exposing (..)

import Css exposing
  ( Color, Style
  -- Container
  , borderTop3, bottom, display, height, left, margin, margin4, padding2
  , position, right, top, width
  -- Content
  , backgroundColor, color, fontSize, fontWeight, verticalAlign
  -- Sizes
  , em, px, vw, zero
  -- Positions
  , absolute
  -- Other values
  , inlineBlock, middle, normal, solid
  )
import Deck.Common exposing (Model, Msg, SlideModel)
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (goodRxLogo, goodRxPoint, numberedGoodRxPoint)
import Html.Styled exposing (Attribute, Html, div, footer, h1, h2, text)
import Svg.Styled.Attributes exposing (css)


sectionCoverSlideView : Int -> String -> Html Msg
sectionCoverSlideView number title =
  div [ css [ backgroundColor goodRxLightYellow2 ] ]
  [ goodRxPoint
  , h1
    [ css
      [ position absolute, margin zero
      , top (vw 5), left (vw 6)
      , numberFontFamily, fontWeight normal, fontSize (vw 35)
      ]
    ]
    [ text (toString number) ]
  , h1
    [ css
      [ position absolute
      , top (vw 18), left (vw 35), width (vw 55)
      , headerFontFamily, fontSize (vw 6)
      ]
    ]
    [ text title ]
  ]


standardSlideView : Int -> String -> String -> Html Msg -> Html Msg
standardSlideView page heading subheading content =
  div []
  [ h1 [ css [ headerStyle ] ] [ text heading ]
  , div [ css [ contentContainerStyle ] ]
    [ h2 [ css [ subHeaderStyle ] ] [ text subheading ]
    , content
    , footer
      [ css
        [ position absolute
        , right (vw 4), bottom zero, left (vw 4), height (vw 3)
        , borderTop3 (vw 0.1) solid goodRxBlack
        , padding2 (vw 1) zero
        , paragraphFontFamily, fontSize (vw 1.3), color goodRxLightGray3
        ]
      ]
      [ goodRxLogo
      , div [ css [ display inlineBlock, position absolute, right zero ] ]
        [ text "What Does It Mean for a Programming Language to Be Strongly Typed?"
        , numberedGoodRxPoint page 50
          [ css [ width (vw 2.5), margin4 zero zero (em 0.1) (em 0.4), verticalAlign middle ] ]
        ]
      ]
    ]
  ]
