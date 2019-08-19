module Status exposing (Status(..), decoder, encode, toString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Status
    = Scheduled
    | Complete
    | Error


decoder : Decoder Status
decoder =
    Decode.map fromString Decode.string


encode : Status -> Value
encode status =
    Encode.string (toString status)


fromString : String -> Status
fromString string =
    case String.toLower string of
        "scheduled" ->
            Scheduled

        "complete" ->
            Complete

        _ ->
            Error


toString : Status -> String
toString status =
    case status of
        Scheduled ->
            "scheduled"

        Complete ->
            "complete"

        Error ->
            "error"
