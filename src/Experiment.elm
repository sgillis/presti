module Experiment where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Signal (..)
import List (..)

import HtmlConstructs (..)
import Files (..)
import Sound
import Slider
import Screens
import ListUtils ((!), set, randomize, (!!))

-- MODELS

type alias Experiment =
    { samples : List Int
    , rates : List Int
    , repeats : List Int
    , sound : Sound.Model
    , i : Int
    }

emptyExperiment : Int -> Experiment
emptyExperiment x =
    let samples = randomize x [0..2]
    in -- { samples = randomize x [0..526]
       -- , rates = repeat 527 50
       -- , repeats = repeat 527 0
       { samples = samples
       , rates = repeat 3 50
       , repeats = repeat 3 0
       , sound = { soundId = samples !! 0, playSound = True }
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
    Replay -> { exp | sound <- Sound.repeatSound exp.sound
                    , repeats <- set exp.repeats exp.i (exp.repeats !! exp.i + 1) }

updateSound : Experiment -> Experiment
updateSound exp = case (exp.samples ! exp.i) of
    Nothing -> exp
    Just x  -> { exp | sound <- Sound.playSound x exp.sound }


-- VIEW

view : Experiment -> Html
view exp = div [ class "container" ]
    [ audioHtml experimentAudio
    , prestiTitle
    , row [ text <| "Brabbel " ++ toString (exp.i + 1) ++ "/" ++ toString (length exp.samples) ]
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

replayButton : Experiment -> Html
replayButton exp =
    if exp.repeats !! exp.i >= 2
    then div [ ] [ ]
    else button [ onClick (send experimentChannel Replay) ] [ text "Herbeluister" ]

buttons : Experiment -> Html
buttons exp =
    if lastFragment exp
    then row [ replayButton exp, Screens.nextScreenButton ]
    else row [ replayButton exp, nextButton ]


-- CHANNELS
experimentChannel : Channel Update
experimentChannel = channel NoOp
