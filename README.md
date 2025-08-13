# hexMath
## Note: offset coordinate system works properly only with grid systems which has even rows shoved to the right and pointy top hexagons.
Huge thanks to [RedBlobGames](https://www.redblobgames.com/) as their work has inspired me to create this library. Most of the math in this library is adapted from their [Hexagonal grid reference](https://www.redblobgames.com/grids/hexagons/).
* [Getting Started](#getting-started)
  * [Basic Grid](#basic-grid)
  * [Getting Coordinates](#getting-coordinates)
  * [Drawing line through the center of hexes](#drawing-line-through-the-center-of-hexes)
  * [Drawing line with points](#drawing-line-with-points)
* [API Reference](#api-reference)
  * [Properties](#properties)
  * [Hexagon Building](#hexagon-building)
  * [Coordinate Conversions](#coordinate-conversions)
  * [Grid Building](#grid-building)
  * [Hex To Pixel](#hex-to-pixel)
  * [Pixel To Hex](#pixel-to-hex)
  * [Distance](#distance)
  * [Neighbors](#neighbors)
 
*Getting Started*
-
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
local mq, mr = hexMath.pixelToAxialHex(mx, my)
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

*API Reference*
-
This library fully supports two coordinate systems **Offset** (with even `rows` or `y` shoved to the right) and **Axial** for indexing individual hexagons (tiles) in an hexagonal grid.\
As **Offset** is more familiar because it can be indexed by `columns` `(x)` going to the right and `rows` `(y)` goint to the bottom similar so Cartesian coordinate system, 
**Axial** coordinate is based on whole another coordinate system called **Cubic** system. **Axial** system allows us to work with grid logic _like finding neighbors and distance_, it's equivalent to columns being `q` axis works similar to `x` axis of cartesian coordinate system,
it's row equivalent axis `r` is place "diagonally" from `-q` to `+q`.\
For more in-depth and visual explanation ypu should check out this [guide](https://www.redblobgames.com/grids/hexagons/#coordinates) by Red Blob Games.

Properties
-
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

Hexagon building
-
#### `hexMath.hexCoords(x, y)`
Takes `(x, y)` coordinates and builds `coords` table with coordinates of 6 hexagon corners. `(x, y)` being center of this hexagon \
Note: to build hexagon with your desired size, you need to define `hexMath.size`
- Arguments:
   * number `x`
   * number `y`
- Returns:
   * table `points`
- Example:
```lua
hexMath.size = 48 --distance from the center to corner of a hexagon
local coords = hexMath.hexCoord(100, 100)
love.graphics.polygon('line', coords)
-- Draws polygon with center at (100, 100)
```
  
Coordinate Conversions
-

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

Grid Building
-
#### hexMath.hexagonGridAxial(q, r, size)
Returns table with hexagonal grid, that uses axial coordinates, structured like `grid[row][col] = {}`
- Arguments:
   * number `q` - "column" index of the center of the grid in axial coordinate system.
   * number `r` - "row" index of the center of the grid in axial coordinate system.
   * number `size` - distance from the center `(q, r)` to border of the grid.
 - Returns:
    * table `grid` - which contains:
       - table indexed by __row:__ `-size <= row <= +size` - each table contains:
           - table indexed but __col:__ `-size <= col <= +size`
 #### hexMath.hexagonGridOffset(col, row, size)
 Returns table with hexagonal grid, that uses offset coordinates, structured like `grid[row][col] = {}`
 - Argumants:
    * number `col` - column index of the center of the grid in offset coordinate system.
    * number `row` - column index of the center of the grid in offset coordinate system.
    * number `size` - distance from the center `(col, row)` to border of the grid.
  - Returns:
    * table `grid` - which contains:
       - table indexed by __row:__ `-size <= row <= +size` - each table contains:
           - table indexed but __col:__ `-size <= col <= +size`
        
Hex To Pixel
-
#### `hexMath.axialHexToPixel(q, r)`
Converts axial `(q, r)` coordinates to screen coordinates `(x, y)` of the center of the corresponding hex.
- Arguments :
   * number `q`
   * number `r`
 - Returns:
    * number `x`
    * number `y`
#### `hexMath.offsetHexToPixel(col, row)`
Converts offset `(col, row)` coordinates to screen coordinates `(x, y)` of the center of the corresponding hex.
- Arguments :
   * number `col`
   * number `row`
 - Returns:
    * number `x`
    * number `y`
  
Pixel To Hex
-
#### `hexMath.pixelToAxialHex(x, y)`
Converts give screen coordinates `(x, y)` to axial coordinates `(q, r)` 
- Arguments :
   * number `x`
   * number `y`
 - Returns:
    * number `q`
    * number `r`
#### `hexMath.pixelToOffsetHex(x, y)`
Converts give screen coordinates `(x, y)` to offset coordinates `(col, row)` 
- Arguments :
   * number `x`
   * number `y`
 - Returns:
    * number `col`
    * number `row`
  
Distance
-
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
Neighbors
-
#### `hexMath.getAxialNeigbor(hex, vec)`
Gets table with axial coordinates `{q, r}` of the neighboring hex in a given direction vector.
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
Grid Border
-
#### `hexMath.getAxialGridBorder(grid)`
Takes grid (structured like `grid[row][col] = {}`), that uses axial coordinates and returns table `borderHexes` with its border hexes. Can also be used for polygonal shaped grids.
- Arguments:
  * table `grid` - must contain:
      * table `row` - must contains:
         * table `col` _or_ numbers `col`
- Returns:
  * table `borderHexes` a list of border hexes, where each entry is a table containing:
     * table `{q = col, r = row}` - the axial coordinates of the hex.
     * (other tables with axial hex coordinates)...
- Example:
```lua
hexGrid = hexMath.hexagonGridAxial(0, 0 , 5)
local gridOutline = hexMath.getAxialGridBorder(hexGrid)
for _, hex in pairs(gridOutline) do
   local x, y = hexMath.offsetHexToPixel(hex.q, hex.r)
   local coords = hexMath.hexCoords(x, y)
   love.graphics.polygon('line', coords)
end
```
<img width="198" height="170" alt="ExampleBorder" src="https://github.com/user-attachments/assets/b3282402-09ce-434f-86eb-219c665aa5c5" />

#### `hexMath.getOffsetGridBorder(grid)`
Takes grid (structured like `grid[row][col] = {}`), that uses offset coordinates and returns table `borderHexes` with its border hexes. Can also be used for polygonal shaped grids.
- Arguments:
  * table `grid` - must contain:
      * table `row` - must contains:
         * table `col` _or_ numbers `col`
- Returns:
  * table `borderHexes` a list of border hexes, where each entry is a table containing:
     * table `{x = col, y = row}` - the axial coordinates of the hex.
     * (other tables with axial hex coordinates)...
   
Lines
-
#### `hexMath.axialHexLine(startHex, finishHex)`
- Arguments:
  * table `startHex` - must contain:
    * key `q` - number
    * key `r` - number
  * table `finishHex` - must contain:
    * key `q` - number
    * key `r` - number
- Returns:
   * table `hexLine` an array of hexes along the line where each element is:
      * table `{q = col, r = row}` - the axial coordinates of the hex.
      * (other tables with axial hex coordinates)...

#### `hexMath.axialPointLine(startHex, finishHex)`
Returns table with coordinates of the points along the line.
- Arguments:
   * table `startHex` - must contain:
    * key `q` - number
    * key `r` - number
  * table `finishHex` - must contain:
    * key `q` - number
    * key `r` - number
 - Returns:
   * table `lineTable` that contains:
      * number `x1` - x coordinate of first point.
      * number `y1` - y coordinate of first point.
      * number `x2` - x coordinate of second point.
      * number `y2` - y coordinate of second point.
      * number ...
