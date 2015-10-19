module Questionnaire where

import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)
import List
import String exposing (toInt)

import HtmlConstructs exposing (..)
import Screens


-- MODELS

type alias Questions =
    { leeftijd : String
    , geslacht : String
    , vraag1 : String
    , opmerking1 : String
    , vraag2 : String
    , opmerking2 : String
    , vraag3 : String
    , opmerking3 : String
    , vraag4 : String
    , opmerking4 : String
    , vraag5 : String
    , opmerking5 : String
    , vraag6 : String
    , opmerking6 : String
    , vraag7 : String
    , opmerking7 : String
    , vraag8 : String
    , opmerking8 : String
    , vraag9 : String
    , opmerking9 : String
    , vraag10 : String
    , opmerking10 : String
    , vraag11 : String
    , errors: ValidationErrors
    }

emptyQuestions : Questions
emptyQuestions =
    { leeftijd = ""
    , geslacht = ""
    , vraag1 = ""
    , opmerking1 = ""
    , vraag2 = ""
    , opmerking2 = ""
    , vraag3 = ""
    , opmerking3 = ""
    , vraag4 = ""
    , opmerking4 = ""
    , vraag5 = ""
    , opmerking5 = ""
    , vraag6 = ""
    , opmerking6 = ""
    , vraag7 = ""
    , opmerking7 = ""
    , vraag8 = ""
    , opmerking8 = ""
    , vraag9 = ""
    , opmerking9 = ""
    , vraag10 = ""
    , opmerking10 = ""
    , vraag11 = ""
    , errors = emptyValidationErrors
    }

validateModel : Questions -> Bool
validateModel q =
    let isInt s = case toInt s of
                       Ok x -> True
                       Err x -> False
    in if (  isInt q.leeftijd
          && q.geslacht /= ""
          && q.vraag1 /= ""
          && q.vraag2 /= ""
          && q.vraag3 /= ""
          && q.vraag4 /= ""
          && q.vraag5 /= ""
          && q.vraag6 /= ""
          && q.vraag7 /= ""
          && q.vraag8 /= ""
          && q.vraag9 /= ""
          && q.vraag10 /= ""
          && q.vraag11 /= ""
          )
       then True
       else False

setValidationErrors : Questions -> Questions
setValidationErrors q =
    let isInt s = case toInt s of
                       Ok x -> True
                       Err x -> False
        newErrors =
            { emptyValidationErrors | leeftijd <- not (isInt q.leeftijd)
                                    , geslacht <- q.geslacht == ""
                                    , vraag1 <- q.vraag1 == ""
                                    , vraag2 <- q.vraag2 == ""
                                    , vraag3 <- q.vraag3 == ""
                                    , vraag4 <- q.vraag4 == ""
                                    , vraag5 <- q.vraag5 == ""
                                    , vraag6 <- q.vraag6 == ""
                                    , vraag7 <- q.vraag7 == ""
                                    , vraag8 <- q.vraag8 == ""
                                    , vraag9 <- q.vraag9 == ""
                                    , vraag10 <- q.vraag10 == ""
                                    , vraag11 <- q.vraag11 == "" }
    in { q | errors <- newErrors }

type alias ValidationErrors =
    { leeftijd : Bool
    , geslacht : Bool
    , vraag1 : Bool
    , vraag2 : Bool
    , vraag3 : Bool
    , vraag4 : Bool
    , vraag5 : Bool
    , vraag6 : Bool
    , vraag7 : Bool
    , vraag8 : Bool
    , vraag9 : Bool
    , vraag10 : Bool
    , vraag11 : Bool
    }

emptyValidationErrors : ValidationErrors
emptyValidationErrors =
    { leeftijd = False
    , geslacht = False
    , vraag1 = False
    , vraag2 = False
    , vraag3 = False
    , vraag4 = False
    , vraag5 = False
    , vraag6 = False
    , vraag7 = False
    , vraag8 = False
    , vraag9 = False
    , vraag10 = False
    , vraag11 = False
    }

type Update = NoOp
            | Leeftijd String
            | Geslacht String
            | Vraag1 String
            | Opmerking1 String
            | Vraag2 String
            | Opmerking2 String
            | Vraag3 String
            | Opmerking3 String
            | Vraag4 String
            | Opmerking4 String
            | Vraag5 String
            | Opmerking5 String
            | Vraag6 String
            | Opmerking6 String
            | Vraag7 String
            | Opmerking7 String
            | Vraag8 String
            | Opmerking8 String
            | Vraag9 String
            | Opmerking9 String
            | Vraag10 String
            | Opmerking10 String
            | Vraag11 String
            | TrySend


-- UPDATE

update : Update -> Questions -> Questions
update u q = case u of
    NoOp            -> q
    Leeftijd str    -> { q | leeftijd    <- str }
    Geslacht str    -> { q | geslacht    <- str }
    Vraag1 str      -> { q | vraag1      <- str }
    Opmerking1 str  -> { q | opmerking1  <- str }
    Vraag2 str      -> { q | vraag2      <- str }
    Opmerking2 str  -> { q | opmerking2  <- str }
    Vraag3 str      -> { q | vraag3      <- str }
    Opmerking3 str  -> { q | opmerking3  <- str }
    Vraag4 str      -> { q | vraag4      <- str }
    Opmerking4 str  -> { q | opmerking4  <- str }
    Vraag5 str      -> { q | vraag5      <- str }
    Opmerking5 str  -> { q | opmerking5  <- str }
    Vraag6 str      -> { q | vraag6      <- str }
    Opmerking6 str  -> { q | opmerking6  <- str }
    Vraag7 str      -> { q | vraag7      <- str }
    Opmerking7 str  -> { q | opmerking7  <- str }
    Vraag8 str      -> { q | vraag8      <- str }
    Opmerking8 str  -> { q | opmerking8  <- str }
    Vraag9 str      -> { q | vraag9      <- str }
    Opmerking9 str  -> { q | opmerking9  <- str }
    Vraag10 str     -> { q | vraag10     <- str }
    Opmerking10 str -> { q | opmerking10 <- str }
    Vraag11 str     -> { q | vraag11     <- str }
    TrySend         -> setValidationErrors q


