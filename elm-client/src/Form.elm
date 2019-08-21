module Form exposing (Model, Msg, Worker(..), init, submit, update, view)

import Api exposing (RemoteList)
import Api.Payload exposing (Payload)
import Bulma.Classes as Bu
import DateTime
import Html exposing (Html, button, div, form, input, label, text)
import Html.Attributes exposing (checked, class, id, name, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit)



-- MODEL


type alias Model =
    { worker : Worker
    , body : String
    , date : String
    , time : String
    }


type Worker
    = SendGeneralNotification
    | SendBoardNotification
    | SendJackMessage
    | SendNicoleMessage


init : String -> Model
init localeString =
    { worker = SendBoardNotification
    , body = ""
    , date = localeString |> DateTime.fromLocaleString |> DateTime.toDateString
    , time = ""
    }



-- UPDATE


type Msg
    = SubmittedForm
    | ClickedWorker Worker
    | UpdatedDate String
    | UpdatedMessage String
    | UpdatedTime String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmittedForm ->
            submit model

        ClickedWorker worker ->
            updateWorker model worker

        UpdatedDate string ->
            updateDate model string

        UpdatedMessage string ->
            updateBody model string

        UpdatedTime string ->
            updateTime model string


submit : Model -> ( Model, Cmd msg )
submit model =
    let
        localeString =
            ( model.date, model.time ) |> DateTime.fromTuple |> DateTime.toLocaleString

        apiCmd =
            workerToCmd model.worker (Payload model.body localeString)
    in
    ( { model | body = "", time = "" }
    , apiCmd
    )


updateWorker : Model -> Worker -> ( Model, Cmd Msg )
updateWorker model worker =
    ( { model | worker = worker }, Cmd.none )


updateBody : Model -> String -> ( Model, Cmd Msg )
updateBody model string =
    ( { model | body = string }, Cmd.none )


updateDate : Model -> String -> ( Model, Cmd Msg )
updateDate model string =
    ( { model | date = string }, Cmd.none )


updateTime : Model -> String -> ( Model, Cmd Msg )
updateTime model string =
    ( { model | time = string }, Cmd.none )


workerToCmd : Worker -> (Payload -> Cmd msg)
workerToCmd worker =
    let
        tag =
            case worker of
                SendJackMessage ->
                    Api.SendJackMessage

                SendNicoleMessage ->
                    Api.SendNicoleMessage

                SendGeneralNotification ->
                    Api.SendGeneralNotification

                SendBoardNotification ->
                    Api.SendBoardNotification
    in
    tag >> Api.send



-- VIEW


view : String -> Model -> Html Msg
view id_ model =
    form [ id "input-form", onSubmit SubmittedForm ]
        [ workerMenu model
        , inputField id_ "Message" model.body "Your message here" UpdatedMessage
        , inputField "time-input" "Time" model.time "13:15 or 1:15 PM" UpdatedTime
        , inputField "date-input" "Date" model.date "01/01/2001" UpdatedDate
        , button [ id "submit-button", class Bu.button, class Bu.isInfo ] [ text "Send" ]
        ]


inputField : String -> String -> String -> String -> (String -> Msg) -> Html Msg
inputField id_ label_ value_ placeholder_ toMsg =
    div [ class Bu.field ]
        [ label [ class Bu.label ] [ text label_ ]
        , div [ class Bu.control ]
            [ input [ id id_, class Bu.input, type_ "text", placeholder placeholder_, value value_, onInput toMsg ]
                []
            ]
        ]


workerMenu : Model -> Html Msg
workerMenu model =
    div [ class Bu.field ]
        [ div [ class Bu.control ]
            [ radio "Send Board Broadcast"
                (model.worker == SendBoardNotification)
                (ClickedWorker SendBoardNotification)
            , radio "Send General Broadcast"
                (model.worker == SendGeneralNotification)
                (ClickedWorker SendGeneralNotification)
            , radio "Send Jack Message"
                (model.worker == SendJackMessage)
                (ClickedWorker SendJackMessage)
            , radio "Send Nicole Message"
                (model.worker == SendNicoleMessage)
                (ClickedWorker SendNicoleMessage)
            ]
        ]


radio : String -> Bool -> Msg -> Html Msg
radio value isChecked msg =
    label
        [ style "padding" "20px", class Bu.radio ]
        [ input [ type_ "radio", name "worker-type", onInput (\_ -> msg), checked isChecked ] []
        , text value
        ]
