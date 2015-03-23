module Instructions where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Signal (..)

import HtmlConstructs (..)
import Files (..)
import Screens
import Sound
import Slider


-- MODELS

type alias Instructions =
    { sound : Sound.Model
    , slider : Slider.Model
    }

type Update = NoOp

emptyInstructions : Instructions
emptyInstructions =
    { sound  = { soundId = 0, playSound = True }
    , slider = 50
    }


-- UPDATE


-- VIEW

view : Instructions -> Html
view model = div [ class "container" ]
    [ audioHtml trialAudio
    , prestiTitle
    , instructions1
    , Slider.slider model.slider
    , instructions2
    , pageBreak
    , instructions3
    , row [ button [ onClick (send Screens.screenChannel Screens.NextScreen) ]
                   [ text "Start" ]
          ]
    ]

instructions1 : Html
instructions1 = row
    [ p [ ] [ text """
                   In het experiment waar je zo meteen aan deelneemt, zal je
                   betekenisloze brabbels van kinderen te horen krijgen.
                   """
            ]
    , p [ ] [ text """

                   Deze
                   brabbels bestaan uit twee delen (bv. ba ba). Deze delen
                   kunnen in bepaalde gradaties benadrukt worden.
                   Bijvoorbeeld: er kan veel, weinig of matig nadruk kan op het
                   eerste deel liggen. Hetzelfde kan het geval zijn voor het
                   tweede deel. De nadruk op deel 1 en deel 2 kan verschillen,
                   maar kan ook gelijk zijn.
                   """
            ]
    , p [ ] [ text """
                   Je taak bestaat erin aan te geven
                   waar de nadruk ligt en hoe sterk deze nadruk is. Dit doe je
                   door het balkje naar links of naar rechts te schuiven.
                   Wanneer je naar links schuift, wordt het linkerbolletje
                   groter en het rechterbolletje kleiner. Wanneer je naar
                   rechts schuift, gebeurt het omgekeerde. De grootte van de
                   bolletjes is een visuele weergave van de nadruk die je hoort
                   op elk deel: hoe groter hoe meer nadruk.  Probeer maar eens
                   uit:
                   """
            ]
    ]

instructions2 : Html
instructions2 = row
    [ p [ ] [ text """
                   Als je de brabbel nog eens wilt beluisteren druk je op
                   volgende knop:
                   """
            ]
    , Sound.replayButton
    , p [ ] [ text """
                   In totaal kan je de brabbel maximaal 3 keer beluisteren.
                   """
            ]
    ]

instructions3 : Html
instructions3 = row
    [ p [ ] [ text """
                   Voor we aan de slag gaan, laten we je eerst 6 voorbeelden
                   zien en horen. Je zal telkens een brabbel horen en je zal
                   zien hoe het balkje in de juiste positie geschoven wordt.
                   Jij zal op dezelfde manier tewerk moeten gaan in het
                   experiment.
                   """
            ]
    , p [ ] [ text """
                   Na deze 6 voorbeelden kan je zelf even oefenen op 20
                   brabbels waarin de nadruk duidelijk te horen is. Bij de
                   eerste 10 brabbels zal je de boodschap “probeer opnieuw”
                   krijgen, als je het balkje aan de foute kant van de as
                   geplaatst hebt. Dit wil namelijk zeggen dat je de nadruk
                   niet correct gelokaliseerd hebt. Als je balkje aan de
                   juiste kant staat kan je naar de volgende brabbel gaan.
                   """
            ]
    , p [ ] [ text """
                   Bij de laatste 10 brabbels uit de oefenfase zal je geen
                   herkansing meer krijgen en moet je zelf de nadruk weten te
                   lokaliseren. Als je dat lukt, mag je aan het eigenlijke
                   experiment beginnen.
                   """
            ]
    , p [ ] [ text """
                   Het eigenlijke experiment zal er exact hetzelfde uitzien als
                   in deze oefenfase.
                   """
            ]
    , p [ ] [ b [ ] [ text "Belangrijk!" ]
            , text """
                   In de oefenfase zal de nadruk duidelijk op het eerste of het
                   tweede deel vallen. Of de nadruk zal gelijk zijn op beide
                   delen. Deze training dient om je te laten wennen aan het
                   feit dat twee delen anders kunnen klinken. In de brabbels
                   die je zal horen in het echte experiment is de nadruk vaak
                   minder duidelijk hoorbaar dan in de oefensessie. In
                   tegenstelling tot de oefenfase, is er dan geen juist of fout
                   antwoord. Tijdens het experiment ga je gewoon af op je
                   intuïtie. Wat jij hoort is voor ons belangrijk.
                   """
            ]
    , p [ ] [ b [ ] [ text "Kort samengevat:" ]
            , ul [ ] [ li [ ] [ text """
                                     We tonen je eerst 6 voorbeelden zodanig
                                     dat  je eens kan horen en zien hoe je te
                                     werk moet gaan
                                     """
                              ]
                     , li [ ]
                          [ text """
                                 Dan begint de oefenfase die bestaat uit de
                                 beoordeling van 20 duidelijke
                                 oefenbrabbels:
                                 """
                          , ul [ ] [ li [ ]
                                        [ text """
                                               Bij de eerste 10 kan je enkel
                                               doorgaan wanneer het balkje in
                                               de juiste positie staat.
                                               """
                                        ]
                                   , li [ ]
                                        [ text """
                                               Bij de laatste 10 krijg je geen
                                               feedback meer.
                                               """
                                        ]
                                   ]
                          ]
                     , li [ ]
                          [ text """
                                 Als je geslaagd bent in de oefening mag je
                                 starten met het echte experiment. Hier is er
                                 geen juist of fout antwoord en ga je gewoon af
                                 op je gehoor.
                                 """
                          ]
                     ]
            ]
    , p [ ] [ text """
                   Heb je nog vragen? Spreek dan nu even de begeleider aan.
                   """
            ]
    , p [ ] [ text """
                   Ben je klaar om de voorbeelden te bekijken? Druk op start.
                   """
            ]
    ]
