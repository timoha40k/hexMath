# hexMath
## Note: offset coordinate system works properly only with grid systems which has even rows shoved to the right and pointy top hexagons.
Huge thanks to [RedBlobGames](https://www.redblobgames.com/) as they have inspired me to create this library. Most of the math in this library is adapted from their [Hexagonal grid reference](https://www.redblobgames.com/grids/hexagons/).
* [Getting Started](#getting-started)
  * [Basic Grid](#basic-grid)
  * [Getting Coordinates](#getting-coordinates)
  * [Drawing line through the center of hexes](#drawing-line-through-the-center-of-hexes)
  * [Drawing line with points](#drawing-line-with-points)
* [API Reference](#api-reference)
  * [Properties](#properties)
  * [Coordinate Conversions](#coordinate-conversions)
## Getting Started
Download the hexMath.lua file and add it to your project
```lua
hexMath = require('hexMath')
```
### Basic Grid
```lua
function love.load()
    hexMath = require("hexMath")
    hexMath.size = 32 --size being radius of outer circle touching the corners.
    --In other words - size is distance between center of the hexagon to its' corners
    hexMath.origin = {x = love.graphics.getWidth()/2, y = love.graphics.getHeight()/2} --origin is starting coordinates in pixels
    hexGrid = hexMath.hexagonGridAxial(0, 0 , 5) --returns tablewith grid[row][col] = {}
end

function love.draw()
    for row, cols in pairs(hexGrid) do
        for col in pairs(cols) do
            local x, y = hexMath.axialHexToPixel(col, row) --converts axial coordinates to coordinates on the screen
            local coords = hexMath.hexCoords(x, y) --converts given coordinates (in pixel) to coordinates of 6 hexagon corners with (x, y) being center of the hex
            love.graphics.polygon('line', coords)
        end
    end
end
```
![Example grid](preview/ExampleGrid.png)
### Getting Coordinates
```lua
local mx, my = love.mouse.getPosition
local x, y = hexMath.pixelToHexOffset(mx, my)
love.graphics.print("X:"..x..' Y:'..y, 0, 0)
local mq, mr = hexMath.pixelToAxialHex(mx, my)
love.graphics.print("q:"..mq..' r:'..mr,0, 10)
```
![20250811-1431-36 1145406](https://github.com/user-attachments/assets/799622f0-ee2f-4517-8646-59d5e14ce587)
### Drawing line through the center of hexes
```lua
local mx, my = love.mouse.getPosition()
local mq, mr = hexMath.pixelToAxialHex(mx, my
local line = hexMath.axialHexLine({q = 0, r= 0}, {q=mq,r=mr})
for i, hex in ipairs(line) do
    if line[i+1] then
        local x1, y1 = hexMath.axialHexToPixel(hex.q, hex.r)
        local x2, y2 = hexMath.axialHexToPixel(line[i+1].q, line[i+1].r)
        love.graphics.line(x1, y1, x2,y2)
    end
end
```
![20250811-1447-52 5068616](https://github.com/user-attachments/assets/96e7630a-26c2-4cc4-9b8c-35cad4476de0)
### Drawing line with points

```lua
local lineTable = hexMath.axialPointLine({q = 0, r= 0}, {q=mq,r=mr})
love.graphics.line(lineTable)
love.graphics.setPointSize(10)
love.graphics.points(lineTable)
```
![20250811-1452-17 3034069](https://github.com/user-attachments/assets/1117339e-f0cc-4f81-a2c6-4c677a83c1e6)

## API Reference
### Properties
#### `hexMath.origin`
A table containing starting coordinates (in pixels) of grid system.
* Fields:
   * `x` - horizontal starting coordinate. `0` by default.
   * `y` - vertical starting coordiante. `0` by default.
 * Example:
```lua
hexMath.origin.x = 500
hexMath.origin.y = 300
```
#### `hexMath.size`
Contains size of hexagon, used for `axialHexToPixel`, `pixelToOffsetPixel` etc.
```lua
hexMath.size = 32 --value by default
```
#### `hexMath.axialNeighbors`
A lookup table of neighbor directions and their corresponding axial vector.
* Structure
```lua
{
   ['East'] = {q = 1, r = 0},
   ['NorthEast'] = {q = 1, r = -1},
   ['NorthWest'] = {q = 0, r = -1},
   ['West'] = {q = -1, r = 0},
   ['SouthWest'] = {q = -1, r = 1},
   ['SouthEast'] = {q = 0, r = 1}
}
```
Note:\
This table is used internally by functions like [`getAxialNeighbor`](#hexmathgetaxialneigborhex-vec), so
you don't need to worry about it _unless you want_ to redefine directions to suit your grid
### Coordinate Conversions
#### `hexMath.offsetToAxial(col, row)`
Converts offset coordinates `(col, row)` to axial coordinates `(q, r)`
- Arguments:
  * number `col`
  * number `row`
- Returns:
  * number `q`
  * number `r`
#### `hexMath.axialToOffset(q, r)`
Converts offset coordinates `(q, r)` to axial coordinates `(col, row)`.
- Arguments:
  * number `q`
  * number `r`
- Returns:
  * number `col`
  * number `row`
#### hexMath.axialToCube(hex)
Takes table with q and r keys `{q = q, r =r }`. Returns cubic coordinates `(q, r, s)`.
- Arguments:
  * table `hex`
     * key `q`
     * key `r`
- Returns:
  * number `q`
  * number `r`
  * number `s`
#### `hexMath.cubeToAxial(q, r, s)`
- Converts cubic coordinates `q, r, s` to axial cooridnates `q, r`.

### Grid Building

#### hexMath.hexagonGridAxial(q, r, radius)

### Distance
#### `hexMath.offsetDistance(x1, y1, x2, y2)`
Calculates distance between two hexes in offset coordinate system.
- Arguments:
  * number `x1`
  * number `y1`
  * number `x2`
  * number `y2`
- Returns:
  * number `distance`
#### `hexMath.axialDistance(startHex, finishHex)`
Calculates distance between two hexes in axial coordinate system.
- Arguments:
  * table `startHex` - must contain:
     * key `q` - number
     * key `r` - number
  * table `finishHex` - must contain:
     * key `q` - number
     * key `r` - number
- Returns:
  * number `distance`
- Example:
 ```lua
local axialDistance = hexMath.axialDistance({q = 0, r = 0}, {q = 5, r =3}
print(axialDistance)
```
### Neighbors
#### `hexMath.getAxialNeigbor(hex, vec)`
- Arguments:
  * table `hex` - must contain:
     * key `q` - number
     * key `r` - number
  * table `vec` - must contain:
     * key `q` - number
     * key `r` - number
- Returns:
   * table `hex` - that contains:
      * key `q` - number
      * key `r` - number
- Example find neighbors to the right and bottom-left of given hex:
```lua
Hex = {q = 0, r = 0}
hexRight = hexMath.getAxialNeighbor(Hex, hexMath.axialNeighbors['East'])
hexBottomLeft = hexMath.getAxialNeighbor(Hex, hexMath.axialNeighbors['SouthWest'])
local x, y = hexMath.axialHexToPixel(hexRight.q, hexRight.r)
local coords = hexMath.hexCoords(x,y)
love.graphics.polygon('line', coords) --draws hexagon to the right
```

