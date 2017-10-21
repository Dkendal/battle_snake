module Game.Decoder exposing (..)

import Json.Decode exposing (..)
import Game.Types exposing (..)
import Dict


(:=) : String -> Decoder a -> Decoder a
(:=) =
    field


defaultHeadUrl : String
defaultHeadUrl =
    ""


maybeWithDefault : a -> Decoder a -> Decoder a
maybeWithDefault value decoder =
    decoder |> maybe |> map (Maybe.withDefault value)


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
    map8 Snake
        (maybe <| "causeOfDeath" := string)
        ("color" := string)
        ("coords" := list point)
        ("health" := int)
        ("id" := string)
        ("name" := string)
        (maybe <| "taunt" := string)
        (maybeWithDefault defaultHeadUrl <| "headUrl" := string)


permalink : Decoder Permalink
permalink =
    map3 Permalink
        ("id" := string)
        ("url" := string)
        (succeed Loading)


database :
    Decoder { a | id : comparable }
    -> Decoder (Dict.Dict comparable { a | id : comparable })
database decoder =
    list decoder
        |> map (List.map (\y -> ( y.id, y )))
        |> map Dict.fromList


lobby : Decoder Lobby
lobby =
    map Lobby
        ("data" := database permalink)


gameEvent : Decoder a -> Decoder (GameEvent a)
gameEvent decoder =
    map2 GameEvent
        (at [ "rel", "game_id" ] int)
        decoder


snakeEvent : Decoder a -> Decoder (SnakeEvent a)
snakeEvent decoder =
    map3 SnakeEvent
        (at [ "rel", "game_id" ] int)
        (at [ "rel", "snake_id" ] string)
        decoder


error : Decoder (SnakeEvent String)
error =
    snakeEvent (at [ "data", "error" ] string)


lobbySnake : Decoder (SnakeEvent LobbySnake)
lobbySnake =
    let
        data =
            map6 LobbySnake
                ("color" := string)
                ("id" := string)
                ("name" := string)
                ("taunt" := maybe string)
                ("url" := string)
                (maybeWithDefault defaultHeadUrl <| "headUrl" := string)
    in
        snakeEvent (field "data" data)
