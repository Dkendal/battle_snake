module Game.Util exposing (..)

import Types exposing (..)


bgId : Model -> String
bgId { gameid } =
    "bg-" ++ gameid


fgId : Model -> String
fgId { gameid } =
    "fg-" ++ gameid
