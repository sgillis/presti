module Instructions where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (..)

import HtmlConstructs exposing (..)
import Files exposing (..)
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
    , row [ button [ onClick Screens.screenAddress Screens.NextScreen ]
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
                   brabbels bestaan uit twee delen (bv. ti ti). Deze delen
                   kunnen in bepaalde gradaties benadrukt worden.
                   Bijvoorbeeld: er kan veel, weinig of matig nadruk kan op het
                   eerste deel liggen. Hetzelfde kan het geval zijn voor het
                   tweede deel. De nadruk op deel 1 en deel 2 kan verschillen,
                   maar kan ook gelijk zijn.
                   """
            ]
    , p [ ] [ text """
                   Je taak bestaat erin aan te geven hoe de twee delen zich
                   verhouden tegenover elkaar. Dit doe je door het balkje naar
                   links of naar rechts te schuiven.  Wanneer je naar links
                   schuift, wordt het linkerbolletje groter en het
                   rechterbolletje kleiner. Wanneer je naar rechts schuift,
                   gebeurt het omgekeerde. De grootte van de bolletjes is een
                   visuele weergave van de verhouding tussen de twee delen: hoe
                   groter één van de twee bollen, hoe groter het verschil in
                   nadruk tussen de twee delen.  Probeer maar eens uit:
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
                   """
            ]
    , p [ ] [ text """
                   Na deze 6 voorbeelden kan je zelf even oefenen op 20
                   brabbels waarin de nadruk duidelijk te horen is.  Bij de
                   eerste 10 brabbels zal je de boodschap “Dit is niet helemaal
                   juist. Luister nog eens goed?” krijgen, wanneer je het
                   balkje aan de foute kant van de as geplaatst hebt.  Dit wil
                   namelijk zeggen dat je de nadruk niet correct gelokaliseerd
                   hebt. Als het balkje aan de juiste kant staat kan je naar de
                   volgende brabbel gaan.
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
                   tweede deel vallen.  Deze training dient om je te laten
                   wennen aan het feit dat twee delen anders kunnen klinken. In
                   de brabbels die je zal horen in het echte experiment is de
                   nadruk vaak minder duidelijk hoorbaar dan in de oefensessie.
                   In tegenstelling tot de oefenfase, is er dan geen juist of
                   fout antwoord. Tijdens het experiment ga je gewoon af op je
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
                                 starten met het echte experiment. Tijdens het
                                 echte experiment is er geen juist of fout
                                 antwoord en ga je gewoon af op je gehoor. De
                                 balk bovenaan het scherm geeft aan hoe ver je
                                 al gevorderd bent in het experiment. Er staat
                                 geen tijdslimiet op het experiment. Je kan dus
                                 zelf kiezen of je eventjes een pauze wilt
                                 nemen.
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
