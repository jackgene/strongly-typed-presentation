module Deck.Slide.ExhaustivenessChecking exposing
  ( introduction
  , blahGo
  , blahPython
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
--import SyntaxHighlight.Model exposing
--  ( ColumnEmphasis, ColumnEmphasisType(..), LineEmphasis(..) )


-- Constants
title : String
title = TypeSystemProperties.title ++ ": Exhaustiveness Checking"

subheadingGo : String
subheadingGo = "Go Does Not Have Exhaustiveness Checking"

subheadingPython : String
subheadingPython = "Python Can Have Exhaustiveness Checking"

subheadingTypeScript : String
subheadingTypeScript = "TypeScript Can Have Exhaustiveness Checking"

subheadingKotlin : String
subheadingKotlin = "Kotlin Can Have Exhaustiveness Checking"

subheadingSwift : String
subheadingSwift = "Swift Can Have Exhaustiveness Checking"


-- Slides
introduction : UnindexedSlideModel
introduction =
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title
      "Ensures All Code Flows Are Accounted For"
      ( div []
        [ p []
          [ text "TODO" ]
        ]
      )
    )
  }


blahGo : UnindexedSlideModel
blahGo =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Go Dict.empty Dict.empty []
      """
// Blah blah
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingGo
      ( div []
        [ p []
          [ text "Blah blah:" ]
        , div [] [ codeBlock ]
        ]
      )
    )
  }


blahPython : UnindexedSlideModel
blahPython =
  let
    codeBlock : Html msg
    codeBlock =
      syntaxHighlightedCodeBlock Python Dict.empty Dict.empty []
      """
# Blah blah
"""
  in
  { baseSlideModel
  | view =
    ( \page _ ->
      standardSlideView page title subheadingPython
      ( div []
        [ p []
          [ text "Blah blah:" ]
        , div [] [ codeBlock ]
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
