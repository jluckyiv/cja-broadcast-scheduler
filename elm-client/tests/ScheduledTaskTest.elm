module ScheduledTaskTest exposing (suite)

import DateTime
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode
import MessageOptions exposing (MessageOptions)
import NotificationOptions exposing (NotificationOptions)
import ScheduledTask exposing (ScheduledTask)
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
        ]
