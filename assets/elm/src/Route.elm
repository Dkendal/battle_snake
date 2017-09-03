module Route exposing (..)

import Types exposing (..)
import List


type Route
    = EditGame
    | Games


route : Route -> Model -> String
route name { gameid } =
    case name of
        Games ->
            "/"

        EditGame ->
            path [ gameid, "edit" ]


path : List String -> String
path strings =
    ("" :: strings)
        |> List.intersperse "/"
        |> List.foldr (++) ""
