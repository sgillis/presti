module Presti where

import Html (..)
import Html.Events (..)
import Html.Attributes (..)
import Signal (..)
import Time (..)

import HtmlConstructs (..)
import Screens
import Questionnaire
import Sound
import Experiment

-- MODEL

type Action = NoOp
            | ScreenUpdate Screens.Update
            | QuestionnaireUpdate Questionnaire.Update
            | DragSlider Int
            | SoundUpdate Sound.Update

type alias Model =
    { screen : Screens.Model
    , questions : Questionnaire.Questions
    , sliderPosition : Int
    , sound : Sound.Model
    , experiment : Experiment.Experiment
    }

initialModel : Model
initialModel =
    { screen = Screens.initialScreen
    , questions = Questionnaire.emptyQuestions
    , sliderPosition = 50
    , sound = Sound.emptyModel
    , experiment = Experiment.emptyExperiment
    }

getSound : Model -> Sound.Model
getSound model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> Sound.emptyModel
    Screens.InstructionsScreen -> model.sound
    Screens.ExperimentScreen -> model.experiment.sound


-- UPDATE

update : Action -> Model -> Model
update action model = case action of
    NoOp -> model
    ScreenUpdate u -> { model | screen <- Screens.update u model.screen }
    QuestionnaireUpdate update ->
        { model | questions <- Questionnaire.update update model.questions }
    DragSlider x -> { model | sliderPosition <- x }
    SoundUpdate update -> updateSound update model
    _ -> model

updateSound : Sound.Update -> Model -> Model
updateSound u model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> model
    Screens.InstructionsScreen ->
        { model | sound <- Sound.update u model.sound }
    Screens.ExperimentScreen ->
        let exp = model.experiment
            newExp = { exp | sound <- Sound.update u exp.sound }
        in { model | experiment <- newExp }


-- VIEW

view : Model -> Html
view model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> div [ class "container" ]
        [ Questionnaire.questionScreen model.questions
        , pageBreak
        , row [ Screens.nextScreenButton ]
        ]
    Screens.InstructionsScreen -> div [ class "container" ]
        [ prestiTitle
        , row [ text "Some instructions" ]
        , slider model.sliderPosition
        , row [ Screens.previousScreenButton
              , Sound.replayButton
              , Screens.nextScreenButton
              ]
        ]
    Screens.ExperimentScreen -> Experiment.view model.experiment
    _ -> row [ text "unknown screen" ]


-- SIGNALS

main : Signal Html
main = map view model

model : Signal Model
model = foldp update initialModel inputSignal

inputSignal : Signal Action
inputSignal =
    merge (ScreenUpdate <~ subscribe Screens.screenChannel)
 <| merge (QuestionnaireUpdate <~ subscribe Questionnaire.updateChannel)
 <| merge (DragSlider <~ sliderValue)
          (SoundUpdate <~ (Sound.SoundPlayed <~ donePlaying))

soundIdSignal : Signal Int
soundIdSignal = .soundId <~ (getSound <~ model)

playSoundSignal : Signal Bool
playSoundSignal = merge (.playSound <~ (getSound <~ model))
                        (subscribe Sound.soundChannel)


-- PORTS

port soundId : Signal Int
port soundId = soundIdSignal

port playSound : Signal Bool
port playSound = playSoundSignal

port donePlaying : Signal Bool

port refreshFoundation : Signal Float
port refreshFoundation = every second

port sliderValue : Signal Int
