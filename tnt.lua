tnts = {}

function spawnTNT(x, y)
    local tnt = world:newRectangleCollider(x, y, 64, 64, {collision_class = "TNT"})
    tnt:setType('static')


    table.insert(tnts, tnt)
end

function updateTNT(dt)

end

function drawTNT()

    for i,t in ipairs(tnts) do
        love.graphics.draw(sprites.tnt, t:getX(), t:getY(), nil, 1, 1, 32, 32)
    end

end