-- camera/rendering.lua
-- Drawing and depth-related functions

local rendering = {}

-- Calculate isometric depth for sorting
-- Used for proper back-to-front rendering in isometric view
function rendering.calculateIsoDepth(x, y, z)
    -- This depth formula prioritizes x and y equally, with z having double impact
    -- Used for sorting objects and faces from back to front in isometric rendering
    return - (x + y + 2*z)
end

-- Sort objects by their isometric depth (used for painter's algorithm)
function rendering.sortByDepth(objects)
    table.sort(objects, function(a, b)
        local depthA = rendering.calculateIsoDepth(a.x, a.y, a.z)
        local depthB = rendering.calculateIsoDepth(b.x, b.y, b.z)
        return depthA > depthB -- draw farthest objects first
    end)
    return objects
end

-- Calculate depth for a face's center point
function rendering.calculateFaceDepth(corners3D, faceVertices)
    -- Calculate center point of the face
    local centerX, centerY, centerZ = 0, 0, 0
    for _, v in ipairs(faceVertices) do
        centerX = centerX + corners3D[v][1]
        centerY = centerY + corners3D[v][2]
        centerZ = centerZ + corners3D[v][3]
    end
    centerX = centerX / #faceVertices
    centerY = centerY / #faceVertices
    centerZ = centerZ / #faceVertices
    
    -- Use function for depth calculation
    return rendering.calculateIsoDepth(centerX, centerY, centerZ)
end

-- Draw a polygon with the specified vertices and color
function rendering.drawPolygon(vertices, color, outlined)
    -- Fill the polygon with the main color
    love.graphics.setColor(color)
    love.graphics.polygon("fill", 
        vertices[1][1], vertices[1][2],
        vertices[2][1], vertices[2][2],
        vertices[3][1], vertices[3][2],
        vertices[4][1], vertices[4][2]
    )

    -- Draw outline if requested
    if outlined then
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.setLineWidth(1)
        love.graphics.polygon("line",
            vertices[1][1], vertices[1][2],
            vertices[2][1], vertices[2][2],
            vertices[3][1], vertices[3][2],
            vertices[4][1], vertices[4][2]
        )
    end
end

-- Save and restore color state
function rendering.withColor(func)
    local r, g, b, a = love.graphics.getColor()
    func()
    love.graphics.setColor(r, g, b, a)
end

return rendering
