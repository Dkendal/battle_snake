module Test.Decoder exposing (..)

import Json.Decode exposing (..)
import Test.Types exposing (..)


(:=) : String -> Decoder a -> Decoder a
(:=) =
    field


v =
    map2 V
        ("x" := int)
        ("y" := int)


agent =
    "body" := list v


scenario =
    map5 Scenario
        ("agents" := list agent)
        ("player" := agent)
        ("food" := list v)
        ("width" := int)
        ("height" := int)


assertionError =
    map AssertionError
        ("scenario" := scenario)



-- scenario = Map


a =
    { world =
        { width = 2
        , turn = 0
        , snakes = {}
        , moves = {}
        , max_food = 2
        , id = null
        , height = 2
        , game_id = "a7310622-3574-4a20-b955-7d5341b17b7b"
        , game_form_id = null
        , food = {}
        , deaths = {}
        , dead_snakes = {}
        , created_at = null
        }
    , scenario =
        { width = 2
        , player = { id = null, body = {} }
        , id = null
        , height = 2
        , food = {}
        , agents = {}
        }
    , player =
        { taunt = null
        , name = ""
        , id = "ee9b4dc9-c43a-4efa-9e42-16badbe1f20b"
        , health_points = 100
        , coords = {}
        }
    }
