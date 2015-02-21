module Experiment where

import Html (..)
import Html.Attributes (..)

import HtmlConstructs (..)

-- MODELS

type alias Experiment =
    { sounds : List Int
    , rates : List Int
    , currentSound : Int
    }

emptyExperiment : Experiment
emptyExperiment =
    { sounds = [1,2,3,4,5]
    , rates = []
    , currentSound = 1
    }

type Update = NoOp


-- UPDATE

update : Update -> Experiment -> Experiment
update upd exp = case upd of
    NoOp -> exp


-- VIEW

view : Experiment -> Html
view exp = div [ class "container" ]
    [ prestiTitle
    , slider 50
    ]

-- UTILS
(!) : List a -> Int -> Maybe a
xs ! n = case xs of
    [] -> Nothing
    (x :: xs) -> Just x
    (x :: xs) -> xs ! (n-1)
