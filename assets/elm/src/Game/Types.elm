module Game.Types exposing (..)

import Phoenix.Socket
import Json.Encode exposing (Value)
import Keyboard exposing (KeyCode)
import Types exposing (..)
import Time exposing (Time)


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , gameid : String
    , gameState : Maybe GameState
    , board : Maybe Board
    }


type alias Flags =
    { websocket : String
    , gameid : String
    }


type Msg
    = KeyDown KeyCode
    | JoinChannelFailed Value
    | JoinChannelSuccess Value
    | JoinGameChannel
    | PhxMsg PhxSockMsg
    | Broadcast BroadcastMsg
    | Push PushMsg
    | Tick Time


type PushMsg
    = ResumeGame
    | StopGame
    | NextStep
    | PauseGame
    | PrevStep


type BroadcastMsg
    = LobbyInfo Value
    | RecieveTick Value


type alias PhxSock =
    Phoenix.Socket.Socket Msg


type alias PhxSockMsg =
    Phoenix.Socket.Msg Msg
