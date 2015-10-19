module Example where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)
import List exposing (..)

import HtmlConstructs exposing (..)
import Files exposing (..)
import Sound
import Slider
import Screens
import ListUtils exposing ((!), set, randomize, (!!))

-- MODELS

type alias Experiment =
    { samples : List Int
    , rates : List Int
    , repeats : List Int
    , sound : Sound.Model
    , i : Int
    }

emptyExperiment : Experiment
emptyExperiment =
    { samples = [0..5]
    , rates = [20, 50, 80, 50, 70, 30]
    , repeats = repeat 6 0
    , sound = { soundId = 0, playSound = True }
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

explanationStrings : List String
explanationStrings =
    [ "De nadruk ligt op het eerste deel."
    , "De nadruk is op beide delen nagenoeg gelijk."
    , "De nadruk ligt op het tweede deel."
    , "De nadruk is op beide delen nagenoeg gelijk."
    , "De nadruk ligt op het tweede deel."
    , "De nadruk ligt op het eerste deel."
    ]


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
    [ audioHtml trialAudio
    , prestiTitle
    , row [ text <| "Voorbeeld " ++ toString (exp.i + 1) ++ "/" ++ toString (length exp.samples) ]
    , getSlider exp
    , row [ text <| explanationStrings !! exp.i ]
    , pageBreak
    , buttons exp
    ]

getSlider : Experiment -> Html
getSlider exp = case (exp.rates ! exp.i) of
    Nothing -> row [ text "You're at the end of the experiment" ]
    Just x  -> Slider.slider x

nextButton : Html
nextButton = button [ onClick exampleChannel.address Next ]
                    [ text "Volgend fragment" ]

replayButton : Experiment -> Html
replayButton exp =
    if exp.repeats !! exp.i >= 2
    then div [ ] [ ]
    else button [ onClick exampleChannel.address Replay ] [ text "Herbeluister" ]

buttons : Experiment -> Html
buttons exp =
    if lastFragment exp
    then row [ replayButton exp, Screens.nextScreenButton ]
    else row [ replayButton exp, nextButton ]


-- CHANNELS
exampleChannel : Mailbox Update
exampleChannel = mailbox NoOp

exampleSignal = exampleChannel.signal
