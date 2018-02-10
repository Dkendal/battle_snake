module Types exposing (..)

import Json.Encode exposing (Value)
import Math.Vector2 exposing (..)


type Status
    = Cont
    | Halted
    | Suspended


type alias GameState =
    { board : Board
    , status : Status
    }


type alias Board =
    { turn : Int
    , snakes : List Snake
    , gameid : Int
    , food : List Vec2
    , width : Int
    , height : Int
    }


type alias DeathCause =
    String


type alias Death =
    { causes : List DeathCause
    }


type SnakeStatus
    = Alive
    | Dead
    | ConnectionFailure


type alias Snake =
    { death : Maybe Death
    , color : String
    , coords : List Vec2
    , health : Int
    , id : String
    , name : String
    , taunt : Maybe String
    , headUrl : String
    , status : SnakeStatus
    , headType : String
    , tailType : String
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


type TestCaseError
    = Assertion AssertionError
    | Reason ErrorWithReason
    | MultipleReasons ErrorWithMultipleReasons


type alias ErrorWithReason =
    { reason : String
    }


type alias ErrorWithMultipleReasons =
    { errors : List String
    }


type alias AssertionError =
    { id : String
    , reason : String
    , scenario : Scenario
    , player : Snake
    , world : Value
    }
