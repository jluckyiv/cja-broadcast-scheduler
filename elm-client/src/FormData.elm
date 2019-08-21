module FormData exposing (FormData, Worker(..), init, submit)

import Api
import Api.Payload exposing (Payload)
import DateTime


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


init : String -> FormData
init localeString =
    { worker = SendBoardNotification
    , body = ""
    , date = localeString |> DateTime.fromLocaleString |> DateTime.toDateString
    , time = ""
    }


submit : FormData -> ( FormData, Cmd msg )
submit formData =
    let
        localeString =
            ( formData.date, formData.time ) |> DateTime.fromTuple |> DateTime.toLocaleString

        apiCmd =
            workerToCmd formData.worker (Payload formData.body localeString)
    in
    ( { formData | body = "", time = "" }
    , apiCmd
    )


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
