module Scale exposing (..)

import Css exposing (..)


ms : Float -> Px
ms number =
    px (16 * (1.5 ^ number))


ms_3 : Px
ms_3 =
    ms -3


ms_2 : Px
ms_2 =
    ms -2


ms_1 : Px
ms_1 =
    ms -1


ms0 : Px
ms0 =
    ms 0


ms1 : Px
ms1 =
    ms 1


ms2 : Px
ms2 =
    ms 2


ms3 : Px
ms3 =
    ms 3


ms4 : Px
ms4 =
    ms 4
