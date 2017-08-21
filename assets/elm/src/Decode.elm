module Decode exposing (..)

import Types exposing (..)
import Json.Decode exposing (..)


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
        (field "gameId" string)
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
