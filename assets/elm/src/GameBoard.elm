port module GameBoard exposing (..)

import Json.Encode as JE


port mount : String -> Cmd msg


port draw : JE.Value -> Cmd msg
