module Sound where

import Html (..)
import Html.Events (..)
import Signal (..)


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


-- VIEW

replayButton : Html
replayButton = button [ onClick sendPlay ] [ text "Herbeluister" ]


-- CHANNELS

soundChannel : Channel Bool
soundChannel = channel True

sendPlay : Message
sendPlay = send soundChannel True
