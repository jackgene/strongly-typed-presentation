module Deck.Slide.QuestionAnswer exposing (slide)

import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (standardSlideView)
import Html.Styled exposing (Html, text)


slide : UnindexedSlideModel
slide =
  { baseSlideModel
  | view =
    ( \page _ -> standardSlideView page
      "Audience Questions"
      "Questions and Maybe Answers"
      (text "")
    )
  }
