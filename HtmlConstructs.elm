module HtmlConstructs where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Signal (..)
import Graphics.Element (..)
import Graphics.Collage (..)
import Color (..)
import Json.Decode (..)

row : List Html -> Html
row = div [ class "row" ]

column : Int -> List Html -> Html
column size hs = div [ class ("small-" ++ toString size ++ " columns") ] hs

prestiTitle : Html
prestiTitle = row [ h1 [ ] [ text "PreSti" ] ]

pageBreak : Html
pageBreak = row [ hr [] [] ]

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
