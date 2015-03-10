module Screens where

import Html (..)
import Html.Events (..)
import Signal (..)


-- MODELS

type Screen = SubjectScreen
            | QuestionScreen
            | InstructionsScreen
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
    ExperimentScreen   -> "ExperimentScreen"
    SubmitScreen   -> "SubmitScreen"

toScreen : String -> Screen
toScreen s = case s of
    "SubjectScreen"      -> SubjectScreen
    "QuestionScreen"     -> QuestionScreen
    "InstructionsScreen" -> InstructionsScreen
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
    ExperimentScreen   -> fromScreen InstructionsScreen
    SubmitScreen       -> fromScreen ExperimentScreen
    _                  -> fromScreen QuestionScreen

nextScreen : Model -> Model
nextScreen model = case toScreen model of
    SubjectScreen      -> fromScreen QuestionScreen
    QuestionScreen     -> fromScreen InstructionsScreen
    InstructionsScreen -> fromScreen ExperimentScreen
    ExperimentScreen   -> fromScreen SubmitScreen
    SubmitScreen       -> fromScreen SubmitScreen
    _                  -> fromScreen QuestionScreen


-- VIEW
nextScreenButton : Html
nextScreenButton = button [ onClick (send screenChannel NextScreen) ]
                          [ text "Volgende scherm" ]

previousScreenButton : Html
previousScreenButton = button [ onClick (send screenChannel PreviousScreen) ]
                              [ text "Vorige scherm" ]


-- CHANNELS

screenChannel : Channel Update
screenChannel = channel NextScreen
