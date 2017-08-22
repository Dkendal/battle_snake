module GameApp exposing (..)

import Char
import Decode exposing (..)
import GameBoard
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (decodeValue)
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


view : Model -> Html Msg
view model =
    let
        turn =
            model.board
                |> Maybe.andThen (.turn >> toString >> Just)
                |> Maybe.withDefault ""

        snakes =
            model.board
                |> Maybe.andThen (.snakes >> List.map snakeView >> Just)
                |> Maybe.withDefault []
    in
        div [ class "gameapp" ]
            [ div [] [ text turn ]
            , div [ class "col" ]
                [ div
                    [ class "gameboard" ]
                    [ canvas [ id (bgId model) ] []
                    , canvas [ id (fgId model) ] []
                    ]
                , div [ class "snakes" ] snakes
                ]
            ]


snakeView snake =
    let
        healthRemaining =
            (toString (100 - snake.health)) ++ "%"
    in
        div [ class "snake" ]
            [ div
                [ style
                    [ ( "background-color", snake.color )
                    , ( "left", healthRemaining )
                    ]
                , class "snake-healthbar"
                ]
                []
            , div [ class "snake-label" ]
                [ span [ class "snake-name" ] [ text snake.name ]
                , span [ class "snake-health" ] [ text (toString snake.health) ]
                ]
            ]



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { socket = socket flags.websocket flags.gameid
      , gameid = flags.gameid
      , board = Nothing
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
            case decodeValue tick raw of
                Ok { content } ->
                    ( { model | board = Just content }, GameBoard.draw raw )

                _ ->
                    noOp model

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


adminChannel : { a | gameid : String } -> String
adminChannel { gameid } =
    "game_admin:" ++ gameid


spectatorChannel : { a | gameid : String } -> String
spectatorChannel { gameid } =
    "spectator:" ++ gameid


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
    let
        model =
            { gameid = gameid }

        spectator =
            spectatorChannel model
    in
        Socket.init url
            |> Socket.on "tick" spectator Tick


adminCmd : String -> Model -> ( Model, Cmd Msg )
adminCmd cmd model =
    adminChannel model
        |> Push.init cmd
        |> flip Socket.push model.socket
        |> pushCmd model


noOp : Model -> ( Model, Cmd Msg )
noOp model =
    ( model, Cmd.none )
