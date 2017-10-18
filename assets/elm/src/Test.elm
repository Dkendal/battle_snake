module Test exposing (..)

import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Navigation exposing (Location)
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Push as Push exposing (Push)
import Phoenix.Socket as Socket exposing (Socket)
import Tuple
import UrlParser as Url exposing (..)
import Task exposing (..)


type alias Model =
    { agentUrl : String
    , scenarios : List Scenario
    , socket : Socket Msg
    }


type Msg
    = NoOp
    | JoinChannel ChannelName
    | ChanMsg ChannelMsg Value
    | PhxMsg (Socket.Msg Msg)
    | SetNewUrl
    | UpdateAgentUrl String
    | RunSuite
    | PushMsg PushMessage
    | PushReply PushMessage (Result Value Value)


type PushMessage
    = PushRunSuite


type ChannelMsg
    = Joined
    | JoinError
    | Error


type ChannelName
    = TestChannel


type Route
    = Test (Maybe String)


{-| 2d vector
-}
type alias V =
    ( Int, Int )


type alias Food =
    V


type alias Agent =
    List V


type alias Scenario =
    { agents : List Agent
    , player : Agent
    , food : List Food
    , width : Int
    , height : Int
    }


main : Program Never Model Msg
main =
    Navigation.program router
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


router : Location -> Msg
router location =
    NoOp


route : Parser (Route -> c) c
route =
    oneOf
        [ Url.map Test (Url.s "test" <?> stringParam "agentUrl")
        ]


init : Location -> ( Model, Cmd Msg )
init location =
    let
        model_ =
            { model | socket = socket }

        socket =
            Socket.init "ws://localhost:3000/socket/websocket"

        simple =
            { width = 2
            , height = 2
            , agents = []
            , food = [ ( 1, 0 ) ]
            , player = [ ( 0, 0 ) ]
            }

        scenarios : List Scenario
        scenarios =
            [ simple ]

        cmds =
            [ perform identity (succeed (JoinChannel TestChannel)) ]

        model =
            { agentUrl = ""
            , scenarios = scenarios
            , socket = socket
            }
    in
        case (log "init parsePath" (parsePath route location)) of
            Just (Test (Just agentUrl)) ->
                { model | agentUrl = agentUrl } ! cmds

            _ ->
                model ! cmds


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Socket.listen model.socket PhxMsg
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (log "update" msg) of
        JoinChannel TestChannel ->
            let
                channel =
                    Channel.init "test"
                        |> Channel.onJoin (ChanMsg Joined)
                        |> Channel.onJoinError (ChanMsg JoinError)
                        |> Channel.onError (ChanMsg Error)

                ( socket, cmd ) =
                    model.socket
                        |> Socket.join channel
                        |> mapPhxMsg

                model_ =
                    { model | socket = socket }
            in
                model_ ! [ cmd ]

        PushReply pushMsg result ->
            model ! []

        PushMsg PushRunSuite ->
            let
                value =
                    Encode.object
                        [ ( "url", Encode.string model.agentUrl )
                        ]

                push =
                    Push.init "run:suite" "test"
                        |> Push.withPayload value
                        |> Push.onOk (Ok >> PushReply PushRunSuite)
                        |> Push.onError (Err >> PushReply PushRunSuite)

                ( socket, cmd ) =
                    Socket.push push model.socket
                        |> mapPhxMsg

                model_ =
                    { model | socket = socket }

                cmds =
                    [ cmd ]
            in
                model_ ! cmds

        ChanMsg chanMsg raw ->
            case chanMsg of
                {- Reconnects to the channel on disconnect -}
                Error ->
                    model
                        ! [ perform identity (succeed (JoinChannel TestChannel))
                          ]

                _ ->
                    model ! []

        PhxMsg msg ->
            let
                ( socket, cmd ) =
                    Socket.update msg model.socket

                cmd_ =
                    Cmd.map PhxMsg cmd
            in
                { model | socket = socket } ! [ cmd_ ]

        RunSuite ->
            model
                ! [ perform identity (succeed SetNewUrl)
                  , perform identity (succeed (PushMsg PushRunSuite))
                  ]

        SetNewUrl ->
            let
                newUrl =
                    "?agentUrl=" ++ model.agentUrl

                setQueryParams =
                    Navigation.newUrl newUrl
            in
                model ! [ setQueryParams ]

        UpdateAgentUrl agentUrl ->
            { model | agentUrl = agentUrl } ! []

        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    div []
        [ h1 []
            [ text "Snake Test"
            ]
        , div []
            [ label
                [ onEnter RunSuite
                ]
                [ text "url"
                , input
                    [ type_ "url"
                    , tabindex 0
                    , defaultValue model.agentUrl
                    , onInput UpdateAgentUrl
                    ]
                    []
                , button
                    [ onClick RunSuite
                    ]
                    [ text "run test"
                    ]
                ]
            ]
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Decode.succeed msg
            else
                Decode.fail ""
    in
        on "keydown" (Decode.andThen isEnter keyCode)


mapPhxMsg : ( a, Cmd (Socket.Msg Msg) ) -> ( a, Cmd Msg )
mapPhxMsg x =
    Tuple.mapSecond (Cmd.map PhxMsg) x
