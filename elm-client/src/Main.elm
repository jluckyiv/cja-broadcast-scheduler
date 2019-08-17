module Main exposing (main)

import Admin exposing (Admin)
import Api exposing (GenericData)
import Browser
import Browser.Dom as Dom
import Bulma.Classes as Bu
import DateTime exposing (DateTime)
import Html exposing (Html, button, div, form, h3, input, label, nav, p, section, text)
import Html.Attributes exposing (attribute, checked, class, id, name, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import RemoteData exposing (RemoteData(..))
import ScheduledTask exposing (ScheduledTask)
import Session exposing (Session)
import Task
import User exposing (User)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { session : Session
    , formData : FormData
    , completeTasks : RemoteTaskList
    , scheduledTasks : RemoteTaskList
    , admins : RemoteData Decode.Error (List Admin)
    }


type alias RemoteTaskList =
    RemoteData Decode.Error (List ScheduledTask)


type alias FormData =
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


type alias Flags =
    { status : Maybe String
    , dateString : String
    }


init : Flags -> ( Model, Cmd Msg )
init { status, dateString } =
    let
        session =
            status
                |> User.fromMaybe
                |> Session.fromUser dateString
    in
    ( { session = session
      , formData = initFormData dateString
      , scheduledTasks = NotAsked
      , completeTasks = NotAsked
      , admins = Loading
      }
    , Cmd.map GotGenericData (Api.send Api.GetAdmins)
    )


initFormData : String -> FormData
initFormData dateString =
    { worker = SendBoardNotification
    , body = ""
    , date = dateString |> DateTime.fromString |> DateTime.toDateString
    , time = ""
    }



-- UPDATE


type Msg
    = Ignored
    | ClickedRadio Worker String
    | ClickedDelete String
    | GotGenericData GenericData
    | GotSession Session
    | Focus (Result Dom.Error ())
    | Login
    | Logout
    | SubmittedForm
    | UpdatedDate String
    | UpdatedMessage String
    | UpdatedTime String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ignored ->
            ( model, Cmd.none )

        Focus _ ->
            ( model, Cmd.none )

        ClickedDelete id ->
            deleteScheduledTaskById model id

        ClickedRadio worker _ ->
            updateWorker model worker

        GotGenericData genericData ->
            decodeGenericData model genericData

        GotSession session ->
            updateSession model session

        Login ->
            login model

        Logout ->
            logout model

        SubmittedForm ->
            submitForm model

        UpdatedDate string ->
            updateDate model string

        UpdatedMessage string ->
            updateBody model string

        UpdatedTime string ->
            updateTime model string


login : Model -> ( Model, Cmd Msg )
login model =
    ( model, Cmd.map GotSession (Api.send Api.Login) )


logout : Model -> ( Model, Cmd Msg )
logout model =
    ( { model | scheduledTasks = NotAsked, completeTasks = NotAsked }
    , Cmd.map GotSession (Api.send Api.Logout)
    )


updateSession : Model -> Session -> ( Model, Cmd Msg )
updateSession model session =
    ( { model | session = session }, focusMessageInput )


updateWorker : Model -> Worker -> ( Model, Cmd Msg )
updateWorker ({ formData } as model) worker =
    let
        newFormData =
            { formData | worker = worker }
    in
    ( { model | formData = newFormData }, Cmd.none )


updateBody : Model -> String -> ( Model, Cmd Msg )
updateBody ({ formData } as model) string =
    let
        newFormData =
            { formData | body = string }
    in
    ( { model | formData = newFormData }, Cmd.none )


updateDate : Model -> String -> ( Model, Cmd Msg )
updateDate ({ formData } as model) string =
    let
        newFormData =
            { formData | date = string }
    in
    ( { model | formData = newFormData }, Cmd.none )


updateTime : Model -> String -> ( Model, Cmd Msg )
updateTime ({ formData } as model) string =
    let
        newFormData =
            { formData | time = string }
    in
    ( { model | formData = newFormData }, Cmd.none )


submitForm : Model -> ( Model, Cmd Msg )
submitForm ({ formData } as model) =
    let
        apiCmd =
            workerToCmd formData.worker
                { body = formData.body
                , dateString = ( formData.date, formData.time ) |> DateTime.fromTuple |> DateTime.toString
                }
    in
    ( { model | formData = { formData | body = "", time = "" } }
    , Cmd.batch [ apiCmd, focusMessageInput ]
    )


deleteScheduledTaskById : Model -> String -> ( Model, Cmd Msg )
deleteScheduledTaskById model id =
    ( model
    , Cmd.map (\_ -> Ignored) (Api.send (Api.DeleteTask id))
    )


workerToCmd : Worker -> (Api.Payload -> Cmd msg)
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


bodyInputId : String
bodyInputId =
    "body-input"


focusMessageInput : Cmd Msg
focusMessageInput =
    Task.attempt Focus (Dom.focus bodyInputId)


decodeGenericData : Model -> GenericData -> ( Model, Cmd Msg )
decodeGenericData model { tag, payload } =
    case tag of
        "GotAdmins" ->
            let
                admins =
                    payload
                        |> Decode.decodeValue (Decode.list Admin.decoder)
                        |> RemoteData.fromResult

                email =
                    model.session
                        |> Session.user
                        |> User.email

                isAuthorized =
                    RemoteData.map (Admin.isAuthorized email) admins

                ( newModel, cmd ) =
                    case isAuthorized of
                        RemoteData.Success auth ->
                            if auth then
                                ( { model
                                    | scheduledTasks = RemoteData.Loading
                                    , completeTasks = RemoteData.Loading
                                  }
                                , focusMessageInput
                                )

                            else
                                ( model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            ( { newModel | admins = admins }, cmd )

        "GotComplete" ->
            let
                tasks =
                    payload
                        |> Decode.decodeValue (Decode.list ScheduledTask.decoder)
                        |> RemoteData.fromResult
            in
            ( { model | completeTasks = tasks }, Cmd.none )

        "GotScheduled" ->
            let
                tasks =
                    payload
                        |> Decode.decodeValue (Decode.list ScheduledTask.decoder)
                        |> RemoteData.fromResult
            in
            ( { model | scheduledTasks = tasks }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (toSession model)
        , Api.dataToElm GotGenericData
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        user =
            Session.user (toSession model)
    in
    { title = "CJA Twilio Scheduler"
    , body =
        [ section [ class Bu.section ]
            [ div [ class Bu.container ]
                [ navHeader user
                , inputSection model
                , scheduledTaskSection model
                , completeTaskSection model
                ]
            ]
        ]
    }


navHeader : User -> Html Msg
navHeader user =
    nav [ class Bu.navbar, class Bu.isLight, class Bu.isSpaced ]
        [ div [ class Bu.navbarBrand ] [ div [ class Bu.navbarItem, class Bu.isSize3 ] [ text "CJA Twilio Scheduler" ] ]
        , div [ class Bu.navbarEnd ]
            [ div [ class Bu.navbarItem ] [ text (User.displayName user) ]
            , div [ class Bu.navbarItem ] [ text (User.displayEmail user) ]
            , div [ class Bu.navbarItem ] [ div [ class Bu.buttons ] [ loginButton user ] ]
            ]
        ]


loginButton : User -> Html Msg
loginButton user =
    case user of
        User.Anonymous ->
            button [ onClick Login, class Bu.button, class Bu.isPrimary ] [ text "Login" ]

        User.Pending _ ->
            button [ attribute "disabled" "", class Bu.button, class Bu.isPrimary, class Bu.isLoading ] [ text "Loggin in" ]

        User.LoggedIn _ ->
            button [ onClick Logout, class Bu.button, class Bu.isPrimary ] [ text "Logout" ]


inputSection : Model -> Html Msg
inputSection model =
    section [ class "section" ]
        [ h3 [ class Bu.isSize3 ] [ text "Schedule Message" ]
        , inputForm model
        ]


inputForm : Model -> Html Msg
inputForm model =
    case Session.user (toSession model) of
        User.LoggedIn _ ->
            loggedInForm model.formData

        _ ->
            p [] [ text "Only logged in users can input data." ]


loggedInForm : FormData -> Html Msg
loggedInForm formData =
    form [ id "input-form", onSubmit SubmittedForm ]
        [ workerMenu formData
        , inputField bodyInputId "Message" formData.body "Your message here" UpdatedMessage
        , inputField "time-input" "Time" formData.time "13:15 or 1:15 PM" UpdatedTime
        , inputField "date-input" "Date" formData.date "01/01/2001" UpdatedDate
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


workerMenu : FormData -> Html Msg
workerMenu formData =
    div [ class Bu.field ]
        [ div [ class Bu.control ]
            [ radio "Send Board Broadcast" (formData.worker == SendBoardNotification) (ClickedRadio SendBoardNotification)
            , radio "Send General Broadcast" (formData.worker == SendGeneralNotification) (ClickedRadio SendGeneralNotification)
            , radio "Send Jack Message" (formData.worker == SendJackMessage) (ClickedRadio SendJackMessage)
            , radio "Send Nicole Message" (formData.worker == SendNicoleMessage) (ClickedRadio SendNicoleMessage)
            ]
        ]


radio : String -> Bool -> (String -> msg) -> Html msg
radio value isChecked msg =
    label
        [ style "padding" "20px", class Bu.radio ]
        [ input [ type_ "radio", name "worker-type", onInput msg, checked isChecked ] []
        , text value
        ]


scheduledTaskSection : Model -> Html Msg
scheduledTaskSection model =
    taskSection "Scheduled Tasks" model.scheduledTasks


completeTaskSection : Model -> Html Msg
completeTaskSection model =
    taskSection "Complete Tasks" model.completeTasks


taskSection : String -> RemoteTaskList -> Html Msg
taskSection title taskList =
    section [ class Bu.section ]
        [ h3 [ class Bu.isSize3 ] [ text title ]
        , scheduledTaskList taskList
        ]


scheduledTaskList : RemoteTaskList -> Html Msg
scheduledTaskList remoteData =
    case remoteData of
        Loading ->
            text "Loading"

        NotAsked ->
            text "Only logged in users can see this data."

        Failure e ->
            text ("Error: " ++ Decode.errorToString e)

        Success list ->
            ScheduledTask.listToHtml ClickedDelete list



-- HELPERS


toSession : Model -> Session
toSession model =
    model.session
