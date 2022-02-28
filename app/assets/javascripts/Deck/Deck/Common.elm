module Deck.Common exposing (..)

import Array exposing (Array)
import Html.Styled exposing (Html)


-- Messages
type Msg
  = Next
  | Last
  | Event String
  | NoOp


-- Model
type alias SlideModel =
  { active : Model -> Bool
  , update : Msg -> Model -> (Model, Cmd Msg)
  , view : Model -> Html Msg
  , eventsWsPath : Maybe String
  }


type Slide = Slide SlideModel


type alias Model =
  { eventsWsUrl : Maybe String
  , slides : Array Slide
  , slideIndex: Int
  , languagesAndCounts : List (String, Int)
  , typeScriptVsJavaScript :
    { typeScriptFraction : Float
    , lastVoteTypeScript : Bool
    }
  }
