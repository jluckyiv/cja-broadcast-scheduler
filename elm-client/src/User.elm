module User exposing
    ( User(..)
    , decodeWithDefault
    , decoder
    , displayEmail
    , displayName
    , email
    , fromMaybe
    , uid
    )

import Email exposing (Email)
import Json.Decode as Decode exposing (Decoder, Value, string)
import Json.Decode.Pipeline exposing (required)
import UserId exposing (UserId)


type User
    = SignedIn UserData
    | Anonymous
    | Pending PendingData


type alias UserData =
    { displayName : String
    , uid : UserId
    , email : Email
    }


type alias PendingData =
    String


fromMaybe : Maybe a -> User
fromMaybe maybe =
    case maybe of
        Nothing ->
            Anonymous

        _ ->
            Pending "Pending"


decodeWithDefault : User -> Value -> User
decodeWithDefault default value =
    value
        |> Decode.decodeValue decoder
        |> Result.withDefault default


decoder : Decoder User
decoder =
    Decode.oneOf
        [ Decode.map SignedIn decodeUserData
        , Decode.map Pending decodePendingUserData
        ]


decodeUserData : Decoder UserData
decodeUserData =
    Decode.succeed UserData
        |> required "displayName" string
        |> required "uid" UserId.decoder
        |> required "email" Email.decoder


decodePendingUserData : Decoder PendingData
decodePendingUserData =
    Decode.string


displayName : User -> String
displayName user =
    case user of
        SignedIn data ->
            data.displayName

        Pending _ ->
            "Pending"

        Anonymous ->
            ""


displayEmail : User -> String
displayEmail user =
    case user of
        SignedIn userData ->
            Email.toString userData.email

        Anonymous ->
            ""

        Pending _ ->
            ""


uid : User -> Maybe UserId
uid user =
    case user of
        SignedIn data ->
            Just data.uid

        _ ->
            Nothing


email : User -> Email
email user =
    case user of
        SignedIn data ->
            data.email

        Pending _ ->
            Email.fromString "Pending"

        Anonymous ->
            Email.fromString "Anonymous"
