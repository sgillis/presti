module Practice where

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
import List
import ListUtils exposing ((!), set, randomize, (!!), zip)

-- MODELS

type alias Experiment =
    { samples : List Int
    , correct : List (Int, Int)
    , rates : List Int
    , repeats : List Int
    , sound : Sound.Model
    , i : Int
    , firstPhase : Int
    , error : Bool
    , endEarly : Bool
    , done : Bool
    , explanation : Bool
    }

emptyExperiment : Int -> Experiment
emptyExperiment x =
    let samples = randomize x [0..19]
    in { samples = samples
       , correct = randomize x correctAnswers
       , rates = repeat 20 50
       , repeats = repeat 20 0
       , sound = { soundId = Maybe.withDefault 0 <| samples !! 0
                 , playSound = True }
       , i = 0
       , firstPhase = 10
       , error = False
       , endEarly = False
       , done = False
       , explanation = True
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
        correct = drop exp.firstPhase exp.correct
        list = zip answers correct
        f = \(x, (lower, upper)) -> (lower <= x) && (x <= upper)
        trues = List.filter f list
    in (List.length trues) <= ((List.length exp.rates - exp.firstPhase) // 2)

type Update = NoOp
            | SliderUpdate Int
            | Next
            | Previous
            | Replay
            | End
            | ExplanationDone

correctAnswers : List (Int, Int)
correctAnswers =
    [ (0, 49)
    , (0, 49)
    , (51, 100)
    , (0, 49)
    , (0, 49)
    , (51, 100)
    , (0, 49)
    , (51, 100)
    , (0, 49)
    , (51, 100)
    , (51, 100)
    , (51, 100)
    , (51, 100)
    , (0, 49)
    , (51, 100)
    , (0, 49)
    , (51, 100)
    , (0, 49)
    , (0, 49)
    , (51, 100)
    ]

isCorrect : Experiment -> Bool
isCorrect exp =
    let correctAnswer = Maybe.withDefault (0,100) <| exp.correct !! exp.i
        lowerBound = fst correctAnswer
        upperBound = snd correctAnswer
    in (lowerBound <= (Maybe.withDefault 0 <| exp.rates !! exp.i)) &&
       ((Maybe.withDefault 0 <| exp.rates !! exp.i)  <= upperBound)


-- UPDATE

update : Update -> Experiment -> Experiment
update upd exp = case upd of
    NoOp -> exp
    SliderUpdate x -> { exp | rates = set exp.rates exp.i x }
    Next -> if firstPhase exp
            then if isCorrect exp
                 then updateSound { exp | i = exp.i + 1
                                        , error = False }
                 else { exp | error = True }
            else updateSound { exp | i = exp.i + 1 }
    Previous -> updateSound { exp | i = exp.i - 1 }
    Replay ->
      { exp | sound = Sound.repeatSound exp.sound
      , repeats = set exp.repeats exp.i
                  ((Maybe.withDefault 0 <| exp.repeats !! exp.i) + 1)
      }
    End -> { exp | done = True
                 , endEarly = endEarly exp }
    ExplanationDone -> { exp | explanation = False }

updateSound : Experiment -> Experiment
updateSound exp = case (exp.samples ! exp.i) of
    Nothing -> exp
    Just x  -> { exp | sound = Sound.playSound x exp.sound }


-- VIEW

view : Experiment -> Html
view exp = if exp.explanation
           then explanation
           else if exp.done
                then if exp.endEarly
                     then prematureEnd
                     else startExperiment
                else mainView exp

explanation : Html
explanation = div [ class "container" ]
    [ prestiTitle
    , row [ p [ ] [ text """
                         Je mag nu zelf proberen om de correcte nadruk aan te
                         geven. Bij de eerste 10 brabbels zal je een melding
                         krijgen wanneer je beoordeling fout is. Je mag verder
                         gaan naar de volgende brabbel wanneer je antwoord
                         correct is. Bij de laatste 10 brabbels krijg je geen
                         feedback meer.
                         """
                  ]
          ]
    , row [ button [ onClick practiceChannel.address ExplanationDone ]
                   [ text "Start" ]
          ]
    ]

prematureEnd : Html
prematureEnd = div [ class "container" ]
    [ prestiTitle
    , row [ text "Bedankt voor je deelname aan het experiment" ]
    ]

startExperiment : Html
startExperiment = div [ class "container" ]
    [ prestiTitle
    , row [ p [ ] [ text """
                         Je oefenfase zit erop. Als je geen vragen meer hebt
                         kan je beginnen aan het experiment.
                         """
                  ]
          , p [ ] [ text """
                         Heb je nog vragen? Spreek dan nu even de begeleider
                         aan.
                         """
                  ]
          , p [ ] [ text """
                         Ben je klaar om te beginnen? Druk op start.
                         """
                  ]
          ]
    , row [ button [ onClick Screens.screenAddress Screens.NextScreen ]
                   [ text "Start" ]
          ]
    ]

mainView : Experiment -> Html
mainView exp = div [ class "container" ]
    [ audioHtml trainingAudio
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
nextButton = button [ onClick practiceChannel.address Next ]
                    [ text "Volgend fragment" ]

replayButton : Experiment -> Html
replayButton exp =
    if (Maybe.withDefault 0 <| exp.repeats !! exp.i) >= 2
    then div [ ] [ ]
    else button [ onClick practiceChannel.address Replay ] [ text "Herbeluister" ]

endButton : Html
endButton = button [ onClick practiceChannel.address End ] [ text "Volgende scherm" ]

buttons : Experiment -> Html
buttons exp =
    if lastFragment exp
    then row [ replayButton exp, endButton ]
    else row [ replayButton exp, nextButton ]


-- CHANNELS
practiceChannel : Mailbox Update
practiceChannel = mailbox NoOp

practiceSignal = practiceChannel.signal
