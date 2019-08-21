module Session exposing (Session, changes, dateString, email, fromUser, init, user)

import Api
import Email exposing (Email)
import User exposing (User)


type DateString
    = DateString String


type Session
    = Session DateString User


init : String -> User -> Session
init string user_ =
    Session (DateString string) user_


user : Session -> User
user (Session _ user_) =
    user_


email : Session -> Email
email session =
    session
        |> user
        |> User.email


dateString : Session -> String
dateString (Session (DateString string) _) =
    string


fromUser : String -> User -> Session
fromUser string user_ =
    init string user_


changes : (Session -> msg) -> Session -> Sub msg
changes toMsg session =
    Api.userChanges (\user_ -> toMsg (fromUser (dateString session) user_))
