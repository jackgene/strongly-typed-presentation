module Deck.Slide.QuestionAnswer exposing (slide)

import Deck.Common exposing (Slide(Slide))
import Deck.Slide.Common exposing (..)
import Html.Styled exposing (Html, text)


slide : Slide
slide =
  Slide
  { baseSlideModel
  | view =
    ( \_ -> standardSlideView "Audience Questions" "Questions and (Possibly) Answers" (text "") )
  }
