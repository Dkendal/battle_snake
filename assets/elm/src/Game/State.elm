module Game.State exposing (init, update, subscriptions)

import Char
import Debug exposing (..)
import Decoder as Decoder
import Game.Types exposing (..)
import GameBoard
import Json.Decode as JD exposing (decodeValue)
import Json.Encode as JE
import Keyboard
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Phoenix.Socket as Socket
import Task exposing (..)
import Tuple exposing (..)
import Time exposing (..)


fps : Float
fps =
    (Time.second / 60)


init : Flags -> ( Model, Cmd Msg )
init { websocket, gameid } =
    let
        model =
            { socket = socket websocket gameid
            , gameid = gameid
            , gameState = Nothing
            , board = Nothing
            }

        cmds =
            [ emit JoinGameChannel
            ]
    in
        model ! cmds


subscriptions : Model -> Sub Msg
subscriptions { socket } =
    Sub.batch
        [ Socket.listen socket PhxMsg
        , Keyboard.downs KeyDown

        -- , every fps Tick
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        topic =
            "game:" ++ model.gameid

        decodeTick raw =
            case decodeValue Decoder.tick raw of
                Ok gameState ->
                    { model | gameState = Just gameState }
                        ! []

                Err e ->
                    Debug.crash (JE.encode 4 raw)

        updateBroadcast cmd =
            case cmd of
                RecieveTick raw ->
                    decodeTick raw

                LobbyInfo raw ->
                    model ! []

        updateKeyDown code =
            case Char.fromCode code of
                'H' ->
                    model ! [ emit (Push ResumeGame) ]

                'J' ->
                    model ! [ emit (Push NextStep) ]

                'K' ->
                    model ! [ emit (Push PrevStep) ]

                'L' ->
                    model ! [ emit (Push PauseGame) ]

                'Q' ->
                    model ! [ emit (Push StopGame) ]

                _ ->
                    model ! []

        updatePush msg =
            case msg of
                ResumeGame ->
                    push topic "resume" model

                PauseGame ->
                    push topic "pause" model

                StopGame ->
                    push topic "stop" model

                NextStep ->
                    push topic "next" model

                PrevStep ->
                    push topic "prev" model
    in
        case msg of
            Tick time ->
                let
                    board =
                        Maybe.map .board model.gameState
                in
                    { model | board = board } ! []

            Push msg ->
                updatePush msg

            Broadcast msg ->
                updateBroadcast msg

            KeyDown code ->
                updateKeyDown code

            PhxMsg msg ->
                Socket.update msg model.socket
                    |> pushCmd model

            JoinGameChannel ->
                joinChannel topic model

            JoinChannelSuccess _ ->
                model ! []

            JoinChannelFailed error ->
                Debug.crash (toString error)


emit : msg -> Cmd msg
emit msg =
    perform identity (succeed msg)


socket : String -> String -> PhxSock
socket url gameid =
    let
        topic =
            "game:" ++ gameid

        model =
            { gameid = gameid }
    in
        Socket.init url
            |> Socket.on "tick" topic (Broadcast << RecieveTick)
            |> Socket.on "lobbyinfo" topic (Broadcast << LobbyInfo)


{-| Push a command to a topic which will be handled by
BsWeb.GameChannel.handle_in/3 (lib/bs_web/channels/game_channel.ex)
-}
push : String -> String -> Model -> ( Model, Cmd Msg )
push topic cmd model =
    Push.init cmd topic
        |> flip Socket.push model.socket
        |> pushCmd model


pushCmd : Model -> ( PhxSock, Cmd PhxSockMsg ) -> ( Model, Cmd Msg )
pushCmd model ( socket, msg ) =
    ( socket, phxMsg msg )
        |> mapFirst (\x -> { model | socket = x })


joinChannel : String -> Model -> ( Model, Cmd Msg )
joinChannel channel model =
    let
        payload =
            (JE.object [ ( "id", JE.string model.gameid ) ])
    in
        Channel.init channel
            |> Channel.withPayload payload
            |> Channel.onJoin JoinChannelSuccess
            |> Channel.onJoinError JoinChannelFailed
            |> flip Socket.join model.socket
            |> pushCmd model


phxMsg : Cmd PhxSockMsg -> Cmd Msg
phxMsg =
    Cmd.map PhxMsg
