module UserId exposing (UserId, decoder, fromString, toString)

import Json.Decode as Decode exposing (Decoder)


type UserId
    = UserId String


fromString : String -> UserId
fromString string =
    UserId string


toString : UserId -> String
toString (UserId email) =
    email


decoder : Decoder UserId
decoder =
    Decode.map UserId Decode.string
