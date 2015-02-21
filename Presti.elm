module Presti where

import Html (..)
import Html.Events (..)
import Html.Attributes (..)
import Signal (..)
import Time (..)

import HtmlConstructs (..)
import Screens
import Sound
import Slider
import Questionnaire
import Instructions
import Experiment

-- MODEL

type Action = NoOp
            | ScreenUpdate Screens.Update
            | QuestionnaireUpdate Questionnaire.Update
            | SliderUpdate Slider.Update
            | SoundUpdate Sound.Update

type alias Model =
    { screen : Screens.Model
    , questions : Questionnaire.Questions
    , instructions : Instructions.Instructions
    , sliderPosition : Int
    , experiment : Experiment.Experiment
    }

initialModel : Model
initialModel =
    { screen = Screens.initialScreen
    , questions = Questionnaire.emptyQuestions
    , instructions = Instructions.emptyInstructions
    , sliderPosition = 50
    , experiment = Experiment.emptyExperiment
    }

getSound : Model -> Sound.Model
getSound model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> Sound.emptyModel
    Screens.InstructionsScreen -> model.instructions.sound
    Screens.ExperimentScreen -> model.experiment.sound

getSlider : Model -> Slider.Model
getSlider model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> Slider.emptySlider
    Screens.InstructionsScreen -> model.instructions.slider
    Screens.ExperimentScreen -> Slider.emptySlider


-- UPDATE

update : Action -> Model -> Model
update action model = case action of
    NoOp -> model
    ScreenUpdate u -> { model | screen <- Screens.update u model.screen }
    QuestionnaireUpdate update ->
        { model | questions <- Questionnaire.update update model.questions }
    SliderUpdate update -> updateSlider update model
    SoundUpdate update -> updateSound update model
    _ -> model

updateSound : Sound.Update -> Model -> Model
updateSound u model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> model
    Screens.InstructionsScreen ->
        let ins = model.instructions
            newIns = { ins | sound <- Sound.update u ins.sound }
        in { model | instructions <- newIns }
    Screens.ExperimentScreen ->
        let exp = model.experiment
            newExp = { exp | sound <- Sound.update u exp.sound }
        in { model | experiment <- newExp }

updateSlider : Slider.Update -> Model -> Model
updateSlider u model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> model
    Screens.InstructionsScreen ->
        let ins = model.instructions
            newIns = { ins | slider <- Slider.update u ins.slider }
        in { model | instructions <- newIns }
    Screens.ExperimentScreen ->
        let exp = model.experiment
            newExp = { exp | slider <- Slider.update u exp.slider }
        in { model | experiment <- newExp }


-- VIEW

view : Model -> Html
view model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> div [ class "container" ]
        [ Questionnaire.questionScreen model.questions
        , pageBreak
        , row [ Screens.nextScreenButton ]
        ]
    Screens.InstructionsScreen -> Instructions.view model.instructions
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
 <| merge (SliderUpdate <~ (Slider.DragSlider <~ sliderValue))
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
