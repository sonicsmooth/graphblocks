import std/[json, math, strutils, tables]
import jsony



type
  VarKind = enum vkInt, vkFloat, vkString
  JVal = object
    case kind: VarKind
    of vkInt: intVal: ref int
    of vkFloat: floatVal: ref float
    of vkString: strVal: ref string

  JPoint = object of RootObj
    x, y: JVal

  ShapeKind = enum skPolyLine, skLine
  JShape = object
    case kind: ShapeKind
    # of skRect:
    #   pos: JPoint
    #   w, h: JVal
    of skLine:
      pt0: JPoint
      pt1: JPoint
    of skPolyLine:
      pts: seq[JPoint]
  JDoc = object
    vars: Table[string, JVal]
    shapes: Table[string, JShape]

proc parseHook(s: string, i: var int, val: var JVal) =
  var xf: float
  var xi: int
  var ii = i
  try:
    parseHook(s, i, xf)
    parseHook(s, ii, xi)
    if xf.round == xf:
      var xref = new int
      xref[] = xi
      val = JVal(kind: vkInt, intVal: xref)
    else:
      var xref = new float
      xref[] = xf
      val = JVal(kind: vkFloat, floatVal: xref)
  except Exception as e:
    # Advance until whitespace, comma, or ), then copy string segment
    # Copied with minor modifications from parseSymbol in jsony.nim
    var j = i
    while i < s.len:
      if s[i] in {')', ',', ' ', '\t', '\n', '\r'}:
        break
      inc i
    
    var xref = new string
    xref[] = s[j ..< i]
    val = JVal(kind: vkString, strVal: xref)

proc parseHook(s: string, i: var int, val: var JPoint) =
  # Parse (x, y)
  var x, y: JVal
  eatChar(s, i, '"')
  eatChar(s, i, '(')
  parseHook(s, i, x)
  eatChar(s, i, ',')
  parseHook(s, i, y)
  eatChar(s, i, ')')
  eatChar(s, i, '"')
  val = JPoint(x: x, y: y)

proc `$`(x: ref SomeNumber): string = "→" & $x[]
proc `$`(x: ref string): string = "→\"" & x[] & "\""

try:

  echo "Doing JPoint"
  echo """ "(1, 2)"  """.fromJson(JPoint)
  echo ""

  echo "Doing seq of JPoints"
  echo """ ["(1, 2)", "(3, 4)"]  """.fromJson(seq[JPoint])
  echo ""

  echo "Doing JShape with line"
  echo """{"kind": "skLine", "pt0": "(1, 2)", "pt1": "(3, 4)"}""".fromJson(JShape)
  echo ""

  echo "Doing JShape with polyline"
  echo """{"kind": "skPolyLine", "pts": ["(1, 2)", "(3, 4)"]}""".fromJson(JShape)
  echo ""

  echo "Doing JShape with polyline"
  echo """{"kind": "skPolyLine", "pts": ["(1.5, 2.5)", "($var1, $var2)"]}""".fromJson(JShape)
  echo ""

  echo "Doing doc from file"
  echo readFile("data.json").fromJson(JDoc)
  echo ""

except Exception as e:
  echo e.msg
  echo e.getStackTrace()


# proc newRefInt(name: string, val: int): ref JVal =
#   let iref = new int
#   iref[] = val
#   #result = new RefVal
#   result = new JVal
#   result[] = JVal(kind: rkInt, name: name, intVal: iref)

# proc newRefFloat(name: string, val: float): ref JVal =
#   let fref = new float
#   fref[] = val
#   #result = new RefVal
#   result = new JVal
#   result[] = JVal(kind: rkFloat, name: name, floatVal: fref)

# proc `$`(jvalRef: ref JVal): string =
#   result = jvalRef.name & ": "
#   case jvalRef.kind
#   of rkInt: result = result & $jvalRef.intVal
#   of rkFloat: result = result & $jvalRef.floatVal


# var varTableRef = new VarTable

# var j = str.parseJson() # -> JSonNode
# for varName, varDesc in j["vars"]:
#   let val: JSonNode = varDesc["value"]
#   case varDesc["type"].getStr
#   of "int":
#     varTableRef[varName] = newRefInt(varName, val.getInt)
#   of "float":
#     varTableRef[varName] = newRefFloat(varName, val.getFloat)

# echo varTableRef["myvar1"]
# echo varTableRef["myvar2"]
# echo varTableRef["myvar3"]




