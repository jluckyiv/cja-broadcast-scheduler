module Worker exposing (Worker(..), decoder, encode, toString, toHtml)

import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Worker
    = SendMessage
    | SendBoardMessage
    | SendNotification
    | SendBoardNotification
    | Unknown


decoder : Decoder Worker
decoder =
    Decode.map fromString Decode.string


encode : Worker -> Value
encode status =
    Encode.string (toString status)


fromString : String -> Worker
fromString string =
    case string of
        "sendMessage" ->
            SendMessage

        "sendBoardMessage" ->
            SendBoardMessage

        "sendBoardNotification" ->
            SendBoardNotification

        "sendNotification" ->
            SendNotification

        _ ->
            Unknown


toString : Worker -> String
toString worker =
    case worker of
        SendMessage ->
            "sendMessage"

        SendBoardMessage ->
            "sendBoardMessage"

        SendNotification ->
            "sendNotification"

        SendBoardNotification ->
            "sendBoardNotification"

        Unknown ->
            "unknown"


toHtml : Worker -> Html msg
toHtml worker =
    case worker of
        SendMessage ->
            Html.text "Direct Message (General)"

        SendBoardMessage ->
            Html.text "Direct Message (Board)"

        SendBoardNotification ->
            Html.text "Board Notification"

        SendNotification ->
            Html.text "General Notification"

        Unknown ->
            Html.text "Unknown"
