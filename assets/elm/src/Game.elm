module Game exposing (..)

import Char
import Debug exposing (..)
import Decoder
import Dict
import GameBoard
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as JD
import Json.Encode as JE
import Keyboard
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Phoenix.Socket as Socket
import Route exposing (..)
import Task exposing (..)
import Tuple exposing (..)
import Types exposing (..)


-- MAIN


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- FLAGS


type alias Flags =
    { websocket : String
    , gameid : String
    }



-- MODEL


type alias Model =
    { socket : Socket.Socket Msg
    , gameid : String
    , board : Maybe Board
    , lobby : Maybe Lobby
    }



-- MSG


type Msg
    = KeyDown Keyboard.KeyCode
    | JoinAdminChannel
    | JoinSpectatorChannel
    | JoinChannelFailed JE.Value
    | JoinChannelSuccess JE.Value
    | MountCanvasApp
    | NextStep
    | PauseGame
    | PhxMsg PhxSockMsg
    | PrevStep
    | ResumeGame
    | StopGame
    | RecieveTick JE.Value
    | ReceiveRestartInit JE.Value
    | ReceiveRestartFinished JE.Value
    | ReceiveRestartRequestError JE.Value
    | ReceiveRestartRequestOk JE.Value


type alias PhxSock =
    Socket.Socket Msg


type alias PhxSockMsg =
    Socket.Msg Msg



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [ class "gameapp" ]
            [ div [ class "main" ] <|
                [ canvas
                    [ id (fgId model)
                    , class "gameboard-canvas"
                    , style fgCanvas
                    ]
                    []
                , canvas
                    [ id (bgId model)
                    , class "gameboard-canvas"
                    ]
                    []
                , div [ class "lobby" ] <|
                    case model.lobby of
                        Nothing ->
                            []

                        Just lobby ->
                            let
                                item snake =
                                    p [] [ text snake.url ]
                            in
                                Dict.values lobby.snakes
                                    |> List.map item
                ]
            , scoreboard model
            ]
        ]


gameboard : Model -> Html msg
gameboard model =
    div
        [ class "main" ]
        [ canvas [ id (fgId model), class "gameboard-canvas", style fgCanvas ] []
        , canvas [ id (bgId model), class "gameboard-canvas" ] []
        ]


logoAdvanced : String
logoAdvanced =
    "/images/division-advanced.svg"


logoLight : String
logoLight =
    "/images/bs-logo-light.svg"


fgCanvas : List ( String, String )
fgCanvas =
    ( "z-index", "1" ) :: []


turn : Model -> String
turn model =
    model.board
        |> Maybe.andThen (.turn >> toString >> Just)
        |> Maybe.withDefault ""


snakesView : Model -> Html msg
snakesView model =
    div [ class "scoreboard-snakes" ] <|
        List.concat
            [ model.board
                |> Maybe.andThen (.snakes >> List.map (snakeView True) >> Just)
                |> Maybe.withDefault []
            , model.board
                |> Maybe.andThen (.deadSnakes >> List.map (snakeView False) >> Just)
                |> Maybe.withDefault []
            ]


scoreboardHeader : Model -> Html msg
scoreboardHeader model =
    let
        turnText =
            ("Turn" ++ " " ++ (turn model))
    in
        div [ class "scoreboard-header" ]
            [ div []
                [ img [ src logoLight ] []
                , img [ src logoAdvanced, class "division-logo" ] []
                , div []
                    [ div []
                        [ span [] [ text model.gameid ] ]
                    , div []
                        [ span [] [ text turnText ]
                        ]
                    ]
                ]
            ]


scoreboard : Model -> Html Msg
scoreboard model =
    div [ class "scoreboard" ]
        [ scoreboardHeader model
        , snakesView model
        , controls model
        ]


