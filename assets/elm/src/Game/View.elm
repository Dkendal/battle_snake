module Game.View exposing (..)

import Css exposing (..)
import Game.Types exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import Md exposing (..)
import Route exposing (..)
import Types exposing (..)


pallet :
    { blue : Color
    , grey : Color
    , lightgrey : Color
    , pink : Color
    , white : Color
    , yellow : Color
    }
pallet =
    { white = hex "#fcfcfc"
    , lightgrey = hex "#e8e8e8"
    , pink = hex "#f7567c"
    , yellow = hex "#fffae3"
    , blue = hex "#99e1d9"
    , grey = hex "#5d576b"
    }


ms : Float -> Px
ms number =
    Css.px (16 * (1.5 ^ number))


ms_3 : Px
ms_3 =
    ms -3


ms_2 : Px
ms_2 =
    ms -2


ms_1 : Px
ms_1 =
    ms -1


ms0 : Px
ms0 =
    ms 0


ms1 : Px
ms1 =
    ms 1


ms2 : Px
ms2 =
    ms 2


ms3 : Px
ms3 =
    ms 3


ms4 : Px
ms4 =
    ms 4


theme =
    { bgPrimary = pallet.grey
    , bgSecondary = pallet.white
    , sidebarPlayerHeight = ms 3
    , buttonAccent = pallet.lightgrey
    }


sidebarTheme : Style
sidebarTheme =
    batch
        [ backgroundColor theme.bgPrimary
        , color theme.bgSecondary
        ]


view : Model -> Html Msg
view model =
    div []
        [ viewPort []
            [ column
                [ css [ flex auto ] ]
                [ board model
                , div [ css [ alignSelf center ] ] [ text (turn model) ]
                , avControls []
                    [ btn
                        [ onClick (Push PrevStep)
                        , title "Previous turn (k)"
                        ]
                        [ mdSkipPrev ]
                    , btn
                        [ onClick (Push StopGame)
                        , title "Reset Game (q)"
                        ]
                        [ mdReplay ]
                    , playPause model
                    , btn
                        [ onClick (Push NextStep)
                        , title "Next turn (j)"
                        ]
                        [ mdSkipNext ]
                    ]
                ]
            , sidebar model
            ]
        ]


board : Model -> Html msg
board { gameid } =
    container
        [ css
            [ position relative
            , margin ms0
            ]
        ]
        [ div [ id gameid ] []
        ]


sidebar : Model -> Html Msg
sidebar model =
    let
        content =
            case model.gameState of
                Nothing ->
                    text "loading..."

                Just { board } ->
                    container []
                        (List.concat
                            [ List.map (snake True) board.snakes
                            , List.map (snake False) board.deadSnakes
                            ]
                        )
    in
        column
            [ css
                [ padding ms1
                , justifyContent spaceBetween
                , minWidth (px 300)
                , overflowWrap breakWord
                , sidebarTheme
                ]
            ]
            [ content
            , sidebarControls []
                [ a [ href <| editGamePath model.gameid ] [ text "Edit" ]
                , a [ href <| gamesPath ] [ text "Games" ]
                ]
            ]


snake : Bool -> Snake -> Html msg
snake alive snake =
    let
        healthbarWidth =
            if alive then
                (toString snake.health) ++ "%"
            else
                "0%"

        transition =
            Css.batch <|
                if alive then
                    []
                else
                    [ Css.property "transition-property" "width, background-color"
                    , Css.property "transition-duration" "1s"
                    , Css.property "transition-timing-function" "ease"
                    ]

        healthbarStyle =
            [ ( "background-color", snake.color )
            , ( "width", healthbarWidth )
            ]

        healthbar =
            div
                [ style healthbarStyle
                , css [ Css.height (ms_3), transition ]
                ]
                []

        healthText =
            if alive then
                (toString snake.health)
            else
                "Dead"

        containerOpacity =
            if alive then
                1
            else
                0.5
    in
        div
            [ css
                [ marginBottom ms0
                , opacity (num containerOpacity)
                ]
            ]
            [ flag (avatar [ src snake.headUrl ] [])
                [ div
                    [ css
                        [ displayFlex
                        , justifyContent spaceBetween
                        ]
                    ]
                    [ span [] [ text snake.name ]
                    , span [] [ text healthText ]
                    ]
                , healthbar
                ]
            ]


playPause : Model -> Html Msg
playPause { gameState } =
    let
        gameEnded =
            btn [ title "Game ended", Attr.disabled True ] [ mdStop ]
    in
        case gameState of
            Nothing ->
                gameEnded

            Just { status } ->
                case status of
                    Halted ->
                        gameEnded

                    Suspended ->
                        btn
                            [ onClick (Push ResumeGame)
                            , title "Resume game (h)"
                            ]
                            [ mdPause ]

                    Cont ->
                        btn
                            [ onClick (Push PauseGame)
                            , title "Pause game (l)"
                            ]
                            [ mdPlayArrow ]


column : List (Attribute msg) -> List (Html msg) -> Html msg
column =
    styled div
        [ displayFlex
        , flexDirection Css.column
        ]


row : List (Attribute msg) -> List (Html msg) -> Html msg
row =
    styled div
        [ displayFlex
        , flexDirection Css.row
        ]


viewPort : List (Attribute msg) -> List (Html msg) -> Html msg
viewPort =
    styled row [ Css.height (vh 100), Css.width (vw 100) ]


avControls : List (Attribute msg) -> List (Html msg) -> Html msg
avControls =
    styled div [ alignSelf center, flex Css.content, margin ms0 ]


sidebarControls : List (Attribute msg) -> List (Html msg) -> Html msg
sidebarControls =
    styled div
        [ displayFlex
        , justifyContent spaceAround
        ]


avatar : List (Attribute msg) -> List (Html msg) -> Html msg
avatar =
    styled img
        [ marginRight ms0
        , Css.width theme.sidebarPlayerHeight
        , Css.height theme.sidebarPlayerHeight
        ]


container : List (Attribute msg) -> List (Html msg) -> Html msg
container =
    styled div [ flex auto ]


btn : List (Attribute msg) -> List (Html msg) -> Html msg
btn =
    styled button
        [ border inherit
        , outline inherit
        , Css.property "-webkit-appearance" "none"
        , Css.property "-moz-appearance" "none"
        , backgroundColor inherit
        , color inherit
        , cursor pointer
        , Css.disabled
            [ backgroundColor inherit
            , color theme.buttonAccent
            ]
        , hover
            [ backgroundColor theme.buttonAccent ]
        ]


flag : Html msg -> List (Html msg) -> Html msg
flag img_ body =
    div
        [ css
            [ displayFlex
            , minHeight theme.sidebarPlayerHeight
            ]
        ]
        [ img_
        , container [] body
        ]


turn : Model -> String
turn { gameState } =
    case gameState of
        Just { board } ->
            toString board.turn

        Nothing ->
            ""
