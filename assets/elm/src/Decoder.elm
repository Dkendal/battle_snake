module Decoder exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)


tick : Decoder TickMsg
tick =
    map TickMsg
        (field "content" board)


board : Decoder Board
board =
    map5 Board
        (field "turn" int)
        (field "snakes" (list snake))
        (field "deadSnakes" (list snake))
        (field "gameId" int)
        (field "food" (list point))


point : Decoder Point
point =
    map2 Point
        (index 0 int)
        (index 1 int)


snake : Decoder Snake
snake =
    map7 Snake
        (maybe (field "causeOfDeath" string))
        (field "color" string)
        (field "coords" (list point))
        (field "health" int)
        (field "id" string)
        (field "name" string)
        (field "taunt" (maybe string))


permalink : Decoder Permalink
permalink =
    map2 Permalink
        (field "id" string)
        (field "url" string)


lobby : Decoder Lobby
lobby =
    map Lobby
        (field "data" (list permalink))


error : Decoder String
error =
    at [ "data", "error" ] string
