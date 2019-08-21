module Api.Payload exposing (Payload, encode)

import Json.Encode as Encode exposing (Value)


type alias Payload =
    { body : String
    , localeString : String
    }


encode : Payload -> Value
encode payload =
    Encode.object
        [ ( "body", Encode.string <| payload.body )
        , ( "localeString", Encode.string <| payload.localeString )
        ]
