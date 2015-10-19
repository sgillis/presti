module HtmlConstructs where

import Html exposing (..)
import Html.Attributes exposing (..)

row : List Html -> Html
row = div [ class "row" ]

column : Int -> List Html -> Html
column size hs = div [ class ("small-" ++ toString size ++ " columns") ] hs

prestiTitle : Html
prestiTitle = row [ h1 [ ] [ text "Presti" ]
                  , hr [] []
                  ]

pageBreak : Html
pageBreak = row [ hr [] [] ]
