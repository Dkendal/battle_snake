module Decoder exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)


(:=) : String -> Decoder a -> Decoder a
(:=) =
    field


tick : Decoder TickMsg
tick =
    map TickMsg
        (field "content" board)


board : Decoder Board
board =
    map5 Board
        ("turn" := int)
        ("snakes" := list snake)
        ("deadSnakes" := list snake)
        ("gameId" := int)
        ("food" := list point)


point : Decoder Point
point =
    map2 Point
        (index 0 int)
        (index 1 int)


snake : Decoder Snake
snake =
    map7 Snake
        (maybe <| "causeOfDeath" := string)
        ("color" := string)
        ("coords" := list point)
        ("health" := int)
        ("id" := string)
        ("name" := string)
        ("taunt" := maybe string)


permalink : Decoder Permalink
permalink =
    map2 Permalink
        ("id" := string)
        ("url" := string)


lobby : Decoder Lobby
lobby =
    map Lobby
        ("data" := list permalink)


error : Decoder String
error =
    at [ "data", "error" ] string
