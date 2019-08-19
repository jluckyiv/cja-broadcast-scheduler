module DateTime exposing (DateTime, decoder, fromString, fromTuple, new, toDateString, toHtml, toString, toTimeString)

import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)


type DateTime
    = DateTime String


decoder : Decoder DateTime
decoder =
    Decode.map DateTime Decode.string


toHtml : DateTime -> Html msg
toHtml dateTime =
    Html.text (toString dateTime)


new : String -> Maybe DateTime
new string =
    Just (DateTime string)


fromString : String -> DateTime
fromString string =
    DateTime string


fromTuple : ( String, String ) -> DateTime
fromTuple ( dateString, timeString ) =
    DateTime (String.trim dateString ++ ", " ++ String.trim timeString)


toString : DateTime -> String
toString (DateTime string) =
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
