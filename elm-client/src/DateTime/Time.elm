module DateTime.Time exposing
    ( Time
    , fromLocaleString
    , fromString
    , toLocaleString
    )

import DateTime.Parser as Parser
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


hourToInt : Hour -> Int
hourToInt (Hour int) =
    int


hourToString : Hour -> String
hourToString (Hour int) =
    String.fromInt int


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


fromLocaleString : String -> Result (List Parser.DeadEnd) Time
fromLocaleString =
    fromString


fromString : String -> Result (List Parser.DeadEnd) Time
fromString string =
    string
        |> String.replace "." ":"
        |> Parser.run timeParser


timeParser : Parser Time
timeParser =
    Parser.succeed fromHourMinuteCycle
        |. Parser.whitespace
        |= hourParser
        |. Parser.whitespace
        |= minuteParser
        |. Parser.whitespace
        |= cycleParser
        |. Parser.whitespace
        |. Parser.end


hourParser : Parser Int
hourParser =
    Parser.digit
        |> Parser.andThen (Parser.inRange 0 23)


minuteParser : Parser Int
minuteParser =
    Parser.digit
        |> Parser.andThen (Parser.inRange 0 59)


cycleParser : Parser String
cycleParser =
    Parser.alpha
        |> Parser.map String.toUpper
        |> Parser.andThen (Parser.isMember [ "AM", "PM" ])


minuteFromInt : Int -> Minute
minuteFromInt int =
    clamp 0 59 int |> Minute


fromHourMinuteCycle : Int -> Int -> String -> Time
fromHourMinuteCycle hour_ minute_ cycle_ =
    let
        minute =
            minuteFromInt minute_

        ( hour, cycle ) =
            toHourAndCycle hour_ cycle_
    in
    Time hour minute cycle


toHourAndCycle : Int -> String -> ( Hour, Cycle )
toHourAndCycle hour_ cycle_ =
    let
        hour =
            clamp 0 23 hour_

        cycle =
            cycle_ |> String.toUpper |> String.left 1
    in
    if hour > 12 then
        ( Hour (hour - 12), PM )

    else
        case cycle of
            "A" ->
                ( Hour hour, AM )

            "P" ->
                ( Hour hour, PM )

            _ ->
                if hour < 8 then
                    ( Hour hour, PM )

                else if hour == 12 then
                    ( Hour hour, PM )

                else
                    ( Hour hour, AM )
