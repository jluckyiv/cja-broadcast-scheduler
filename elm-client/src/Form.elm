module Form exposing (Model, Msg, Worker(..), init, submit, subscription, update, view)

import Api exposing (RemoteList)
import Api.Payload exposing (Payload)
import Browser.Dom as Dom
import Bulma.Classes as Bu
import DateTime
import DateTime.Date as Date
import DateTime.Time as Time
import Html exposing (Html, button, div, form, input, label, p, text)
import Html.Attributes exposing (attribute, checked, class, id, name, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Task
import Validate exposing (Valid, Validator)



-- MODEL


type alias Model =
    { worker : Worker
    , body : String
    , time : String
    , date : String
    , errors : List FormError
    }


type alias FormError =
    ( Field, String )


type Field
    = Body
    | Time
    | Date


type Worker
    = SendGeneralNotification
    | SendBoardNotification
    | SendJackMessage
    | SendNicoleMessage


init : String -> ( Model, Cmd Msg )
init localeString =
    ( checkErrors
        { worker = SendBoardNotification
        , body = ""
        , time = ""
        , date = localeString |> DateTime.fromLocaleString |> DateTime.toDateString
        , errors = []
        }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Ignored
    | Focus (Result Dom.Error ())
    | GotApiData Api.DataToElm
    | ClickedWorker Worker
    | SubmittedForm
    | UpdatedDate String
    | UpdatedMessage String
    | UpdatedTime String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ignored ->
            ( model, Cmd.none )

        Focus result ->
            case result of
                Err (Dom.NotFound id) ->
                    ( model, Api.consoleError ("Focus failed for element with id: #" ++ id) )

                Ok _ ->
                    ( model, Cmd.none )

        GotApiData apiData ->
            case apiData of
                Api.GotAdmins _ ->
                    ( model, focusMessageInput )

                Api.GotFirebaseSuccess (Just "DeleteTask") ->
                    ( model, focusMessageInput )

                _ ->
                    ( model, Cmd.none )

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


submit : Model -> ( Model, Cmd Msg )
submit model =
    case validateModel model of
        Ok validModel ->
            submitValid validModel

        Err errors ->
            ( { model | errors = errors }, Cmd.none )


submitValid : Valid Model -> ( Model, Cmd Msg )
submitValid validModel =
    let
        model =
            Validate.fromValid validModel

        localeString =
            ( model.date, model.time ) |> DateTime.fromTuple |> DateTime.toLocaleString

        apiCmd =
            workerToCmd model.worker (Payload model.body localeString)
    in
    ( checkErrors { model | body = "", time = "" }
    , Cmd.batch [ apiCmd, focusMessageInput ]
    )


updateWorker : Model -> Worker -> ( Model, Cmd Msg )
updateWorker model worker =
    ( { model | worker = worker }, Cmd.none )


updateBody : Model -> String -> ( Model, Cmd Msg )
updateBody model string =
    ( checkErrors { model | body = string }, Cmd.none )


updateDate : Model -> String -> ( Model, Cmd Msg )
updateDate model string =
    ( checkErrors { model | date = string }, Cmd.none )


updateTime : Model -> String -> ( Model, Cmd Msg )
updateTime model string =
    ( checkErrors { model | time = string }, Cmd.none )


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



-- VALIDATION


checkErrors : Model -> Model
checkErrors model =
    case validateModel model of
        Ok _ ->
            { model | errors = [] }

        Err errors ->
            { model | errors = errors }


validateModel : Model -> Result (List FormError) (Valid Model)
validateModel model =
    Validate.validate modelValidator model


modelValidator : Validator FormError Model
modelValidator =
    Validate.all
        [ Validate.ifBlank .body ( Body, "Please enter a message" )
        , Validate.firstError
            [ Validate.ifBlank .time ( Time, "Please enter a time" )
            , Validate.ifTrue (\model -> isInvalidTime model.time) ( Time, "Please format time as HH:mm AM/PM" )
            ]
        , Validate.firstError
            [ Validate.ifBlank .date ( Date, "Please enter a date" )
            , Validate.ifTrue (\model -> isInvalidDate model.date) ( Date, "Please format date as M/D/YY" )
            ]
        ]


isInvalidTime : String -> Bool
isInvalidTime string =
    case Time.fromLocaleString string of
        Err _ ->
            True

        Ok _ ->
            False


isInvalidDate : String -> Bool
isInvalidDate string =
    case Date.fromLocaleString string of
        Err _ ->
            True

        Ok _ ->
            False



-- VIEW


bodyInputId : String
bodyInputId =
    "body-input"


focusMessageInput : Cmd Msg
focusMessageInput =
    Task.attempt Focus (Dom.focus bodyInputId)


view : Model -> Html Msg
view model =
    let
        ( onSubmit_, submitButton ) =
            case model.errors of
                [] ->
                    ( SubmittedForm
                    , button [ id "submit-button", class Bu.button, class Bu.isInfo ] [ text "Send" ]
                    )

                _ ->
                    ( Ignored
                    , button [ id "submit-button", class Bu.button, class Bu.isDisabled, attribute "disabled" "" ] [ text "Send" ]
                    )
    in
    form [ id "input-form", onSubmit onSubmit_ ]
        [ workerMenu model
        , inputField model Body bodyInputId "Message" "Your message here" UpdatedMessage
        , inputField model Time "time-input" "Time" "E.g., 1:15 PM" UpdatedTime
        , inputField model Date "date-input" "Date" "1/1/19" UpdatedDate
        , submitButton
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


inputField : Model -> Field -> String -> String -> String -> (String -> Msg) -> Html Msg
inputField model field id_ label_ placeholder_ toMsg =
    let
        fieldErrors : List FormError -> Field -> String
        fieldErrors errors_ field_ =
            errors_
                |> List.filter (\tuple -> Tuple.first tuple == field_)
                |> List.map Tuple.second
                |> String.join ". "

        ( value_, help_ ) =
            case field of
                Body ->
                    ( model.body, fieldErrors model.errors Body )

                Time ->
                    ( model.time, fieldErrors model.errors Time )

                Date ->
                    ( model.date, fieldErrors model.errors Date )
    in
    div [ class Bu.field ]
        [ label [ class Bu.label ] [ text label_ ]
        , div [ class Bu.control ]
            [ input [ id id_, class Bu.input, type_ "text", placeholder placeholder_, value value_, onInput toMsg ]
                []
            ]
        , p [ class Bu.help, class Bu.isDanger ] [ text help_ ]
        ]


subscription : Sub Msg
subscription =
    Sub.batch
        [ Sub.map GotApiData Api.subscription
        ]
