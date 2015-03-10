module Slider where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Color (..)
import Graphics.Element (..)
import Graphics.Collage (..)

import HtmlConstructs (..)
import Sound


-- MODELS

type alias Model = Int

type Update = NoOp
            | DragSlider Int

emptySlider : Model
emptySlider = 0


-- UPDATE

update : Update -> Model -> Model
update u s = case u of
    NoOp -> s
    DragSlider x -> x


-- VIEW
slider : Int -> Html
slider size =
    div [ ]
    [ row [ div [ style [("margin", "auto"), ("width", "405px")] ] [ fromElement <|
                collage 405 205 [ leftCircle (101-size), rightCircle (size+1) ] ] ]
    , row [ div [ class "small-12 columns" ]
                [ div [ class "range-slider"
                      , attribute "data-slider" (toString size)
                      , id "slider"
                      ]
                      [ span [ class "range-slider-handle" ] [ ]
                      , span [ class "range-slider-active-segment" ] [ ]
                      , input [ hidden True ] [ ]
                      ]
                ]
          ]
    ]

leftCircle : Int -> Form
leftCircle x = moveX (-100) <| filled blue <| circle (toFloat x)

rightCircle : Int -> Form
rightCircle x = moveX (100) <| filled blue <| circle (toFloat x)
