module Deck.Slide.SafeTypeCast exposing
  ( introduction
  , unsafeGo, unsafeGoRun
  , unsafePython
  , blahTypeScript
  , blahKotlin
  , blahSwift
  )

import Deck.Slide.Common exposing (..)
import Deck.Slide.SyntaxHighlight exposing (..)
import Deck.Slide.Template exposing (standardSlideView)
import Deck.Slide.TypeSystemProperties as TypeSystemProperties
import Dict exposing (Dict)
import Html.Styled exposing (Html, div, p, text)
import SyntaxHighlight.Model exposing
  ( ColumnEmphasis, ColumnEmphasisType(..), LineEmphasis(..) )


-- Constants
title = TypeSystemProperties.title ++ ": Safe Type Cast"

subheadingGo = "Go Is Not Type Cast Safe"

subheadingPython = "Python Is Not Type Cast Safe"

subheadingTypeScript = "TypeScript Is Not Type Cast Safe"

subheadingKotlin = "Kotlin Is Type Cast Safe (With Options to Be Unsafe)"

subheadingSwift = "Swift Is Type Cast Safe (With Options to Be Unsafe)"


-- Slides
introduction : UnindexedSlideModel
introduction =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Prevents Type Cast Failures"
      ( div []
        [ p []
          [ text "As long as there is a type hierarchy, or abstract types, type casts are inevitable."
          ]
        , p []
          [ text "Languages with safe type casts require programmers to "
          , mark [] [ text "account for cast failures" ]
          , text "."
          ]
        ]
      )
    )
  }


unsafeGo : UnindexedSlideModel
unsafeGo =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Go Dict.empty Dict.empty []
      """
package main

func main() {
    var data interface{} = "hello"

    num, _ := data.(int) // non-panicking type assertion
    println(num)         // let's hope zero-value is Ok!

    num = data.(int)     // unsafe type assertion - panic!
}
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingGo
      ( div []
        [ p []
          [ text "The following type assertion will clearly fail, but the Go compiler allows it:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafeGoRun : UnindexedSlideModel
unsafeGoRun =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingGo
      ( div []
        [ p [] [ text "But the program immediately panics when run:" ]
        , console
          """
% safe_type_cast/unsafe
0
panic: interface conversion: interface {} is string, not int

goroutine 1 [running]:
main.main()
    /strongly-typed/safe_type_cast/unsafe.go:8 +0x49
"""
        ]
      )
    )
  }


unsafePython : UnindexedSlideModel
unsafePython =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python Dict.empty Dict.empty []
      """
from typing import cast

dictionary: dict[str, str] = cast(dict[str, str], 42)
print(dictionary["key"])
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingPython
      ( div []
        [ p []
          [ text "Casting is just an escape hatch to “cheat” the type system:" ]
        , div [] [ codeBlock ]
        , p []
          [ text "Casts will never fail in Python, but what happens after may:" ]
        , console
          """
% python unsafe.py
Traceback (most recent call last):
  File "/strongly-typed/safe_type_cast/unsafe.py", line 4, in <module>
    print(dictionary["key"])
TypeError: 'int' object is not subscriptable
"""
        ]
      )
    )
  }


blahTypeScript : UnindexedSlideModel
blahTypeScript =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock TypeScript Dict.empty Dict.empty []
      """
// Blah blah
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingTypeScript
      ( div []
        [ p []
          [ text "Blah blah:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


blahKotlin : UnindexedSlideModel
blahKotlin =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Kotlin Dict.empty Dict.empty []
      """
// Blah blah
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingKotlin
      ( div []
        [ p []
          [ text "Blah blah:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


blahSwift : UnindexedSlideModel
blahSwift =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Swift Dict.empty Dict.empty []
      """
// Blah blah
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingSwift
      ( div []
        [ p []
          [ text "Blah blah:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }
