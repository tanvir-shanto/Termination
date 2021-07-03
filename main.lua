function love.load()

    -- To make the randomization more unique
    math.randomseed(os.time())

    love.mouse.setVisible(false)      -- Hides the mouse

    importLibraries()
    importSprites()
    createGrid()
    createAnimation()
    importAudio()
    createGameWorld()
    addCollisionClasses()
    importAllFiles()

    scoreFont = love.graphics.newFont("fonts/Judges SC.ttf", 40)
    gameOverFont = love.graphics.newFont("fonts/Judges SC.ttf", 55)
    textFont = love.graphics.newFont("fonts/Judges SC.ttf", 22)
    creditsFont = love.graphics.newFont("fonts/Judges SC.ttf", 18)

    -- Timer for spawning zombies in the survival mode
    maxTime = 2
    timer = maxTime

    gameState = 1 -- 1 represents menu, 2 represents play (Either survival or mission), 3 represents credits, 4 represents player dead, 5 represents game over
    playState = 2 -- 2 represents mission, 1 represents survival

    flagX = -200
    flagY = -200

    saveData = {}   -- To save certain data
    saveData.currentLevel = "level1"

    -- Load info from data.lua
    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()    -- Update all the info/data related to saveData table
    end

    -- Read the credis from a file
    creditText, size = love.filesystem.read( "credits/License.txt" , 822)

end


-- Imports the external libraries
function importLibraries()

    -- Import Simple-Tiled-Implementation library
    sti = require 'libraries/Simple-Tiled-Implementation/sti'

    -- Import 'hump' library to include camera support
    cameraFile = require 'libraries/hump/camera'
    cam = cameraFile()      -- Create the cameras
    anim8 = require 'libraries/anim8/anim8'

    -- Import windfield to handle the physics in the project
    wf = require 'libraries/windfield/windfield' 

    require('libraries/show')   -- To save data/ serialization


end

