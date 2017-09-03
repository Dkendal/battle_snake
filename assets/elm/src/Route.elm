module Route exposing (..)

import List


gamesPath : String
gamesPath =
    "/"


editGamePath : String -> String
editGamePath id =
    path [ id, "edit" ]


path : List String -> String
path strings =
    ("" :: strings)
        |> List.intersperse "/"
        |> List.foldr (++) ""
