module Types exposing (..)

import Dict exposing (Dict)
import Phoenix.Socket
import Json.Encode
import Keyboard


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
    | JoinSpectatorChannel
    | JoinChannelFailed Json.Encode.Value
    | JoinChannelSuccess Json.Encode.Value
    | MountCanvasApp
    | NextStep
    | PauseGame
    | PhxMsg PhxSockMsg
    | PrevStep
    | ResumeGame
    | StopGame
    | RecieveTick Json.Encode.Value
    | ReceiveRestartInit Json.Encode.Value
    | ReceiveRestartFinished Json.Encode.Value
    | ReceiveRestartRequestError Json.Encode.Value
    | ReceiveRestartRequestOk Json.Encode.Value


type alias PhxSock =
    Phoenix.Socket.Socket Msg


type alias PhxSockMsg =
    Phoenix.Socket.Msg Msg


type Phase
    = InitPhase
    | LobbyPhase Lobby
    | GamePhase Board
    | ResultPhase


type alias Board =
    { turn : Int
    , snakes : List Snake
    , deadSnakes : List Snake
    , gameid : Int
    , food : List Point
    }


type alias Database a =
    Dict String a


type alias Lobby =
    { snakes : Database Permalink }


type RequestState
    = Loading
    | Ready LobbySnake
    | Failed String


type alias Permalink =
    { id : String
    , url : String
    , loadingState : RequestState
    }


type Point
    = Point Int Int


type alias LobbySnake =
    { color : String
    , id : String
    , name : String
    , taunt : Maybe String
    , url : String
    , headUrl : String
    }


type alias Snake =
    { causeOfDeath : Maybe String
    , color : String
    , coords : List Point
    , health : Int
    , id : String
    , name : String
    , taunt : Maybe String
    , headUrl : String
    }


type alias TickMsg =
    { content : Board }


type alias GameEvent a =
    { gameId : Int
    , data : a
    }


type alias SnakeEvent a =
    { gameId : Int
    , snakeId : String
    , data : a
    }
