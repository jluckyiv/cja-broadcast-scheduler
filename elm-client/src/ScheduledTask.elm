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
import DateTime exposing (DateTime)
import Html exposing (Html, button, div, p, table, tbody, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import MessageOptions exposing (MessageOptions)
import NotificationOptions exposing (NotificationOptions)
import Status exposing (Status)
import TaskId exposing (TaskId)
import Worker exposing (Worker)


type alias ScheduledTask =
    Params


type alias Params =
    { id : TaskId
    , performAt : DateTime
    , status : Status
    , worker : Worker
    , options : Options
    }


type Options
    = Message MessageOptions
    | Notification NotificationOptions


decoder : Decoder ScheduledTask
decoder =
    Decode.succeed Params
        |> required "id" TaskId.decoder
        |> required "performAt" DateTime.decoder
        |> required "status" Status.decoder
        |> required "worker" Worker.decoder
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


listToHtml : (TaskId -> msg) -> List ScheduledTask -> Html msg
listToHtml deleteMsg scheduledTaskList =
    case List.map (toHtml deleteMsg) scheduledTaskList of
        [] ->
            div [] [ p [] [ text "No entries" ] ]

        list ->
            div []
                [ table [ class Bu.table, class Bu.isFullwidth ]
                    [ tbody [] list ]
                ]


toHtml : (TaskId -> msg) -> ScheduledTask -> Html msg
toHtml deleteMsg scheduledTask =
    div [ class Bu.columns ]
        [ deleteButton deleteMsg scheduledTask
        , dateTimeColumn scheduledTask.performAt
        , workerColumn scheduledTask.worker
        , optionsColumn scheduledTask.options
        ]


deleteButton : (TaskId -> msg) -> ScheduledTask -> Html msg
deleteButton toMsg scheduledTask =
    case scheduledTask.status of
        Status.Scheduled ->
            div [ class Bu.column, class Bu.is1 ]
                [ button
                    [ class Bu.button
                    , class Bu.isDanger
                    , onClick (toMsg (id scheduledTask))
                    ]
                    [ text "Del" ]
                ]

        _ ->
            text ""


dateTimeColumn : DateTime -> Html msg
dateTimeColumn performAt =
    div [ class Bu.column, class Bu.is2, class Bu.isPulledRight ] [ DateTime.toHtml performAt ]


workerColumn : Worker -> Html msg
workerColumn worker =
    div [ class Bu.column, class Bu.is3 ] [ Worker.toHtml worker ]


optionsColumn : Options -> Html msg
optionsColumn options =
    div [ class Bu.column ] [ optionsToHtml options ]


optionsToHtml : Options -> Html msg
optionsToHtml options =
    case options of
        Message messageOptions ->
            MessageOptions.toHtml messageOptions

        Notification notificationOptions ->
            NotificationOptions.toHtml notificationOptions


id : ScheduledTask -> TaskId
id scheduledTask =
    scheduledTask.id
