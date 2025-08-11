local hexMath = {}

--Note: offset functions works properly only with grid system which has even rows and pointy top hexes

hexMath.axialNeighbors = {
        ['East'] = {q = 1, r = 0},
        ['NorthEast'] = {q = 1, r = -1},
        ['NorthWest'] = {q = 0, r = -1},
        ['West'] = {q = -1, r = 0},
        ['SouthWest'] = {q = -1, r = 1},
        ['SouthEast'] = {q = 0, r = 1}
    }

hexMath.offsetToAxial = function(x, y)
    local parity = y%2
    local q = x - (y + parity)/2
    local r = y
    return q, r
end

hexMath.axialToOffset = function(q, r)
    local parity = r % 2
    local col = q + math.floor((r + parity) / 2)
    local row = r
    return col, row
end

hexMath.axialToCube = function(hex)
    local q = hex.q
    local r = hex.r
    local s = -hex.q-hex.r
    return{q,r,s}
end

hexMath.cubeToAxial = function(q, r, s)
    return q, r
end


hexMath.offsetDistance = function(x1, y1, x2, y2)
    local q1, r1 = hexMath.offsetToAxial(x1, y1)
    local q2, r2 = hexMath.offsetToAxial(x2, y2)
    local hex1 = {q = q1, r = r1}
    local hex2 = {q = q2, r = r2}
    return hexMath.axialDistance(hex1, hex2)
end

hexMath.axialDistance = function(hex1, hex2)
    local vec = hexMath.axial_subtract(hex1, hex2)
    return (math.abs(vec.q)+ math.abs(vec.q + vec.r)+ math.abs(vec.r))/2
end

hexMath.axial_subtract = function(hex1, hex2)
    local result = {q = hex1.q - hex2.q, r = hex1.r - hex2.r}
    return result
end

hexMath.axial_add = function(hex, vec)
    local Hex = {q = hex.q + vec.q, r = hex.r + vec.r}
    return Hex
end

hexMath.getAxialNeighbor = function(hex, direction) -- hex = {q, r} direction = string (East, NorthEast etc from axialNeighbors)
    return hexMath.axial_add(hex, hexMath.axialNeighbors[direction])
end

hexMath.getAxialGridBorder = function(grid)
    local outlineHexes = {}
    for row, cols in pairs(grid) do
        for col in pairs(cols) do
            for direction in pairs(hexMath.axialNeighbors) do
                local neighborHex = hexMath.getAxialNeighbor({q = col, r = row}, direction)
                if grid[neighborHex.r] and grid[neighborHex.r][neighborHex.q] then
                else
                    table.insert(outlineHexes, {q = col, r = row})
                end
            end
        end
    end
    return outlineHexes
end

hexMath.getOffsetGridBorder = function(grid)
    local outlineHexes = {}
    for row, cols in pairs(grid) do
        for col in pairs(cols) do
            local q, r = hexMath.offsetToAxial(col, row)
            for direction in pairs(hexMath.axialNeighbors) do
                local neighborHex = hexMath.getAxialNeighbor({q = q, r = r}, direction)
                local neighborOffsetX, neighborOffsetY = hexMath.axialToOffset(neighborHex.q, neighborHex.r)
                if grid[neighborOffsetY] and grid[neighborOffsetY][neighborOffsetX] then
                else
                    table.insert(outlineHexes, {x = col, y = row})
                end
            end
        end
    end
    return outlineHexes
end

hexMath.hexagonGridOffset = function(centerX, centerY, radius)--centerX and centerY in offset grid coordinates
    local grid = {}
    local centerQ, centerR = hexMath.offsetToAxial(centerX, centerY)
    for dq = -radius, radius, 1 do
        for dr = math.max(-radius, -dq - radius), math.min(radius, -dq + radius) do
            local q = centerQ+dq
            local r = centerR+dr
            local col, row = hexMath.axialToOffset(q,r)
            col = math.floor(col)
            row = math.floor(row)
            if not grid[row] then grid[row] = {} end
            grid[row][col] = {}
        end
    end
    return grid
