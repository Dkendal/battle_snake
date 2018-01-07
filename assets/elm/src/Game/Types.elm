module Game.Types exposing (..)

import Phoenix.Socket
import Json.Encode
import Keyboard
import Types exposing (..)


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , gameid : String
    , phase : Phase
    }


type alias Flags =
    { websocket : String
    , gameid : String
    }


type Msg
    = KeyDown Keyboard.KeyCode
    | JoinAdminChannel
    | JoinChannelFailed Json.Encode.Value
    | JoinChannelSuccess Json.Encode.Value
    | JoinSpectatorChannel
    | NextStep
    | PauseGame
    | PhxMsg PhxSockMsg
    | PrevStep
    | ReceiveMoveResponse Json.Encode.Value
    | ReceiveRestartFinished Json.Encode.Value
    | ReceiveRestartInit Json.Encode.Value
    | ReceiveRestartRequestError Json.Encode.Value
    | ReceiveRestartRequestOk Json.Encode.Value
    | RecieveTick Json.Encode.Value
    | ResumeGame
    | StopGame


type alias PhxSock =
    Phoenix.Socket.Socket Msg


type alias PhxSockMsg =
    Phoenix.Socket.Msg Msg


type Phase
    = InitPhase
    | LobbyPhase Lobby
    | GamePhase Board
    | ResultPhase
