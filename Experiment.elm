module Experiment where

import Html (..)
import Html.Attributes (..)

import HtmlConstructs (..)
import Sound

-- MODELS

type alias Experiment =
    { samples : List Int
    , rates : List Int
    , sound : Sound.Model
    }

emptyExperiment : Experiment
emptyExperiment =
    { samples = [1,2,3,4,5]
    , rates = []
    , sound = { soundId = 1, playSound = True }
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
