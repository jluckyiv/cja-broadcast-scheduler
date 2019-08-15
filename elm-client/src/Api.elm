port module Api exposing
    ( GenericData
    , Payload
    , Tag(..)
    , dataFromElm
    , dataToElm
    , send
    , userChanges
    )

import Json.Encode exposing (Value, null)
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


type alias Payload =
    { body : String
    , dateString : String
    }


type Tag
    = Login
    | Logout
    | DeleteTask String
    | GetAdmins
    | SendJackMessage Payload
    | SendNicoleMessage Payload
    | SendGeneralNotification Payload
    | SendBoardNotification Payload


send : Tag -> Cmd msg
send tag =
    dataFromElm { tag = tagToString tag, payload = tagToValue tag }


tagToString : Tag -> String
tagToString tag =
    case tag of
        Login ->
            "Login"

        Logout ->
            "Logout"

        DeleteTask _ ->
            "DeleteTask"

        GetAdmins ->
            "GetAdmins"

        SendJackMessage _ ->
            "SendJackMessage"

        SendNicoleMessage _ ->
            "SendNicoleMessage"

        SendBoardNotification _ ->
            "SendBoardNotification"

        SendGeneralNotification _ ->
            "SendGeneralNotification"


tagToValue : Tag -> Value
tagToValue tag =
    case tag of
        SendJackMessage payload ->
            encodeMessagePayload payload

        SendNicoleMessage payload ->
            encodeMessagePayload payload

        SendBoardNotification payload ->
            encodeMessagePayload payload

        SendGeneralNotification payload ->
            encodeMessagePayload payload

        DeleteTask id ->
            Json.Encode.string id

        _ ->
            null


userChanges : (User -> msg) -> Sub msg
userChanges toMsg =
    authStateChanged (\value -> toMsg (User.decode value))



-- HELPERS


encodeMessagePayload : Payload -> Json.Encode.Value
encodeMessagePayload payload =
    Json.Encode.object
        [ ( "body", Json.Encode.string <| payload.body )
        , ( "dateString", Json.Encode.string <| payload.dateString )
        ]
