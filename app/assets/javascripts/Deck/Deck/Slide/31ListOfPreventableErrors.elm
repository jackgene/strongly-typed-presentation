module Deck.Slide.ListOfPreventableErrors exposing (slide)

import Css exposing
  (
  -- Content
    backgroundImage, backgroundPosition2, backgroundRepeat
  , listStylePosition, paddingLeft
  -- Size
  , em, px, zero
  -- Other value
  , inside, noRepeat, url
  )
import Deck.Common exposing (Slide(Slide))
import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (standardSlideView)
import Html.Styled exposing (Html, div, li, ol, text)
import Html.Styled.Attributes exposing (css)


slide : Slide
slide =
  Slide
  { baseSlideModel
  | view =
    ( \_ -> standardSlideView "Type-Checker Preventable Errors" "These Are Errors That Can Be Detected Before Runtime"
      ( div []
        [ ol []
          [ li [] [ text "Memory Leak" ]
          , li [] [ text "Buffer Overflow" ]
          , li [] [ text "Type Mismatch" ]
          , li [] [ text "Null Pointer Dereference" ]
          , li [] [ text "Type Converstion Error" ]
          , li [] [ text "Out Of Bounds Array Access" ]
          , li [] [ text "User Defined Error" ]
          , li [] [ text "Arithmetic Error" ]
          , li [] [ text "Data Race" ]
          , li [] [ text "Other Sources of Errors" ]
          ]
        ]
      )
    )
  }
