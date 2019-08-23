module DateTime.Parser exposing
    ( alpha
    , digit
    , digitString
    , fromMaybe
    , inRange
    , isMember
    , nonDigit
    , whitespace
    )

import Parser exposing (..)


alpha : Parser String
alpha =
    getChompedString <|
        succeed identity
            |= chompWhile Char.isAlpha


digit : Parser Int
digit =
    -- int cannot parse leading zeroes
    digitString
        |> map String.toInt
        |> andThen fromMaybe


digitString : Parser String
digitString =
    succeed identity
        |. nonDigit
        |= (getChompedString <| chompWhile Char.isDigit)


nonDigit : Parser ()
nonDigit =
    chompWhile (\c -> not (Char.isDigit c))


whitespace : Parser ()
whitespace =
    chompWhile (\c -> c == ' ')


fromMaybe : Maybe a -> Parser a
fromMaybe maybe =
    case maybe of
        Just n ->
            succeed n

        Nothing ->
            problem "Invalid input: Nothing."


inRange : Int -> Int -> Int -> Parser Int
inRange min max int =
    if int >= min && int <= max then
        succeed int

    else
        problem "Int is out of range."


isMember : List String -> String -> Parser String
isMember list string =
    if List.member string list then
        succeed string

    else
        problem <| "String: " ++ string ++ " is not in list [" ++ String.join ", " list ++ "]."

