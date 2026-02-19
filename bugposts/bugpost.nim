import std/[json, strutils]
import jsony



type
  VarKind = enum vkInt, vkFloat, vkString
  JVal = object
    case kind: VarKind
    of vkInt: intVal: int
    of vkFloat: floatVal: float
    of vkString: strVal: string

  JPoint = object of RootObj
    x, y: JVal

  ShapeKind = enum skLine, skPolyLine
  JShape = object
    case kind: ShapeKind
    of skLine:
      pt0: JPoint
      pt1: JPoint
    of skPolyLine:
      pts: seq[JPoint]

proc parseHook(s: string, i: var int, val: var JVal) =
  # Only parse ints for now to keep it simple
  var x: int
  parseHook(s, i, x)
  val = JVal(kind: vkInt, intVal: x)
  echo "created jval: ", val

proc parseHook(s: string, i: var int, val: var JPoint) =
  # Parse (x, y)
  echo "Parsing JPoint at index ", i
  var x, y: JVal
  eatChar(s, i, '"')
  eatChar(s, i, '(')
  parseHook(s, i, x)
  eatChar(s, i, ',')
  parseHook(s, i, y)
  eatChar(s, i, ')')
  eatChar(s, i, '"')
  val = JPoint(x: x, y: y)


try:

  # OK
  echo "Doing JPoint"
  echo """ "(1, 2)" """.fromJson(JPoint)
  echo ""

  # OK
  echo "Doing seq of JPoints"
  echo """ ["(1, 2)", "(3, 4)"]  """.fromJson(seq[JPoint])
  echo ""

  # OK
  echo "Doing JShape with line"
  echo """{"kind": "skLine", "pt0": "(1, 2)", "pt1": "(3, 4)"}""".fromJson(JShape)
  echo ""

  # Error: SIGSEGV: Illegal storage access. (Attempt to read from nil?)
  echo "doing JShape with polyline"
  echo """{"kind": "skPolyLine", "pts": ["(1, 2)", "(3, 4)"]}""".fromJson(JShape)
  echo ""

except Exception as e:
  echo e.msg
  echo e.getStackTrace()