end

hexMath.hexagonGridAxial = function(centerQ, centerR, range) -- centerQ and centerR in axial coordinates of grid system
    local grid = {}
    local radius = range - 1
    for dq = -radius, radius do
        for dr = math.max(-radius, -dq - radius), math.min(radius, -dq + radius) do
            local hex = hexMath.axial_add({q = centerQ, r = centerR}, {q = dq, r = dr})
            if not grid[hex.r] then grid[hex.r] = {} end
            grid[hex.r][hex.q] = {}
        end
    end
    return grid
end

hexMath.pixelToHexOffset = function(x, y, hexSide) --return offset grid position
    local q, r = hexMath.pixelToAxialHex(x, y, hexSide)
    return hexMath.axialToOffset(q, r)
end


hexMath.axialHexToPixel = function(q, r, hexSide) -- return center of the Hex in pixels
    local x = math.sqrt(3)*q + math.sqrt(3)/2*r
    local y = 3/2*r
    x = x*hexSide
    y = y*hexSide
    return x, y
end

hexMath.offsetHexToPixel = function(col, row, hexSide)
    local q, r = hexMath.offsetToAxial(col, row)
    return hexMath.axialHexToPixel(q, r, hexSide)
end

hexMath.hexCoords = function(cx, cy, hexSide) --cx cy center of the hex in pixels
    --cx, cy - of the center
    local coordinates = {}
    for i=0, 5, 1 do
        local rotation = math.rad(-60*i+30)
        local x = cx + hexSide*math.cos(rotation)
        local y = cy + hexSide*math.sin(rotation)
        table.insert(coordinates, x)
        table.insert(coordinates, y)
    end
    return coordinates --returns table with coordinates
end

hexMath.pixelToAxialHex = function(px, py, hexSide)
    local x = px/hexSide
    local y = py/hexSide
    local q = math.sqrt(3)/3 * x - 1/3*y
    local r = 2/3*y
    return hexMath.cubeRound(q, r, -q-r)
end

hexMath.cubeRound = function(cq, cr, cs)
    local q = math.floor(cq+0.5)
    local r = math.floor(cr+0.5)
    local s = math.floor(cs+0.5)

    local q_diff = math.abs(q-cq)
    local r_diff = math.abs(r-cr)
    local s_diff = math.abs(s-cs)

    if q_diff > r_diff and q_diff > s_diff then
        q = -r - s
    elseif r_diff>s_diff then
        r =-q - s
    else
        s = -q -r
    end
    return q, r
end

local function lerp(a,b,t)
    return a + (b-a)*t
end

hexMath.axialLerp = function(a, b, t)
    return lerp(a.q, b.q, t), lerp(a.r, b.r, t), lerp(-a.q-a.r, -b.q-b.r, t)
end

hexMath.axialHexLine = function(startHex, finishHex) --returns hex.q, hex.r of hexes that belongs to the line
    local n = hexMath.axialDistance(startHex, finishHex)
    local result = {}
    for i=0, n do
        local qf, rf, sf = hexMath.axialLerp(startHex, finishHex, i / n)
        local q, r = hexMath.cubeRound(qf, rf, sf) 
        table.insert(result, { q = q, r = r })
    end
    return result
end

hexMath.axialPointLine = function(startHex, finishHex, hexSide) -- returns x, y of points used to draw line
    local n = hexMath.axialDistance(startHex, finishHex)
    local lineTable = {}
    for i = 0, n do
        local qf, rf = hexMath.axialLerp(startHex, finishHex, i / n)
        local x, y = hexMath.axialHexToPixel(qf, rf, hexSide)
        table.insert(lineTable, x)
        table.insert(lineTable, y)
    end
    return lineTable
end


return hexMath