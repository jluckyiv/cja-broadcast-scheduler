module NotificationOptions exposing (NotificationOptions, decoder, encode, toHtml)

import Html exposing (Html, text)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)


type alias NotificationOptions =
    { body : String
    }


toHtml : NotificationOptions -> Html msg
toHtml options =
    text options.body


decoder : Decoder NotificationOptions
decoder =
    Decode.succeed NotificationOptions
        |> required "body" Decode.string


encode : NotificationOptions -> Value
encode { body } =
    Encode.object
        [ ( "body", Encode.string body )
        ]
