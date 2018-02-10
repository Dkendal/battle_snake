module Game.View exposing (..)

import Theme exposing (..)
import Scale exposing (..)
import Css exposing (..)
import Game.Types exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import Game.BoardView
import Md exposing (..)
import Route exposing (..)
import Types exposing (..)


sidebarPlayerHeight =
    ms3


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
                [ model.gameState
                    |> Maybe.map .board
                    |> Maybe.map (Game.BoardView.view False)
                    |> Maybe.withDefault (text "")
                , column [ css [ flexGrow (int 0) ] ]
                    [ div [ css [ alignSelf center ] ] [ text (turn model) ]
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
                ]
            , sidebar model
            ]
        ]


sidebar : Model -> Html Msg
sidebar model =
    let
        container_ board =
            container
                [ css
                    [ overflow auto
                    , Css.property "mask-image" "linear-gradient(rgba(0, 0, 0, 1.0), rgba(0, 0, 0, 1.0), rgba(0, 0, 0, 1.0), rgba(0, 0, 0, 1.0), rgba(0, 0, 0, 1.0), transparent)"
                    ]
                ]
                (List.concat [ List.map snakeView board.snakes ])

        content =
            case model.gameState of
                Nothing ->
                    text "loading..."

                Just { board } ->
                    container_ board
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


snakeView : Snake -> Html msg
snakeView snake =
    let
        alive =
            snake.status == Alive

        healthbarWidth =
            if alive then
                (toString snake.health) ++ "%"
            else
                "0%"

        healthbarStyle =
            [ ( "background-color", snake.color )
            , ( "width", healthbarWidth )
            , ( "transition-property", "width, background-color" )
            , ( "transition-duration", "0.2s" )
            , ( "transition-timing-function", "linear" )
            ]

        healthbar =
            div
                [ style healthbarStyle
                , css [ Css.height (ms_3) ]
                ]
                []

        healthText =
            case snake.status of
                Alive ->
                    (toString snake.health)

                Dead ->
                    "Dead"

                ConnectionFailure ->
                    "Error"

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
        , Css.width sidebarPlayerHeight
        , Css.height sidebarPlayerHeight
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
            , minHeight sidebarPlayerHeight
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
