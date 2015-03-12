module Presti where

import Html (..)
import Html.Events (..)
import Html.Attributes (..)
import Signal (..)
import Time (..)

import HtmlConstructs (..)
import Files (..)
import Screens
import Sound
import Slider
import Subject
import Questionnaire
import Instructions
import Example
import Experiment

-- MODEL

type Action = NoOp
            | ScreenUpdate Screens.Update
            | SubjectUpdate Subject.Update
            | QuestionnaireUpdate Questionnaire.Update
            | ExampleUpdate Example.Update
            | ExperimentUpdate Experiment.Update
            | SliderUpdate Slider.Update
            | SoundUpdate Sound.Update
            | Submit
            | ModelSent Bool
            | SubmitError Bool
            | Username String
            | Password String
            | SetModel Model
            | Time Float

type alias Model =
    { startDate : Float
    , now : Float
    , screen : Screens.Model
    , subject : Subject.Subject
    , questions : Questionnaire.Questions
    , instructions : Instructions.Instructions
    , example : Example.Experiment
    , experiment : Experiment.Experiment
    , submit : Bool
    , submitE : Bool
    , submitted : Bool
    , username : String
    , password : String
    }

initialModel : Model
initialModel =
    { startDate = 0
    , now = 0
    , screen = Screens.initialScreen
    , subject = Subject.emptySubject
    , questions = Questionnaire.emptyQuestions
    , instructions = Instructions.emptyInstructions
    , example = Example.emptyExperiment
    , experiment = Experiment.emptyExperiment 0
    , submit = False
    , submitE = False
    , submitted = False
    , username = ""
    , password = ""
    }

getSound : Model -> Sound.Model
getSound model = case Screens.toScreen model.screen of
    Screens.InstructionsScreen -> model.instructions.sound
    Screens.ExampleScreen -> model.example.sound
    Screens.ExperimentScreen -> model.experiment.sound
    _ -> Sound.emptyModel


-- UPDATE

update : Action -> Model -> Model
update action model = case action of
    NoOp -> model
    ScreenUpdate u -> { model | screen <- Screens.update u model.screen }
    SubjectUpdate update ->
        { model | subject <- Subject.update update model.subject }
    QuestionnaireUpdate update ->
        { model | questions <- Questionnaire.update update model.questions }
    ExampleUpdate update ->
        { model | example <- Example.update update model.example }
    ExperimentUpdate update ->
        { model | experiment <- Experiment.update update model.experiment }
    SliderUpdate update -> updateSlider update model
    SoundUpdate update -> updateSound update model
    Submit -> { model | submit <- True }
    ModelSent True -> { model | submit <- False
                              , submitted <- True
                              , password <- "" }
    SubmitError x -> { model | submitE <- x }
    Username x -> { model | username <- x }
    Password x -> { model | password <- x }
    SetModel m -> m
    Time x -> if model.startDate == 0
              then { model | startDate <- x
                           , now <- x
                           , experiment <- Experiment.emptyExperiment (round x) }
              else { model | now <- x }
    _ -> model

updateSound : Sound.Update -> Model -> Model
updateSound u model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> model
    Screens.InstructionsScreen ->
        let ins = model.instructions
            newIns = { ins | sound <- Sound.update u ins.sound }
        in { model | instructions <- newIns }
    Screens.ExampleScreen ->
        let ex = model.example
            newEx = { ex | sound <- Sound.update u ex.sound }
        in { model | example <- newEx }
    Screens.ExperimentScreen ->
        let exp = model.experiment
            newExp = { exp | sound <- Sound.update u exp.sound }
        in { model | experiment <- newExp }
    _ -> model

updateSlider : Slider.Update -> Model -> Model
updateSlider u model = case Screens.toScreen model.screen of
    Screens.QuestionScreen -> model
    Screens.InstructionsScreen ->
        let ins = model.instructions
            newIns = { ins | slider <- Slider.update u ins.slider }
        in { model | instructions <- newIns }
    Screens.ExperimentScreen -> case u of
        Slider.DragSlider x ->
            { model | experiment <- Experiment.update
                                    (Experiment.SliderUpdate x)
                                    model.experiment }
        _ -> model
    _ ->  model


-- VIEW

view : Model -> Html
view model = case Screens.toScreen model.screen of
    Screens.SubjectScreen -> Subject.view model.subject
    Screens.QuestionScreen -> Questionnaire.view model.questions
    Screens.InstructionsScreen -> Instructions.view model.instructions
    Screens.ExampleScreen -> Example.view model.example
    Screens.ExperimentScreen -> Experiment.view model.experiment
    Screens.SubmitScreen -> submitView model
    _ -> row [ text "unknown screen" ]

submitView : Model -> Html
submitView model = div [ class "container" ]
    [ audioHtml experimentAudio
    , prestiTitle
    , usernameField model.username
    , passwordField model.password
    , row [ button [ onClick (send actionChannel Submit) ]
                   [ text "Submit data" ] ]
    , if model.submitted
      then submissionComplete model
      else div [ ] [ ]
    ]

submissionComplete : Model -> Html
submissionComplete model =
    if model.submitE
    then row [ text """
Er ging iets mis bij het doorsturen. Kopieer onderstaande data naar de harde
schijf en contacteer de administrator
"""
             , pageBreak
             , text <| toString model ]
    else row [ text "Data is doorgestuurd" ]

usernameField : String -> Html
usernameField val = row
    [ column 3 [ text "Username" ]
    , column 9 [ input [ value val
                       , type' "text"
                       , on "input" targetValue (send actionChannel << Username)
                       , style [("width", "200px")]
                       ] [ ]
               ]
    ]

passwordField : String -> Html
passwordField val = row
    [ column 3 [ text "Password" ]
    , column 9 [ input [ value val
                       , type' "password"
                       , on "input" targetValue (send actionChannel << Password)
                       , style [("width", "200px")]
                       ] [ ]
               ]
    ]

-- SIGNALS

main : Signal Html
main = map view model

model : Signal Model
model = foldp update initialModel inputSignal

inputSignal : Signal Action
inputSignal =
    merge (subscribe actionChannel)
 <| merge (ScreenUpdate <~ subscribe Screens.screenChannel)
 <| merge (SubjectUpdate <~ subscribe Subject.updateChannel)
 <| merge (QuestionnaireUpdate <~ subscribe Questionnaire.updateChannel)
 <| merge (SliderUpdate <~ (Slider.DragSlider <~ sliderValue))
 <| merge (SoundUpdate <~ (Sound.SoundPlayed <~ donePlaying))
 <| merge (ExampleUpdate <~ subscribe Example.exampleChannel)
 <| merge (ExperimentUpdate <~ subscribe Experiment.experimentChannel)
 <| merge (ModelSent <~ modelSent)
 <| merge (SubmitError <~ submitError)
 <| merge (SetModel <~ setModel)
          (Time <~ currentTime)

soundIdSignal : Signal Int
soundIdSignal = .soundId <~ (getSound <~ model)

playSoundSignal : Signal Bool
playSoundSignal = merge (.playSound <~ (getSound <~ model))
                        (subscribe Sound.soundChannel)


-- CHANNELS

actionChannel : Channel Action
actionChannel = channel NoOp


-- PORTS

port soundId : Signal Int
port soundId = soundIdSignal

port playSound : Signal Bool
port playSound = playSoundSignal

port donePlaying : Signal Bool

port refreshFoundation : Signal Float
port refreshFoundation = every second

port sliderValue : Signal Int

port elmModel : Signal Model
port elmModel = model

port modelSent : Signal Bool

port submitError : Signal Bool

port setModel : Signal Model

port currentTime : Signal Float
