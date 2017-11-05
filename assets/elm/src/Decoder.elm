module Decoder exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)
import Dict


(:=) : String -> Decoder a -> Decoder a
(:=) =
    field


(@=) =
    at


defaultHeadUrl : String
defaultHeadUrl =
    ""


maybeWithDefault : a -> Decoder a -> Decoder a
maybeWithDefault value decoder =
    decoder |> maybe |> map (Maybe.withDefault value)


tick : Decoder ( Board, Value )
tick =
    map2 (\x y -> ( x, y ))
        ("content" := board)
        ("content" := value)


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


point2 : Decoder Point
point2 =
    map2 Point
        ("x" := int)
        ("y" := int)


death =
    map Death
        ("causes" := list string)


snake : Decoder Snake
snake =
    map8 Snake
        (maybe <| "death" := death)
        ("color" := string)
        ("coords" := list point)
        ("health" := int)
        ("id" := string)
        ("name" := string)
        (maybe <| "taunt" := string)
        (maybeWithDefault defaultHeadUrl <| "headUrl" := string)


snake2 : Decoder Snake
snake2 =
    map8 Snake
        (maybe <| "death" := death)
        ("color" := string)
        (at [ "body", "data" ] (list point2))
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


v2 : Decoder V2
v2 =
    map2 V2
        ("x" := int)
        ("y" := int)


agent : Decoder Agent
agent =
    "body" := list v2


scenario : Decoder Scenario
scenario =
    map5 Scenario
        ("agents" := list agent)
        ("player" := agent)
        ("food" := list v2)
        ("width" := int)
        ("height" := int)


testCaseError : Decoder TestCaseError
testCaseError =
    ("object" := string)
        |> andThen
            (\object ->
                case object of
                    "assertion_error" ->
                        map Assertion assertionError

                    "error_with_reason" ->
                        map Reason errorWithReason

                    "error_with_multiple_reasons" ->
                        map MultipleReasons errorWithMultipleReasons

                    x ->
                        fail (x ++ " is not a known test case error")
            )


errorWithReason : Decoder ErrorWithReason
errorWithReason =
    map ErrorWithReason ("reason" := string)


errorWithMultipleReasons : Decoder ErrorWithMultipleReasons
errorWithMultipleReasons =
    map ErrorWithMultipleReasons ("errors" := list string)


assertionError : Decoder AssertionError
assertionError =
    map5 AssertionError
        ("id" := string)
        ("reason" := string)
        ("scenario" := scenario)
        ("player" := snake2)
        ("world" := value)
