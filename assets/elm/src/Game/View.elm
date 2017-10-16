module Game.View exposing (..)

import Dict
import Game.Util exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (..)
import Types exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ div [ class "gameapp" ]
            [ div [ class "main" ] <|
                [ canvas
                    [ id (fgId model)
                    , class "gameboard-canvas"
                    , style [ ( "z-index", "1" ) ]
                    ]
                    []
                , canvas
                    [ id (bgId model)
                    , class "gameboard-canvas"
                    ]
                    []
                ]
            , scoreboardView model
            ]
        ]


scoreboardView : Model -> Html Msg
scoreboardView model =
    let
        logoAdvanced =
            "/images/division-advanced.svg"

        logoLight =
            "/images/bs-logo-light.svg"

        lobbyPhaseView lobby =
            lobby.snakes
                |> Dict.values
                |> List.map lobbyItemView
                |> div [ class "scoreboard-snakes" ]

        lobbyItemView snake =
            case snake.loadingState of
                Loading ->
                    flag
                        (avatar "/images/rolling.svg")
                        [ div [] [ text snake.url ]
                        , div [] [ text "loading..." ]
                        ]

                Ready snake ->
                    flag
                        (avatar snake.headUrl)
                        [ div [] [ text snake.name ]
                        , div [] [ text <| Maybe.withDefault "" snake.taunt ]
                        ]

                Failed reason ->
                    flag
                        (avatar "")
                        [ div [] [ text snake.url ]
                        , div [] [ text reason ]
                        ]

        gamePhaseView board =
            div [ class "scoreboard-snakes" ] <|
                List.concat
                    [ List.map (snakeView True) board.snakes
                    , List.map (snakeView False) board.deadSnakes
                    ]
    in
        div [ class "scoreboard" ]
            [ div [ class "scoreboard-header" ]
                [ div []
                    [ img [ src logoLight ] []
                    , img [ src logoAdvanced, class "division-logo" ] []
                    ]
                ]
            , case model.phase of
                LobbyPhase lobby ->
                    lobbyPhaseView lobby

                GamePhase board ->
                    gamePhaseView board

                _ ->
                    text "other"
            , div [ class "controls" ]
                [ a [ href <| editGamePath model.gameid ] [ text "Edit" ]
                , a [ href <| gamesPath ] [ text "Games" ]
                ]
            ]


snakeView : Bool -> Snake -> Html msg
snakeView alive snake =
    let
        healthRemaining =
            (toString snake.health) ++ "%"

        snakeStyle =
            [ ( "background-color", snake.color )
            , ( "width", healthRemaining )
            ]

        props =
            [ classList
                [ ( "scoreboard-snake", True )
                , ( "scoreboard-snake-dead", not alive )
                , ( "scoreboard-snake-alive", alive )
                ]
            ]

        body =
            [ div [ class "healthbar-text" ]
                [ span [] [ text snake.name ]
                , span [] [ text <| toString snake.health ]
                ]
            , div [ style snakeStyle, class "healthbar" ] []
            ]
    in
        div props [ flag (avatar snake.headUrl) body ]


avatar : String -> Html msg
avatar src_ =
    img [ src src_, class "avatar" ] []


flag : Html msg -> List (Html msg) -> Html msg
flag img_ body =
    div [ style [ ( "display", "flex" ), ( "min-height", "60px" ) ] ]
        [ img_
        , div [ style [ ( "flex", "1" ) ] ] body
        ]
