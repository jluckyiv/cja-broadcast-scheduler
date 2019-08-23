module FirebaseError exposing (FirebaseError, decoder)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type alias FirebaseError =
    { name : String
    , message : String
    , code : String
    }


decoder : Decoder FirebaseError
decoder =
    Json.Decode.succeed FirebaseError
        |> required "name" Json.Decode.string
        |> required "message" Json.Decode.string
        |> required "code" Json.Decode.string
