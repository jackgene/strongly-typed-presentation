module Deck.Slide.Template exposing (..)

import Css exposing
  ( Color, Style
  -- Container
  , left, margin, position, top, width
  -- Content
  , backgroundColor, fontSize, fontWeight
  -- Sizes
  , vw, zero
  -- Positions
  , absolute
  -- Other values
  , normal
  )
import Deck.Common exposing (Model, Msg, SlideModel)
import Deck.Slide.Common exposing (..)
import Deck.Slide.Graphics exposing (goodRxPoint)
import Html.Styled exposing (Attribute, Html, div, h1, h2, text)
import Html.Styled.Attributes exposing (css)


sectionCoverSlideView : Int -> String -> Html Msg
sectionCoverSlideView number title =
  div [ css [ backgroundColor goodRxLightYellow2 ] ]
  [ goodRxPoint
  , h1
    [ css
      [ position absolute, margin zero
      , top (vw 12), left (vw 6)
      , numberFontFamily, fontWeight normal, fontSize (vw 35)
      ]
    ]
    [ text (toString number) ]
  , h1
    [ css
      [ position absolute
      , top (vw 24), left (vw 35), width (vw 55)
      , headerFontFamily, fontSize (vw 6)
      ]
    ]
    [ text title ]
  ]


standardSlideView : String -> String -> Html Msg -> Html Msg
standardSlideView heading subheading content =
  div []
  [ h1 [ css [ headerStyle ] ] [ text heading ]
  , div [ css [ contentContainerStyle ] ]
    [ h2 [ css [ subHeaderStyle ] ] [ text subheading ]
    , content
    ]
  ]
