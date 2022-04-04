module Deck.Slide.Common exposing (..)

import Css exposing
  ( Color, Style, property
  -- Container
  , boxShadow4, display, float, height, inset, left, margin2
  , marginRight, width
  -- Content
  , backgroundColor, before, fontFamilies, fontSize, fontStyle
  -- Units
  , em, vw, zero
  -- Alignments & Positions
  -- Other values
  , block, italic, none, rgb, rgba, transparent
  )
import Deck.Common exposing (Model, Msg, SlideModel)
import Dict exposing (Dict)
import Html.Styled as Html exposing (Attribute, Html, div, text)
import Html.Styled.Attributes exposing (css)
import Parser
import SyntaxHighlight
import SyntaxHighlight.Language as Language
import SyntaxHighlight.Line as Line
import SyntaxHighlight.Model exposing
  ( Block, ColumnEmphasis, ColumnEmphasisType(..), LineEmphasis(..), Theme )
import SyntaxHighlight.Theme.Common exposing
  ( bold, noEmphasis, noStyle, squigglyUnderline, strikeThrough, textColor )


type alias UnindexedSlideModel =
  { active : Model -> Bool
  , update : Msg -> Model -> (Model, Cmd Msg)
  , view : Int -> Model -> Html Msg
  , eventsWsPath : Maybe String
  }


type Language = Go | Kotlin | Python | Swift | TypeScript


-- Constants
transitionDurationMs : Float
transitionDurationMs = 500


baseSlideModel : UnindexedSlideModel
baseSlideModel =
  { active = always True
  , update = ( \_ model -> (model, Cmd.none) )
  , view = ( \_ _ -> text "(Placeholder)" )
  , eventsWsPath = Nothing
  }


-- Styles
-- GoodRx colors https://www.dropbox.com/s/j6uf6di5m97j0b1/GoodRx_Digital%20Palette.pdf?dl=0
goodRxWhite : Color
goodRxWhite = rgb 255 255 255


goodRxOffWhite : Color
goodRxOffWhite = rgb 255 255 251


goodRxBlack : Color
goodRxBlack = rgb 32 31 27


goodRxLightGray1 : Color
goodRxLightGray1 = rgb 87 87 87


goodRxLightGray2 : Color
goodRxLightGray2 = rgb 117 117 117


goodRxLightGray3 : Color
goodRxLightGray3 = rgb 171 171 171


goodRxLightGray4 : Color
goodRxLightGray4 = rgb 217 217 215


goodRxLightGray5 : Color
goodRxLightGray5 = rgb 235 235 235


goodRxLightGray6 : Color
goodRxLightGray6 = rgb 247 247 244


goodRxBlackTranslucent : Color
goodRxBlackTranslucent = rgba 32 31 27 0.15


goodRxYellow : Color
goodRxYellow = rgb 253 219 0


goodRxLightYellow1 : Color
goodRxLightYellow1 = rgb 255 228 51


goodRxLightYellow2 : Color
goodRxLightYellow2 = rgb 254 233 96


goodRxLightYellow3 : Color
goodRxLightYellow3 = rgb 253 241 144


goodRxLightYellow4 : Color
goodRxLightYellow4 = rgb 255 246 191


goodRxLightYellow5 : Color
goodRxLightYellow5 = rgb 255 250 220


goodRxLightYellow6 : Color
goodRxLightYellow6 = rgb 255 253 239


goodRxBlue : Color
goodRxBlue = rgb 0 55 110


goodRxDigitalBlue : Color
goodRxDigitalBlue = rgb 29 116 222


goodRxGreen : Color
goodRxGreen = rgb 21 96 66


goodRxDigitalGreen : Color
goodRxDigitalGreen = rgb 0 142 87


goodRxLightGreen1 : Color
goodRxLightGreen1 = rgb 221 247 225


goodRxOrange : Color
goodRxOrange = rgb 171 77 0


goodRxDigitalOrange : Color
goodRxDigitalOrange = rgb 245 145 15


goodRxRed : Color
goodRxRed = rgb 143 37 4


goodRxDigitalRed : Color
goodRxDigitalRed = rgb 209 71 21


goodRxLightRed1 : Color
goodRxLightRed1 = rgb 255 213 200


headerFontFamily : Style
headerFontFamily = fontFamilies [ "GoodRx Moon" ]


numberFontFamily : Style
numberFontFamily = fontFamilies [ "GoodRx Goodall" ]


