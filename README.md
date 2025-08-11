# hexMath
Note: offset coordinate system works properly only with grid systems which has even rows shoved to the right and pointy top hexagons.\
Huge thanks to [RedBlobGames](https://www.redblobgames.com/) as they have inspired me to create this library. Most of the math in this library is adapted from their [Hexagonal grid reference](https://www.redblobgames.com/grids/hexagons/).
# Getting Started
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
### Coordinates tracing
```lua
local mx, my = love.mouse.getPosition
local x, y = hexMath.pixelToHexOffset(mx, my, hexSide)
love.graphics.print("X:"..x..' Y:'..y, 0, 0)
local mq, mr = hexMath.pixelToAxialHex(mx, my, hexSide)
love.graphics.print("q:"..mq..' r:'..mr,0, 10)
```
