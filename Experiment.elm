module Experiment where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Signal (..)
import List (..)

import HtmlConstructs (..)
import Sound
import Slider
import Screens
import ListUtils ((!), set)

-- MODELS

type alias Experiment =
    { samples : List Int
    , rates : List Int
    , sound : Sound.Model
    , i : Int
    }

emptyExperiment : Experiment
emptyExperiment =
    { samples = [1,2]
    , rates = [50,50]
    , sound = { soundId = 1, playSound = True }
    , i = 0
    }

lastFragment : Experiment -> Bool
lastFragment exp = exp.i == (length exp.samples - 1)

firstFragment : Experiment -> Bool
firstFragment exp = exp.i == 0

type Update = NoOp
            | SliderUpdate Int
            | Next
            | Previous
            | Replay


-- UPDATE

update : Update -> Experiment -> Experiment
update upd exp = case upd of
    NoOp -> exp
    SliderUpdate x -> { exp | rates <- set exp.rates exp.i x }
    Next -> updateSound { exp | i <- exp.i + 1 }
    Previous -> updateSound { exp | i <- exp.i - 1 }
    Replay -> { exp | sound <- Sound.repeatSound exp.sound }

updateSound : Experiment -> Experiment
updateSound exp = case (exp.samples ! exp.i) of
    Nothing -> exp
    Just x  -> { exp | sound <- Sound.playSound x exp.sound }


-- VIEW

view : Experiment -> Html
view exp = div [ class "container" ]
    [ prestiTitle
    , getSlider exp
    , buttons exp
    ]

getSlider : Experiment -> Html
getSlider exp = case (exp.rates ! exp.i) of
    Nothing -> row [ text "You're at the end of the experiment" ]
    Just x  -> Slider.slider x

nextButton : Html
nextButton = button [ onClick (send experimentChannel Next) ]
                    [ text "Volgend fragment" ]

previousButton : Html
previousButton = button [ onClick (send experimentChannel Previous) ]
                        [ text "Vorig fragment" ]

buttons : Experiment -> Html
buttons exp =
    if firstFragment exp
    then row [ nextButton ]
    else if lastFragment exp
         then row [ previousButton
                  , Screens.nextScreenButton ]
         else row [ previousButton
                  , nextButton ]


-- CHANNELS
experimentChannel : Channel Update
experimentChannel = channel NoOp
