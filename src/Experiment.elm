module Experiment where

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

emptyExperiment : Int -> Experiment
emptyExperiment x =
    let samples = randomize x [0..1]
    in { samples = samples
       , rates = repeat 2 50
       , repeats = repeat 2 0
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

view : String -> Experiment -> Html
view list exp =
    let audioFiles = case list of
                          "1" -> experimentAudio1
                          "2" -> experimentAudio2
    in div [ class "container" ]
           [ audioHtml audioFiles
           , prestiTitle
           , progressBar exp.i (length exp.samples - 1)
           , getSlider exp
           , buttons exp
           ]

progressBar : Int -> Int -> Html
progressBar x total = row [ div [ class "progress round" ]
    [ span [ class "meter"
           , style [("width", toString (x*100 // total) ++ "%")]
           ] [ ]
    ] ]

getSlider : Experiment -> Html
getSlider exp = case (exp.rates ! exp.i) of
    Nothing -> row [ text "You're at the end of the experiment" ]
    Just x  -> Slider.slider x

nextButton : Html
nextButton = button [ onClick experimentChannel.address Next ]
                    [ text "Volgend fragment" ]

replayButton : Experiment -> Html
replayButton exp =
    if exp.repeats !! exp.i >= 2
    then div [ ] [ ]
    else button [ onClick experimentChannel.address Replay ] [ text "Herbeluister" ]

buttons : Experiment -> Html
buttons exp =
    if lastFragment exp
    then row [ replayButton exp, Screens.nextScreenButton ]
    else row [ replayButton exp, nextButton ]


-- CHANNELS
experimentChannel : Mailbox Update
experimentChannel = mailbox NoOp

experimentSignal = experimentChannel.signal
