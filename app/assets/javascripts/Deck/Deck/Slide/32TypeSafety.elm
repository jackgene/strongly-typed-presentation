module Deck.Slide.TypeSafety exposing
  ( introduction
  , safeGo, invalidSafeGo, unsafeGo
  , safePython, invalidSafePython, unsafePython
  , safeTypeScript, invalidSafeTypeScript
  , safeKotlin
  , safeSwift
  )

import Css exposing
  -- Container
  ( height
  -- Units
  , vw
  -- Other Values
  )
import Deck.Slide.Common exposing (..)
import Deck.Slide.SyntaxHighlight exposing (..)
import Deck.Slide.Template exposing (standardSlideView)
import Deck.Slide.TypeSystemProperties as TypeSystemProperties
import Dict exposing (Dict)
import Html.Styled exposing (Html, div, em, p, text)
import Html.Styled.Attributes exposing (css)
import SyntaxHighlight.Model exposing
  ( ColumnEmphasis, ColumnEmphasisType(..), LineEmphasis(..) )


-- Constants
title : String
title = TypeSystemProperties.title ++ ": Type Safety"


-- Slides
introduction : UnindexedSlideModel
introduction =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Prevents Type Mismatch Errors"
      ( div []
        [ p []
          [ text "This is the most fundamental aspect of strong typing." ]
        , p []
          [ text "All data values (variables, constants) have distinct "
          , em [] [ text "types" ]
          , text ". As do function inputs (parameters) and outputs (return value). Types must match across the entire program."
          ]
        , p []
          [ text "To most people this ", em [] [ text "is" ], text " strong typing." ]
        , p []
          [ text "Indeed, the other properties of strong typing all builds upon this." ]
        ]
      )
    )
  }


safeGo : UnindexedSlideModel
safeGo =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Go Dict.empty Dict.empty Nothing
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
          [ text "Function parameters and return values "
          , em [] [ text "must " ]
          , text "have declared types, and must be called with those types:" ]
        , div [] [ codeBlock ]
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
      ( Just
        ( CodeBlockError 7 23
          [ div []
            [ text """cannot use "42" (type untyped string) as type float64 in argument to Multiply""" ]
          , div []
            [ text "cannot use true (type untyped bool) as type float64 in argument to Multiply" ]
          ]
        )
      )
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
          [ text "Compilation fails if a function is called with non-matching parameter types:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafeGo : UnindexedSlideModel
unsafeGo =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Go Dict.empty Dict.empty Nothing
      """
package typesafety
import "errors"

func Multiply(any1, any2 interface{}) (float64, error) {
  num1, ok := any1.(float64)
  if !ok { return 0, errors.New("any1 is not a float64") }
  num2, ok := any2.(float64)
  if !ok { return 0, errors.New("any2 is not a float64") }
  return num1 * num2, nil
}
var product, err = Multiply("42", true)
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Go is Type Safe"
      ( div []
        [ p []
          [ text "You would have to Go out of your way to defeat the type system:" ]
        , div [] [] -- Different block, to bypass transition
        , div [] [ codeBlock ]
        ]
      )
    )
  }


safePython : UnindexedSlideModel
safePython =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python Dict.empty Dict.empty Nothing
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
          [ text "Function parameters and return values can have declared types..." ]
        , div [ css [ height (vw 15) ] ] [ codeBlock ]
        , p []
          [ text "...and if so, must be called with those types." ]
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
      ( Just
        ( CodeBlockError 4 6
          [ div []
            [ text """Argument of type "Literal['42']" cannot be assigned to parameter "num1" of type "float" in function "multiply" """ ]
          ]
        )
      )
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
          [ text "Type-checking fails if a function is called with non-matching parameter types:" ]
        , div [ css [ height (vw 15) ] ] [ codeBlock ]
        , p []
          [ text "Note: "
          , syntaxHighlightedCodeSnippet Python "True"
          , text " is a valid parameter value here. This is because a Python "
          , syntaxHighlightedCodeSnippet Python "bool"
          , text " is a sub-type of "
          , syntaxHighlightedCodeSnippet Python "int"
          , text ", which is compatible with "
          , syntaxHighlightedCodeSnippet Python "float"
          , text "."
          ]
        ]
      )
    )
  }


unsafePython : UnindexedSlideModel
unsafePython =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python
      ( Dict.fromList
        [ (0, Deletion), (1, Addition)
        , (4, Deletion), (5, Addition)
        ]
      )
      Dict.empty Nothing
      """
def multiply(num1: float, num2: float) -> float:
def multiply(num1, num2):
  return num1 * num2

product: float = multiply("42", True)
product = multiply([1,2,3], {"key":"value"})
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Python Can Be Type Safe"
      ( div []
        [ p []
          [ text "Python typing is optional, and is incredibly easy to defeat. Python type-checkers will happilly allow this:" ]
        , div [ css [ height (vw 15) ] ] [ codeBlock ]
        , p []
          [ text "Which results in a runtime exception. It is up to the programmer to be disciplined about type-checking." ]
        ]
      )
    )
  }


safeTypeScript : UnindexedSlideModel
safeTypeScript =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock TypeScript Dict.empty Dict.empty Nothing
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
          [ text "Function parameters and return values can have declared types..." ]
        , div [] [ codeBlock ]
        , p []
          [ text "...and if so, must be called with those types." ]
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
      ( Just
        ( CodeBlockError 5 19
          [ div []
            [ text "TS2345: Argument of type 'string' is not assignable to parameter of type 'number'." ]
          , div []
            [ text "TS2345: Argument of type 'boolean' is not assignable to parameter of type 'number'." ]
          ]
        )
      )
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
        , div [] [ codeBlock ]
        ]
      )
    )
  }


safeKotlin : UnindexedSlideModel
safeKotlin =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Kotlin Dict.empty Dict.empty Nothing
      """
fun multiply(num1: Double, num2: Double): Double = num1 * num2

val product: Double = multiply(42.0, 2.718)
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Kotlin is Type Safe"
      ( div []
        [ p []
          [ text "Function parameters and return values "
          , em [] [ text "must " ]
          , text "have declared types, and must be called with those types:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


safeSwift : UnindexedSlideModel
safeSwift =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Swift Dict.empty Dict.empty Nothing
      """
func multiply(_ num1: Double, _ num2: Double) -> Double {
    num1 * num2
}

let product: Double = multiply(42, 2.718)
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Swift is Type Safe"
      ( div []
        [ p []
          [ text "Function parameters and return values "
          , em [] [ text "must " ]
          , text "have declared types, and must be called with those types:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }
