player = world:newCircleCollider(400, 304, 20, {collision_class = "Player"})
playerRadius = world:newCircleCollider(100, 100, 70, {collision_class = "PlayerRadius"})
player.speed = 250
player.health = 3
player.dead = false
player.recovering = false
player.score = 0

-- Timer for player recovery
maxRecoveryTime = 2
recoveryTimer = maxRecoveryTime


function playerUpdate(dt)

    -- Keyboard update
    local px, py = player:getPosition()
    if love.keyboard.isDown('d') then
        player:setX(px + player.speed*dt)
    end
    if love.keyboard.isDown('a') then
        player:setX(px - player.speed*dt)
    end
    if love.keyboard.isDown('w') then
        player:setY(py - player.speed*dt)
    end
    if love.keyboard.isDown('s') then
        player:setY(py + player.speed*dt)
    end

    -- Reset the playerRadius
    playerRadius:setX(player:getX())
    playerRadius:setY(player:getY())

    -- Timer update
    if player.recovering then
        recoveryTimer = recoveryTimer - dt
        if recoveryTimer < 0 then
            player.recovering = false
            recoveryTimer = maxRecoveryTime
        end
    end

    -- Check collison with zombies or other type of danger
    -- Collision between player and the zombies


    for i,z in ipairs(zombies) do
        if distanceBetween(z:getX(), z:getY(), player:getX(), player:getY()) < 41 then
            if not(player.recovering) then
                player.recovering = true
                player.health = player.health - 1

                if player.health <= 0 then
                    playerDie()
                end

            end
        end
    end


end

function drawPlayer()
    love.graphics.draw(sprites.player, player:getX(), player:getY(), playerMouseAngle(), 0.3, 0.3, 70, 90)
end

-- find the angle between player and the mouse
function playerMouseAngle()
    --return math.atan2(player:getY() - love.mouse.getY(), player:getX() - love.mouse.getX()) + math.pi
    return math.atan2(304 - love.mouse.getY(), 400 - love.mouse.getX()) + math.pi
    -- math.pi simply flips the angle
end

function playerDie()
    sounds.death:play()
    gameState = 4
end