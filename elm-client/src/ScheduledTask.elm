module ScheduledTask exposing
    ( Options(..)
    , Params
    , ScheduledTask
    , decoder
    , listToHtml
    , optionsDecoder
    , toHtml
    )

import Bulma.Classes as Bu
import Html exposing (Html, button, div, p, table, tbody, td, text, tr)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import MessageOptions exposing (MessageOptions)
import NotificationOptions exposing (NotificationOptions)


type alias ScheduledTask =
    Params


type alias Params =
    { id : String
    , performAt : String
    , status : String
    , worker : String
    , options : Options
    }


type Options
    = Message MessageOptions
    | Notification NotificationOptions


listToHtml : (String -> msg) -> List ScheduledTask -> Html msg
listToHtml toMsg scheduledTaskList =
    let
        list =
            scheduledTaskList
                |> List.map (toHtml toMsg)
    in
    case list of
        [] ->
            div [] [ p [] [ text "No entries" ] ]

        _ ->
            div []
                [ table [ class Bu.table, class Bu.isFullwidth ]
                    [ tbody [] list ]
                ]


toHtml : (String -> msg) -> ScheduledTask -> Html msg
toHtml toMsg scheduledTask =
    div [ class Bu.columns ]
        [ deleteButton toMsg scheduledTask
        , dateTimeColumn scheduledTask
        , workerColumn scheduledTask
        , optionsColumn scheduledTask
        ]


deleteButton : (String -> msg) -> ScheduledTask -> Html msg
deleteButton toMsg scheduledTask =
    case scheduledTask.status of
        "scheduled" ->
            div [ class Bu.column, class Bu.is1 ]
                [ button
                    [ class Bu.button
                    , class Bu.isDanger
                    , onClick (toMsg scheduledTask.id)
                    ]
                    [ text "Del" ]
                ]

        _ ->
            text ""


dateTimeColumn : ScheduledTask -> Html msg
dateTimeColumn scheduledTask =
    div [ class Bu.column, class Bu.is2, class Bu.isPulledRight ] [ text scheduledTask.performAt ]


workerColumn : ScheduledTask -> Html msg
workerColumn scheduledTask =
    div [ class Bu.column, class Bu.is3 ] [ text (workerToString scheduledTask.worker) ]


optionsColumn : ScheduledTask -> Html msg
optionsColumn scheduledTask =
    div [ class Bu.column ] [ optionsToHtml scheduledTask.options ]


optionsToHtml : Options -> Html msg
optionsToHtml options =
    case options of
        Message messageOptions ->
            MessageOptions.toHtml messageOptions

        Notification notificationOptions ->
            NotificationOptions.toHtml notificationOptions


decoder : Decoder ScheduledTask
decoder =
    Decode.succeed Params
        |> required "id" Decode.string
        |> required "performAt" Decode.string
        |> required "status" Decode.string
        |> required "worker" Decode.string
        |> required "options" optionsDecoder


optionsDecoder : Decoder Options
optionsDecoder =
    Decode.oneOf
        [ messageDecoder
        , notificationDecoder
        ]


messageDecoder : Decoder Options
messageDecoder =
    Decode.map Message MessageOptions.decoder


notificationDecoder : Decoder Options
notificationDecoder =
    Decode.map Notification NotificationOptions.decoder


workerToString : String -> String
workerToString string =
    case string of
        "sendMessage" ->
            "Direct Message (from General)"

        "sendBoardMessage" ->
            "Direct Message (from Board)"

        "sendBoardNotification" ->
            "Board Notification"

        "sendNotification" ->
            "General Notification"

        _ ->
            "Unknown"
