module Practice where

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
import List
import ListUtils ((!), set, randomize, (!!), zip)

-- MODELS

type alias Experiment =
    { samples : List Int
    , rates : List Int
    , repeats : List Int
    , sound : Sound.Model
    , i : Int
    , firstPhase : Int
    , error : Bool
    , endEarly : Bool
    , done : Bool
    }

emptyExperiment : Experiment
emptyExperiment =
    { samples = [0..9]
    , rates = repeat 10 50
    , repeats = repeat 10 0
    , sound = { soundId = 1, playSound = True }
    , i = 0
    , firstPhase = 5
    , error = False
    , endEarly = False
    , done = False
    }

lastFragment : Experiment -> Bool
lastFragment exp = exp.i == (length exp.samples - 1)

firstFragment : Experiment -> Bool
firstFragment exp = exp.i == 0

firstPhase : Experiment -> Bool
firstPhase exp =
    exp.i < exp.firstPhase

endEarly : Experiment -> Bool
endEarly exp =
    let answers = drop exp.firstPhase exp.rates
        correct = drop exp.firstPhase correctAnswers
        list = zip answers correct
        f = \(x, (lower, upper)) -> (lower <= x) && (x <= upper)
        trues = filter f list
    in (List.length trues) <= ((List.length exp.rates - exp.firstPhase) // 2)

type Update = NoOp
            | SliderUpdate Int
            | Next
            | Previous
            | Replay
            | End

correctAnswers : List (Int, Int)
correctAnswers =
    [ (0, 20)
    , (0, 20)
    , (0, 20)
    , (0, 20)
    , (0, 20)
    , (0, 20)
    , (0, 20)
    , (0, 20)
    , (0, 20)
    , (0, 20)
    ]

isCorrect : Experiment -> Bool
isCorrect exp =
    let correctAnswer = correctAnswers !! exp.i
        lowerBound = fst correctAnswer
        upperBound = snd correctAnswer
    in (lowerBound <= (exp.rates !! exp.i)) &&
       ((exp.rates !! exp.i)  <= upperBound)


-- UPDATE

update : Update -> Experiment -> Experiment
update upd exp = case upd of
    NoOp -> exp
    SliderUpdate x -> { exp | rates <- set exp.rates exp.i x }
    Next -> if firstPhase exp
            then if isCorrect exp
                 then updateSound { exp | i <- exp.i + 1
                                        , error <- False }
                 else { exp | error <- True }
            else updateSound { exp | i <- exp.i + 1 }
    Previous -> updateSound { exp | i <- exp.i - 1 }
    Replay -> { exp | sound <- Sound.repeatSound exp.sound
                    , repeats <- set exp.repeats exp.i (exp.repeats !! exp.i + 1) }
    End -> { exp | done <- True
                 , endEarly <- endEarly exp }

updateSound : Experiment -> Experiment
updateSound exp = case (exp.samples ! exp.i) of
    Nothing -> exp
    Just x  -> { exp | sound <- Sound.playSound x exp.sound }


-- VIEW

view : Experiment -> Html
view exp = if exp.done
           then if exp.endEarly
                then prematureEnd
                else startExperiment
           else mainView exp

prematureEnd : Html
prematureEnd = div [ class "container" ]
    [ prestiTitle
    , row [ text "Bedankt voor je deelname aan het experiment" ]
    ]

startExperiment : Html
startExperiment = div [ class "container" ]
    [ prestiTitle
    , row [ text "Ga verder naar het experiment" ]
    , pageBreak
    , row [ Screens.nextScreenButton ]
    ]

mainView : Experiment -> Html
mainView exp = div [ class "container" ]
    [ audioHtml experimentAudio
    , prestiTitle
    , row [ text <| "Oefenbrabbel " ++ toString (exp.i + 1) ++ "/" ++ toString (length exp.samples) ]
    , getSlider exp
    , if exp.error
      then row [ text "Dit is niet helemaal juist. Luister nog eens goed?" ]
      else row [ ]
    , buttons exp
    ]

getSlider : Experiment -> Html
getSlider exp = case (exp.rates ! exp.i) of
    Nothing -> row [ text "You're at the end of the experiment" ]
    Just x  -> Slider.slider x

nextButton : Html
nextButton = button [ onClick (send practiceChannel Next) ]
                    [ text "Volgend fragment" ]

replayButton : Experiment -> Html
replayButton exp =
    if exp.repeats !! exp.i >= 2
    then div [ ] [ ]
    else button [ onClick (send practiceChannel Replay) ] [ text "Herbeluister" ]

endButton : Html
endButton = button [ onClick (send practiceChannel End) ] [ text "Volgende scherm" ]

buttons : Experiment -> Html
buttons exp =
    if lastFragment exp
    then row [ replayButton exp, endButton ]
    else row [ replayButton exp, nextButton ]


-- CHANNELS
practiceChannel : Channel Update
practiceChannel = channel NoOp
