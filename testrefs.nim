import std/[json, math, strutils, tables]
import jsony



type
  VarKind = enum vkInt, vkFloat, vkString
  JVal = object
    case kind: VarKind
    of vkInt: intVal: ref int
    of vkFloat: floatVal: ref float
    of vkString: strVal: ref string

  JPoint = object
    x, y: JVal

  # Looks like the first enum must not be allowed to match the
  # first field of the variant type else strange bug occurs
  ShapeKind = enum skRect, skLine, skPolyLine
  JShape = object
    name: string
    text: string
    case kind: ShapeKind
    of skRect:
      pos: JPoint
      w, h: JVal
    of skLine:
      pt0: JPoint
      pt1: JPoint
    of skPolyLine:
      pts: seq[JPoint]
  VarTable = Table[string, JVal]
  ShapeTable = Table[string, JShape]
  JDoc = object
    vars: VarTable
    shapes: ShapeTable

proc `$`(x: ref SomeNumber): string = "→" & $x[]
proc `$`(x: ref string): string = "→\"" & x[] & "\""

proc isStringOnly(x: JVal): bool =
  x.kind == vkString and not x.strVal[].startswith("$")

proc parseHook(s: string, i: var int, val: var JVal) =
  var xf: float
  let j = i
  try:
    parseHook(s, i, xf)
    if '.' in s[j ..< i] or
       'e' in s[j ..< i] or
       'E' in s[j ..< i]:
      var xref = new float
      xref[] = xf
      val = JVal(kind: vkFloat, floatVal: xref)
    else:
      var xref = new int
      xref[] = xf.int
      val = JVal(kind: vkInt, intVal: xref)
  except Exception:
    # Didn't parse as number, try parsing as string with optional quotes
    # Copied with minor modifications from parseSymbol in jsony.nim
    var inQuote = s[i] == '"'
    if inQuote: inc i
    var j = i
    while i < s.len:
      if (inQuote and s[i] == '"') or 
         (s[i] in {')', ',', '\t', '\n', '\r'}):
        break
      inc i
    var xref = new string
    xref[] = s[j ..< i].strip()
    #echo "got string: ->", xref[], "<-"
    if inQuote: inc i
    val = JVal(kind: vkString, strVal: xref)

proc parseHook(s: string, i: var int, val: var JPoint) =
  # Parse (x, y)
  var x, y: JVal
  eatChar(s, i, '"')
  eatChar(s, i, '(')
  parseHook(s, i, x)
  if x.isStringOnly:
    echo "Warning: \"", x.strVal[], "\" as x value in point"
  eatChar(s, i, ',')
  parseHook(s, i, y)
  if y.isStringOnly:
    echo "Warning: \"", y.strVal[], "\" as y value in point"
  eatChar(s, i, ')')
  eatChar(s, i, '"')
  val = JPoint(x: x, y: y)

# proc tests() = 
#   try:
#       echo "Doing JVal"
#       echo """ 42 """.fromJson(JVal)
#       echo """ +42 """.fromJson(JVal)
#       echo """ -42 """.fromJson(JVal)
#       echo """ 42e5 """.fromJson(JVal)
#       echo """ +42e5 """.fromJson(JVal)
#       echo """ -42e5 """.fromJson(JVal)
#       echo """ 42e+5 """.fromJson(JVal)
#       echo """ +42e+5 """.fromJson(JVal)
#       echo """ -42e+5 """.fromJson(JVal)
#       echo """ 42e-5 """.fromJson(JVal)
#       echo """ +42e-5 """.fromJson(JVal)
#       echo """ -42e-5 """.fromJson(JVal)

#       echo """  19.0 """.fromJson(JVal)
#       echo """ +19.0 """.fromJson(JVal)
#       echo """ -19.0 """.fromJson(JVal)
#       echo """  19.0e5 """.fromJson(JVal)
#       echo """ +19.0e5 """.fromJson(JVal)
#       echo """ -19.0e5 """.fromJson(JVal)
#       echo """  19.0e+5 """.fromJson(JVal)
#       echo """ +19.0e+5 """.fromJson(JVal)
#       echo """ -19.0e+5 """.fromJson(JVal)
#       echo """  19.0e-5 """.fromJson(JVal)
#       echo """ +19.0e-5 """.fromJson(JVal)
#       echo """ -19.0e-5 """.fromJson(JVal)

