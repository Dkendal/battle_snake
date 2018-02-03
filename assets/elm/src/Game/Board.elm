module Game.Board exposing (view)

import Game.Types exposing (..)
import Html.Styled
import Svg.Styled as Svg exposing (..)
import Svg.Styled.Attributes as Attrs exposing (..)
import Svg.Styled.Events exposing (..)
import Css exposing (hex)
import Types exposing (..)
import Theme exposing (theme)


scale x =
    x * 100


margin =
    20


gridPos x_ =
    x_ |> scale |> (+) margin |> toString


gridUnit =
    1 |> scale |> (+) (margin * -1)


gridUnitString =
    gridUnit |> toString


gridPathOffset =
    round ((scale 1 / 2) + (margin / 2))


view : Board -> Html.Styled.Html Msg
view board =
    let
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
        svg [ viewBox (viewBox_) ]
            [ defs []
                [ pattern
                    [ id "GridPattern"
                    , x "0"
                    , y "0"
                    , width (1.0 / toFloat width_ |> toString)
                    , height (1.0 / toFloat height_ |> toString)
                    ]
                    [ rect
                        [ gridPos 0 |> x
                        , gridUnitString |> width
                        , gridPos 0 |> y
                        , gridUnitString |> height
                        , fill theme.tile.value
                        ]
                        []
                    ]
                ]
            , rect
                [ fill "url(#GridPattern)"
                , width (width_ |> scale |> toString)
                , height (height_ |> scale |> toString)
                ]
                []
            , g [ transform (translate gridPathOffset gridPathOffset) ] (List.map snakeView snakes)
            ]


blockSnakeView : Snake -> Svg Msg
blockSnakeView snake =
    g []
        (snake.coords
            |> List.map
                (\point ->
                    case point of
                        Point x_ y_ ->
                            rect
                                [ gridPos x_ |> x
                                , gridUnitString |> width
                                , gridPos y_ |> y
                                , gridUnitString |> height
                                , fill snake.color
                                ]
                                []
                )
        )


snakeView : Snake -> Svg Msg
snakeView snake =
    polyline
        [ snake.coords
            |> List.concatMap
                (\point ->
                    case point of
                        Point x y ->
                            [ x, y ]
                )
            |> List.map scale
            |> List.map toString
            |> String.join " "
            |> points
        , css
            [ Css.property "stroke-width" gridUnitString
            , Css.property "stroke" snake.color
            , Css.property "fill" "none"
            ]
        ]
        []


gridView2 : Int -> Int -> Svg msg
gridView2 height_ width_ =
    let
        range =
            (List.range 0 height_)

        domain =
            (List.range 0 width_)

        square x_ y_ =
            rect
                [ gridPos x_ |> x
                , gridUnitString |> width
                , gridPos y_ |> y
                , gridUnitString |> height
                ]
                []

        map f =
            (List.concatMap (\y_ -> List.map (\x_ -> f x_ y_) domain) range)

        stylesheet =
            [ Css.fill theme.tile ]
    in
        g [ css stylesheet ] (map square)


translate : Int -> Int -> String
translate x y =
    ("translate(" ++ (toString x) ++ ", " ++ (toString y) ++ ")")
