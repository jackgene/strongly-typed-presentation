module Deck.Slide.SafeTypeConversion exposing
  ( introduction
  , introGo, unsafeGo, unsafeGoRun
  , safePython, unsafePythonGoodGuard
  , unsafePythonBadGuard, unsafePythonBadGuardRun, unsafePythonCast
  , safeTypeScript, unsafeTypeScriptGoodPredicateInvalid, unsafeTypeScriptGoodPredicate
  , unsafeTypeScriptBadPredicate, unsafeTypeScriptBadPredicateRun
  , safeKotlinSmart, safeKotlinExplicit, unsafeKotlin
  , safeSwift, unsafeSwift
  )

import Deck.Slide.Common exposing (..)
import Deck.Slide.SyntaxHighlight exposing (..)
import Deck.Slide.Template exposing (standardSlideView)
import Deck.Slide.TypeSystemProperties as TypeSystemProperties
import Dict exposing (Dict)
import Html.Styled exposing (Html, br, div, em, p, text)
import SyntaxHighlight.Model exposing
  ( ColumnEmphasis, ColumnEmphasisType(..), LineEmphasis(..) )


-- Constants
title = TypeSystemProperties.title ++ ": Safe Type Conversion"

subheadingGo = "Go Is Not Type Conversion Safe"

subheadingPython = "Python Can Be Type Conversion Safe"

subheadingTypeScript = "TypeScript Is Not Type Conversion Safe"

subheadingKotlin = "Kotlin Is Type Conversion Safe (With Options to Be Unsafe)"

subheadingSwift = "Swift Is Type Conversion Safe (With Options to Be Unsafe)"


-- Slides
introduction : UnindexedSlideModel
introduction =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Prevents Type Conversion Failures"
      ( div []
        [ p []
          [ text "As long as there is a type hierarchy, or abstract types, type conversions are inevitable."
          ]
        , p []
          [ text "Languages with safe type conversions require programmers to "
          , mark [] [ text "account for conversion failures" ]
          , text "."
          ]
        ]
      )
    )
  }


introGo : UnindexedSlideModel
introGo =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Go Dict.empty Dict.empty []
      """
package main

func main() {
    var data interface{} = 42
    if str, ok := data.(string); ok {
        println("data is the string:", str)
    }
}
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingGo
      ( div []
        [ p []
          [ text "This is the idiomatic way to do type assertions:" ]
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
      syntaxHighlightedCodeBlock Go Dict.empty Dict.empty []
      """
package main

