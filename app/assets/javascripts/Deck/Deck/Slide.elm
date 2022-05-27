module Deck.Slide exposing (activeNavigationOf, slideFromLocationHash, slideView)

import Array exposing (Array)
import Css exposing
  ( property
  -- Container
  , height, margin, width, overflow, position
  -- Content
  , backgroundColor, color, fontSize
  -- Units
  , auto, pct, vw
  -- Alignments & Positions
  , absolute, relative
  -- Other values
  , hidden, rgb
  )
import Deck.Common exposing (Model, Msg, Navigation, Slide(Slide), SlideModel)
import Deck.Font exposing (..)
import Deck.Slide.Common exposing (UnindexedSlideModel, goodRxBlack, goodRxOffWhite, paragraphFontFamily)
import Deck.Slide.QuestionAnswer as QuestionAnswer
import Deck.Slide.Cover as Cover
import Deck.Slide.AudiencePoll as AudiencePoll
import Deck.Slide.SectionCover as SectionCover
import Deck.Slide.Introduction as Introduction
import Deck.Slide.TypeSystemProperties as TypeSystemProperties
import Deck.Slide.TypeSafety as TypeSafety
import Deck.Slide.NullSafety as NullSafety
import Deck.Slide.ExceptionSafety as ExceptionSafety
import Deck.Slide.SafeTypeCast as SafeTypeCast
import Deck.Slide.SafeArrayAccess as SafeArrayAccess
import Deck.Slide.ExhaustivenessChecking as ExhaustivenessChecking
import Deck.Slide.Immutability as Immutability
import Deck.Slide.Encapsulation as Encapsulation
import Html.Styled exposing (Html, div, node, text)
import Html.Styled.Attributes exposing (css, type_)


-- Common
indexSlide : Int -> UnindexedSlideModel -> Slide
indexSlide index unindexedSlide =
  Slide
  { active = unindexedSlide.active
  , update = unindexedSlide.update
  , view = unindexedSlide.view index
  , index = index
  , eventsWsPath = unindexedSlide.eventsWsPath
  , animationFrames = unindexedSlide.animationFrames
  }


