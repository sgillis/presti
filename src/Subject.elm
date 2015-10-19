module Subject where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)

import HtmlConstructs exposing (..)
import Screens

-- MODELS

type alias Subject = { number : String }

type Update = NoOp
            | Number String

emptySubject : Subject
emptySubject = { number = "" }


-- UPDATE

update : Update -> Subject -> Subject
update upd subj = case upd of
    NoOp -> subj
    Number x -> { subj | number <- x }


-- VIEW

view : Subject -> Html
view sub = div [ class "container" ]
    [ prestiTitle
    , subjectField sub.number
    , if sub.number /= ""
      then row [ Screens.nextScreenButton ]
      else div [ ] [ ]
    ]

subjectField : String -> Html
subjectField val = row
    [ column 3 [ text "Subject ID" ]
    , column 9 [ input [ value val
                       , type' "text"
                       , on "input" targetValue (message updateChannel.address << Number)
                       , style [("width", "200px")]
                       ] [ ]
               ]
    ]


-- CHANNELS

updateChannel : Mailbox Update
updateChannel = mailbox NoOp

updateSignal = updateChannel.signal