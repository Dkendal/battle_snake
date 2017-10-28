port module GameBoard exposing (..)

import Json.Encode exposing (Value)


port render : Value -> Cmd msg