controls : Model -> Html Msg
controls model =
    div [ class "controls" ]
        [ a [ href <| editGamePath model.gameid ] [ text "Edit" ]
        , a [ href <| gamesPath ] [ text "Games" ]
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
    in
        div
            [ classList
                [ ( "scoreboard-snake", True )
                , ( "scoreboard-snake-dead", not alive )
                , ( "scoreboard-snake-alive", alive )
                ]
            ]
            [ div [ class "healthbar-text" ]
                [ span [] [ text snake.name ]
                , span [] [ text <| toString snake.health ]
                ]
            , div [ style snakeStyle, class "healthbar" ] []
            ]



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { socket = socket flags.websocket flags.gameid
      , gameid = flags.gameid
      , board = Nothing
      , lobby = Nothing
      }
    , Cmd.batch
        [ emit JoinSpectatorChannel
        , emit JoinAdminChannel
        , emit MountCanvasApp
        ]
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyDown keyCode ->
            case Char.fromCode keyCode of
                'H' ->
                    ( model, emit ResumeGame )

                'J' ->
                    ( model, emit NextStep )

                'K' ->
                    ( model, emit PrevStep )

                'L' ->
                    ( model, emit PauseGame )

                'Q' ->
                    ( model, emit StopGame )

                _ ->
                    noOp model

        PhxMsg msg ->
            Socket.update msg model.socket
                |> pushCmd model

        JoinSpectatorChannel ->
            joinChannel "spectator" model

        JoinAdminChannel ->
            joinChannel "admin" model

        JoinChannelSuccess _ ->
            noOp model

        JoinChannelFailed error ->
            Debug.crash (toString error)

        ResumeGame ->
            adminCmd "resume" model

        PauseGame ->
            adminCmd "pause" model

        StopGame ->
            adminCmd "stop" model

        NextStep ->
            adminCmd "next" model

        PrevStep ->
            adminCmd "prev" model

        ReceiveRestartRequestOk _ ->
            ( { model | lobby = Nothing }, Cmd.none )

        ReceiveRestartRequestError raw ->
            case JD.decodeValue Decoder.error raw of
                Ok error ->
                    ( model, Cmd.none )

                Err e ->
                    Debug.crash e

        ReceiveRestartFinished _ ->
            ( model, Cmd.none )

        ReceiveRestartInit raw ->
            case JD.decodeValue Decoder.lobby raw of
                Ok lobby ->
                    ( { model | lobby = Just lobby }, Cmd.none )

                Err e ->
                    Debug.crash e

        RecieveTick raw ->
            case JD.decodeValue Decoder.tick raw of
                Ok { content } ->
                    ( { model | board = Just content }, GameBoard.draw raw )

                Err e ->
                    Debug.crash e

        MountCanvasApp ->
            ( model
            , GameBoard.mount
                { fgId = fgId model
                , bgId = bgId model
                }
            )



-- SUBS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Socket.listen model.socket PhxMsg
        , Keyboard.downs KeyDown
        ]



-- FUNCTIONS


bgId : Model -> String
bgId { gameid } =
    "bg-" ++ gameid


fgId : Model -> String
fgId { gameid } =
    "fg-" ++ gameid


emit : msg -> Cmd msg
emit msg =
    perform identity (succeed msg)


phxMsg : Cmd PhxSockMsg -> Cmd Msg
phxMsg =
    Cmd.map PhxMsg


pushCmd :
    Model
    -> ( PhxSock, Cmd PhxSockMsg )
    -> ( Model, Cmd Msg )
pushCmd model ( socket, msg ) =
    ( socket, phxMsg msg )
        |> mapFirst (\x -> { model | socket = x })


joinChannel : String -> Model -> ( Model, Cmd Msg )
joinChannel channel model =
    Channel.init channel
        |> Channel.withPayload (JE.object [ ( "id", JE.string model.gameid ) ])
        |> Channel.onJoin JoinChannelSuccess
        |> Channel.onJoinError JoinChannelFailed
        |> flip Socket.join model.socket
        |> pushCmd model


socket : String -> String -> PhxSock
socket url gameid =
    let
        model =
            { gameid = gameid }
    in
        Socket.init url
            |> Socket.on "tick" "spectator" RecieveTick
            |> Socket.on "restart:init" "spectator" ReceiveRestartInit
            |> Socket.on "restart:finished" "spectator" ReceiveRestartFinished
            |> Socket.on "restart:request:error" "spectator" ReceiveRestartRequestError
            |> Socket.on "restart:request:ok" "spectator" ReceiveRestartRequestOk


adminCmd : String -> Model -> ( Model, Cmd Msg )
adminCmd cmd model =
    Push.init cmd "admin"
        |> flip Socket.push model.socket
        |> pushCmd model


noOp : Model -> ( Model, Cmd Msg )
noOp model =
    ( model, Cmd.none )
