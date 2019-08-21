port module Api exposing
    ( DataFromElm(..)
    , DataToElm(..)
    , RemoteList
    , consoleError
    , consoleInfo
    , consoleLog
    , dataFromElm
    , dataToElm
    , deleteTask
    , getAdmins
    , send
    , signIn
    , signOut
    , subscription
    , userChanges
    )

import Admin exposing (Admin)
import Api.Payload as Payload exposing (Payload)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import RemoteData exposing (RemoteData)
import ScheduledTask exposing (ScheduledTask)
import TaskId exposing (TaskId)
import User exposing (User)



-- PORTS


port authStateChanged : (Value -> msg) -> Sub msg


port dataFromElm : GenericData -> Cmd msg


port dataToElm : (GenericData -> msg) -> Sub msg



-- MODELS


type alias GenericData =
    { tag : String
    , payload : Value
    }


type alias RemoteList a =
    RemoteData Decode.Error (List a)


type DataToElm
    = Unrecognized
    | GotCompleteTasks (RemoteList ScheduledTask)
    | GotScheduledTasks (RemoteList ScheduledTask)
    | GotAdmins (RemoteList Admin)


type DataFromElm
    = ConsoleError String
    | ConsoleInfo String
    | ConsoleLog String
    | DeleteTask TaskId
    | GetAdmins
    | SendBoardNotification Payload
    | SendGeneralNotification Payload
    | SendJackMessage Payload
    | SendNicoleMessage Payload
    | SignIn
    | SignOut


send : DataFromElm -> Cmd msg
send tag =
    let
        ( tagString, payloadValue ) =
            encodeTag tag
    in
    dataFromElm { tag = tagString, payload = payloadValue }


consoleError : String -> Cmd msg
consoleError string =
    send (ConsoleError string)


consoleInfo : String -> Cmd msg
consoleInfo string =
    send (ConsoleInfo string)


consoleLog : String -> Cmd msg
consoleLog string =
    send (ConsoleLog string)


deleteTask : TaskId -> Cmd msg
deleteTask taskId =
    send (DeleteTask taskId)


getAdmins : Cmd msg
getAdmins =
    send GetAdmins


signIn : Cmd msg
signIn =
    send SignIn


signOut : Cmd msg
signOut =
    send SignOut



-- SERIALIZATION


decodeGenericData : GenericData -> DataToElm
decodeGenericData { tag, payload } =
    let
        remoteListFromPayload decoder =
            payload
                |> Decode.decodeValue (Decode.list decoder)
                |> RemoteData.fromResult
    in
    case tag of
        "GotAdmins" ->
            GotAdmins (remoteListFromPayload Admin.decoder)

        "GotComplete" ->
            GotCompleteTasks (remoteListFromPayload ScheduledTask.decoder)

        "GotScheduled" ->
            GotScheduledTasks (remoteListFromPayload ScheduledTask.decoder)

        _ ->
            Unrecognized


encodeTag : DataFromElm -> ( String, Value )
encodeTag tag =
    case tag of
        ConsoleLog string ->
            ( "ConsoleLog", Encode.string string )

        ConsoleError string ->
            ( "ConsoleError", Encode.string string )

        ConsoleInfo string ->
            ( "ConsoleInfo", Encode.string string )

        DeleteTask id ->
            ( "DeleteTask", TaskId.encode id )

        GetAdmins ->
            ( "GetAdmins", Encode.null )

        SendJackMessage payload ->
            ( "SendJackMessage", Payload.encode payload )

        SendNicoleMessage payload ->
            ( "SendNicoleMessage", Payload.encode payload )

        SendBoardNotification payload ->
            ( "SendBoardNotification", Payload.encode payload )

        SendGeneralNotification payload ->
            ( "SendGeneralNotification", Payload.encode payload )

        SignIn ->
            ( "SignIn", Encode.null )

        SignOut ->
            ( "SignOut", Encode.null )



-- HELPERS


userChanges : (User -> msg) -> Sub msg
userChanges toMsg =
    authStateChanged (\value -> toMsg (User.decodeWithDefault User.Anonymous value))


subscription : Sub DataToElm
subscription =
    dataToElm decodeGenericData
