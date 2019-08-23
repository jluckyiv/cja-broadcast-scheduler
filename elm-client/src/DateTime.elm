module DateTime exposing
    ( DateTime
    , decoder
    , fromLocaleString
    , fromTuple
    , toDateString
    , toHtml
    , toLocaleString
    , toTimeString
    , toValidDate
    , toValidTime
    )

import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Parser exposing (Parser)
import DateTime.Date as Date exposing (Date)


type DateTime
    = DateTime String

decoder : Decoder DateTime
decoder =
    Decode.map DateTime Decode.string


fromLocaleString : String -> DateTime
fromLocaleString string =
    DateTime string


fromTuple : ( String, String ) -> DateTime
fromTuple ( dateString, timeString ) =
    DateTime (String.trim dateString ++ ", " ++ String.trim timeString)


toLocaleString : DateTime -> String
toLocaleString (DateTime string) =
    string


toDateString : DateTime -> String
toDateString (DateTime string) =
    string
        |> String.split ","
        |> List.head
        |> Maybe.withDefault string
        |> String.trim


toTimeString : DateTime -> String
toTimeString (DateTime string) =
    string
        |> String.split ","
        |> List.reverse
        |> List.head
        |> Maybe.withDefault string
        |> String.trim


toHtml : DateTime -> Html msg
toHtml dateTime =
    Html.text (toLocaleString dateTime)


toValidDate : String -> Result (List Parser.DeadEnd) String
toValidDate string =
    let
        result =
            string
                |> Date.fromLocaleString
                |> Result.map Date.toLocaleString
    in
    result


toValidTime : String -> Result String String
toValidTime string =
    Ok string
