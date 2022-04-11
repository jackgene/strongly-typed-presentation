module Deck.Slide.Common exposing (..)

import Css exposing
  ( Color, Style, property
  -- Container
  , boxShadow4, display, float, height, inset, left, margin2
  , marginRight, width
  -- Content
  , backgroundColor, before
  , fontFamilies, fontSize, fontStyle, fontWeight
  -- Units
  , em, int, rgb, rgba, vw, zero
  -- Alignments & Positions
  -- Other values
  , block, italic, transparent
  )
import Deck.Common exposing (Model, Msg)
import Html.Styled as Html exposing (Attribute, Html, text)
import Html.Styled.Attributes exposing (css)


-- Model
type alias UnindexedSlideModel =
  { active : Model -> Bool
  , update : Msg -> Model -> (Model, Cmd Msg)
  , view : Int -> Model -> Html Msg
  , eventsWsPath : Maybe String
  }


-- Constants
transitionDurationMs : Float
transitionDurationMs = 500


baseSlideModel : UnindexedSlideModel
baseSlideModel =
  { active = always True
  , update = ( \_ model -> (model, Cmd.none) )
  , view = ( \_ _ -> text "(Placeholder)" )
  , eventsWsPath = Nothing
  }


-- Styles
-- GoodRx colors https://www.dropbox.com/s/j6uf6di5m97j0b1/GoodRx_Digital%20Palette.pdf?dl=0
goodRxWhite : Color
goodRxWhite = rgb 255 255 255


goodRxOffWhite : Color
goodRxOffWhite = rgb 255 255 251


goodRxBlack : Color
goodRxBlack = rgb 32 31 27


goodRxLightGray1 : Color
goodRxLightGray1 = rgb 87 87 87


goodRxLightGray2 : Color
goodRxLightGray2 = rgb 117 117 117


goodRxLightGray3 : Color
goodRxLightGray3 = rgb 171 171 171


goodRxLightGray4 : Color
goodRxLightGray4 = rgb 217 217 215


goodRxLightGray5 : Color
goodRxLightGray5 = rgb 235 235 235


goodRxLightGray6 : Color
goodRxLightGray6 = rgb 247 247 244


goodRxBlackTranslucent : Color
goodRxBlackTranslucent = rgba 32 31 27 0.15


goodRxYellow : Color
goodRxYellow = rgb 253 219 0


goodRxLightYellow1 : Color
goodRxLightYellow1 = rgb 255 228 51


goodRxLightYellow2 : Color
goodRxLightYellow2 = rgb 254 233 96


goodRxLightYellow3 : Color
goodRxLightYellow3 = rgb 253 241 144


goodRxLightYellow4 : Color
goodRxLightYellow4 = rgb 255 246 191


goodRxLightYellow5 : Color
goodRxLightYellow5 = rgb 255 250 220


goodRxLightYellow6 : Color
goodRxLightYellow6 = rgb 255 253 239


goodRxBlue : Color
goodRxBlue = rgb 0 55 110


goodRxDigitalBlue : Color
goodRxDigitalBlue = rgb 29 116 222


goodRxGreen : Color
goodRxGreen = rgb 21 96 66


goodRxDigitalGreen : Color
goodRxDigitalGreen = rgb 0 142 87


goodRxLightGreen1 : Color
goodRxLightGreen1 = rgb 221 247 225


goodRxOrange : Color
goodRxOrange = rgb 171 77 0


goodRxDigitalOrange : Color
goodRxDigitalOrange = rgb 245 145 15


goodRxRed : Color
goodRxRed = rgb 143 37 4


goodRxDigitalRed : Color
goodRxDigitalRed = rgb 209 71 21


goodRxLightRed1 : Color
goodRxLightRed1 = rgb 255 213 200


goodRxLightRed2 : Color
goodRxLightRed2 = rgb 255 246 244


headerFontFamily : Style
headerFontFamily = fontFamilies [ "GoodRx Moon" ]


numberFontFamily : Style
numberFontFamily = fontFamilies [ "GoodRx Goodall" ]


paragraphFontFamily : Style
paragraphFontFamily = fontFamilies [ "GoodRx Bolton" ]


codeFontFamily : Style
codeFontFamily = Css.batch [ fontFamilies [ "Fira Code" ], fontWeight (int 500) ]


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


li : List (Attribute msg) -> List (Html msg) -> Html msg
li attributes =
  Html.li
  ( css [ margin2 (em 0.5) zero ]
  ::attributes
  )
