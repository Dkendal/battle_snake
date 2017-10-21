module Test.Types exposing (..)

import Json.Encode as Encode exposing (Value)
import Phoenix.Socket as Socket exposing (Socket)


type alias Model =
    { agentUrl : String
    , results : List (Result AssertionError Pass)
    , scenarios : List Scenario
    , socket : Socket Msg
    }


type Pass
    = Pass


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


type alias V =
    { x : Int
    , y : Int
    }


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


type alias AssertionError =
    { scenario : Scenario }
