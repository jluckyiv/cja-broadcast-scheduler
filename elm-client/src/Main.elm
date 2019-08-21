module Main exposing (main)

import Admin exposing (Admin)
import Api exposing (RemoteList)
import Browser
import Browser.Dom as Dom
import Bulma.Classes as Bu
import Form
import FormData exposing (FormData)
import Html exposing (Html, button, div, h3, nav, p, section, text)
import Html.Attributes exposing (attribute, class, id)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import RemoteData exposing (RemoteData(..))
import ScheduledTask exposing (ScheduledTask)
import ScheduledTask.TaskId exposing (TaskId)
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
    , formData : Form.Model
    , completeTasks : RemoteList ScheduledTask
    , scheduledTasks : RemoteList ScheduledTask
    , admins : RemoteList Admin
    }


type alias Flags =
    { status : Maybe String
    , localeString : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { session = initSession flags
      , formData = Form.init flags.localeString
      , scheduledTasks = NotAsked
      , completeTasks = NotAsked
      , admins = Loading
      }
    , Cmd.map GotApiData Api.getAdmins
    )


initSession : Flags -> Session
initSession { status, localeString } =
    status
        |> User.fromMaybe
        |> Session.fromUser localeString



-- UPDATE


type Msg
    = ClickedDelete TaskId
    | ConsoleError String
    | ConsoleInfo String
    | ConsoleLog String
    | Focus (Result Dom.Error ())
    | GotApiData Api.DataToElm
    | GotFormMsg Form.Msg
    | GotSession Session
    | SignIn
    | SignOut
    | SubmittedForm


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedDelete id ->
            deleteScheduledTaskById model id

        ConsoleError error ->
            ( model, consoleError error )

        ConsoleInfo info ->
            ( model, consoleInfo info )

        ConsoleLog log ->
            ( model, consoleLog log )

        Focus result ->
            case result of
                Err (Dom.NotFound id) ->
                    ( model, consoleError ("Focus failed for element with id: #" ++ id) )

                Ok _ ->
                    ( model, Cmd.none )

        GotApiData data ->
            updateWithApiData model data

        GotFormMsg formMsg ->
            let
                ( subModel, subMsg ) =
                    Form.update formMsg model.formData
            in
            ( { model | formData = subModel }, Cmd.map GotFormMsg subMsg )

        GotSession session ->
            updateSession model session

        SignIn ->
            signIn model

        SignOut ->
            signOut model

        SubmittedForm ->
            submitForm model


updateWithApiData : Model -> Api.DataToElm -> ( Model, Cmd Msg )
updateWithApiData model apiData =
    case apiData of
        Api.GotAdmins admins ->
            let
                isAuthorized =
                    admins
                        |> RemoteData.map
                            (model |> toSession |> Session.email |> Admin.isAuthorized)
                        |> RemoteData.withDefault False

                ( newModel, cmd ) =
                    if isAuthorized then
                        ( { model
                            | scheduledTasks = RemoteData.Loading
                            , completeTasks = RemoteData.Loading
                          }
                        , focusMessageInput
                        )

                    else
                        ( model, Cmd.none )
            in
            ( { newModel | admins = admins }, cmd )

        Api.GotCompleteTasks tasks ->
            ( { model | completeTasks = tasks }, Cmd.none )

        Api.GotScheduledTasks tasks ->
            ( { model | scheduledTasks = tasks }, Cmd.none )

        Api.Unrecognized ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (toSession model)
        , Sub.map GotApiData Api.subscription
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
            , div [ class Bu.navbarItem ] [ div [ class Bu.buttons ] [ signInButton user ] ]
            ]
        ]


signInButton : User -> Html Msg
signInButton user =
    case user of
        User.Anonymous ->
            button [ onClick SignIn, class Bu.button, class Bu.isPrimary ] [ text "Sign in" ]

        User.Pending _ ->
            button [ attribute "disabled" "", class Bu.button, class Bu.isPrimary, class Bu.isLoading ] [ text "Signing in" ]

        User.SignedIn _ ->
            button [ onClick SignOut, class Bu.button, class Bu.isPrimary ] [ text "Sign out" ]


inputSection : Model -> Html Msg
inputSection model =
    section [ class "section" ]
        [ h3 [ class Bu.isSize3 ] [ text "Schedule Message" ]
        , inputForm model
        ]


inputForm : Model -> Html Msg
inputForm model =
    case Session.user (toSession model) of
        User.SignedIn _ ->
            Html.map GotFormMsg (Form.view bodyInputId model.formData)

        _ ->
            p [] [ text "Only logged in users can input data." ]


scheduledTaskSection : Model -> Html Msg
scheduledTaskSection model =
    taskSection "Scheduled Tasks" model.scheduledTasks


completeTaskSection : Model -> Html Msg
completeTaskSection model =
    taskSection "Complete Tasks" model.completeTasks


taskSection : String -> RemoteList ScheduledTask -> Html Msg
taskSection title taskList =
    section [ class Bu.section ]
        [ h3 [ class Bu.isSize3 ] [ text title ]
        , scheduledTaskList taskList
        ]


scheduledTaskList : RemoteList ScheduledTask -> Html Msg
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


submitForm : Model -> ( Model, Cmd Msg )
submitForm model =
    let
        ( subModel, subCmd ) =
            Form.submit model.formData
    in
    ( { model | formData = subModel }
    , Cmd.batch
        [ subCmd
        , focusMessageInput
        ]
    )



-- UI


bodyInputId : String
bodyInputId =
    "body-input"


focusMessageInput : Cmd Msg
focusMessageInput =
    Task.attempt Focus (Dom.focus bodyInputId)



-- LOGGING


consoleError : String -> Cmd msg
consoleError error =
    Api.consoleError error


consoleInfo : String -> Cmd msg
consoleInfo info =
    Api.consoleInfo info


consoleLog : String -> Cmd msg
consoleLog log =
    Api.consoleLog log



-- TASKS


deleteScheduledTaskById : Model -> TaskId -> ( Model, Cmd Msg )
deleteScheduledTaskById model id =
    ( model
    , Cmd.map ConsoleLog (Api.deleteTask id)
    )



-- SESSION


signIn : Model -> ( Model, Cmd Msg )
signIn model =
    ( model, Cmd.map GotSession Api.signIn )


signOut : Model -> ( Model, Cmd Msg )
signOut model =
    ( { model
        | scheduledTasks = NotAsked
        , completeTasks = NotAsked
      }
    , Cmd.map GotSession Api.signOut
    )


updateSession : Model -> Session -> ( Model, Cmd Msg )
updateSession model session =
    ( { model | session = session }, focusMessageInput )


toSession : Model -> Session
toSession model =
    model.session
