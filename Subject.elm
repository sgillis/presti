module Subject where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Signal (..)

import HtmlConstructs (..)
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
    , row [ Screens.nextScreenButton ]
    ]

subjectField : String -> Html
subjectField val = row
    [ column 3 [ text "Subject ID" ]
    , column 9 [ input [ value val
                       , type' "text"
                       , on "input" targetValue (send updateChannel << Number)
                       , style [("width", "200px")]
                       ] [ ]
               ]
    ]


-- CHANNELS

updateChannel : Channel Update
updateChannel = channel NoOp
