import json, jsony, tables



type
  VarKind = enum vkInt, vkFloat, vkString
  ShapeKind = enum skRect, skLine
  JVarVal = object
    case kind: VarKind
    of vkInt: intVal: int
    of vkFloat: floatVal: float
    of vkString: strVal: string
  JShape = object
    case kind: ShapeKind
    of skRect: x,y,w,h: float
    of skLine: x0,y0,x1,y1: float
  JDoc = object
    vars: Table[string, JVarVal]
    shapes: Table[string, JShape]



var jv = readFile("data.json").fromJson(JDoc)
echo jv



#   JVal = object of RootObj
#     name: string
#     case kind: RefKind 
#       of rkInt: intVal: ref int
#       of rkFloat: floatVal: ref float
#       of rkString: stringVal: ref string
#   VarTable = Table[string, ref JVal]

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
# proc `$`(iRef: ref int): string = $iRef[]
# proc `$`(fRef: ref float): string = $fRef[]


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


  

