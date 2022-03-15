module Deck.Slide.CommonDefinitions exposing (slide)

import Deck.Common exposing (Slide(Slide))
import Deck.Slide.Common exposing (..)
import Html.Styled exposing (Html, div, p, text)


slide : Slide
slide =
  Slide
  { baseSlideModel
  | view =
    ( \_ -> standardSlideView "What is “Strongly Typed”?" "There Are No Formal Definitions of the Term"
      ( div []
        [ p []
          [ text "Most early examples on Wikipedia are from the 70s, and uses “Strongly Typed” interchangeably with “Statically Typed.”" ]
        , p []
          [ text "An example of a modern usage is from Luca Cardelli's 1989 paper “Typeful Programming”:" ]
        , blockquote []
          [ text "… Hence, typeful programming advocates static typing, as much as possible, and dynamic typing when necessary; the strict observance of either or both of these techniques leads to "
          , mark [] [ text "strong typing, intended as the absence of unchecked run-time type errors" ]
          , text ". …"
          ]
        ]
      )
    )
  }
