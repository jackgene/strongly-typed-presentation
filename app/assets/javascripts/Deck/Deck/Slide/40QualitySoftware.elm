module Deck.Slide.QualitySoftware exposing (slide)

import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (sectionCoverSlideView)


slide : UnindexedSlideModel
slide =
  { baseSlideModel
  | view = ( \_ _ -> sectionCoverSlideView 3 "Strong Typing & Quality Software" )
  }
