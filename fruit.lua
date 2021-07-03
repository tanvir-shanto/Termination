fruits = {}

function spawnFruit(x, y)
    local fruit = world:newRectangleCollider(x, y, 24, 24, {collision_class = "Fruit"})
    fruit:setType('static')
    fruit.image = sprites.orange

    decider = math.random(1,3)

    if decider == 1 then
        fruit.image = sprites.orange
    elseif decider == 2 then
        fruit.image = sprites.apple   
    end


    table.insert(fruits, fruit)
end

function updateFruit(dt)

end

function drawFruit()

    for i,f in ipairs(fruits) do
       love.graphics.draw(f.image, f:getX(), f:getY(), nil, 0.03, 0.03, 380, 380)
    end

end