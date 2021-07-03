explosionX = 0
explosionY = 0
exploding = false

maxExplosionTimer = 1.2
explosionTimer = maxExplosionTimer


function createExplosionPoint(x, y)
    explosionX = x
    explosionY = y

    exploding = true
end

function updateExplosion(dt)
    
    if exploding then
        explosionTimer = explosionTimer - dt
        explosionCollision()
        animations.explosion:update(dt)
        if explosionTimer < 0 then
            explosionTimer = maxExplosionTimer
            exploding = false
            explosionX = 0
            explosionY = 0
        end
    end

end

function drawExplosion()
    if exploding then
        animations.explosion:draw(sprites.explosionSheet, explosionX, explosionY, nil, 1.5, 1.5, 40, 40 )
    end
end

function explosionCollision()
    for i, z in ipairs(zombies) do
        if distanceBetween(z:getX(), z:getY(), explosionX, explosionY) < 130 then
            z.life = 0
            removeZombie(i)
        end
    end

    for i, s in ipairs(soldiers) do
        if distanceBetween(s:getX(), s:getY(), explosionX, explosionY) < 130 then
            s.life = 0
            removeSoldier(i)
        end
    end
end