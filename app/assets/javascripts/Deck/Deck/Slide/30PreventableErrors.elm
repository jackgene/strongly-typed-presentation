module Deck.Slide.PreventableErrors exposing (slide)

import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (sectionCoverSlideView)


slide : UnindexedSlideModel
slide =
  { baseSlideModel
  | view = ( \_ _ -> sectionCoverSlideView 2 "Type-Checker Preventable Errors" )
  }
