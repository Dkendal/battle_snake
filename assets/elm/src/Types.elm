module Types exposing (..)

import Json.Encode as JE
import Keyboard
import Phoenix.Socket as Socket


-- FLAGS


type alias Flags =
    { websocket : String
    , gameid : String
    }



-- MODEL


type alias Model =
    { socket : Socket.Socket Msg
    , gameid : String
    }



-- MSG


type Msg
    = KeyDown Keyboard.KeyCode
    | JoinAdminChannel
    | JoinSpectatorChannel
    | JoinChannelFailed JE.Value
    | JoinChannelSuccess JE.Value
    | MountCanvasApp
    | NextStep
    | PauseGame
    | PhxMsg PhxSockMsg
    | PrevStep
    | ResumeGame
    | StopGame
    | Tick JE.Value


type alias PhxSock =
    Socket.Socket Msg


type alias PhxSockMsg =
    Socket.Msg Msg
