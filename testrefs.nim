import std/[json, math, strutils, tables]
import jsony



type
  VarKind = enum vkInt, vkFloat, vkString
  JVal = object
    case kind: VarKind
    of vkInt: intVal: int
    of vkFloat: floatVal: float
    of vkString: strVal: string

  JValRef = object of RootObj
    case kind: VarKind 
    of vkInt: intVal: ref int
    of vkFloat: floatVal: ref float
    of vkString: stringVal: ref string

  ShapeKind = enum skRect, skLine
  JShape = object
    case kind: ShapeKind
    of skRect: x, y, w, h: JValRef
    of skLine: x0, y0, x1, y1: JValRef
  JDoc = object
    vars: Table[string, JVal]
    shapes: Table[string, JShape]

proc parseHook(s: string, i: var int, val: var JValRef) =
  var xf: float
  var xi: int
  var xs: string
  var ii = i
  echo "i before: ", i
  echo "ii before: ", ii
  try:
    parseHook(s, i, xf)
    parseHook(s, ii, xi)
    if xf.round == xf:
      var x = new int
      x[] = xi
      val = JValRef(kind: vkInt, intVal: x)
    else:
      var x = new float
      x[] = xf
      val = JValRef(kind: vkFloat, floatVal: x)
  except Exception as e:
    echo e.msg
    echo "i during1: ", i
    parseHook(s, i, xs)
    echo "i during2: ", i
    var x = new string
    x[] = xs
    val = JValRef(kind: vkString, stringVal: x)
    
  echo "i after: ", i
  echo "ii after: ", ii

  

proc `$`(x: ref SomeNumber):    string = $x[]
# proc `$`(x: ref float):  string = $x[]
proc `$`(x: ref string): string = "\"" & x[] & "\""

var jvr = """[ 1, "2", 3.14, 5.0]""".fromJson(seq[JValRef])
echo jvr

# var jv = readFile("data.json").fromJson(JDoc)
# echo jv




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


  

