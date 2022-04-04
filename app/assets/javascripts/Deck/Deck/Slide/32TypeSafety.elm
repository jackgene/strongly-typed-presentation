module Deck.Slide.TypeSafety exposing
  ( safeTypeScript, invalidSafeTypeScript
  , safePython, invalidSafePython
  , safeGo, invalidSafeGo
  )

import Css exposing
  -- Container
  ( height, overflow, position, width
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


title : String
title = TypeSystemProperties.title ++ ": Type Safety"


safeTypeScript : UnindexedSlideModel
safeTypeScript =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock TypeScript Dict.empty Dict.empty
      """
function multiply(num1: number, num2: number): number {
  return num1 * num2;
}

const product: number = multiply(42, 2.718);
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "TypeScript Can Be Type Safe"
      ( div []
        [ p []
          [ text "Function parameters and return values have declared types, and must be called with those types:" ]
        , div
          [ css
            [ position relative, width (vw 85), height (vw 20), overflow hidden ]
          ]
          [ codeBlock ]
        ]
      )
    )
  }


invalidSafeTypeScript : UnindexedSlideModel
invalidSafeTypeScript =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock TypeScript
      ( Dict.fromList [ (4, Deletion), (5, Addition) ] )
      ( Dict.fromList [ (5, [ ColumnEmphasis Error 33 4,  ColumnEmphasis Error 39 4 ] ) ] )
      """
function multiply(num1: number, num2: number): number {
  return num1 * num2;
}

const product: number = multiply(42, 2.718);
const product: number = multiply("42", true);
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "TypeScript Can Be Type Safe"
      ( div []
        [ p []
          [ text "Compilation fails if a function is called with non-matching parameter types:" ]
        , div
          [ css
            [ position relative, width (vw 85), height (vw 20), overflow hidden ]
          ]
          [ codeBlock ]
        ]
      )
    )
  }


safePython : UnindexedSlideModel
safePython =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python Dict.empty Dict.empty
      """
def multiply(num1: float, num2: float) -> float:
  return num1 * num2

product: float = multiply(42, 2.718)
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Python Can Be Type Safe"
      ( div []
        [ p []
          [ text "Some code:" ]
        , div
          [ css
            [ position relative, width (vw 85), height (vw 20), overflow hidden ]
          ]
          [ codeBlock ]
        ]
      )
    )
  }


invalidSafePython : UnindexedSlideModel
invalidSafePython =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python
      ( Dict.fromList [ (3, Deletion), (4, Addition) ] )
      ( Dict.fromList [ (4, [ ColumnEmphasis Error 26 4 ] ) ] )
      """
def multiply(num1: float, num2: float) -> float:
  return num1 * num2

product: float = multiply(42, 2.718)
product: float = multiply("42", True)
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Python Can Be Type Safe"
      ( div []
        [ p []
          [ text "Some code:" ]
        , div
          [ css
            [ position relative, width (vw 85), height (vw 20), overflow hidden ]
          ]
          [ codeBlock ]
          -- Argument 1 to [ b [] [ text "\"multiply\"" ] ] has incompatible type [ b [] [ text "\"str\"" ] ]; expected [ b [] [ text "\"float\"" ] ]
        ]
      )
    )
  }


safeGo : UnindexedSlideModel
safeGo =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Go Dict.empty Dict.empty
      """
package typesafety

func Multiply(num1 float64, num2 float64) float64 {
  return num1 * num2
}

var product float64 = Multiply(42, 2.718)
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Go is Type Safe"
      ( div []
        [ p []
          [ text "Some code:" ]
        , div
          [ css
            [ position relative, width (vw 85), height (vw 24), overflow hidden ]
          ]
          [ codeBlock ]
        ]
      )
    )
  }


invalidSafeGo : UnindexedSlideModel
invalidSafeGo =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Go
      ( Dict.fromList [ (6, Deletion), (7, Addition) ] )
      ( Dict.fromList [ (7, [ ColumnEmphasis Error 31 4,  ColumnEmphasis Error 37 4 ] ) ] )
      """
package typesafety

func Multiply(num1 float64, num2 float64) float64 {
  return num1 * num2
}

var product float64 = Multiply(42, 2.718)
var product float64 = Multiply("42", true)
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Go is Type Safe"
      ( div []
        [ p []
          [ text "Some code:" ]
        , div
          [ css
            [ position relative, width (vw 85), height (vw 24), overflow hidden ]
          ]
          [ codeBlock ]
          -- cannot use "42" (type untyped string) as type float64 in argument to Multiply
          -- cannot use true (type untyped bool) as type float64 in argument to Multiply
        ]
      )
    )
  }
