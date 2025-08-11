# hexMath
## Note: offset coordinate system works properly only with grid systems which has even rows shoved to the right and pointy top hexagons.
Huge thanks to [RedBlobGames](https://www.redblobgames.com/) as they have inspired me to create this library. Most of the math in this library is adapted from their [Hexagonal grid reference](https://www.redblobgames.com/grids/hexagons/).
# Getting Started
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
            local x, y = hexMath.axialHexToPixel(col, row, hexSide)
            local coords = hexMath.hexCoords(x, y, hexSide)
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
        local x1, y1 = hexMath.axialHexToPixel(hex.q, hex.r, hexSide)
        local x2, y2 = hexMath.axialHexToPixel(line[i+1].q, line[i+1].r)
        love.graphics.line(x1, y1, x2,y2)
    end
end
```
![20250811-1447-52 5068616](https://github.com/user-attachments/assets/96e7630a-26c2-4cc4-9b8c-35cad4476de0)
### Drawing Line with points

```lua
local lineTable = hexMath.axialPointLine({q = 0, r= 0}, {q=mq,r=mr})
love.graphics.line(lineTable)
love.graphics.setPointSize(10)
love.graphics.points(lineTable)
```
![20250811-1452-17 3034069](https://github.com/user-attachments/assets/1117339e-f0cc-4f81-a2c6-4c677a83c1e6)

## Full functionality is on the wiki

