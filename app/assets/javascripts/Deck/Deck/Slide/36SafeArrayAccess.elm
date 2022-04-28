module Deck.Slide.SafeArrayAccess exposing (..)

import Css exposing
  (
  -- Container
    height, overflow, position, width
  -- Scalar
  , vw
  -- Other Values
  , hidden, relative
  )
import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (standardSlideView)
import Deck.Slide.TypeSystemProperties as TypeSystemProperties
import Dict exposing (Dict)
import Html.Styled exposing (Html, div, p, text)
import Html.Styled.Attributes exposing (css)
import SyntaxHighlight.Model exposing
  ( ColumnEmphasis, ColumnEmphasisType(..), LineEmphasis(..) )


-- Constants
title : String
title = TypeSystemProperties.title ++ ": Safe Array Access"


-- Slides
introduction : UnindexedSlideModel
introduction =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Prevents Errors Related to Accessing Out Of Bounds Array Elements"
      ( div []
        [ p []
          [ text "TODO" ]
        ]
      )
    )
  }
