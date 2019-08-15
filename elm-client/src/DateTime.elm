module DateTime exposing (DateTime, fromString, fromTuple, new, toDateString, toString, toTimeString)



type DateTime
    = DateTime String


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
