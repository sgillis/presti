module Screens where

import Html exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)


-- MODELS

type Screen = SubjectScreen
            | QuestionScreen
            | InstructionsScreen
            | ExampleScreen
            | PracticeScreen
            | ExperimentScreen
            | SubmitScreen

type alias Model = String

type Update = PreviousScreen
            | NextScreen

initialScreen : Model
initialScreen = fromScreen SubjectScreen

fromScreen : Screen -> String
fromScreen s = case s of
    SubjectScreen      -> "SubjectScreen"
    QuestionScreen     -> "QuestionScreen"
    InstructionsScreen -> "InstructionsScreen"
    ExampleScreen      -> "ExampleScreen"
    PracticeScreen     -> "PracticeScreen"
    ExperimentScreen   -> "ExperimentScreen"
    SubmitScreen       -> "SubmitScreen"

toScreen : String -> Screen
toScreen s = case s of
    "SubjectScreen"      -> SubjectScreen
    "QuestionScreen"     -> QuestionScreen
    "InstructionsScreen" -> InstructionsScreen
    "ExampleScreen"      -> ExampleScreen
    "PracticeScreen"     -> PracticeScreen
    "ExperimentScreen"   -> ExperimentScreen
    "SubmitScreen"       -> SubmitScreen
    _                    -> QuestionScreen


-- UPDATE

update : Update -> Model -> Model
update u model = case u of
    PreviousScreen -> previousScreen model
    NextScreen     -> nextScreen model

previousScreen : Model -> Model
previousScreen model = case toScreen model of
    SubjectScreen      -> fromScreen SubjectScreen
    QuestionScreen     -> fromScreen SubjectScreen
    InstructionsScreen -> fromScreen QuestionScreen
    ExampleScreen      -> fromScreen InstructionsScreen
    PracticeScreen     -> fromScreen ExampleScreen
    ExperimentScreen   -> fromScreen PracticeScreen
    SubmitScreen       -> fromScreen ExperimentScreen
    _                  -> fromScreen QuestionScreen

nextScreen : Model -> Model
nextScreen model = case toScreen model of
    SubjectScreen      -> fromScreen QuestionScreen
    QuestionScreen     -> fromScreen InstructionsScreen
    InstructionsScreen -> fromScreen ExampleScreen
    ExampleScreen      -> fromScreen PracticeScreen
    PracticeScreen     -> fromScreen ExperimentScreen
    ExperimentScreen   -> fromScreen SubmitScreen
    SubmitScreen       -> fromScreen SubmitScreen
    _                  -> fromScreen QuestionScreen

-- previousScreen : Model -> Model
-- previousScreen model = case toScreen model of
--     SubjectScreen      -> fromScreen ExperimentScreen
--     QuestionScreen     -> fromScreen SubjectScreen
--     InstructionsScreen -> fromScreen QuestionScreen
--     ExampleScreen      -> fromScreen InstructionsScreen
--     PracticeScreen     -> fromScreen ExampleScreen
--     ExperimentScreen   -> fromScreen SubjectScreen
--     SubmitScreen       -> fromScreen ExperimentScreen
--     _                  -> fromScreen QuestionScreen

-- nextScreen : Model -> Model
-- nextScreen model = case toScreen model of
--     SubjectScreen      -> fromScreen ExperimentScreen
--     QuestionScreen     -> fromScreen InstructionsScreen
--     InstructionsScreen -> fromScreen ExampleScreen
--     ExampleScreen      -> fromScreen PracticeScreen
--     PracticeScreen     -> fromScreen ExperimentScreen
--     ExperimentScreen   -> fromScreen SubmitScreen
--     SubmitScreen       -> fromScreen SubmitScreen
--     _                  -> fromScreen QuestionScreen




-- VIEW
nextScreenButton : Html
nextScreenButton = button [ onClick screenChannel.address NextScreen ]
                          [ text "Volgende scherm" ]

previousScreenButton : Html
previousScreenButton = button [ onClick screenChannel.address PreviousScreen ]
                              [ text "Vorige scherm" ]


-- CHANNELS

screenChannel : Mailbox Update
screenChannel = mailbox NextScreen

screenAddress = screenChannel.address
screenSignal = screenChannel.signal