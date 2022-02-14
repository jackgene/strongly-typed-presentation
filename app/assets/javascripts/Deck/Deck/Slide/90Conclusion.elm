module Deck.Slide.Conclusion exposing (slide)

import Deck.Common exposing (Slide(Slide))
import Deck.Slide.Common exposing (..)
import Html.Styled exposing (Html, div, h1, p, text)
import Html.Styled.Attributes exposing (css)


slide : Slide
slide =
  Slide
  { slideTemplate
  | view =
    ( \_ ->
      div []
      [ h1 [ css [ headerStyle ] ] [ text "Audience Questions" ]
      , p [ css [ paragraphFontFamily ] ]
        [ text "Questions and (Maybe) Answers..." ]
      ]
    )
  }
