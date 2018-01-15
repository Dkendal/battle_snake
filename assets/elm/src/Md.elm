module Md exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


icon : String -> Html msg
icon name =
    i [ class "material-icons" ] [ text name ]


mdStop =
    icon "stop"


mdReplay =
    icon "replay"


mdPlayArrow =
    icon "play_arrow"


mdPause =
    icon "pause"


mdSkipNext =
    icon "skip_next"


mdSkipPrev =
    icon "skip_previous"