slidesList : List Slide
slidesList =
  List.indexedMap indexSlide
  [ Cover.cover
  , AudiencePoll.poll, AudiencePoll.jsVsTs

  -- Introduction
  , SectionCover.introduction
  , Introduction.wikipediaDefinitions
  , Introduction.typefulDefinitions
  , Introduction.ourDefinition
  , Introduction.outOfScope
  , Introduction.inScope

  -- Type System Properties
  , SectionCover.typeSystemProperties
  , TypeSystemProperties.tableOfContent Nothing
  , TypeSystemProperties.methodology
  , TypeSystemProperties.tableOfContent (Just 0)
  , TypeSafety.introduction
  , TypeSafety.safeGo
  , TypeSafety.invalidSafeGo
  , TypeSafety.invalidUnsafeGo
  , TypeSafety.unsafeGo
  , TypeSafety.safePython
  , TypeSafety.invalidSafePython
  , TypeSafety.unsafePythonAny
  , TypeSafety.unsafePythonUnannotated
  , TypeSafety.unsafePythonRun
  , TypeSafety.pythonTypeHintUnannotated
  , TypeSafety.pythonTypeHintWrong
  , TypeSafety.pythonTypeHintWrongRun
  , TypeSafety.safeTypeScript
  , TypeSafety.invalidSafeTypeScript
  , TypeSafety.unsafeTypeScriptAny
  , TypeSafety.unsafeTypeScriptUnannotated
  , TypeSafety.safeKotlin
  , TypeSafety.invalidSafeKotlin
  , TypeSafety.invalidUnsafeKotlin
  , TypeSafety.unsafeKotlin
  , TypeSafety.safeSwift
  , TypeSafety.invalidSafeSwift
  , TypeSafety.invalidUnsafeSwift
  , TypeSafety.unsafeSwift
  , TypeSystemProperties.languageReport 0
  , TypeSystemProperties.tableOfContent (Just 1)
  , NullSafety.introduction
  , NullSafety.unsafeGo
  , NullSafety.unsafeGoRun
  , NullSafety.safePythonNonNull
  , NullSafety.safePythonNonNullInvalid
  , NullSafety.safePythonNullableInvalid
  , NullSafety.safePythonNullable
  , NullSafety.safeTypeScriptNonNullInvalid
  , NullSafety.safeTypeScriptNullableInvalid
  , NullSafety.safeTypeScriptNullable
  , NullSafety.safeKotlinNullable
  , NullSafety.unsafeKotlin
  , NullSafety.safeSwiftNullable
  , NullSafety.safeSwiftNullableFun
  , NullSafety.unsafeSwift
  , TypeSystemProperties.languageReport 1
  , TypeSystemProperties.tableOfContent (Just 2)
  , SafeArrayAccess.introduction
  , SafeArrayAccess.unsafeGo
  , SafeArrayAccess.blahPython
  , SafeArrayAccess.blahTypeScript
  , SafeArrayAccess.blahKotlin
  , SafeArrayAccess.blahSwift
  , TypeSystemProperties.languageReport 2
  , TypeSystemProperties.tableOfContent (Just 3)
  , SafeTypeCast.introduction
  , SafeTypeCast.unsafeGo
  , SafeTypeCast.unsafeGoRun
  , SafeTypeCast.unsafePython
  , SafeTypeCast.blahTypeScript
  , SafeTypeCast.blahKotlin
  , SafeTypeCast.blahSwift
  , TypeSystemProperties.languageReport 3
  , TypeSystemProperties.tableOfContent (Just 4)
  , ExceptionSafety.introduction
  , ExceptionSafety.introGo
  , ExceptionSafety.unsafeGoExplicit
  , ExceptionSafety.unsafeGoVariableReuse
  , ExceptionSafety.unsafePython
  , ExceptionSafety.unsafePythonRun
  , ExceptionSafety.safePython
  , ExceptionSafety.unsafeTypeScript
  , ExceptionSafety.safeTypeScript
  , ExceptionSafety.unsafeKotlin
  , ExceptionSafety.safeKotlin
  , ExceptionSafety.safeKotlinInvalid
  , ExceptionSafety.safeSwift
  , ExceptionSafety.safeSwiftInvalid
  , ExceptionSafety.safeSwiftInvocation
  , ExceptionSafety.unsafeSwift
  , ExceptionSafety.safeSwiftMonadic
  , ExceptionSafety.safeSwiftMonadicInvalid
  , TypeSystemProperties.languageReport 4
  , TypeSystemProperties.tableOfContent (Just 5)
  , ExhaustivenessChecking.introduction
  , ExhaustivenessChecking.blahGo
  , ExhaustivenessChecking.blahPython
  , ExhaustivenessChecking.blahTypeScript
  , ExhaustivenessChecking.blahKotlin
  , ExhaustivenessChecking.blahSwift
  , TypeSystemProperties.languageReport 5
  , TypeSystemProperties.tableOfContent (Just 6)
  , Encapsulation.introduction
  , Encapsulation.blahGo
  , Encapsulation.blahPython
  , Encapsulation.blahTypeScript
  , Encapsulation.blahKotlin
  , Encapsulation.blahSwift
  , TypeSystemProperties.languageReport 6
  , TypeSystemProperties.tableOfContent (Just 7)
  , Immutability.introduction
  , Immutability.blahGo
  , Immutability.blahPython
  , Immutability.blahTypeScript
  , Immutability.blahKotlin
  , Immutability.blahSwift
  , TypeSystemProperties.languageReport 7
  , SectionCover.conclusion
  -- TODO strong typing + unit testing
  -- TODO pie charts of languages, and errors prevented
  -- Q & A
  , SectionCover.questions
  , QuestionAnswer.slide
  ]


slides : Array Slide
slides = Array.fromList slidesList


