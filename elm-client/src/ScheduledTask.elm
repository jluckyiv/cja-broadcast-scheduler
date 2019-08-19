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


dateTimeColumn : ScheduledTask -> Html msg
dateTimeColumn scheduledTask =
    div [ class Bu.column, class Bu.is2, class Bu.isPulledRight ] [ DateTime.toHtml scheduledTask.performAt ]


workerColumn : ScheduledTask -> Html msg
workerColumn scheduledTask =
    div [ class Bu.column, class Bu.is3 ] [ Worker.toHtml scheduledTask.worker ]


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


id : ScheduledTask -> String
id scheduledTask =
    TaskId.toString scheduledTask.id
