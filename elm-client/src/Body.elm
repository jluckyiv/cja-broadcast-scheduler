module Body exposing (Body, new, toString)


type Body
    = Body String


new : String -> Maybe Body
new string =
    Just (Body string)


toString : Body -> String
toString (Body string) =
    string
