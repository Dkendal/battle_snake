module Types exposing (..)


type alias Board =
    { turn : Int
    , snakes : List Snake
    , deadSnakes : List Snake
    , gameid : Int
    , food : List Point
    }


type alias Lobby =
    { snakes : List Permalink
    }


type alias Permalink =
    { id : String
    , url : String
    }


type Point
    = Point Int Int


type alias Snake =
    { causeOfDeath : Maybe String
    , color : String
    , coords : List Point
    , health : Int
    , id : String
    , name : String
    , taunt : Maybe String
    }


type alias TickMsg =
    { content : Board }
