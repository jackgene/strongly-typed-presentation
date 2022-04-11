module Deck.Slide.Introduction exposing
  ( commonDefinitions, ourDefinition, outOfScope, inScope )

import Css exposing
  ( Style
  -- Container
  , float, width
  -- Units
  , pct
  -- Other values
  , left
  )
import Deck.Slide.Common exposing (..)
import Deck.Slide.Template exposing (standardSlideView)
import Html.Styled exposing (Html, b, div, p, text, ul)
import Html.Styled.Attributes exposing (css)


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
          [ text "Let’s start by talking about the kinds of errors no type system could detect:"
          , ul []
            [ li []
              [ b [] [ text "Infinite Loops" ]
              , text " - or in general, if a program will terminate"
              ]
            , li []
              [ b [] [ text "Stack Overflow" ]
              , text " - exceeding the call stack, typically due to recursive functions" ]
            , li []
              [ b [] [ text "Out of Memory Error" ]
              , text " - error allocating new memory"
              ]
            , li []
              [ b [] [ text "Arithmetic Errors" ]
              , text " - division by zero, overflows, underflows"
              ]
            , li []
              [ b [] [ text "Functional Error / Correctness" ]
              , text " - e.g., application background is the wrong color, incorrect form validation"
              ]
            ]
          ]
        ]
      )
    )
  }


inScope : UnindexedSlideModel
inScope =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Errors That A Strong Type System Can Prevent"
      ( let
          listStyle : Style
          listStyle = Css.batch [ width (pct 50), float left ]
        in
        div []
        [ p []
          [ text "The following are some classes of errors a type system can prevent:"
          , ul [] [ li [ css [ listStyle ] ] [ text "Memory Leaks & Buffer Overflows" ] ]
          , ul [] [ li [ css [ listStyle ] ] [ text "Type Mismatches" ] ]
          , ul [] [ li [ css [ listStyle ] ] [ text "Null Pointer Dereference" ] ]
          , ul [] [ li [ css [ listStyle ] ] [ text "Unhandled General Errors" ] ]
          , ul [] [ li [ css [ listStyle ] ] [ text "Type Conversion Failure" ] ]
          , ul [] [ li [ css [ listStyle ] ] [ text "Out Of Bounds Array Access" ] ]
          , ul [] [ li [ css [ listStyle ] ] [ text "Inexhaustive Matches" ] ]
          , ul [] [ li [ css [ listStyle ] ] [ text "Unintended State Mutation" ] ]
          , ul [] [ li [ css [ listStyle ] ] [ text "Race Conditions" ] ]
          ]
        ]
      )
    )
  }
