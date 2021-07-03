zombies = {}

function spawnZombie(x , y)
    zombie = world:newCircleCollider(x, y, 20, {collision_class = "Zombie"})
    zombie.speed = 140
    zombie.dead = false
    zombie.life = 3
    zombie.animation = animations.zombieMove


    table.insert(zombies, zombie)
end

function updateZombies(dt)

    -- Move them towards the player
    for i, z in ipairs(zombies) do 

        if distanceBetween(player:getX(), player:getY(), z:getX(), z:getY()) < 450 then

            z:setX(z:getX() + (math.cos(zombiePlayerAngle(z))* z.speed * dt))
            z:setY(z:getY() + (math.sin(zombiePlayerAngle(z))* z.speed * dt))

            z.animation:update(dt)
        end
    end


    

end


function drawZombies()

    for i, z in ipairs(zombies) do 
        zombie.animation:draw(sprites.zombieSheet, z:getX(), z:getY(), zombiePlayerAngle(z), 0.3, 0.3, 100, 140)
    end

end

-- find the angle between player and the zombie
function zombiePlayerAngle(zombie)
    return math.atan2(player:getY() - zombie:getY(), player:getX() - zombie:getX())
end