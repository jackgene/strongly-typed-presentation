module Deck.Slide.OurDefinition exposing (slide)

import Deck.Common exposing (Slide(Slide))
import Deck.Slide.Common exposing (..)
import Html.Styled exposing (Html, div, p, text)


slide : Slide
slide =
  Slide
  { baseSlideModel
  | view =
    ( \_ -> standardSlideView "What is “Strongly Typed”?" "Definition for the Purpose of this Talk"
      ( div []
        [ p []
          [ text "The strength of a type system describes its ability to prevent runtime errors." ]
        , p []
          [ text "The stronger the type system, the more kinds of errors are detected during type checking, the fewer kinds of unchecked errors are possible during runtime." ]
        ]
      )
    )
  }

--Notes on definition:
--maybe more than “prevent runtime errors” it’s “account for possible behaviors/outputs”
--
--and “runtime errors” are one of the things that happen when the type doesn’t describe all the possibilities
--
--the DOT “soundness proof” was about “we can guarantee that if the program terminates, the output conforms to the declared type”
--
--so that necessarily implies that types of acceptable errors are accountable in the type