function importSprites()

    sprites = {}
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.soldier = love.graphics.newImage('sprites/soldier.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.bullet2 = love.graphics.newImage('sprites/bullet2.png')
    sprites.crosshair = love.graphics.newImage('sprites/crosshair.png')
    sprites.heart = love.graphics.newImage('sprites/heart.png')
    sprites.tnt = love.graphics.newImage('sprites/tnt.png')
    sprites.background = love.graphics.newImage('sprites/background.png')

    sprites.yellowBackground = love.graphics.newImage('sprites/yellowBackground.png')
    sprites.blueBackground = love.graphics.newImage('sprites/blueBackground.png')
    sprites.brownBackground = love.graphics.newImage('sprites/brownBackground.png')
    sprites.greenBackground = love.graphics.newImage('sprites/greenBackground.png')
    sprites.gameOverScreen = love.graphics.newImage('sprites/gameOverScreen.png')
    
    -- The fruits
    sprites.apple = love.graphics.newImage('sprites/apple.png')
    sprites.berry = love.graphics.newImage('sprites/berry.png')
    sprites.orange = love.graphics.newImage('sprites/orange.png')

    sprites.zombieSheet = love.graphics.newImage('sprites/zombie.png')
    sprites.explosionSheet = love.graphics.newImage('sprites/Explosion.png')

    sprites.mainMenuBackground = love.graphics.newImage('sprites/mainMenu.png')

    -- The buttons
    sprites.playButton = love.graphics.newImage('sprites/buttons/playButton.png')
    sprites.creditsButton = love.graphics.newImage('sprites/buttons/creditsButton.png')
    sprites.quitButton = love.graphics.newImage('sprites/buttons/quitButton.png')

end

function createGrid()

    zombieGrid = anim8.newGrid(318, 294 ,sprites.zombieSheet:getWidth(), sprites.zombieSheet:getHeight())  -- Grid for Zombie
    explosionGrid = anim8.newGrid(96, 96, sprites.explosionSheet:getWidth(), sprites.explosionSheet:getHeight())

end

function createAnimation()
    animations = {}

    -- Zombie Animations
    animations.zombieMove = anim8.newAnimation(zombieGrid('1-9', 1), 0.5)
    animations.explosion = anim8.newAnimation(explosionGrid('1-12', 1), 0.1)
end

function importAudio()
    sounds = {}

    sounds.gunShot = love.audio.newSource('audio/gunshot.wav', 'static')
    sounds.gunShot2 = love.audio.newSource('audio/gunshot2.wav', 'static')
    sounds.playerHit = love.audio.newSource('audio/playerHit.wav', 'static')
    sounds.enemyDown = love.audio.newSource('audio/enemyDown.wav', 'static')
    sounds.growl = love.audio.newSource('audio/growl.wav', 'static')
    sounds.bomb = love.audio.newSource('audio/bomb.mp3', 'static')
    sounds.death = love.audio.newSource('audio/death.wav', 'static')
    
    sounds.background = love.audio.newSource('audio/backgroundMusic.wav', 'stream')
    sounds.background:setLooping(true)

end

function createGameWorld()
    world = wf.newWorld(0, 0, false)
    world:setQueryDebugDrawing(true)   -- So that the query objects are visible 
end

function addCollisionClasses()
    world:addCollisionClass('PlayerRadius')
    world:addCollisionClass('TNT')
    world:addCollisionClass('Fruit')
    world:addCollisionClass('Boundary', {ignores = {"PlayerRadius"}})
    world:addCollisionClass('Zombie', {ignores = {"PlayerRadius"}})
    world:addCollisionClass('Soldier', {ignores = {"PlayerRadius"}})
    world:addCollisionClass('Bullet', {ignores = {"PlayerRadius"}})
    world:addCollisionClass('SoldierBullet', {ignores = {"PlayerRadius"}})
    world:addCollisionClass('Player', {ignores = {"Bullet", "PlayerRadius"}})
end

function importAllFiles()
    require('player')
    require('soldier')
    require('bullet')
    require('soldierBullet')
    require('zombie')
    require('boundary')
    require('explosion')
    require('tnt')
    require('fruit')
end


function love.update(dt)

    if (gameState == 2) then
        world:update(dt)

        playerUpdate(dt)
        updateSoldiers(dt)
        updateBullets(dt)
        updateSoldierBullets(dt)
        updateZombies(dt)
        updateExplosion(dt)
    
        checkCollision()

        -- Get player position to pass it to the camera
        local px, py = player:getPosition()
        cam:lookAt(px, py)    -- Look at the player all the time/ Follow the player

        -- Change level if necessary
        local distanceFromFinishLine = distanceBetween(player:getX(), player:getY(), flagX, flagY)
        if distanceFromFinishLine < 32 then
            if saveData.currentLevel == "level1" then           
                player.health = 3
                loadMap("level2")   
            elseif saveData.currentLevel == "level2" then
                player.health = 3   
                loadMap("level3") 
            elseif saveData.currentLevel == "level3" then   -- If the game is finished 
                player.health = 3
                loadMap("level4")
            elseif saveData.currentLevel == "level4" then
                player.health = 3
                loadMap("level5")
            elseif saveData.currentLevel == "level5" then
                player.health = 3
                saveData.currentLevel = "level1"
                gameState = 5
            end
        end

        
        if playState == 2 then
            -- Automatic spawning of zombies
            timer = timer - dt
            if timer <= 0 then
                    -- Determine the side from which the zombies will appear
                local side = math.random(1, 4)

                if side == 1 then  -- Left side of the screen
                    x = -30
                    y = math.random(0, love.graphics.getHeight())
                elseif side == 2 then   -- Right side of the screen
                    x = love.graphics.getWidth() + 30
                    y = math.random(0, love.graphics.getHeight())
                elseif side == 3 then   -- top side of the screen
                    x = math.random(0, love.graphics.getWidth())
                    y = -30
                elseif side == 4 then   -- bottom side of the screen
                    x = math.random(0, love.graphics.getWidth())
                    y = love.graphics.getHeight() + 30
                end
                --spawnZombie(x, y)
                maxTime = 0.95 * maxTime -- maxTime will decrease by 5% everytime a new zombie appears
                timer = maxTime    -- So that the timer gets reset and if it again becomes less than 0, more zombies will spawn (In every 2 seconds 1 zombie will spawn)
            end
        end

    elseif gameState == 4 then
        
    end


end


function updateSurvival(dt)

end


function updateMission(dt)

end


function checkCollision()


    -- Collision between bullet and zombie & bullet and boundary
    for i, z in ipairs(zombies) do 
        if z:enter("Bullet") then
            z.life = z.life - 1
            if z.life < 1 then
                z.dead = true
                player.score = player.score + 1
                sounds.enemyDown:play()
                removeZombie(i)
            end
        end
    end

    for j, b in ipairs(bullets) do
        if b:enter("Zombie") or b:enter("Boundary") then
            b.dead = true
            removeBullet(j)
        end
    end

    -- Collision between enemy bullet and boundary

    for i, b in ipairs(soldier_bullets) do
        if  b:enter("Boundary") then
            b.dead = true
            removeSoldierBullet(i)
        end
    end

    -- Collision between player bullet and soldier
    for i, s in ipairs(soldiers) do 
        if s:enter("Bullet") then
            s.life = s.life - 1
            if s.life < 1 then
                s.dead = true
                player.score = player.score + 2
                sounds.enemyDown:play()
                removeSoldier(i)
            end
        end
    end

    -- Collision between player bullet and TNT crates
    for i, t in ipairs(tnts) do
        if t:enter("Bullet") then
            sounds.bomb:play()
            createExplosionPoint(t:getX(), t:getY())
            removeTNT(i)
        end
    end

    for i, b in ipairs(bullets) do
        if b:enter("TNT") then
            b.dead = true
            removeBullet(i)
        end
    end

    -- Collision between player and soldier bullets
    if player:enter("SoldierBullet") then
        player.health = player.health - 1
        sounds.playerHit:play()

        if player.health <= 0 then
            playerDie()
        end
    end

    -- Player and fruits

    for i, f in ipairs(fruits) do
        if f:enter("Player") then
            if player.health < 3 then
                player.health = player.health + 1
            end
            removeFruit(i)
        end
    end


end


function removeBullet(j)
    bullets[j]:destroy()
    table.remove(bullets, j)
end

function removeZombie(i)
    zombies[i]:destroy()
    table.remove(zombies, i)
end

function removeSoldier(i)
    soldiers[i]:destroy()
    table.remove(soldiers, i)
end

function removeSoldierBullet(i)
    soldier_bullets[i]:destroy()
    table.remove(soldier_bullets, i)
end

function removeTNT(i)
    tnts[i]:destroy()
    table.remove(tnts, i)
end

function removeFruit(i)
    fruits[i]:destroy()
    table.remove(fruits, i)
end


function love.draw()

    if (gameState == 2) then
        --love.graphics.draw(sprites.background)

        if saveData.currentLevel == "level1" then
            love.graphics.draw(sprites.yellowBackground)
        elseif saveData.currentLevel == "level2" then
            love.graphics.draw(sprites.yellowBackground)
        elseif saveData.currentLevel == "level3" then
            love.graphics.draw(sprites.greenBackground)
        elseif saveData.currentLevel == "level4" then
            love.graphics.draw(sprites.blueBackground)
        elseif saveData.currentLevel == "level5" then
            love.graphics.draw(sprites.brownBackground)
        end


        cam:attach()
            -- Draw the map
            gameMap:drawLayer(gameMap.layers["tileView"])
            --gameMap:drawLayer(gameMap.layers["tileView"])

            --world:draw()       -- Draws the colliders in the game world
      
            drawPlayer()
            drawBullets()
            drawSoldierBullets()
            drawZombies()
            drawSoldiers()
            drawTNT()
            drawExplosion()
            drawFruit()

        cam:detach()

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(scoreFont)
        love.graphics.printf(saveData.currentLevel, 0, 0, love.graphics.getWidth(), "left")
       
                    
        -- TEMP Player life
        --love.graphics.printf("".. player.health, 0, 0, love.graphics.getWidth(), "center")

        for i=1,player.health do
            love.graphics.draw(sprites.heart, love.graphics.getWidth() - i * (32 + 4), 10)
        end
                    
        -- Draw the crosshair
        love.graphics.draw(sprites.crosshair, love.mouse.getX() - sprites.crosshair:getWidth()/2, love.mouse.getY() - sprites.crosshair:getHeight()/2)
    elseif gameState == 1 then
        love.graphics.draw(sprites.mainMenuBackground); -- The background

        -- draw the buttons
        love.graphics.draw(sprites.playButton, 40, love.graphics:getHeight()/2)
        love.graphics.draw(sprites.creditsButton, 40, love.graphics:getHeight()/2 + 70)
        love.graphics.draw(sprites.quitButton, 40, love.graphics:getHeight()/2 + 140)

        love.graphics.setFont(textFont)
        love.graphics.printf("Guide:- Press w, s, a, d to move and left mouse button to shoot.",225, love.graphics:getHeight() - 100, 250, "center")

        love.graphics.draw(sprites.crosshair, love.mouse.getX() - sprites.crosshair:getWidth()/2, love.mouse.getY() - sprites.crosshair:getHeight()/2) -- The crosshair
    elseif gameState == 4 then
        love.graphics.draw(sprites.gameOverScreen)

        love.graphics.setColor(255/255,69/255, 51/255)
        love.graphics.setFont(gameOverFont)   -- Set the font for the score
        love.graphics.printf("YOU DIED!!", 0, love.graphics:getHeight()/3, love.graphics.getWidth(), "center")

        love.graphics.setColor(1,1,1)
        love.graphics.setFont(textFont)   -- Set the font for the score
        love.graphics.printf("Press left mouse button to restart, or right mouse button to go to the main menu.", 0, love.graphics:getHeight()/2 + 50, love.graphics.getWidth(), "center")

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.crosshair, love.mouse.getX() - sprites.crosshair:getWidth()/2, love.mouse.getY() - sprites.crosshair:getHeight()/2) -- The crosshair

    elseif gameState == 5 then
        love.graphics.draw(sprites.gameOverScreen)

        love.graphics.setColor(255/255,69/255, 51/255)
        love.graphics.setFont(gameOverFont)   -- Set the font for the score
        love.graphics.printf("GAME OVER. Congratulations!", 0, love.graphics:getHeight()/3, love.graphics.getWidth(), "center")

        love.graphics.setColor(237/255,255/255, 51/255)
        love.graphics.setFont(textFont)   -- Set the font for the score
        love.graphics.printf("Press left mouse button to go to main menu, or right mouse button to see credits.", 0, love.graphics:getHeight()/2 + 50, love.graphics.getWidth(), "center")

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.crosshair, love.mouse.getX() - sprites.crosshair:getWidth()/2, love.mouse.getY() - sprites.crosshair:getHeight()/2) -- The crosshair

    elseif gameState == 3 then
        love.graphics.draw(sprites.gameOverScreen)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(creditsFont)
        love.graphics.printf(creditText, 0, 0, love.graphics.getWidth(), "left")

        love.graphics.setColor(1,0, 0)
        love.graphics.setFont(textFont)   -- Set the font for the score
        love.graphics.printf("Press ESC to go to the main menu", 0, love.graphics:getHeight() - 40, love.graphics.getWidth(), "center")

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.crosshair, love.mouse.getX() - sprites.crosshair:getWidth()/2, love.mouse.getY() - sprites.crosshair:getHeight()/2) -- The crosshair

    end

