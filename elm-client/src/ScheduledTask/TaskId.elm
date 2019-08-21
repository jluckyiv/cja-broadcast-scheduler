module ScheduledTask.TaskId exposing
    ( TaskId
    , decoder
    , encode
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type TaskId
    = TaskId String


fromString : String -> TaskId
fromString string =
    TaskId string


toString : TaskId -> String
toString (TaskId id) =
    id


decoder : Decoder TaskId
decoder =
    Decode.map TaskId Decode.string


encode : TaskId -> Value
encode (TaskId taskId) =
    Encode.string taskId
