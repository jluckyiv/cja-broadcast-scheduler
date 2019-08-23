module DateTime.Time exposing
    ( Time
    , fromLocaleString
    , fromString
    , toLocaleString
    )

import Parser exposing ((|.), (|=), Parser)


type alias Time =
    { hour : Hour
    , minute : Minute
    , cycle : Cycle
    }


type Hour
    = Hour Int


type Minute
    = Minute Int


type Cycle
    = AM
    | PM


hourFromInt : Int -> Hour
hourFromInt int =
    clamp 0 23 int |> Hour


hourToInt : Hour -> Int
hourToInt (Hour int) =
    int


hourToString : Hour -> String
hourToString (Hour int) =
    String.fromInt int


minuteFromInt : Int -> Minute
minuteFromInt int =
    clamp 0 59 int |> Minute


minuteToInt : Minute -> Int
minuteToInt (Minute int) =
    int


minuteToString : Minute -> String
minuteToString (Minute int) =
    let
        string =
            String.fromInt int
    in
    if int < 10 then
        "0" ++ string

    else
        string


cycleToString : Cycle -> String
cycleToString cycle =
    case cycle of
        AM ->
            "AM"

        PM ->
            "PM"


nonDigit : Parser ()
nonDigit =
    Parser.chompWhile (\c -> not (Char.isDigit c))


whitespace : Parser ()
whitespace =
    Parser.chompWhile (\c -> c == ' ')


digitParser : Parser Int
digitParser =
    (Parser.succeed identity
        |. nonDigit
        |= (Parser.getChompedString <| Parser.chompWhile Char.isDigit)
    )
        |> Parser.map String.toInt
        |> Parser.andThen
            (\maybe ->
                case maybe of
                    Just n ->
                        Parser.succeed n

                    Nothing ->
                        Parser.problem "Invalid digits"
            )


hourParser : Parser Int
hourParser =
    let
        checkDigits : Int -> Parser Int
        checkDigits int =
            if int >= 0 && int <= 23 then
                Parser.succeed int

            else
                Parser.problem "Hour must be between 0 and 23"
    in
    digitParser
        |> Parser.andThen checkDigits


minuteParser : Parser Int
minuteParser =
    let
        checkDigits : Int -> Parser Int
        checkDigits int =
            if int >= 0 && int <= 59 then
                Parser.succeed int

            else
                Parser.problem "Hour must be between 0 and 23"
    in
    digitParser
        |> Parser.andThen checkDigits


cycleParser : Parser String
cycleParser =
    Parser.getChompedString <|
        Parser.succeed identity
            |= Parser.chompWhile Char.isAlpha


time12Parser : Parser Time
time12Parser =
    Parser.succeed from12Hour
        |= hourParser
        |= minuteParser
        |. whitespace
        |= cycleParser
        |. Parser.end


hourAndCycle : Int -> String -> ( Hour, Cycle )
hourAndCycle hour_ cycle_ =
    let
        hour =
            clamp 0 23 hour_

        _ =
            Debug.log "cycle_" cycle_
    in
    if hour > 12 then
        ( hourFromInt (hour - 12), PM )

    else
        case cycle_ of
            "AM" ->
                ( hourFromInt hour, AM )

            "PM" ->
                ( hourFromInt hour, PM )

            _ ->
                if hour < 8 then
                    ( hourFromInt hour, PM )

                else if hour == 12 then
                    ( hourFromInt hour, PM )

                else
                    ( hourFromInt hour, AM )


from12Hour : Int -> Int -> String -> Time
from12Hour hour_ minute_ cycle_ =
    let
        minute =
            minuteFromInt minute_

        ( hour, cycle ) =
            hourAndCycle hour_ cycle_
    in
    Time hour minute cycle


fromLocaleString : String -> Result (List Parser.DeadEnd) Time
fromLocaleString =
    fromString


fromString : String -> Result (List Parser.DeadEnd) Time
fromString string =
    string
        |> String.replace "." ":"
        |> Parser.run time12Parser


toLocaleString : Time -> String
toLocaleString time =
    let
        hour =
            hourToString time.hour

        minute =
            minuteToString time.minute

        cycle =
            cycleToString time.cycle
    in
    hour ++ ":" ++ minute ++ " " ++ cycle