end


function drawSurvival()

end


function drawMission()

end

-- Map related function
function loadMap(mapName)

    saveData.currentLevel = mapName

    love.filesystem.write("data.lua", table.show(saveData, "saveData"))   -- This will save the saveData table

    destroyAll()
    
    gameMap = sti("maps/" .. mapName.. ".lua")   -- Load the tileMap

    player:setPosition(400, 304)  -- Set the player position

    -- Iterate through all the objects in the map and add them to the boundaries table
    for i, obj in pairs(gameMap.layers["boundary"].objects) do
        spawnBoundary(obj.x, obj.y, obj.width, obj.height)
    end

    for i, obj in pairs(gameMap.layers["zombies"].objects) do
        spawnZombie(obj.x, obj.y)
    end

    
    for i, obj in pairs(gameMap.layers["soldiers"].objects) do
        spawnSoldier(obj.x, obj.y)
    end

    for i, obj in pairs(gameMap.layers["tnt"].objects) do
        spawnTNT(obj.x, obj.y)
    end

    for i, obj in pairs(gameMap.layers["fruits"].objects) do
        spawnFruit(obj.x, obj.y)
    end

    for i, obj in pairs(gameMap.layers["flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end


end

function destroyAll()

    -- Remove previous platforms
    local i = #boundaries
    while i > -1 do
        if boundaries[i] ~= nil then
            boundaries[i]:destroy() 
        end
        table.remove(boundaries, i)
        i = i - 1
    end

    local j = #zombies
    while j > -1 do
        if zombies[j] ~= nil then
            zombies[j]:destroy() 
        end
        table.remove(zombies, j)
        j = j - 1
    end

    local k = #soldiers
    while k > -1 do
        if soldiers[k] ~= nil then
            soldiers[k]:destroy() 
        end
        table.remove(soldiers, k)
        k = k - 1
    end

    local m = #tnts
    while m > -1 do
        if tnts[m] ~= nil then
            tnts[m]:destroy() 
        end
        table.remove(tnts, m)
        m = m - 1
    end

    local n = #fruits
    while n > -1 do
        if fruits[n] ~= nil then
            fruits[n]:destroy() 
        end
        table.remove(fruits, n )
        n = n - 1
    end
end




function love.mousepressed(x , y , button)

    if gameState == 1 then
        if button == 1 then
            if x > 40 and x < 166 and y > love.graphics:getHeight()/2 and y < love.graphics:getHeight()/2 + 40 then
                sounds.background:play()
                gameState = 2
                playState = 2
                loadMap(saveData.currentLevel)
            elseif x > 40 and x < 166 and y > love.graphics:getHeight()/2 + 70 and y < love.graphics:getHeight()/2 + 110 then
                gameState = 3
            elseif x > 40 and x < 166 and y > love.graphics:getHeight()/2 + 140 and y < love.graphics:getHeight()/2 + 180 then
                quitGame()
            end
        end
    elseif gameState == 2 then
        if button == 1 then
            sounds.gunShot2:play()
            createBullet(player:getX() , player:getY())
        end
    elseif gameState == 4 then
        if button == 1 then        -- Restart the game
            sounds.background:play()
            gameState = 2
            player.health = 3
            loadMap(saveData.currentLevel)
        else
            gameState = 1
            player.health = 3
            destroyAll()
        end
    end

end

-- call the spawnZombie() function if spacebar is pressed
function love.keypressed(key)
    if gameState == 2 then
        if key == "escape" then
            sounds.background:stop()
            gameState = 1
        end
    elseif gameState == 3 then
        if key == "escape" then
            sounds.background:stop()
            gameState = 1
        end
    end
end

-- To calculate the distance between two points
function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function quitGame()
    love.event.quit()
end