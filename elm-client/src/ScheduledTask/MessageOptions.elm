module ScheduledTask.MessageOptions exposing (MessageOptions, decoder, encode, toHtml)

import Html exposing (Html, text)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)


type alias MessageOptions =
    { phoneNumber : String
    , body : String
    }


toHtml : MessageOptions -> Html msg
toHtml options =
    text options.body


decoder : Decoder MessageOptions
decoder =
    Decode.succeed MessageOptions
        |> required "phoneNumber" Decode.string
        |> required "body" Decode.string


encode : MessageOptions -> Value
encode { phoneNumber, body } =
    Encode.object
        [ ( "phoneNumber", Encode.string phoneNumber )
        , ( "body", Encode.string body )
        ]
