module Instructions where

import Html (..)
import Html.Attributes (..)

import HtmlConstructs (..)
import Screens
import Sound
import Slider


-- MODELS

type alias Instructions =
    { sound : Sound.Model
    , slider : Slider.Model
    }

type Update = NoOp

emptyInstructions : Instructions
emptyInstructions =
    { sound  = { soundId = 1, playSound = True }
    , slider = 50
    }


-- UPDATE


-- VIEW

view : Instructions -> Html
view model = div [ class "container" ]
    [ prestiTitle
    , row [ text "Some instructions" ]
    , Slider.slider model.slider
    , row [ Screens.previousScreenButton
          , Sound.replayButton
          , Screens.nextScreenButton
          ]
    ]

