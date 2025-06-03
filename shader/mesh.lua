-- shader/mesh.lua
-- Cube mesh generation and instance data management for GPU rendering

local mesh = {}
local geometry = require('cube.geometry')

-- Create a single cube mesh that will be instanced
function mesh.create()
    -- Define the vertices for all faces
    local vertices = {}
    
    -- Loop through each face of the cube
    for faceIndex, faceVertices in ipairs(geometry.faces) do
        -- Get face normal (simple approach - could be improved)
        local normal = mesh.getFaceNormal(faceIndex)
        
        -- Each face is drawn as 2 triangles (6 vertices)
        -- Triangle 1: v1, v2, v3
        table.insert(vertices, {
            geometry.cornerOffsets[faceVertices[1]][1],
            geometry.cornerOffsets[faceVertices[1]][2],
            geometry.cornerOffsets[faceVertices[1]][3],
            normal[1], normal[2], normal[3],
            faceIndex,
            0.0, 0.0  -- Bottom-left texture coordinate
        })
        table.insert(vertices, {
            geometry.cornerOffsets[faceVertices[2]][1],
            geometry.cornerOffsets[faceVertices[2]][2],
            geometry.cornerOffsets[faceVertices[2]][3],
            normal[1], normal[2], normal[3],
            faceIndex,
            1.0, 0.0  -- Bottom-right texture coordinate
        })
        table.insert(vertices, {
            geometry.cornerOffsets[faceVertices[3]][1],
            geometry.cornerOffsets[faceVertices[3]][2],
            geometry.cornerOffsets[faceVertices[3]][3],
            normal[1], normal[2], normal[3],
            faceIndex,
            1.0, 1.0  -- Top-right texture coordinate
        })
        
        -- Triangle 2: v1, v3, v4
        table.insert(vertices, {
            geometry.cornerOffsets[faceVertices[1]][1],
            geometry.cornerOffsets[faceVertices[1]][2],
            geometry.cornerOffsets[faceVertices[1]][3],
            normal[1], normal[2], normal[3],
            faceIndex,
            0.0, 0.0  -- Bottom-left texture coordinate (same as first triangle)
        })
        table.insert(vertices, {
            geometry.cornerOffsets[faceVertices[3]][1],
            geometry.cornerOffsets[faceVertices[3]][2],
            geometry.cornerOffsets[faceVertices[3]][3],
            normal[1], normal[2], normal[3],
            faceIndex,
            1.0, 1.0  -- Top-right texture coordinate (same as first triangle)
        })
        table.insert(vertices, {
            geometry.cornerOffsets[faceVertices[4]][1],
            geometry.cornerOffsets[faceVertices[4]][2],
            geometry.cornerOffsets[faceVertices[4]][3],
            normal[1], normal[2], normal[3],
            faceIndex,
            0.0, 1.0  -- Top-left texture coordinate
        })
    end
    
    -- Define the vertex format for our mesh
    local vertexFormat = {
        {"VertexPosition", "float", 3},  -- x, y, z
        {"VertexNormal", "float", 3},    -- nx, ny, nz
        {"VertexFaceIndex", "float", 1}, -- face index (1-6)
        {"VertexTexCoord", "float", 2}   -- u, v texture coordinates for wireframe
    }
    
    -- Create the mesh
    local mesh = love.graphics.newMesh(vertexFormat, vertices, "triangles", "static")
    return mesh
end

-- Get the normal for a specific face
function mesh.getFaceNormal(faceIndex)
    -- Pre-defined normals for each face
    -- These match the order in geometry.faces
    local normals = {
        {0, 0, 1},    -- top (1)
        {0, 0, -1},   -- bottom (2)
        {0, -1, 0},   -- front (3)
        {1, 0, 0},    -- right (4)
        {0, 1, 0},    -- back (5)
        {-1, 0, 0}    -- left (6)
    }
    
    return normals[faceIndex]
end

-- Create instance data for an array of cubes
function mesh.createInstanceData(visibleCubes)
    -- Create a table to hold instance data
    local instanceData = {}
    
    for _, cube in ipairs(visibleCubes) do
        -- Calculate face visibility flags (as a bit field)
        local visibilityFlags = 0
        for _, faceInfo in ipairs(cube.visibleFaces) do
            visibilityFlags = visibilityFlags + 2^(faceInfo.index-1)
        end
        
        -- Add this cube's instance data
        table.insert(instanceData, {
            cube.x, cube.y, cube.z,              -- InstancePosition
            cube.color[1], cube.color[2], cube.color[3], 1.0,  -- InstanceColor
            visibilityFlags                       -- InstanceVisibility
        })
    end
    
    -- Create a mesh with the instance data
    local format = {
        {"InstancePosition", "float", 3},
        {"InstanceColor", "float", 4},
        {"InstanceVisibility", "float", 1}
    }
    
    local instanceMesh = love.graphics.newMesh(format, instanceData, nil, "dynamic")
    return instanceMesh, #instanceData
end

return mesh
