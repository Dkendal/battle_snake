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
    , board : Maybe Board
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


type alias TickMsg =
    { content : Board }


type alias Board =
    { turn : Int
    , snakes : List Snake
    , deadSnakes : List Snake
    , gameid : String
    , food : List Point
    }


type alias Snake =
    { causeOfDeath : Maybe String
    , color : String
    , coords : List Point
    , health : Int
    , id : String
    , name : String
    , taunt : Maybe String
    }


type Point
    = Point Int Int
