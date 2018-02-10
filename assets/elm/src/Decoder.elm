module Decoder exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)
import Json.Decode.Pipeline exposing (..)
import Math.Vector2 exposing (..)


(:=) : String -> Decoder a -> Decoder a
(:=) =
    field


(@=) : List String -> Decoder a -> Decoder a
(@=) =
    at


defaultHeadUrl : String
defaultHeadUrl =
    ""


maybeWithDefault : a -> Decoder a -> Decoder a
maybeWithDefault value decoder =
    decoder |> maybe |> map (Maybe.withDefault value)


tick : Decoder GameState
tick =
    ("content" := decodeGameState)


parseError : String -> Decoder a
parseError val =
    fail ("don't know how to parse [" ++ val ++ "]")


decodeStatus : Decoder Status
decodeStatus =
    andThen
        (\x ->
            case x of
                "cont" ->
                    succeed Cont

                "suspend" ->
                    succeed Suspended

                "halted" ->
                    succeed Halted

                _ ->
                    parseError x
        )
        string


decodeGameState : Decoder GameState
decodeGameState =
    map2 GameState
        ("board" := decodeBoard)
        ("status" := decodeStatus)


decodeBoard : Decoder Board
decodeBoard =
    decode Board
        |> required "turn" (int)
        |> required "snakes" (list decodeSnake)
        |> required "gameId" (int)
        |> required "food" (list decodeVec2)
        |> required "width" (int)
        |> required "height" (int)


decodeVec2 : Decoder Vec2
decodeVec2 =
    map2 vec2
        (index 0 float)
        (index 1 float)


point2 : Decoder Vec2
point2 =
    map2 vec2
        ("x" := float)
        ("y" := float)


death : Decoder Death
death =
    map Death
        ("causes" := list string)


decodeSnake : Decoder Snake
decodeSnake =
    decode Snake
        |> hardcoded Nothing
        |> required "color" string
        |> required "coords" (list decodeVec2)
        |> required "health" int
        |> required "id" string
        |> required "name" string
        |> required "taunt" (maybe string)
        |> (string
                |> maybe
                |> map (Maybe.withDefault "")
                |> required "headUrl"
           )
        |> required "status" decodeSnakeStatus
        |> required "headType" string
        |> required "tailType" string


decodeSnakeStatus : Decoder SnakeStatus
decodeSnakeStatus =
    let
        decodeType record =
            case record of
                "dead" ->
                    succeed Dead

                "alive" ->
                    succeed Alive

                "connection_failure" ->
                    succeed ConnectionFailure

                _ ->
                    fail (toString record)
    in
        (field "type" string)
            |> andThen decodeType


snake2 : Decoder Snake
snake2 =
    decode Snake
        |> required "death" (maybe death)
        |> required "color" string
        |> required "coords" (list decodeVec2)
        |> required "health" int
        |> required "id" string
        |> required "name" string
        |> required "taunt" (maybe string)
        |> required "headUrl" string
        |> required "status" decodeSnakeStatus
        |> required "headType" string
        |> required "tailType" string


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
                        parseError x
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
