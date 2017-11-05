module Test exposing (..)

import Debug exposing (..)
import Decoder exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import HtmlUtil exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Navigation exposing (Location)
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Push as Push exposing (Push)
import Phoenix.Socket as Socket exposing (Socket)
import Task exposing (..)
import Tuple
import Types exposing (..)
import UrlParser as Url exposing (..)
import GameBoard


type alias Model =
    { agentUrl : String
    , results : List (Result TestCaseError Pass)
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
    | ReceiveTestCase (Result Value Value)


type Pass
    = Pass


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


type alias Flags =
    { websocket : String }


main : Program Flags Model Msg
main =
    Navigation.programWithFlags router
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


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        model_ =
            { model | socket = socket }

        socket =
            Socket.init flags.websocket
                |> Socket.withDebug
                |> Socket.on "test:failed" "test" (Err >> ReceiveTestCase)
                |> Socket.on "test:pass" "test" (Ok >> ReceiveTestCase)

        cmds =
            [ perform identity (succeed (JoinChannel TestChannel)) ]

        model =
            { agentUrl = ""
            , results = []
            , scenarios = []
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
        ReceiveTestCase (Err raw) ->
            case Decode.decodeValue testCaseError raw of
                Err err ->
                    crash err

                Ok assertionError ->
                    let
                        results =
                            (Err assertionError) :: model.results

                        model_ =
                            { model | results = results }

                        cmd =
                            case assertionError of
                                Assertion { world } ->
                                    GameBoard.render world

                                _ ->
                                    Cmd.none
                    in
                        model_ ! [ cmd ]

        ReceiveTestCase (Ok raw) ->
            let
                results =
                    (Ok Pass) :: model.results

                model_ =
                    { model | results = results }
            in
                model_ ! []

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
                    { model | socket = socket, results = [] }

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
    let
        summaryView result =
            case result of
                Err (Assertion err) ->
                    div []
                        [ p [ class "failed" ]
                            [ span [] [ text "Failed: " ]
                            , span [] [ text err.reason ]
                            ]
                        , div
                            [ id err.id
                            , style
                                [ ( "width", "300px" )
                                , ( "height", "500px" )
                                ]
                            ]
                            []
                        ]

                Err (Reason { reason }) ->
                    div []
                        [ p [ class "failed" ]
                            [ span [] [ text "Failed: " ]
                            , span [] [ text reason ]
                            ]
                        ]

                Err (MultipleReasons { errors }) ->
                    div [] <|
                        [ p [ class "failed" ]
                            [ span [] [ text "Failed: " ]
                            ]
                        ]
                            ++ List.map
                                (\error ->
                                    div [] [ text error ]
                                )
                                errors

                Ok _ ->
                    empty

        progressView result =
            case result of
                Ok _ ->
                    span [ class "pass" ] [ text "." ]

                Err result_ ->
                    span [ class "failed" ] [ text "F" ]
    in
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
            , div []
                (List.map progressView model.results)
            , div [] <|
                (h2 [] [ text "Test Summary:" ])
                    :: (List.map summaryView model.results)
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


isErr : Result error value -> Bool
isErr result =
    case result of
        Err _ ->
            True

        Ok _ ->
            False
