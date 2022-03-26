module Deck.Slide.Introduction exposing (slide)

import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (sectionCoverSlideView)


slide : UnindexedSlideModel
slide =
  { baseSlideModel
  | view = ( \_ _ -> sectionCoverSlideView 1 "Introduction" )
  }
