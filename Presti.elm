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

type Screen = QuestionScreen
            | InstructionsScreen
            | ExperimentScreen

type alias Model =
    { screen : String
    , questions : Questionnaire.Questions
    , sliderPosition : Int
    , sound : Sound.Model
    , experiment : Experiment.Experiment
    }

-- PORTS

port soundId : Signal Int
port soundId = soundIdSignal

port playSound : Signal Bool
port playSound = playSoundSignal

port donePlaying : Signal Bool

port refreshFoundation : Signal Float
port refreshFoundation = every second

port sliderValue : Signal Int

-- UPDATE

update : Action -> Model -> Model
update action model = case action of
    NoOp -> model
    ScreenUpdate u -> Screens.update u previousScreen nextScreen model
    QuestionnaireUpdate update ->
        { model | questions <- Questionnaire.update update model.questions }
    DragSlider x -> { model | sliderPosition <- x }
    SoundUpdate update ->
        { model | sound <- Sound.update update model.sound }
    _ -> model

nextScreen : Model -> Model
nextScreen model = case toScreen model.screen of
    QuestionScreen     -> { model | screen <- fromScreen InstructionsScreen
                                  , sound  <- Sound.playSound 1 model.sound }
    InstructionsScreen -> { model | screen <- fromScreen ExperimentScreen
                                  , sound  <- Sound.playSound
                                                model.experiment.currentSound
                                                model.sound }
    ExperimentScreen   -> { model | screen <- fromScreen ExperimentScreen
                                  , sound  <- Sound.playSound
                                                model.experiment.currentSound
                                                model.sound }

previousScreen : Model -> Model
previousScreen model = case toScreen model.screen of
    QuestionScreen     -> { model | screen <- fromScreen QuestionScreen }
    InstructionsScreen -> { model | screen <- fromScreen QuestionScreen }
    ExperimentScreen    -> { model | screen <- fromScreen InstructionsScreen }

fromScreen : Screen -> String
fromScreen s = case s of
    QuestionScreen     -> "QuestionScreen"
    InstructionsScreen -> "InstructionsScreen"
    ExperimentScreen   -> "ExperimentScreen"

toScreen : String -> Screen
toScreen s = case s of
    "QuestionScreen"     -> QuestionScreen
    "InstructionsScreen" -> InstructionsScreen
    "ExperimentScreen"   -> ExperimentScreen
    _                    -> QuestionScreen


-- VIEW

view : Model -> Html
view model = case toScreen model.screen of
    QuestionScreen -> div [ class "container" ]
        [ Questionnaire.questionScreen model.questions
        , pageBreak
        , row [ Screens.nextScreenButton ]
        ]
    InstructionsScreen -> div [ class "container" ]
        [ prestiTitle
        , row [ text "Some instructions" ]
        , slider model.sliderPosition
        , row [ Screens.previousScreenButton
              , Sound.replayButton
              , Screens.nextScreenButton
              ]
        ]
    ExperimentScreen -> Experiment.view model.experiment
    _ -> row [ text "unknown screen" ]


-- SIGNALS

main : Signal Html
main = map view model

model : Signal Model
model = foldp update initialModel inputSignal

initialModel : Model
initialModel =
    { screen = "QuestionScreen"
    , questions = Questionnaire.emptyQuestions
    , sliderPosition = 50
    , sound = Sound.emptyModel
    , experiment = Experiment.emptyExperiment
    }

inputSignal : Signal Action
inputSignal = merge (ScreenUpdate <~ subscribe Screens.screenChannel)
    <| merge (QuestionnaireUpdate <~ subscribe Questionnaire.updateChannel)
    <| merge (DragSlider <~ sliderValue)
             (SoundUpdate <~ (Sound.SoundPlayed <~ donePlaying))

soundIdSignal : Signal Int
soundIdSignal = .soundId <~ (.sound <~ model)

playSoundSignal : Signal Bool
playSoundSignal = merge (.playSound <~ (.sound <~ model))
                        (subscribe Sound.soundChannel)
