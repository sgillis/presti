module Screens where

import Html (..)
import Html.Events (..)
import Signal (..)


-- MODELS

type Update = PreviousScreen
            | NextScreen


-- UPDATE

update : Update -> (a -> a) -> (a -> a) -> a -> a
update u previous next model = case u of
    PreviousScreen -> previous model
    NextScreen     -> next model


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