func main() {
    var data interface{} = 42

    text, _ := data.(string) // non-panicking type assertion
    println(text)            // let's hope zero-value is ok!

    text = data.(string)     // unsafe type assertion - panic!
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

panic: interface conversion: interface {} is int, not string

goroutine 1 [running]:
main.main()
    /strongly-typed/safe_type_cast/unsafe.go:9 +0x49
"""
        ]
      )
    )
  }


safePython : UnindexedSlideModel
safePython =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python Dict.empty
      ( Dict.fromList [ (4, [ ColumnEmphasis Error 6 7 ] ) ] )
      [ CodeBlockError 4 5
        [ div []
          [ text """Cannot access member "upper" for type "int" """ ]
        ]
      ]
      """
import random

thing: int | str = random.choice([42, "forty-two"])

thing.upper()

if isinstance(thing, str):
    thing.upper()
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingPython
      ( div []
        [ p []
          [ text "Through type narrowing, there’s rarely a need to explicitly convert types:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafePythonGoodGuard : UnindexedSlideModel
unsafePythonGoodGuard =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python Dict.empty Dict.empty []
      """
from typing import Any, TypeGuard

def is_str_array(objs: list[Any]) -> TypeGuard[list[str]]:
    return all(isinstance(obj, str) for obj in objs)

nums: list[object] = [1, 2, 3]
if is_str_array(nums):
    for num in nums:
        print(num.upper())
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingPython
      ( div []
        [ p []
          [ text "However, Python sometimes require you to implement your own type checking:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafePythonBadGuard : UnindexedSlideModel
unsafePythonBadGuard =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python
      ( Dict.fromList
        [ (3, Deletion), (4, Addition)
        ]
      )
      Dict.empty []
      """
from typing import Any, TypeGuard

def is_str_array(objs: list[Any]) -> TypeGuard[list[str]]:
    return all(isinstance(obj, str) for obj in objs)
    return len(objs) % 2 == 1

nums: list[object] = [1, 2, 3]
if is_str_array(nums):
    for num in nums:
        print(num.upper())
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingPython
      ( div []
        [ p []
          [ text "Without verifying your type checking logic:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafePythonBadGuardRun : UnindexedSlideModel
unsafePythonBadGuardRun =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingPython
      ( div []
        [ p []
          [ text "Only at runtime do you learn about these errors:" ]
        , console
          """
% python safe_type_cast/unsafe_typeguard.py
Traceback (most recent call last):
  File "/strongly-typed/safe_type_cast/unsafe_typeguard.py", line 9, in <modul
e>
    print(num.upper())
AttributeError: 'int' object has no attribute 'upper'
"""
        ]
      )
    )
  }


unsafePythonCast : UnindexedSlideModel
unsafePythonCast =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python Dict.empty Dict.empty []
      """
from typing import cast

text: str = cast(str, 42)
print(text.upper())
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingPython
      ( div []
        [ p []
          [ text "Casting is just an escape hatch to “cheat” the type system:" ]
        , div [] [] -- Skip transition animation
        , div [] [ codeBlock ]
        , p []
          [ text "Casts will never fail in Python, but what happens after may:" ]
        , console
          """
% python safe_type_cast/unsafe_cast.py
Traceback (most recent call last):
  File "/strongly-typed/safe_type_cast/unsafe_cast.py", line 4, in <module>
    print(text.upper())
AttributeError: 'int' object has no attribute 'upper'
"""
        ]
      )
    )
  }


safeTypeScript : UnindexedSlideModel
safeTypeScript =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock TypeScript Dict.empty
      ( Dict.fromList [ (2, [ ColumnEmphasis Error 6 13 ] ) ] )
      [ CodeBlockError 2 4
        [ div []
          [ text "TS2339: Property 'toUpperCase' does not exist on type 'string | number'."
          , br [] []
          , text "Property 'toUpperCase' does not exist on type 'number'." ]
        ]
      ]
      """
const thing: number|string = Math.random() < 0.5 ? 42 : "forty-two"

thing.toUpperCase()


if (typeof(thing) === "string") {
  thing.toUpperCase()
}
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingTypeScript
      ( div []
        [ p []
          [ text "Thanks to narrowing, type conversion is rarely necessary:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafeTypeScriptGoodPredicateInvalid : UnindexedSlideModel
unsafeTypeScriptGoodPredicateInvalid =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock TypeScript Dict.empty
      ( Dict.fromList [ (7, [ ColumnEmphasis Error 30 13 ] ) ] )
      [ CodeBlockError 7 24
        [ div []
          [ text "TS2339: Property 'toUpperCase' does not exist on type 'string | number'."
          , br [] []
          , text "Property 'toUpperCase' does not exist on type 'number'." ]
        ]
      ]
      """
function isStringArray(objs: any[]): objs is string[] {
  return objs.every(obj => typeof(obj) === "string");
}

const nums: (number|string)[] = Math.random() < 0.5
  ? [1, 2, 3] : ["one", "two", "three"];

nums.forEach(num => alert(num.toUpperCase()));

                                      //
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingTypeScript
      ( div []
        [ p []
          [ text "As with Python, TypeScript sometimes outsources type checking to the programmer:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafeTypeScriptGoodPredicate : UnindexedSlideModel
unsafeTypeScriptGoodPredicate =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock TypeScript
      ( Dict.fromList
        [ (7, Deletion), (8, Addition), (9, Addition), (10, Addition)
        ]
      )
      Dict.empty []
      """
function isStringArray(objs: any[]): objs is string[] {
  return objs.every(obj => typeof(obj) === "string");
}

const nums: (number|string)[] = Math.random() < 0.5
  ? [1, 2, 3] : ["one", "two", "three"];

nums.forEach(num => alert(num.toUpperCase()));
if (isStringArray(nums)) {
  nums.forEach(num => alert(num.toUpperCase()));
}
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingTypeScript
      ( div []
        [ p []
          [ text "As with Python, TypeScript sometimes outsources type checking to the programmer:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafeTypeScriptBadPredicate : UnindexedSlideModel
unsafeTypeScriptBadPredicate =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock TypeScript
      ( Dict.fromList
        [ (1, Deletion), (2, Addition)
        ]
      )
      Dict.empty []
      """
function isStringArray(objs: any[]): objs is string[] {
  return objs.every(obj => typeof(obj) === "string");
  return objs.length % 2 === 1;
}

const nums: (number|string)[] = Math.random() < 0.5
  ? [1, 2, 3] : ["one", "two", "three"];

if (isStringArray(nums)) {
  nums.forEach(num => alert(num.toUpperCase()));
}
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingTypeScript
      ( div []
        [ p []
          [ text "TypeScript does nothing to ensure that type predicates are correct:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafeTypeScriptBadPredicateRun : UnindexedSlideModel
unsafeTypeScriptBadPredicateRun =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingTypeScript
      ( div []
        [ p []
          [ text "About half the time, the program in the previous page fails with:" ]
        , console
          """
% jsc safe_type_cast/unsafe_predicate.js
Exception: TypeError: num.toUpperCase is not a function. (In 'num.toUpperCase(
)', 'num.toUpperCase' is undefined)
@safe_type_cast/unsafe_predicate.js:7:63
forEach@[native code]
global code@safe_type_cast/unsafe_predicate.js:7:17
"""
        ]
      )
    )
  }


safeKotlinSmart : UnindexedSlideModel
safeKotlinSmart =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Kotlin Dict.empty
      ( Dict.fromList [ (2, [ ColumnEmphasis Error 6 11 ] ) ] )
      [ CodeBlockError 2 2
        [ div []
          [ text "error: unresolved reference. None of the following candidates is applicable because of receiver type mismatch:"
          , br [] []
          , text "..." ]
        ]
      ]
      """
val thing: Any = if (Math.random() < 0.5) 42 else "forty-two"

thing.uppercase()


if (thing is String) {
    thing.uppercase()
}
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingKotlin
      ( div []
        [ p []
          [ text "Kotlin’s implicit “smart casts” make explicit casts rarely necessary:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


safeKotlinExplicit : UnindexedSlideModel
safeKotlinExplicit =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Kotlin Dict.empty Dict.empty []
      """
val thing: Any = if (Math.random() < 0.5) 42 else "forty-two"

// null if cast fails
val text: String? = thing as? String

if (text != null) {
    text.uppercase()
}
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingKotlin
      ( div []
        [ p []
          [ text "The the option of a safe explicit cast is available:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafeKotlin : UnindexedSlideModel
unsafeKotlin =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Kotlin Dict.empty Dict.empty []
      """
val text: String = 42 as String  // ClassCastException!
text.uppercase()
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingKotlin
      ( div []
        [ p []
          [ text "An explicit "
          , em [] [ text "unsafe" ]
          , text " cast is also available, which should save you a nanosecond or two:"
          ]
        , div [] [] -- Skip transition animation
        , div [] [ codeBlock ]
        , p []
          [ text "This compiles, but is guaranteed to fail at runtime:"
          ]
        , console
          """
% kotlinc -script safe_type_cast/unsafe.kts
java.lang.ClassCastException: class java.lang.Integer cannot be cast to class java.lang.String (java.lang.Integer and java.lang.String are in module java.base of loader 'bootstrap')
    at Unsafe.<init>(unsafe.kts:1)
"""
        ]
      )
    )
  }


safeSwift : UnindexedSlideModel
safeSwift =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Swift Dict.empty
      ( Dict.fromList [ (2, [ ColumnEmphasis Error 6 12 ] ) ] )
      [ CodeBlockError 2 4
        [ div []
          [ text "value of type 'Any' has no member 'uppercased'" ]
        ]
      ]
      """
let thing: Any = Bool.random() ? 42 : "forty-two"

thing.uppercased()

if let thing = thing as? String {
    thing.uppercased()
}
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingSwift
      ( div []
        [ p []
          [ text "Swift casts must be explicit, but the syntax is fairly succinct:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


unsafeSwift : UnindexedSlideModel
unsafeSwift =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Swift Dict.empty Dict.empty []
      """
let text: String = 42 as! String  // it's a trap!
text.uppercased()
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingSwift
      ( div []
        [ p []
          [ text "When every nanosecond counts, Swift has the "
          , em [] [ text "unsafe" ]
          , text " cast operator - "
          , syntaxHighlightedCodeSnippet Swift "as!"
          , text ":"
          ]
        , div [] [] -- Skip transition animation
        , div [] [ codeBlock ]
        , p []
          [ text "This compiles, but traps with this unhelpful message:"
          ]
        , console
          """
% ./safe_type_cast
zsh: illegal hardware instruction  ./safe_type_cast
"""
        ]
      )
    )
  }
