module Sound where

import Html exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)


-- MODELS

type alias Model =
    { soundId : Int
    , playSound : Bool
    }

emptyModel =
    { soundId = 0
    , playSound = False
    }

type Update = NoOp
            | SoundPlayed Bool


-- UPDATE

update : Update -> Model -> Model
update u m = case u of
    NoOp              -> m
    SoundPlayed True  -> { m | playSound <- False }
    SoundPlayed False -> { m | playSound <- True }

playSound : Int -> Model -> Model
playSound x model = { model | soundId <- x
                            , playSound <- True }

repeatSound : Model -> Model
repeatSound model = { model | playSound <- True }

setSound : Int -> Model -> Model
setSound x model = { model | soundId <- x }


-- VIEW

replayButton : Html
replayButton = button [ onClick soundChannel.address True ] [ text "Herbeluister" ]


-- CHANNELS

soundChannel : Mailbox Bool
soundChannel = mailbox True

soundSignal = soundChannel.signal