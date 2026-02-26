import std/[json, sets, sequtils, strutils, tables]
import jsony

type
  # Types related to JSON intermediate representation.
  JVarKind = enum vkInt, vkFloat, vkString
  JVal = object
    case kind: JVarKind
    of vkInt: intVal: ref int
    of vkFloat: floatVal: ref float
    of vkString: strVal: ref string
  JPoint = object
    x, y: JVal
  JSize = object
    w, h: JVal
  # Looks like the first enum must not be allowed to match the
  # first field of the variant type else strange bug occurs
  ShapeKind = enum skRect, skLine, skPolyLine
  JShape = object
    name: string
    text: string
    penColor: string
    refTo: string
    case kind: ShapeKind
    of skRect:
      pos: JPoint
      size: JSize
      fillColor: string
    of skLine:
      pt0: JPoint
      pt1: JPoint
    of skPolyLine:
      pts: seq[JPoint]
  JVarTable = Table[string, JVal]
  JShapeTable = Table[string, JShape]
  JDoc = object
    vars: JVarTable
    shapes: JShapeTable

  # Real objects
  Point = tuple[x, y: float]
  Size = tuple[w, h: float]
  Shape = ref object of RootObj
    name: string
    text: string
    penColor: string
  Rect = ref object of Shape
    pos: Point
    size: Size
    fillColor: string
  Line = ref object of Shape
    pt0, pt1: Point
  PolyLine = ref object of Shape
    pts: seq[Point]
  ShapeTable = Table[string, Shape]

proc `$`(x: ref SomeNumber): string =
  if x.isNil: "nil"
  else: "→" & $x[]
proc `$`(x: ref string): string =
  if x.isNil: "nil"
  else: "→\"" & x[] & "\""
proc `$`(x: JVal): string =
  result = $x.kind & ": "
  case x.kind
  of vkInt: result &= $x.intVal
  of vkFloat: result &= $x.floatVal
  of vkString: result &= $x.strVal
method `$`(x: Shape): string {.base.} =
  "Base method"
method `$`(x: Rect): string =
  result = "Rect(name: \"" & x.name & "\", "
  result &= "text: \"" & x.text & "\", "
  result &= "pos: (" & $x.pos.x & ", " & $x.pos.y & "), "
  result &= "size: (" & $x.size.w & ", " & $x.size.h & "), "
  result &= "penColor: \"" & x.penColor & "\", "
  result &= "fillColor: \"" & x.fillColor & "\")"
method `$`(x: Line): string =
  result = "Line(name: \"" & x.name & "\", "
  result &= "text: \"" & x.text & "\", "
  result &= "pt0: (" & $x.pt0.x & ", " & $x.pt0.y & "), "
  result &= "pt1: (" & $x.pt1.x & ", " & $x.pt1.y & "), "
  result &= "penColor: \"" & x.penColor & "\")"
method `$`(x: PolyLine): string =
  result = "PolyLine(name: \"" & x.name & "\", text: \"" & x.text &
      "\", pts: " & $x.pts & ", "
  result &= "penColor: \"" & x.penColor & "\")"



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
    # Inspired by parseSymbol in jsony.nim
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
    if inQuote: inc i
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

proc parseHook(s: string, i: var int, val: var JSize) =
  # Parse (w, h)
  var w, h: JVal
  eatChar(s, i, '"')
  eatChar(s, i, '(')
  parseHook(s, i, w)
  eatChar(s, i, ',')
  parseHook(s, i, h)
  eatChar(s, i, ')')
  eatChar(s, i, '"')
  val = JSize(w: w, h: h)

proc number_tests() =
  try:
    echo "Doing JVal"
    echo """ 42 """.fromJson(JVal)
    echo """ +42 """.fromJson(JVal)
    echo """ -42 """.fromJson(JVal)
    echo """ 42e5 """.fromJson(JVal)
    echo """ +42e5 """.fromJson(JVal)
    echo """ -42e5 """.fromJson(JVal)
    echo """ 42e+5 """.fromJson(JVal)
    echo """ +42e+5 """.fromJson(JVal)
    echo """ -42e+5 """.fromJson(JVal)
    echo """ 42e-5 """.fromJson(JVal)
    echo """ +42e-5 """.fromJson(JVal)
    echo """ -42e-5 """.fromJson(JVal)

    echo """  19.0 """.fromJson(JVal)
    echo """ +19.0 """.fromJson(JVal)
    echo """ -19.0 """.fromJson(JVal)
    echo """  19.0e5 """.fromJson(JVal)
    echo """ +19.0e5 """.fromJson(JVal)
    echo """ -19.0e5 """.fromJson(JVal)
    echo """  19.0e+5 """.fromJson(JVal)
    echo """ +19.0e+5 """.fromJson(JVal)
    echo """ -19.0e+5 """.fromJson(JVal)
    echo """  19.0e-5 """.fromJson(JVal)
    echo """ +19.0e-5 """.fromJson(JVal)
    echo """ -19.0e-5 """.fromJson(JVal)

    echo """  21.1 """.fromJson(JVal)
    echo """ +21.1 """.fromJson(JVal)
    echo """ -21.1 """.fromJson(JVal)
    echo """  21.1e5 """.fromJson(JVal)
    echo """ +21.1e5 """.fromJson(JVal)
    echo """ -21.1e5 """.fromJson(JVal)
    echo """  21.1e+5 """.fromJson(JVal)
    echo """ +21.1e+5 """.fromJson(JVal)
    echo """ -21.1e+5 """.fromJson(JVal)
    echo """  21.1e-5 """.fromJson(JVal)
    echo """ +21.1e-5 """.fromJson(JVal)
    echo """ -21.1e-5 """.fromJson(JVal)
  except Exception as e:
    echo e.msg
    echo e.getStackTrace()

