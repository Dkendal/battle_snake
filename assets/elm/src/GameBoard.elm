port module GameBoard exposing (..)

import Json.Encode as JE


port mount : { fgId : String, bgId : String } -> Cmd msg


port draw : JE.Value -> Cmd msg
