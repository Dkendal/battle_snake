module Test exposing (..)

import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (Location)
import Json.Decode
import UrlParser as Url exposing (..)


type alias Model =
    { agentUrl : String
    }


type Msg
    = NoOp
    | UpdateAgentUrl String
    | RunTest


type Route
    = Test (Maybe String)


main : Program Never Model Msg
main =
    Navigation.program router
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


router : Location -> Msg
router location =
    NoOp


route : Parser (Route -> c) c
route =
    oneOf
        [ Url.map Test (Url.s "test" <?> stringParam "agentUrl")
        ]


init : Location -> ( Model, Cmd Msg )
init location =
    case (log "init parsePath" (parsePath route location)) of
        Just (Test (Just agentUrl)) ->
            { agentUrl = agentUrl } ! []

        _ ->
            { agentUrl = "" } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (log "update" msg) of
        RunTest ->
            let
                newUrl =
                    "?agentUrl=" ++ model.agentUrl
            in
                model ! [ Navigation.newUrl newUrl ]

        UpdateAgentUrl agentUrl ->
            { model | agentUrl = agentUrl } ! []

        NoOp ->
            model ! []


view : Model -> Html Msg
view model =
    div []
        [ h1 []
            [ text "Snake Test"
            ]
        , div []
            [ label
                [ onEnter RunTest
                ]
                [ text "url"
                , input
                    [ type_ "url"
                    , tabindex 0
                    , defaultValue model.agentUrl
                    , onInput UpdateAgentUrl
                    ]
                    []
                , button
                    [ onClick RunTest
                    ]
                    [ text "run test"
                    ]
                ]
            ]
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "not ENTER"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)
