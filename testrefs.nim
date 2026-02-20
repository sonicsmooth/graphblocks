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

  # Looks like the first enum must not be allowed to match the
  # first field of the variant type else strange bug occurs
  ShapeKind = enum skPolyLine, skLine, skRect
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

proc parseHook(s: string, i: var int, val: var JVal) =
  var xf: float
  var xi: int
  var ii = i
  try:
    parseHook(s, i, xf)
    parseHook(s, ii, xi)
    # Need to distinguish between ints and various types of floats
    if xf.round == xf:
      var xref = new int
      xref[] = xi
      val = JVal(kind: vkInt, intVal: xref)
    else:
      var xref = new float
      xref[] = xf
      val = JVal(kind: vkFloat, floatVal: xref)
  except Exception as e:
    # Didn't parse as number, try parsing as string with optional quotes
    # Start with optional ", then advance until whitespace, comma, ), or optional closing "
    # then copy string segment
    # Copied with minor modifications from parseSymbol in jsony.nim
    var inQuote = s[i] == '"'
    if inQuote:
      inc i
    var j = i
    while i < s.len:
      if (inQuote and s[i] == '"'):
        break
      if (s[i] in {')', ',', ' ', '\t', '\n', '\r'}):
        break
      inc i
    
    var xref = new string
    if inQuote:
      xref[] = s[j ..< i]
      inc i
    else:
      xref[] = s[j ..< i+1]

    val = JVal(kind: vkString, strVal: xref)
    echo "found: ", val.strVal[]

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



  # echo "Doing JPoint"
  # echo """ "(1, 2)"  """.fromJson(JPoint)
  # echo ""

  # echo "Doing seq of JPoints"
  # echo """ ["(1, 2)", "(3, 4)"]  """.fromJson(seq[JPoint])
  # echo ""

  # echo "Doing JShape with line"
  # echo """{"kind": "skLine", "pt0": "(1, 2)", "pt1": "(3, 4)"}""".fromJson(JShape)
  # echo ""

  # echo "Doing JShape with polyline"
  # echo """{"kind": "skPolyLine", "pts": ["(1, 2)", "(3, 4)"]}""".fromJson(JShape)
  # echo ""

  # echo "Doing JShape with polyline"
  # echo """{"kind": "skPolyLine", "pts": ["(1.5, 2.5)", "($var1, $var2)"]}""".fromJson(JShape)
  # echo ""

  # echo "Doing JShape with rect"
  # echo """{"kind": "skRect", "pos": "(12, 34)", "w": 5, "h": 7.5}""".fromJson(JShape)
  # echo ""

  # echo "Doing JShape with rect"
  # echo """{"kind": "skRect", "pos": "(12, 34)", "w": "boxWidth", "h": "boxHeight"}""".fromJson(JShape)
  # echo ""

  # echo "Doing doc from file"
  # echo readFile("data.json").fromJson(JDoc)
  # echo ""

except Exception as e:
  echo e.msg
  echo e.getStackTrace()

# var doc = readFile("data.json").fromJson(JDoc)
# echo "\nPrinting table of vars:"
# for k,v in doc.vars:
#   echo k, ": ", v 




