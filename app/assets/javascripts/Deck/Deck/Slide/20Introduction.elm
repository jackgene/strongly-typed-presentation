module Deck.Slide.Introduction exposing (commonDefinitions, ourDefinition, outOfScope)

import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (standardSlideView)
import Html.Styled exposing (Html, b, br, div, li, p, text, ul)


-- Constants
title : String
title = "What is “Strongly Typed”?"


-- Slides
commonDefinitions : UnindexedSlideModel
commonDefinitions =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "There Are No Formal Definitions of the Term"
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


ourDefinition : UnindexedSlideModel
ourDefinition =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Definition for the Purpose of this Talk"
      ( div []
        [ p []
          [ text "The strength of a type system describes its ability to prevent runtime errors." ]
        , p []
          [ text "The stronger the type system, the more kinds of errors are detected during type checking, the fewer kinds of unchecked errors are possible during runtime." ]
        ]
      )
    )
  }


outOfScope : UnindexedSlideModel
outOfScope =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Not All Errors Can Be Detected Before Runtime"
      ( div []
        [ p []
          [ text "Let’s start by talking about the kinds of errors no type system could detect:" ]
        , ul []
          [ li []
            [ b [] [ text "Infinite Loops" ]
            , text " - or in general, if a program will terminate - no type system has solved the halting problem"
            ]
          , li []
            [ b [] [ text "Stack Overflow" ]
            , text " - though, as we'll see later, Kotlin has features that go a long way to preventing them" ]
          , li []
            [ b [] [ text "Out of Memory Error" ]
            , text " - error allocating new memory"
            ]
          , li []
            [ b [] [ text "Arithmetic Errors" ]
            , text " - division by zero, overflows, underflows"
            ]
          , li []
            [ b [] [ text "Functional Error" ]
            , text " - e.g., detecting the user of the wrong color background, or incomplete form validation"
            ]
          ]
        ]
      )
    )
  }
