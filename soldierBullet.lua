soldier_bullets = {}

function createSoldierBullet(x , y, angle, sX, sY)

    bullet = world:newRectangleCollider(x , y, 5, 5, {collision_class = "SoldierBullet"})
    bullet.speed = 650
    bullet.direction = angle  -- The direction in which the bullet will travel
    bullet.soldierX = sX
    bullet.soldierY = sY
    bullet.isVisible = true
    bullet.dead = false

    table.insert(soldier_bullets, bullet)

end

function updateSoldierBullets(dt)

    -- Move the bullets
    for i,b in ipairs(soldier_bullets) do
        b:setX(b:getX() + (math.cos(b.direction) * b.speed * dt))
        b:setY(b:getY() + (math.sin(b.direction) * b.speed * dt))
    end

end

function drawSoldierBullets()

    for i,b in ipairs(soldier_bullets) do
        if distanceBetween(b.soldierX, b.soldierY, b:getX(), b:getY()) > 80 then
            love.graphics.draw(sprites.bullet2, b:getX(), b:getY(), nil, 0.06 , 0.06, 60, 60)
        end
    end

end