paragraphFontFamily : Style
paragraphFontFamily = fontFamilies [ "GoodRx Bolton" ]


headerStyle : Style
headerStyle =
  Css.batch
  [ headerFontFamily, fontSize (vw 4)
  , before
    [ property "content" "''"
    , display block, float left
    , width (em 0.2), height (em 1.2)
    , marginRight (em 1.4)
    , backgroundColor goodRxYellow
    ]
  ]


subHeaderStyle : Style
subHeaderStyle =
  Css.batch [ headerFontFamily, fontSize (vw 2.7) ]


contentContainerStyle : Style
contentContainerStyle =
  margin2 zero (vw 7)


goodRxSyntaxTheme : Theme
goodRxSyntaxTheme =
  let
    keyword : Style
    keyword = bold (textColor goodRxBlue)
  in
  { default = noEmphasis goodRxBlack goodRxLightGray6
  , selection = backgroundColor goodRxLightGray3
  , addition = backgroundColor goodRxLightGreen1
  , deletion = strikeThrough (rgba 240 0 0 0.5) (backgroundColor goodRxLightRed1)
  , error = squigglyUnderline (rgba 240 0 0 0.75) noStyle
  , warning = squigglyUnderline (rgba 216 192 0 0.75) noStyle
  , comment = textColor goodRxLightGray3
  , namespace = textColor (rgb 175 191 126)
  , keyword = keyword
  , declarationKeyword = keyword
  , builtIn = textColor goodRxDigitalGreen --keyword
  , operator = textColor goodRxLightGray2
  , number = textColor goodRxRed
  , string = textColor goodRxGreen
  , literal = keyword
  , typeDeclaration = noStyle
  , typeReference = textColor goodRxDigitalOrange
  , functionDeclaration = textColor goodRxDigitalRed
  , functionArgument = noStyle
  , functionReference = textColor goodRxDigitalRed
  , fieldDeclaration = textColor (rgb 152 118 170)
  , fieldReference = textColor (rgb 152 118 170)
  , annotation = textColor (rgb 187 181 41)
  , other = Dict.empty
  , gutter = noEmphasis goodRxLightGray3 goodRxLightGray5
  }


-- View
blockquote : List (Attribute msg) -> List (Html msg) -> Html msg
blockquote attributes = Html.blockquote (css [ fontStyle italic ] :: attributes)


mark : List (Attribute msg) -> List (Html msg) -> Html msg
mark attributes =
  Html.mark
  ( css [ backgroundColor transparent, boxShadow4 inset zero (em -0.6) goodRxYellow ]
  ::attributes
  )


syntaxHighlightedCodeBlock : Language -> Dict Int LineEmphasis -> Dict Int (List ColumnEmphasis) -> String -> Html msg
syntaxHighlightedCodeBlock language lineEmphases columnEmphases source =
  Result.withDefault (text "Error Parsing Source")
  ( let
      parser : String -> Result Parser.Error Block
      parser =
        case language of
          Go -> Language.go
          Kotlin -> Language.kotlin
          Python -> Language.python
          Swift -> Language.swift
          TypeScript -> Language.typeScript
    in
    Result.map
    ( \block ->
      let
        lineEmhasizedBlock : Block
        lineEmhasizedBlock =
          Dict.foldl
          ( \line lineEm accumBlock ->
            Line.emphasizeLines lineEm line (line+1) accumBlock
          )
          block
          lineEmphases

        fullyEmphasizedBlock : Block
        fullyEmphasizedBlock =
          Dict.foldl
          ( \line colEms accumBlock ->
            Line.emphasizeColumns colEms line accumBlock
          )
          lineEmhasizedBlock
          columnEmphases

        codeBlock : Html msg
        codeBlock = SyntaxHighlight.toBlockHtml goodRxSyntaxTheme (Just 1) fullyEmphasizedBlock

        emptyPlaceholder : Html msg
        emptyPlaceholder = div [ css [ display none ] ] []
      in
      div []
      [ if language == Go then codeBlock else emptyPlaceholder
      , if language == Kotlin then codeBlock else emptyPlaceholder
      , if language == Python then codeBlock else emptyPlaceholder
      , if language == Swift then codeBlock else emptyPlaceholder
      , if language == TypeScript then codeBlock else emptyPlaceholder
      ]
    )
    ( parser (String.trim source) )
  )
