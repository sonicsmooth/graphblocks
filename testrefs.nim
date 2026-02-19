import std/[json, math, strutils, tables]
import jsony



type
  VarKind = enum vkInt, vkFloat, vkString
  JVal = object
    case kind: VarKind
    of vkInt: intVal: int
    of vkFloat: floatVal: float
    of vkString: strVal: string

  # # JValRef = int
  # JValRef = object of RootObj
  #   case kind: VarKind 
  #   else: intVal: int
  #   # of vkInt: intVal: ref int
  #   # of vkFloat: floatVal: ref float
  #   # of vkString: stringVal: ref string

  JPoint = object of RootObj
    x, y: JVal

  ShapeKind = enum skRect, skLine, skPolyLine
  JShape = object
    case kind: ShapeKind
    of skRect:
      pos: JPoint
      w, h: JVal
    of skLine:
      pt0: JPoint
      pt1: JPoint
    of skPolyLine:
      pts: seq[JPoint]
  JDoc = object
    vars: Table[string, JVal]
    shapes: Table[string, JShape]

# proc parseHook(s: string, i: var int, val: var JValRef) =
#   var xf: float
#   var xi: int
#   var xs: string
#   var ii = i
#   try:
#     parseHook(s, i, xf)
#     parseHook(s, ii, xi)
#     if xf.round == xf:
#       var x = new int
#       x[] = xi
#       val = JValRef(kind: vkInt, intVal: x)
#     else:
#       var x = new float
#       x[] = xf
#       val = JValRef(kind: vkFloat, floatVal: x)
#   except Exception as e:
#     parseHook(s, i, xs)
#     var x = new string
#     x[] = xs
#     val = JValRef(kind: vkString, stringVal: x)

proc parseHook(s: string, i: var int, val: var JVal) =
  var xi: int
  parseHook(s, i, xi)
  # var x = new int
  # x[] = xi
  echo "creating jval"
  val = JVal(kind: vkInt, intVal: xi)
  echo "created jval: ", val

  
proc parseHook(s: string, i: var int, val: var JPoint) =
  echo "Parsing JPoint at index ", i
  # Parse (x, y)
  eatChar(s, i, '(')
  var x,y: JVal
  echo "default kind: ", x.kind
  parseHook(s, i, x)
  eatChar(s, i, ',')
  parseHook(s, i, y)
  eatChar(s, i, ')')
  echo "done with point"
  val = JPoint(x: x, y: y)

# proc parseHook(s: string, i: var int, val: var seq[JPoint]) =
#   echo "Parsing seq of points at index ", i
#   # Parse ["(x1,y1),(x2,y2)"]
#   # eatChar(s, i, '"')
#   eatChar(s, i, '[')
#   while s[i] != ']':
#     echo s[i]
#     var pt: JPoint
#     parseHook(s, i, pt)
#     val.add pt
#     if s[i] == ',':
#       eatChar(s, i, ',')
#   eatChar(s, i, ']')
#   # eatChar(s, i, '"')


proc `$`(x: ref SomeNumber):    string = $x[]
proc `$`(x: ref string): string = "\"" & x[] & "\""

try:

  # echo "Doing JPoint"
  # echo """ (1, 2)  """.fromJson(JPoint)
  # echo ""

  # echo "Doing seq of JPoints"
  # echo """ [(1, 2), (3, 4)]  """.fromJson(seq[JPoint])
  # echo ""

  # echo "Doing JShape with line"
  # echo """{"kind": "skLine", "pt0": (1, 2), "pt1": (3, 4)}""".fromJson(JShape)
  # echo ""

  echo "doing JShape with polyline"
  echo """{"kind": "skPolyLine", "pts": [(1, 2), (3, 4)]}""".fromJson(JShape)
  echo ""

except Exception as e:
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


  

