soldiers = {}

function spawnSoldier(x, y)
    soldier = world:newCircleCollider(x, y, 20, {collision_class = "Soldier"})
    soldier:setType('static')
    soldier.dead = false
    soldier.life = 2
    soldier.maxTime = 0.4
    soldier.timer = soldier.maxTime

    table.insert(soldiers, soldier)
end

function updateSoldiers(dt)

    for i, s in ipairs(soldiers) do
        if distanceBetween(player:getX(), player:getY(), s:getX(), s:getY()) < 350 then
            s.timer = s.timer - dt
            if s.timer < 0 then
                createSoldierBullet(s:getX(), s:getY(), soldierPlayerAngle(s), s:getX(), s:getY())
                sounds.gunShot:play()
                s.timer = s.maxTime
            end
        end
    end

end

function drawSoldiers()

    for i, s in ipairs(soldiers) do 
        love.graphics.draw(sprites.soldier, s:getX(), s:getY(), soldierPlayerAngle(s), 0.3, 0.3, 80, 80)
    end

end

-- find the angle between player and the soldier
function soldierPlayerAngle(soldier)
    return math.atan2(player:getY() - soldier:getY(), player:getX() - soldier:getX())
end