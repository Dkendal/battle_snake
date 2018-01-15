module Game exposing (main)

import Game.State exposing (..)
import Game.Types exposing (..)
import Game.View exposing (..)
import Html exposing (..)
import Html.Styled exposing (..)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
