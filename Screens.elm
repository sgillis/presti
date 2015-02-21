module Screens where

import Html (..)
import Html.Events (..)
import Signal (..)


-- MODELS

type Screen = QuestionScreen
            | InstructionsScreen
            | ExperimentScreen

type alias Model = String

type Update = PreviousScreen
            | NextScreen

initialScreen : Model
initialScreen = fromScreen QuestionScreen

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


-- UPDATE

update : Update -> Model -> Model
update u model = case u of
    PreviousScreen -> previousScreen model
    NextScreen     -> nextScreen model

previousScreen : Model -> Model
previousScreen model = case toScreen model of
    QuestionScreen     -> fromScreen QuestionScreen
    InstructionsScreen -> fromScreen QuestionScreen
    ExperimentScreen   -> fromScreen InstructionsScreen

nextScreen : Model -> Model
nextScreen model = case toScreen model of
    QuestionScreen     -> fromScreen InstructionsScreen
    InstructionsScreen -> fromScreen ExperimentScreen
    ExperimentScreen   -> fromScreen ExperimentScreen


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
