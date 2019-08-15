module Admin exposing (Admin, decoder, isAuthorized)

import Email exposing (Email)
import Json.Decode as Decode exposing (Decoder)


type Admin
    = Admin Email


isAuthorized : Email -> List Admin -> Bool
isAuthorized email_ admins =
    admins
        |> List.map (email >> Email.toString)
        |> List.member (Email.toString email_)


email : Admin -> Email
email (Admin email_) =
    email_


decoder : Decoder Admin
decoder =
    Decode.map (Email.fromString >> Admin) Decode.string
