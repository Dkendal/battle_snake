module Game exposing (..)

import Char
import Debug exposing (..)
import Dict
import Decoder as Decoder
import Game.Types exposing (..)
import Game.View exposing (..)
import GameBoard
import Html exposing (..)
import Json.Decode as JD exposing (decodeValue)
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
            [ emit JoinGameChannel
            ]
    in
        model ! cmds



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        topic =
            "game:" ++ model.gameid

        updateBroadcast cmd =
            case cmd of
                RecieveTick raw ->
                    case decodeValue Decoder.tick raw of
                        Ok ( world, rawWorld ) ->
                            { model | phase = GamePhase world }
                                ! [ GameBoard.render rawWorld ]

                        Err e ->
                            Debug.crash e

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
        topic =
            "game:" ++ gameid

        model =
            { gameid = gameid }
    in
        Socket.init url
            |> Socket.on "tick" topic (Broadcast << RecieveTick)
            |> Socket.on "lobbyinfo" topic (Broadcast << LobbyInfo)


{-| Push a command to a topic.
-}
push : String -> String -> Model -> ( Model, Cmd Msg )
push topic cmd model =
    Push.init cmd topic
        |> flip Socket.push model.socket
        |> pushCmd model
