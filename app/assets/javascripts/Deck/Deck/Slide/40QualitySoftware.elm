module Deck.Slide.QualitySoftware exposing (slide)

import Deck.Common exposing (Slide(Slide))
import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (sectionCoverSlideView)


slide : Slide
slide =
  Slide
  { baseSlideModel
  | view = ( \_ -> sectionCoverSlideView 3 "Strong Typing & Quality Software" )
  }
