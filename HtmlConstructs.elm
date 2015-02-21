module HtmlConstructs where

import Html (..)
import Html.Attributes (..)

row : List Html -> Html
row = div [ class "row" ]

column : Int -> List Html -> Html
column size hs = div [ class ("small-" ++ toString size ++ " columns") ] hs

prestiTitle : Html
prestiTitle = row [ h1 [ ] [ text "PreSti" ] ]

pageBreak : Html
pageBreak = row [ hr [] [] ]
