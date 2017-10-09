module Types exposing (..)

import Dict exposing (Dict)


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


type alias Permalink =
    { id : String
    , url : String
    , error : Maybe String
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


type alias PermalinkError =
    { id : String
    , error : String
    }