-- VIEW
view : Questions -> Html
view q = div [ class "container" ]
    [ questions q
    , pageBreak
    , if validateModel q
      then row [ Screens.nextScreenButton ]
      else row [ button [ onClick updateChannel.address TrySend ]
                        [ text "Volgende scherm" ]
               ]
    ]

questions : Questions -> Html
questions q =
    div [ class "questions" ]
        [ prestiTitle
        , inputField q.errors.leeftijd "Leeftijd" q.leeftijd Leeftijd
        , selectionField [("m", "Man"), ("v", "Vrouw")] q.errors.geslacht
                         "Geslacht" "geslacht" q.geslacht Geslacht
        , row [ hr [] [] ]
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag1
            "Heb je gehoorproblemen? (Bv. oorsuizingen, hardhorigheid, ...)"
            "vraag1" q.vraag1 Vraag1
        , commentsField q.opmerking1 Opmerking1
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag2
            "Heeft iemand in je familie gehoorproblemen?"
            "vraag2" q.vraag2 Vraag2
        , commentsField q.opmerking2 Opmerking2
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag3
            "Ben je de laatste 24u gaan zwemmen?"
            "vraag3" q.vraag3 Vraag3
        , commentsField q.opmerking3 Opmerking3
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag4
            "Ben je de afgelopen 24u naar een feest of een concert geweest?"
            "vraag4" q.vraag4 Vraag4
        , commentsField q.opmerking4 Opmerking4
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag5
            "Ben je verkouden of heb je een oorontsteking?"
            "vraag5" q.vraag5 Vraag5
        , commentsField q.opmerking5 Opmerking5
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag6
            "Heb je recent een oorontsteking of verkoudheid gehad?"
            "vraag6" q.vraag6 Vraag6
        , commentsField q.opmerking6 Opmerking6
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag7
            "Heb je andere problemen die tot gehoorverlies kunnen leiden?"
            "vraag7" q.vraag7 Vraag7
        , commentsField q.opmerking7 Opmerking7
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag8
            "Ben je ooit gediagnosticeerd met een ontwikkelingsstoornis (zoals autisme, dyslexie, dyspraxie, taalstoornis, ...)?"
            "vraag8" q.vraag8 Vraag8
        , commentsField q.opmerking8 Opmerking8
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag9
            "Heb je een taalkundige achtergrond (beroep, opleiding, ...)?"
            "vraag9" q.vraag9 Vraag9
        , commentsField q.opmerking9 Opmerking9
        , selectionField [("y", "Ja"), ("n", "Nee")] q.errors.vraag10
            "Heb je een fonetische achtergrond?"
            "vraag10" q.vraag10 Vraag10
        , commentsField q.opmerking10 Opmerking10
        , selectionField [ ("a", "Nooit")
                         , ("b", "Een keer per jaar")
                         , ("c", "Een paar keer per jaar")
                         , ("d", "Een keer per maand")
                         , ("e", "Een paar keer per maand")
                         , ("f", "Elke week")
                         , ("g", "Dagelijks")
                         ]
            q.errors.vraag11
            "Hoe vaak kom je met kinderen tussen de 0 en 2 jaar in aanraking?"
            "vraag11" q.vraag11 Vraag11
        ]

inputField : Bool -> String -> String -> (String -> Update) -> Html
inputField error desc val toUpdate = row
    [ column 6 [ span [ getValidationErrorColor error ] [ text desc ] ]
    , column 6 [ input
                  [ value val
                  , type' "text"
                  , on "input" targetValue (message updateChannel.address << toUpdate)
                  , style [ ("width", "100px") ]
                  ] [ ]
                ]
    ]

commentsField : String -> (String -> Update) -> Html
commentsField val toUpdate = row
    [ column 6 [ text "Opmerkingen" ]
    , column 6 [ textarea
                 [ value val
                 , on "input" targetValue (message updateChannel.address << toUpdate)
                 ] [ ]
               ] ]

selectionField : List (String, String) -> Bool -> String -> String -> String ->
                 (String -> Update) -> Html
selectionField options error desc n val toUpdate = row
    [ column 6 [ span [ getValidationErrorColor error ] [ text desc ] ]
    , column 6 (List.map (createInput n toUpdate val) options)
    ]

createInput : String -> (String -> Update) -> String -> (String, String) -> Html
createInput n toUpdate curVal (val, desc) = div [ class "input" ]
    [ input [ type' "radio", name n, value val
            , on "change" targetValue (message updateChannel.address << toUpdate)
            , checked (val==curVal) ]
            [ ]
    , text desc
    ]

getValidationErrorColor : Bool -> Attribute
getValidationErrorColor b =
    if b
    then style [("color", "red")]
    else style [("color", "black")]


-- CHANNELS
updateChannel : Mailbox Update
updateChannel = mailbox NoOp

updateSignal = updateChannel.signal