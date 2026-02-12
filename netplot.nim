import jsony
import pixie
# import winim

type
  Point = tuple[x, y: float32]
  Size = tuple[w, h: float32]
  InstanceKind = enum InstNameRef, InstShapeRef

  BigColl = ref object
    shapes: seq[ShapeNode]
  Shape = ref object of RootObj
    name: string
    pos: Point
  ShapeNode = ref object
    rect: Rect
    instance: Instance
    # ... other objects like Circle, Line, etc.
  Rect = ref object of Shape
      lineWidth: float32
      lineColor: string
      size: Size
  Instance = ref object of Shape
    case kind: InstanceKind
    of InstNameRef: nameRef: string
    of InstShapeRef: shapeRef: Shape
  
method `$`(obj: Shape): string {.base.} =  $obj[]
method `$`(obj: Rect): string = $obj[]
method `$`(obj: Instance): string = $obj[]

proc toSeq(coll: BigColl): seq[Shape] =
  # BigColl is seq of ShapeNodes,
  # Each ShapeNode has many members, but 
  # only one of them is valid.  Take the valid
  # one and add it to the output list.  The
  # output may contain "Instance" objects
  for shapeNode in coll.shapes:
    if not isnil(shapeNode.rect):
      result.add(shapeNode.rect)
    elif not isnil(shapeNode.instance):
      result.add(shapeNode.instance)

proc findShapeByName(shapes: seq[Shape], name: string): Shape =
  # Return the first non-instance shape in shapes which has name
  # else return nil
  for s in shapes:
    if s of Instance:
      continue
    if s.name == name:
      return s

proc reify(shapes: seq[Shape]): seq[Shape] =
  # Go through shapes and copy to result seq,
  # converting any Instances by finding their
  # reference and copying those.
  for s in shapes:
    if s of Rect:
      result.add(s)
    elif s of Instance:
      # The cast defaults to the base variant which is JNameRef
      let i = cast[Instance](s) # json instance with named reference
      let refShape = findShapeByName(shapes, i.nameRef)
      if not refShape.isnil:
        # Create new Instance with ref to shape
        let newInst = Instance(kind: InstShapeRef,
                               name: i.name,
                               pos: i.pos,
                               shapeRef: refShape)
        result.add(newInst)

proc loadData(filepath: string): seq[Shape] =
  let jstr = readFile(filepath)
  let shapes = jstr.fromJson(BigColl).toSeq
  result = reify(shapes)

method draw(shape: Shape, ctx: Context, offset: Point=(0,0)) {.base.} = discard
# method draw(shape: Rect, ctx: Context)
# method draw(shape: Instance, cxt: Context)

method draw(shape: Rect, ctx: Context, offset: Point=(0,0)) =
  let
    x = shape.pos.y + offset.x
    y = shape.pos.y + offset.y
    w = shape.size.w
    h = shape.size.h
  ctx.lineWidth = shape.lineWidth
  ctx.strokeStyle = shape.lineColor
  ctx.strokeRect(rect(x,y,w,h))
  
method draw(shape: Instance, ctx: Context, offset: Point=(0,0)) =
  let
    x = shape.pos.x + offset.x
    y = shape.pos.y + offset.y
    os: Point = (x, y)
  shape.shapeRef.draw(ctx, os)
  discard

proc drawBasicPlot(w,h: int, shapes: seq[Shape], filepath: string) =
  let image = newImage(w,h)
  let ctx = newContext(image)
  image.fill(rgba(255, 255, 255, 255))
  for shape in shapes:
    shape.draw(ctx)
  image.writeFile(filepath)
  

when isMainModule:
  let shapes = loadData("data.json")
  drawBasicPlot(600, 300, shapes, "outfile.png")

  let junk = """{"x": 10, "y": 20}"""
  let p = junk.fromJson(Point)
  echo p