#       echo """  21.1 """.fromJson(JVal)
#       echo """ +21.1 """.fromJson(JVal)
#       echo """ -21.1 """.fromJson(JVal)
#       echo """  21.1e5 """.fromJson(JVal)
#       echo """ +21.1e5 """.fromJson(JVal)
#       echo """ -21.1e5 """.fromJson(JVal)
#       echo """  21.1e+5 """.fromJson(JVal)
#       echo """ +21.1e+5 """.fromJson(JVal)
#       echo """ -21.1e+5 """.fromJson(JVal)
#       echo """  21.1e-5 """.fromJson(JVal)
#       echo """ +21.1e-5 """.fromJson(JVal)
#       echo """ -21.1e-5 """.fromJson(JVal)

#       echo "Doing JPoint"
#       echo """ "(1, 2)"  """.fromJson(JPoint)
#       echo ""

#       echo "Doing seq of JPoints"
#       echo """ ["(1, 2)", "(3, 4)"]  """.fromJson(seq[JPoint])
#       echo ""

#       echo "Doing JShape with line"
#       echo """{"kind": "skLine", "pt0": "(1, 2)", "pt1": "(3, 4)"}""".fromJson(JShape)
#       echo ""

#       echo "Doing JShape with polyline"
#       echo """{"kind": "skPolyLine", "pts": ["(1, 2)", "(3, 4)"]}""".fromJson(JShape)
#       echo ""

#       echo "Doing JShape with polyline"
#       echo """{"kind": "skPolyLine", "pts": ["(1.5, 2.5)", "($var1, $var2)"]}""".fromJson(JShape)
#       echo ""

#       echo "Doing JShape with rect"
#       echo """{"kind": "skRect", "pos": "(12, 34)", "w": 5, "h": 7.5}""".fromJson(JShape)
#       echo ""

#       echo "Doing JShape with rect"
#       echo """{"kind": "skRect", "pos": "(12, 34)", "w": "boxWidth", "h": "boxHeight"}""".fromJson(JShape)
#       echo ""

#       echo "Doing doc from file"
#       echo readFile("data.json").fromJson(JDoc)
#       echo ""

#   except Exception as e:
#     echo e.msg
#     echo e.getStackTrace()

proc resolveVal(val: var JVal, vars: VarTable) =
  # Resolve JVal $var recursively as needed until number is reached
  # If object field needs to be a string, then make it a string, not a JVal
  if val.kind == vkString and val.strVal[].startswith("$"):
    let varname = val.strVal[1 .. ^1]
    if varname in vars:
      val = vars[varname] # -> JVal
      resolveVal(val, vars) # recursively resolve in case of nested references
    else:
      echo "Variable \"", varname, "\" not defined"
  else:
    # done recursing
    if val.kind == vkString:
      echo "Warning: Cannot use \"", val.strVal[], "\" as a number"

proc resolveVal(val: var string, vars: VarTable) =
  # Resolve $string recursively as needed until non-$string is reached
  if val.startsWith("$"):
    let varName = val[1 ..< val.len]
    if varName in vars:
      var resolvedVal = vars[varName]
      resolveVal(resolvedVal, vars) # recursively resolve in case of nested references
      case resolvedVal.kind:
      of vkInt: val = $resolvedVal.intVal[]
      of vkFloat: val = $resolvedVal.floatVal[]
      of vkString: val = resolvedVal.strVal[]
    else:
      echo "Variable ", varName, " not defined2"

proc resolveVals(shape: var JShape, vars: VarTable) =
  resolveVal(shape.text, vars)
  case shape.kind:
  of skRect:
    resolveVal(shape.pos.x, vars)
    resolveVal(shape.pos.y, vars)
    resolveVal(shape.w, vars)
    resolveVal(shape.h, vars)
  of skLine:
    resolveVal(shape.pt0.x, vars)
    resolveVal(shape.pt0.y, vars)
    resolveVal(shape.pt1.x, vars)
    resolveVal(shape.pt1.y, vars)
  of skPolyLine:
    for pt in shape.pts.mitems:
      resolveVal(pt.x, vars)
      resolveVal(pt.y, vars)

proc nameShapes(doc: var JDoc) =
  for key, shape in doc.shapes.mpairs:
    shape.name = key

try:
  var doc = readFile("data.json").fromJson(JDoc)
  nameShapes(doc)

  for shape in doc.shapes.mvalues:
    resolveVals(shape, doc.vars)
    echo shape

except Exception as e:
  echo e.msg
  echo e.getStackTrace()



