module Types exposing (..)

import Dict exposing (..)


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


type alias DeathCause =
    String


type alias Death =
    { causes : List DeathCause
    }


type alias Snake =
    { causeOfDeath : Maybe Death
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


type alias V2 =
    { x : Int
    , y : Int
    }


type alias Food =
    V2


type alias Agent =
    List V2


type alias Scenario =
    { agents : List Agent
    , player : Agent
    , food : List Food
    , width : Int
    , height : Int
    }


type alias AssertionError =
    { scenario : Scenario
    , player : Snake
    }
