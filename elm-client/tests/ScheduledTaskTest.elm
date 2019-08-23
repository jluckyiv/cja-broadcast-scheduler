module ScheduledTaskTest exposing (suite)

import DateTime
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode
import ScheduledTask exposing (ScheduledTask)
import ScheduledTask.MessageOptions as MessageOptions exposing (MessageOptions)
import ScheduledTask.NotificationOptions as NotificationOptions exposing (NotificationOptions)
import Test exposing (..)


suite : Test
suite =
    describe "ScheduledTask"
        [ test "MessageOptions" <|
            \_ ->
                let
                    value =
                        MessageOptions "+15555555555" "Hello World"
                in
                value
                    |> MessageOptions.encode
                    |> Decode.decodeValue MessageOptions.decoder
                    |> Expect.equal (Ok value)
        , test "NotificationOptions" <|
            \_ ->
                let
                    value =
                        NotificationOptions "Hello World"
                in
                value
                    |> NotificationOptions.encode
                    |> Decode.decodeValue NotificationOptions.decoder
                    |> Expect.equal (Ok value)
        , test "oneOf MessageOptions" <|
            \_ ->
                let
                    json =
                        """
                        {
                          "phoneNumber": "+15555555555",
                          "body": "Hello World"
                        }
                        """

                    result =
                        ScheduledTask.Message
                            (MessageOptions "+15555555555" "Hello World")
                in
                json
                    |> Decode.decodeString ScheduledTask.optionsDecoder
                    |> Expect.equal (Ok result)
        , test "oneOf NotificationOptions" <|
            \_ ->
                let
                    json =
                        """
                        {
                          "body": "Hello World"
                        }
                        """

                    result =
                        ScheduledTask.Notification
                            (NotificationOptions "Hello World")
                in
                json
                    |> Decode.decodeString ScheduledTask.optionsDecoder
                    |> Expect.equal (Ok result)
        , test "DateTime" <|
            \_ ->
                "8/13/2019, 11:52:00 PM"
                    |> DateTime.fromLocaleString
                    |> DateTime.toLocaleString
                    |> Expect.equal
                        "8/13/2019, 11:52:00 PM"
        , test "DateTime date" <|
            \_ ->
                "8/13/2019, 11:52:00 PM"
                    |> DateTime.fromLocaleString
                    |> DateTime.toDateString
                    |> Expect.equal
                        "8/13/2019"
        , test "DateTime time" <|
            \_ ->
                "8/13/2019, 11:52:00 PM"
                    |> DateTime.fromLocaleString
                    |> DateTime.toTimeString
                    |> Expect.equal
                        "11:52:00 PM"
        , test "DateTime from date and time" <|
            \_ ->
                ( "8/13/2019", "11:52:00 PM" )
                    |> DateTime.fromTuple
                    |> DateTime.toLocaleString
                    |> Expect.equal
                        "8/13/2019, 11:52:00 PM"
        , test "Date is valid with different separators" <|
            \_ ->
                [ "8/13/2019" , "8-13-2019" , "8.13.2019" , "8/13/2019", "8/13/19" ]
                    |> List.map DateTime.toValidDate
                    |> Expect.equal
                        [ Ok "8/13/2019" , Ok "8/13/2019" , Ok "8/13/2019" , Ok "8/13/2019", Ok "8/13/2019" ]
--        , test "Date errors" <|
--            \_ ->
--                [ "13/13/2019" , "9/31/2019" , "8-13-2018" ]
--                    |> List.map DateTime.toValidDate
--                    |> Expect.equal
--                        [Err "Invalid month", Err "Invalid day", Err "Invalid year"]
--        , test "Time is valid with different separators" <|
--            \_ ->
--                [ "2359" , "23.59" , "23:59", "11:59 PM"]
--                    |> List.map DateTime.toValidTime
--                    |> Expect.equal
--                        [ Ok "11:59 PM" , Ok "11:59 PM" , Ok "11:59 PM" , Ok "11:59 PM" ]
--        , test "Time errors" <|
--            \_ ->
--                [ "2501" , "23.61" ,  "11:59 SM", "13:59 AM"]
--                    |> List.map DateTime.toValidTime
--                    |> Expect.equal
--                        [ Err "Invalid hour" , Ok "Invalid minutes" , Ok "Must be AM or PM" , Ok "13:59 is not AM" ]
        ]
