module Game exposing (..)

import Char
import Debug exposing (..)
import Decoder
import Dict
import Game.View exposing (..)
import Game.Util exposing (..)
import GameBoard
import Html exposing (..)
import Json.Decode as JD
import Json.Encode as JE
import Keyboard
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Phoenix.Socket as Socket
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



-- VIEW


empty : Html Msg
empty =
    text ""



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { socket = socket flags.websocket flags.gameid
            , gameid = flags.gameid
            , phase = InitPhase
            }

        cmds =
            [ emit JoinSpectatorChannel
            , emit JoinAdminChannel
            , emit MountCanvasApp
            ]
    in
        model ! cmds



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (log "msg" msg) of
        KeyDown keyCode ->
            case Char.fromCode keyCode of
                'H' ->
                    model ! [ emit ResumeGame ]

                'J' ->
                    model ! [ emit NextStep ]

                'K' ->
                    model ! [ emit PrevStep ]

                'L' ->
                    model ! [ emit PauseGame ]

                'Q' ->
                    model ! [ emit StopGame ]

                _ ->
                    model ! []

        PhxMsg msg ->
            Socket.update msg model.socket
                |> pushCmd model

        JoinSpectatorChannel ->
            joinChannel "spectator" model

        JoinAdminChannel ->
            joinChannel "admin" model

        JoinChannelSuccess _ ->
            model ! []

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

        ReceiveRestartRequestOk raw ->
            case JD.decodeValue (Decoder.lobbySnake) raw of
                Ok { snakeId, data } ->
                    let
                        updateSnake snake =
                            { snake | loadingState = Ready data }

                        model_ =
                            updateLobbyMember updateSnake model snakeId
                    in
                        model_ ! []

                Err err ->
                    Debug.crash err

        ReceiveRestartRequestError raw ->
            case JD.decodeValue Decoder.error raw of
                Ok { snakeId, data } ->
                    let
                        updateSnake snake =
                            { snake | loadingState = Failed data }

                        model_ =
                            updateLobbyMember updateSnake model snakeId
                    in
                        model_ ! []

                Err e ->
                    Debug.crash e

        ReceiveRestartFinished _ ->
            model ! []

        ReceiveRestartInit raw ->
            case JD.decodeValue Decoder.lobby raw of
                Ok lobby ->
                    { model | phase = LobbyPhase lobby } ! []

                Err e ->
                    Debug.crash e

        RecieveTick raw ->
            case JD.decodeValue Decoder.tick raw of
                Ok { content } ->
                    { model | phase = GamePhase content } ! [ GameBoard.draw raw ]

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


emit : msg -> Cmd msg
emit msg =
    perform identity (succeed msg)


phxMsg : Cmd PhxSockMsg -> Cmd Msg
phxMsg =
    Cmd.map PhxMsg


pushCmd : Model -> ( PhxSock, Cmd PhxSockMsg ) -> ( Model, Cmd Msg )
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


updateLobbyMember : (Permalink -> Permalink) -> Model -> String -> Model
updateLobbyMember update model id =
    let
        updateSnakes snakes =
            Dict.update id (Maybe.map update) snakes

        updateLobby lobby =
            { lobby | snakes = updateSnakes lobby.snakes }

        phase =
            case model.phase of
                LobbyPhase lobby ->
                    LobbyPhase (updateLobby lobby)

                x ->
                    x
    in
        { model | phase = phase }
