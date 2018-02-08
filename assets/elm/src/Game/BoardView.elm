module Game.BoardView exposing (view)

import Math.Vector2 as V2 exposing (..)
import Css exposing (hex)
import Game.Types exposing (..)
import Html.Styled exposing (div)
import Scale exposing (..)
import Svg.Styled as Svg exposing (..)
import Svg.Styled.Attributes as Attrs exposing (..)
import Svg.Styled.Events exposing (..)
import Theme exposing (theme)
import Types exposing (..)
import Tuple


scale : number -> number
scale x =
    x * 100


margin : number
margin =
    20


gridPos : number -> String
gridPos x_ =
    x_ |> scale |> (+) margin |> toString


gridUnit : number
gridUnit =
    1 |> scale |> (+) (margin * -1)


gridUnitString : String
gridUnitString =
    gridUnit |> toString


gridPathOffset =
    ((scale 1 / 2) + (margin / 2))


blockPos : Vec2 -> List (Attribute msg)
blockPos v =
    [ v |> getX |> gridPos |> x
    , gridUnitString |> width
    , v |> getY |> gridPos |> y
    , gridUnitString |> height
    ]


square : List (Attribute msg) -> Vec2 -> Svg msg
square attrs point =
    rect ((blockPos point) ++ attrs) []


circle_ : List (Attribute msg) -> Vec2 -> Svg msg
circle_ attrs v =
    circle
        ([ gridUnit / 2 |> toString |> r
         , v |> getX |> scale |> toString |> cx
         , v |> getY |> scale |> toString |> cy
         ]
            ++ attrs
        )
        []


view : Board -> Html.Styled.Html Msg
view board =
    let
        food =
            board.food

        height_ =
            board.height

        width_ =
            board.width

        snakes =
            board.snakes

        viewBox_ =
            [ 0, 0, scale (width_ + 1), scale (height_ + 1) ]
                |> List.map toString
                |> String.join " "
    in
        svg [ viewBox viewBox_, css [ 1 |> Css.int |> Css.flexGrow, Css.padding ms1 ] ]
            [ defs []
                [ pattern
                    [ id "GridPattern"
                    , x "0"
                    , y "0"
                    , width (1.0 / toFloat width_ |> toString)
                    , height (1.0 / toFloat height_ |> toString)
                    ]
                    [ square [ fill theme.tile.value ] (vec2 0 0) ]
                ]
            , rect
                [ fill "url(#GridPattern)"
                , width (width_ |> scale |> toString)
                , height (height_ |> scale |> toString)
                ]
                []
            , g
                [ vec2 gridPathOffset gridPathOffset
                    |> translate
                    |> transform
                , css [ Css.fill theme.food ]
                ]
                (List.map (circle_ []) food)
            , g [] (List.concatMap snakeView snakes)
            ]


type Acc
    = Acc Term Term Vec2 Vec2 (List Vec2)
    | AccFirst Term
    | AccInit


type alias Term =
    { pos : Vec2, dir : Vec2 }


term : Vec2 -> Term
term pos =
    Term pos (vec2 0 0)


term2 : Vec2 -> Vec2 -> Term
term2 a b =
    Term a (sub a b)


alignWithMargin : Term -> Vec2 -> Vec2
alignWithMargin { dir } vec =
    dir
        |> V2.normalize
        |> V2.scale (((margin / -52)))
        |> add vec


snakeView : Snake -> List (Svg msg)
snakeView record =
    let
        alive =
            record.status == Alive

        coords =
            record.coords
                |> List.foldl reduce (AccInit)

        reduce : Vec2 -> Acc -> Acc
        reduce current acc =
            case acc of
                AccInit ->
                    AccFirst (term current)

                (AccFirst ({ pos } as term)) as acc ->
                    if pos == current then
                        acc
                    else
                        let
                            start =
                                term2 pos current

                            end =
                                term2 current pos
                        in
                            Acc
                                start
                                end
                                current
                                pos
                                [ alignWithMargin end current
                                , alignWithMargin start pos
                                ]

                (Acc start end prev1 prev2 list) as acc ->
                    if current == prev1 then
                        acc
                    else
                        let
                            end_ =
                                term2 current prev1

                            lastSegment =
                                alignWithMargin end_ current

                            list_ =
                                lastSegment :: prev1 :: (List.drop 1 list)
                        in
                            Acc start end_ current prev1 list_

        points_ =
            case coords of
                Acc _ _ _ _ list ->
                    list
                        |> List.concatMap (\v -> [ getX v, getY v ])
                        |> List.map (scale >> truncate >> toString)
                        |> String.join " "

                _ ->
                    ""

        polyline_ =
            case coords of
                Acc _ _ _ _ list ->
                    polyline
                        [ points points_
                        , css
                            [ Css.property "stroke-width" gridUnitString
                            , Css.property "stroke" record.color
                            , Css.property "fill" "none"
                            , Css.property "stroke-linejoin" "round"
                            ]
                        ]
                        []

                _ ->
                    text ""

        path x y =
            ("/images/snake/" ++ x ++ "/" ++ y ++ ".svg#root")

        embed transform_ part type_ { pos, dir } =
            let
                center =
                    (vec2 0.5 0.5)

                dir_ =
                    dir |> toTuple
            in
                svg ((blockPos pos) ++ [ viewBox "0 0 1 1" ])
                    [ g (transformIcon center dir_)
                        [ Svg.title [] [ text (toString dir_) ]
                        , use
                            [ path part type_ |> xlinkHref
                            , width "1"
                            , height "1"
                            , x "0"
                            , y "0"
                            , css [ Css.property "fill" record.color ]
                            ]
                            []
                        ]
                    ]

        icons =
            case coords of
                AccInit ->
                    []

                AccFirst start ->
                    [ start |> (embed "" "head" record.headType) ]

                Acc start end _ _ _ ->
                    [ start |> (embed "" "head" record.headType)
                    , end |> (embed "" "tail" record.tailType)
                    ]
    in
        if alive then
            [ g
                [ vec2 gridPathOffset gridPathOffset
                    |> translate
                    |> transform
                ]
                [ polyline_ ]
            ]
                ++ icons
        else
            []


rotate : a -> String
rotate value =
    ("rotate(" ++ (value |> toString) ++ ")")


rotate2 : a -> Vec2 -> String
rotate2 value vec =
    ("rotate("
        ++ (toString value)
        ++ " "
        ++ (vec |> getX |> toString)
        ++ ","
        ++ (vec |> getY |> toString)
        ++ ")"
    )


translate : Vec2 -> String
translate vec =
    ("translate("
        ++ (vec |> getX |> toString)
        ++ ","
        ++ (vec |> getY |> toString)
        ++ ")"
    )


verticalFlip =
    "scale(-1,1) translate(-1, 0)"


transformList list =
    transform (String.join " " list)


transformOrigin value =
    Css.property "transform-origin" value


transformIcon : Vec2 -> ( number, number1 ) -> List (Attribute msg)
transformIcon center vec =
    case vec of
        ( 0, 0 ) ->
            [ transform (rotate2 -90 center) ]

        ( 1, 0 ) ->
            []

        ( -1, 0 ) ->
            [ transform verticalFlip ]

        ( -1, 1 ) ->
            [ transform (rotate2 45 center) ]

        ( 0, 1 ) ->
            [ transform (rotate2 90 center) ]

        ( 0, -1 ) ->
            [ transform (rotate2 -90 center) ]

        ( _, _ ) ->
            Debug.crash (toString vec)
