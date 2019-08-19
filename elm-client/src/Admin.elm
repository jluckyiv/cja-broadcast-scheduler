module Admin exposing (Admin, decoder, isAuthorized)

import Email exposing (Email)
import Json.Decode as Decode exposing (Decoder)


type Admin
    = Admin Email


decoder : Decoder Admin
decoder =
    Decode.map Admin Email.decoder


isAuthorized : Email -> List Admin -> Bool
isAuthorized candidateEmail admins =
    admins
        |> List.map email
        |> List.member candidateEmail


email : Admin -> Email
email (Admin email_) =
    email_
