module PhoneNumber exposing (PhoneNumber, new, toString)


type PhoneNumber
    = PhoneNumber String


new : String -> Maybe PhoneNumber
new string =
    string
        |> toValidNumber
        |> Maybe.map PhoneNumber


toValidNumber : String -> Maybe String
toValidNumber string =
    let
        numbers =
            string |> String.filter Char.isDigit
    in
    if String.length numbers == 10 then
        Just ("+1" ++ numbers)

    else
        Nothing


toString : PhoneNumber -> String
toString (PhoneNumber string) =
    string
