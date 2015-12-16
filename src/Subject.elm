module Subject where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)

import HtmlConstructs exposing (..)
import Screens
import String

-- MODELS

type alias Subject = { number : String
                     , listNumber : String
                     }

type Update = NoOp
            | Number String
            | ListNumber String

emptySubject : Subject
emptySubject = { number = ""
               , listNumber = "1"
               }


-- UPDATE

update : Update -> Subject -> Subject
update upd subj = case upd of
    NoOp -> subj
    Number x -> { subj | number = x }
    ListNumber x -> { subj | listNumber = x }


-- VIEW

view : Subject -> Html
view sub = div [ class "container" ]
    [ prestiTitle
    , subjectField sub.number
    , listNumberField
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

listNumberField : Html
listNumberField = row
    [ column 3 [ text "Lijst" ]
    , column 9 [ select [ on "change" targetValue
                             (message updateChannel.address << ListNumber) ]
                        [ option [] [ text "1" ]
                        , option [] [ text "2" ]
                        , option [] [ text "3" ]
                        ]
               ]
    ]


-- CHANNELS

updateChannel : Mailbox Update
updateChannel = mailbox NoOp

updateSignal = updateChannel.signal
