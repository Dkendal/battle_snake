module GameApp exposing (..)

import Char
import GameBoard
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD
import Json.Encode as JE
import Keyboard
import Phoenix.Channel as Channel
import Phoenix.Socket as Socket
import Phoenix.Push as Push
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


view : Model -> Html Msg
view model =
    div [ class "gameboard" ]
        [ canvas
            [ id (bgId model), width 1920, height 1920 ]
            []
        , canvas
            [ id (fgId model), width 1920, height 1920 ]
            []
        ]



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { socket = socket flags.websocket flags.gameid
      , gameid = flags.gameid
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
    case Debug.log "Update" msg of
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
                    ( model, Cmd.none )

        PhxMsg msg ->
            Socket.update msg model.socket
                |> pushCmd model

        JoinSpectatorChannel ->
            spectatorChannel model
                |> flip joinChannel model

        JoinAdminChannel ->
            adminChannel model
                |> flip joinChannel model

        JoinChannelSuccess _ ->
            noOp model

        JoinChannelFailed _ ->
            noOp model

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

        Tick raw ->
            ( model, GameBoard.draw raw )

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


adminChannel : Model -> String
adminChannel model =
    "game_admin:" ++ model.gameid


spectatorChannel : Model -> String
spectatorChannel model =
    "spectator:" ++ model.gameid


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
    channel
        |> Channel.init
        |> Channel.onJoin JoinChannelSuccess
        |> Channel.onJoinError JoinChannelFailed
        |> flip Socket.join model.socket
        |> pushCmd model


socket : String -> String -> PhxSock
socket url gameid =
    Socket.init url
        |> Socket.on "tick" ("spectator:" ++ gameid) Tick


adminCmd : String -> Model -> ( Model, Cmd Msg )
adminCmd cmd model =
    adminChannel model
        |> Push.init cmd
        |> flip Socket.push model.socket
        |> pushCmd model


noOp : Model -> ( Model, Cmd Msg )
noOp model =
    ( model, Cmd.none )
