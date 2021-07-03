bullets = {}

function createBullet(x , y)
    bullet = world:newRectangleCollider(x , y, 5, 5, {collision_class = "Bullet"})
    bullet.speed = 1000
    bullet.direction = playerMouseAngle()
    bullet.isVisible = true

    table.insert(bullets, bullet)

end


function updateBullets(dt)

    -- Move the bullets
    for i,b in ipairs(bullets) do
        b:setX(b:getX() + (math.cos(b.direction) * b.speed * dt))
        b:setY(b:getY() + (math.sin(b.direction) * b.speed * dt))
    end

end

function drawBullets()

    for i,b in ipairs(bullets) do
       if distanceBetween(playerRadius:getX(), playerRadius:getY(), b:getX(), b:getY()) > 70 then
           love.graphics.draw(sprites.bullet, b:getX(), b:getY(), nil, 0.06 , 0.06, 60, 60)   
       end
    end

end
