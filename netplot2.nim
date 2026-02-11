import json_serialization


type
  JPoint = object
    x: JsonNumber[string]
    y: JSonNumber[uint64]
  Point = object
    x: float32
    y: float32

  JsonRpcId = distinct JsonString
  Request = object
    jsonrpc: string
    `method`: string # Quote Nim keywords
    params: seq[int] # Map JSON array to `seq`
    id: JsonRpcId


proc readValue*(r: var JsonReader, value: var JsonRpcId) = #{.raises: [IOError, JsonReaderError].} =
  let tok = r.tokKind
  case tok
  of JsonValueKind.Number, JsonValueKind.String, JsonValueKind.Null:
    value = JsonRpcId(r.parseAsString())
  else:
    r.raiseUnexpectedValue("Invalid RequestId, got " & $tok)
proc writeValue*(w: var JsonWriter, value: JsonRpcId) {.raises: [IOError].} =
  w.writeValue(JsonString(value)) # Preserve the original content


try:
  # let p1 = Json.decode(""" {"id": 15, "jsonrpc":"what"} """, Request)
  # echo p1.id.string
  let p2 = Json.decode("""{"x": "var", "y":20}""", JPoint)
  echo p2
  echo p2.typeof
except JsonError as exc:
  echo "Failed to parse document: ", exc.formatMsg("")