activeNavigationOf : Model -> Array Navigation
activeNavigationOf model =
  let
    (onlyPrevsReversed, _) =
      List.foldl
      ( \(Slide slideModel) (accum, maybePrevIdx) ->
        ( ( { lastSlideIndex =
              case maybePrevIdx of
                Just prevIdx -> prevIdx
                Nothing -> slideModel.index
            , nextSlideIndex = -1
            }
          , slideModel
          ) :: accum
        , if not (slideModel.active model) then maybePrevIdx
          else Just slideModel.index
        )
      )
      ( [], Nothing )
      slidesList

    (withNexts, _) =
      List.foldl
      ( \(nav, slideModel) (accum, maybeNextIdx) ->
        ( { nav
          | nextSlideIndex =
            case maybeNextIdx of
              Just nextIdx -> nextIdx
              Nothing -> slideModel.index
          } :: accum
        , if not (slideModel.active model) then maybeNextIdx
          else Just slideModel.index
        )
      )
      ( [], Nothing )
      onlyPrevsReversed
  in
  Array.fromList withNexts


withinIndexRange : Array Slide -> Int -> Int
withinIndexRange slides desiredIndex =
  min
  ( ( Array.length slides ) - 1 )
  ( max 0 desiredIndex )


slideFromLocationHash : String -> Slide
slideFromLocationHash hash =
  Maybe.withDefault (indexSlide 0 Cover.cover)
  ( Maybe.andThen
    ( \parsedIndex -> Array.get (withinIndexRange slides parsedIndex) slides )
    ( Result.toMaybe
      ( String.toInt ( String.dropLeft 7 hash ) )
    )
  )


-- View
slideView : Model -> SlideModel -> Html Msg
slideView model slide =
  div
  [ css
    [ property "display" "grid", position absolute
    , width (pct 100), height (pct 100)
    , backgroundColor (rgb 0 0 0)
    , overflow hidden
    ]
  ]
  [ node "style" [ type_ "text/css" ]
    [ text
      ( """
        @font-face {
          font-family: "GoodRx Moon";
          src: url("data:font/woff2;base64,""" ++ fontGoodRxMoonBoldWoff2Base64 ++ """");
          font-weight: 700;
        }
        @font-face {
          font-family: "GoodRx Goodall";
          src: url("data:font/woff2;base64,""" ++ fontGoodRxGoodallRegularWoff2Base64 ++ """");
          font-weight: 400;
        }
        @font-face {
          font-family: "GoodRx Bolton";
          src: url("data:font/woff2;base64,""" ++ fontGoodRxBoltonRegularWoff2Base64 ++ """");
          font-weight: 400;
        }
        @font-face {
          font-family: "GoodRx Bolton";
          src: url("data:font/woff2;base64,""" ++ fontGoodRxBoltonRegularItalicWoff2Base64 ++ """");
          font-weight: 400;
          font-style: italic;
        }
        @font-face {
          font-family: "GoodRx Bolton";
          src: url("data:font/woff2;base64,""" ++ fontGoodRxBoltonBoldWoff2Base64 ++ """");
          font-weight: 700;
        }
        @font-face {
          font-family: "GoodRx Bolton";
          src: url("data:font/woff2;base64,""" ++ fontGoodRxBoltonBoldItalicWoff2Base64 ++ """");
          font-weight: 700;
          font-style: italic;
        }
        @font-face {
          font-family: "Fira Code";
          src: url("data:font/woff2;base64,""" ++ fontFiraCodeRegularWoff2Base64 ++ """");
          font-weight: 400;
        }
        @font-face {
          font-family: "Fira Code";
          src: url("data:font/woff2;base64,""" ++ fontFiraCodeMediumWoff2Base64 ++ """");
          font-weight: 500;
        }
        @font-face {
          font-family: "Fira Code";
          src: url("data:font/woff2;base64,""" ++ fontFiraCodeBoldWoff2Base64 ++ """");
          font-weight: 700;
        }
        @font-face {
          font-family: "Glass TTY VT220";
          src: url("data:font/ttf;base64,""" ++ fontGlassTtyVt220TtfBase64 ++ """");
          font-weight: 400;
        }
        """
      )
    ]
  , div
    [ css
      [ position relative, width (pct 100), margin auto
      , overflow hidden, property "aspect-ratio" "16 / 9"
      , color goodRxBlack, backgroundColor goodRxOffWhite
      , paragraphFontFamily, fontSize (vw 2.2)
      ]
    ]
    [ slide.view model ]
  ]
