module DateTime.Date exposing
    ( Date
    , fromLocaleString
    , fromString
    , toLocaleString
    )

import DateTime.Parser as Parser
import Parser exposing ((|.), (|=), Parser)


type alias Date =
    { month : Month
    , day : Day
    , year : Int
    }


type Day
    = Day Int


type Month
    = Jan
    | Feb
    | Mar
    | Apr
    | May
    | Jun
    | Jul
    | Aug
    | Sep
    | Oct
    | Nov
    | Dec


monthFromInt : Int -> Month
monthFromInt int =
    case clamp 1 12 int of
        1 ->
            Jan

        2 ->
            Feb

        3 ->
            Mar

        4 ->
            Apr

        5 ->
            May

        6 ->
            Jun

        7 ->
            Jul

        8 ->
            Aug

        9 ->
            Sep

        10 ->
            Oct

        11 ->
            Nov

        _ ->
            Dec


monthToInt : Month -> Int
monthToInt month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


dayFromInt : { month : Month, day : Int, year : Int } -> Day
dayFromInt { month, day, year } =
    let
        min =
            1

        max =
            case ( month, isLeapYear year ) of
                ( Feb, False ) ->
                    28

                ( Feb, True ) ->
                    29

                ( Apr, _ ) ->
                    30

                ( Jun, _ ) ->
                    30

                ( Sep, _ ) ->
                    30

                ( Nov, _ ) ->
                    30

                ( _, _ ) ->
                    31
    in
    clamp min max day |> Day


dayToInt : Day -> Int
dayToInt (Day int) =
    int


isLeapYear : Int -> Bool
isLeapYear year =
    if ((modBy 4 year == 0) && (modBy 100 year /= 0)) || (modBy 400 year == 0) then
        True

    else
        False


monthParser : Parser Int
monthParser =
    Parser.digit
        |> Parser.andThen (Parser.inRange 1 12)


dayParser : Parser Int
dayParser =
    Parser.digit
        |> Parser.andThen (Parser.inRange 1 31)


yearParser : Parser Int
yearParser =
    let
        checkLength : Int -> Parser Int
        checkLength int =
            let
                length =
                    int
                    |> String.fromInt
                    |> String.length
            in
            if length == 2 || length == 4 then
                Parser.succeed int

            else
                Parser.problem "Year must be two or four digits"
    in
    Parser.digit
        |> Parser.andThen checkLength


dateParser : Parser Date
dateParser =
    Parser.succeed fromIntegers
        |= monthParser
        |= dayParser
        |= yearParser
        |. Parser.end


fromString : String -> Result (List Parser.DeadEnd) Date
fromString string =
    string
        |> String.replace "." "/"
        |> Parser.run dateParser


fromLocaleString : String -> Result (List Parser.DeadEnd) Date
fromLocaleString =
    fromString


monthToString : Month -> String
monthToString month =
    month |> monthToInt |> String.fromInt


dayToString : Day -> String
dayToString day =
    day |> dayToInt |> String.fromInt


yearToString : Int -> String
yearToString year =
    year |> String.fromInt


toLocaleString : Date -> String
toLocaleString date =
    let
        month =
            monthToString date.month

        day =
            dayToString date.day

        year =
            yearToString date.year
    in
    [ month, day, year ] |> String.join "/"


fromIntegers : Int -> Int -> Int -> Date
fromIntegers month_ day_ year_ =
    let
        year =
            if year_ < 50 then
                year_ + 2000

            else if year_ < 100 then
                year_ + 1900

            else
                year_

        month =
            monthFromInt month_

        day =
            dayFromInt { month = month, day = day_, year = year }
    in
    Date month day year
