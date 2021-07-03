boundaries = {}


-- Platform (Object Layer) related function
function spawnBoundary(x, y, width, height)
    -- Create a platform for the player
    local boundary = world:newRectangleCollider(x, y, width, height, {collision_class = "Boundary"})
    boundary:setType('static')   -- Setting it to static because we don't want it to be affected by any force

    table.insert(boundaries, boundary)    -- Add the platform object to the platforms table
end