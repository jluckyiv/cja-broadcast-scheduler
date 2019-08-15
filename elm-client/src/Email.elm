module Email exposing (Email, decoder, fromString, toString)

import Json.Decode as Decode exposing (Decoder)


type Email
    = Email String


fromString : String -> Email
fromString string =
    Email string


toString : Email -> String
toString (Email email) =
    email


decoder : Decoder Email
decoder =
    Decode.map Email Decode.string