proc object_tests() =
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

    echo "Doing JShape with rect"
    echo """{"kind": "skRect", "pos": "(12, 34)", "w": 5, "h": 7.5}""".fromJson(JShape)
    echo ""

    echo "Doing JShape with rect"
    echo """{"kind": "skRect", "pos": "(12, 34)", "w": "boxWidth", "h": "boxHeight"}""".fromJson(JShape)
    echo ""

    echo "Doing JShape without kind"
    echo """{"name": "hello"}""".fromJson(JShape)

  except Exception as e:
    echo e.msg
    echo e.getStackTrace()

proc resolveVal(val: var JVal, JVarTable: JVarTable, expectedKind: set[JVarKind]) =
  # Resolve JVal $var recursively as needed until number is reached
  # If object field needs to be a string, then make it a string, not a JVal
  if val.kind == vkString and val.strVal[].startswith("$"):
    let varname = val.strVal[1 .. ^1]
    if varname in JVarTable:
      val = JVarTable[varname] # -> JVal
      resolveVal(val, JVarTable, expectedKind) # recursively resolve
    else:
      echo "Variable \"", varname, "\" not defined"
  if val.kind notin expectedKind:
    echo "Expected ", expectedKind, " but got ", $val

proc resolveVal(val: var string, vars: JVarTable) =
  # Resolve $string recursively as needed until non-$string is reached
  if val.startsWith("$"):
    let varName = val[1 ..< val.len]
    if varName in vars:
      var resolvedVal = vars[varName]
      resolveVal(resolvedVal, vars, {vkString}) # recursively
      case resolvedVal.kind:
      of vkInt: val = $resolvedVal.intVal[]
      of vkFloat: val = $resolvedVal.floatVal[]
      of vkString: val = resolvedVal.strVal[]
    else:
      echo "Variable ", varName, " not defined2"

proc resolveVals(shape: var JShape, vars: JVarTable) =
  resolveVal(shape.text, vars)
  resolveVal(shape.penColor, vars)
  case shape.kind:
  of skRect:
    resolveVal(shape.pos.x, vars, {vkInt, vkFloat})
    resolveVal(shape.pos.y, vars, {vkInt, vkFloat})
    resolveVal(shape.size.w, vars, {vkInt, vkFloat})
    resolveVal(shape.size.h, vars, {vkInt, vkFloat})
    resolveVal(shape.fillColor, vars)
  of skLine:
    resolveVal(shape.pt0.x, vars, {vkInt, vkFloat})
    resolveVal(shape.pt0.y, vars, {vkInt, vkFloat})
    resolveVal(shape.pt1.x, vars, {vkInt, vkFloat})
    resolveVal(shape.pt1.y, vars, {vkInt, vkFloat})
  of skPolyLine:
    for pt in shape.pts.mitems:
      resolveVal(pt.x, vars, {vkInt, vkFloat})
      resolveVal(pt.y, vars, {vkInt, vkFloat})

proc toFloat(x: JVal): float =
  case x.kind
  of vkInt: result =
    if x.intVal.isNil: 0.0
    else: float(x.intVal[])
  of vkFloat: result =
    if x.floatVal.isNil: 0.0
    else: x.floatVal[]
  else: raise newException(ValueError, "Expected number but got " & $x)

proc nameShapes(doc: var JDoc) =
  for name, jshape in doc.shapes.mpairs:
    jshape.name = name

proc newShape(jshape: JShape): Shape =
  # Create a real shape from JShape with all variables resolved
  case jshape.kind:
  of skRect:
    var res = new Rect
    res.name = jshape.name
    res.text = jshape.text
    res.penColor = jshape.penColor
    res.fillColor = jshape.fillColor
    res.pos = (jshape.pos.x.toFloat, jshape.pos.y.toFloat)
    res.size = (jshape.size.w.toFloat, jshape.size.h.toFloat)
    result = res
  of skLine:
    var res = new Line
    res.name = jshape.name
    res.text = jshape.text
    res.penColor = jshape.penColor
    res.pt0 = (jshape.pt0.x.toFloat, jshape.pt0.y.toFloat)
    res.pt1 = (jshape.pt1.x.toFloat, jshape.pt1.y.toFloat)
    result = res
  of skPolyLine:
    var res = new PolyLine
    res.name = jshape.name
    res.text = jshape.text
    res.penColor = jshape.penColor
    for pt in jshape.pts:
      res.pts.add((pt.x.toFloat, pt.y.toFloat))
    result = res

proc isBlank(shape: Shape): bool =
  shape.name == "" and shape.text == "" and shape.penColor == ""

proc shapesFromFile*(filename: string): ref ShapeTable =
  var doc = readFile(filename).fromJson(JDoc)
  doc.nameShapes()
  for jshape in doc.shapes.mvalues:
    resolveVals(jshape, doc.vars)
  result = new ShapeTable
  for jshape in doc.shapes.values:
    if jshape.refTo.len > 0:
      result[jshape.name] = result[jshape.refTo]
      
      #result[jshape.name].name = jshape.name # override name with current shape's name
    else:
      result[jshape.name] = newShape(jshape)

when isMainModule:
  try:
    #number_tests()
    #object_tests()
    let shapeTable = shapesFromFile("data.json")
    shapeTable["line1"].penColor = "red"
    for kee, shape in shapeTable:
      echo kee, ": ", shape
  except Exception as e:
    echo e.msg
    echo e.getStackTrace()
