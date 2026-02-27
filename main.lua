-- graphics
local screenWidth, screenHeight
local scoreFont, scoreFontS, scoreFontXS

-- paddles
local lpX, lpY
local rpX, rpY
local paddleHeight, paddleWidth

-- ball
local bX, bY
local bSize
local bXVel, bYVel
local prevX, prevY
local blueTrail, redTrail

-- gameplay
local lScore, rScore
local pause
local lastHit

-- debug
local showDebug
local debugFont
local bounceCount

-- draws 2 boxes colored in the players colors and overlays their respective scores onto them
function drawScores()
    local rectWidth = 95
    local rectHeight = 120
    local distX = 80
    local distY = 80

    -- same Y value for both boxes
    local boxY = screenHeight - distY - rectHeight

    local leftBoxX = (screenWidth / 2) - distX - rectWidth
    local rightBoxX = (screenWidth / 2) + distX

    -- fill blue rectangle to the left of the center line
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.rectangle("fill", leftBoxX, boxY, rectWidth, rectHeight)

    -- determine font size depending on score's number of digits
    local leftFont
    if lScore < 10 then
        leftFont = scoreFont
    elseif lScore < 100 then
        leftFont = scoreFontS
    else
        leftFont = scoreFontXS
    end
    love.graphics.setFont(leftFont)

    -- center text within rectangle
    local lTextW = leftFont:getWidth(tostring(lScore))
    local lTextH = leftFont:getHeight()
    local lTextX = leftBoxX + (rectWidth / 2) - (lTextW / 2)
    local lTextY = boxY + (rectHeight / 2) - (lTextH / 2)

    -- print score
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(lScore), math.floor(lTextX), math.floor(lTextY))

    -- fill red rectangle to the right of the center line
    love.graphics.setColor(1, 0, 0, 1) -- red
    love.graphics.rectangle("fill", rightBoxX, boxY, rectWidth, rectHeight)

    -- determine font size depending on score's number of digits
    local rightFont
    if rScore < 10 then
        rightFont = scoreFont
    elseif rScore < 100 then
        rightFont = scoreFontS
    else
        rightFont = scoreFontXS
    end
    love.graphics.setFont(rightFont)

    -- center text within rectangle
    local rTextW = rightFont:getWidth(tostring(rScore))
    local rTextH = rightFont:getHeight()
    local rTextX = rightBoxX + (rectWidth / 2) - (rTextW / 2)
    local rTextY = boxY + (rectHeight / 2) - (rTextH / 2)

    -- print score
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(rScore), math.floor(rTextX), math.floor(rTextY))
end

-- draws a width wide center line on the screen, breaks = number of segments, distance = distance between each segment
function drawCenterLine(width, breaks, distance) 
    love.graphics.setColor(0.98, 0.98, 0.98, 1) 
    
    local segmentHeight = screenHeight / breaks
    
    for i = 0, breaks - 1 do

        local yPos = i * segmentHeight
        
        love.graphics.rectangle("fill", (screenWidth / 2) - (width / 2), yPos + (distance / 2), width, segmentHeight - distance)
    end
end

-- draws both player's paddle on the screen in their respective color
function drawPaddles()
    -- left paddle
    love.graphics.setColor(0,0,1,1) -- blue
    love.graphics.rectangle("fill", lpX, lpY, paddleWidth, paddleHeight)

    -- right paddle
    love.graphics.setColor(1,0,0,1) -- red
    love.graphics.rectangle("fill", rpX, rpY, paddleWidth, paddleHeight)
end

-- draws the ball as well as a trail, colored in the color of the player who last hit the ball
function drawBall()
    if lastHit == "none" then
        love.graphics.setColor(0.94,0.94,0.94,0.5)
    elseif lastHit == "blue" then
        love.graphics.setColor(0,0,1,0.5)
    elseif lastHit == "red" then
        love.graphics.setColor(1,0,0,0.5)
    end
    love.graphics.rectangle("fill", prevX, prevY, bSize+1, bSize+1)
    love.graphics.setColor(0.98,0.98,0.98,1)
    love.graphics.rectangle("fill", bX, bY, bSize, bSize)
end

-- allows for movement of 
-- the left (blue) paddle: W = up, S = down
-- the right (red) paddle: ↑ = up, ↓ = down
function movePaddles(dt)

    local vertSpeed = 1700
    if love.keyboard.isDown("w") then
        if lpY > 0 then
            lpY = lpY - (vertSpeed * dt)
        end
    end
    if love.keyboard.isDown("s") then
        if lpY+paddleHeight < screenHeight then
            lpY = lpY + (vertSpeed * dt)
        end
    end
    if love.keyboard.isDown("up") then
        if rpY > 0 then
            rpY = rpY - (vertSpeed * dt)
        end
    end
    if love.keyboard.isDown("down") then
        if rpY+paddleHeight < screenHeight then
            rpY = rpY + (vertSpeed * dt)
        end
    end
end

-- moves the ball by it's current velocity divided by frame delta
-- also saves the balls previous position for the trail effect
function moveBall(dt)
    prevX, prevY = bX-(bXVel*dt), bY-(bYVel*dt)
    bX = bX + (bXVel * dt)
    bY = bY + (bYVel * dt)
end

-- checks for collisions between the ball and the left (blue) paddle
function checkLeftPaddle()
    if bX < lpX + paddleWidth and bX + bSize > lpX then
        if bY < lpY + paddleHeight and bY + bSize > lpY then
            bX = lpX + paddleWidth -- push ball out of paddle
            lastHit = "blue"
            bounce()
        end
    end
end

-- checks for collisions between the ball and the right (red) paddle
function checkRightPaddle() 
    if bX + bSize > rpX and bX < rpX + paddleWidth then
        if bY + bSize > rpY and bY < rpY + paddleHeight then
            bX = rpX - bSize -- push ball out of paddle
            lastHit = "red"
            bounce()
        end
    end
end

-- inverts the ball's horizontal velocity, then increases it and adjusts the vertical velocity slightly
function bounce()
    -- invert X velocity to make ball bounce
    bXVel = -bXVel 

    bounceCount = bounceCount + 1

    -- increase velocity by 60
    if(bXVel < 0) then 
        bXVel = bXVel -60
    else 
        bXVel = bXVel + 60
    end
    if(bYVel < 0) then 
        bYVel = bYVel - 15
    else 
        bYVel = bYVel + 15
    end
end

-- checks the ball for ceiling and net collisions
function checkBall()
    -- check for ceiling collision
    if bY <= 0 then 
        bY = 0
        bYVel = -bYVel 
    elseif bY + bSize >= screenHeight then 
        bY = screenHeight - bSize
        bYVel = -bYVel
    end

    --check for net collision
    if bX <= 0 then
        -- red scored
        rScore = rScore+1
        spawnBall()
    elseif bX + bSize >= screenWidth then
        -- blue scored
        lScore = lScore+1
        spawnBall()
    end
end

-- spawns a ball in a 50 px radius around the center of the screen and initializes its positional and velocity values
-- ball's direction at spawn is determined by current turn:
--                                                      odd turn  -> ball flies right
--                                                      even turn -> ball flies left
function spawnBall()

    bounceCount = 0
    lastHit = "none"

    local initVel = 0

    if (lScore + rScore)%2 == 0 then initVel = 1
    else initVel = -1
    end
    bX = screenWidth/2 + love.math.random(-50, 50)
    bY = screenHeight/2 + love.math.random(-50, 50)
    prevX, prevY = bX, bY
    bSize = 24
    bXVel = (screenWidth/5)* initVel
    bYVel = 0
    while math.abs(bYVel) < 150 do
        bYVel = love.math.random(-250, 250)
    end
end

-- prints out positional and velocity data, as well as last player to hit the ball
function debugPrint()
    love.graphics.setColor(0.98,0.98,0.98,1)
    love.graphics.setFont(debugFont)

    local aggregatedWidth = 10

    local message = "X Velocity: " .. bXVel
    love.graphics.print(message, aggregatedWidth, 10)
    aggregatedWidth = aggregatedWidth + debugFont:getWidth(message) + 10

    message = "Y Velocity: " .. bYVel
    love.graphics.print(message, aggregatedWidth, 10)
    aggregatedWidth = aggregatedWidth + debugFont:getWidth(message) + 10

    message = "X Position: " .. math.floor(bX)
    love.graphics.print(message, aggregatedWidth, 10)
    aggregatedWidth = aggregatedWidth + debugFont:getWidth(message) + 10

    message = "Y Position: " .. math.floor(bY)
    love.graphics.print(message, aggregatedWidth, 10)
    aggregatedWidth = aggregatedWidth + debugFont:getWidth(message) + 10

    -- newline
    aggregatedWidth = 10

    message = "Last Hit: "
    love.graphics.print(message, aggregatedWidth, 26)
    aggregatedWidth = aggregatedWidth + debugFont:getWidth(message)

    if(lastHit == "blue") then love.graphics.setColor(0,0,1,1)
    elseif(lastHit == "red") then love.graphics.setColor(1,0,0,1) end
    message = lastHit
    love.graphics.print(message, aggregatedWidth, 26)
    aggregatedWidth = aggregatedWidth + debugFont:getWidth(message) + 10

    love.graphics.setColor(0.98,0.98,0.98,1)
    message = "Bounce Count: " .. bounceCount
    love.graphics.print(message, aggregatedWidth, 26)

end

function love.keypressed(key)
    if key == "f3" then
        showDebug = not showDebug
    end
    if key == "escape" then
        pause = not pause
    end
end

-- runs once at the start == init
function love.load()

    showDebug = false
    pause = false

    -- initialize all fonts
    scoreFont = love.graphics.newFont(70)
    scoreFontS = love.graphics.newFont(52)
    scoreFontXS = love.graphics.newFont(40)
    debugFont = love.graphics.newFont(16)

    -- get screen dimensions
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    lScore, rScore = 0, 0

    -- set paddles' initial position and size
    paddleWidth, paddleHeight = 30, 200
    lpX, lpY = 70, 20
    rpX, rpY = screenWidth - 70 - paddleWidth, 20

    -- set ball's initial position, size, and assign a random velocity
    spawnBall()
end

-- runs every frame
-- dt = delta == time since last frame
function love.update(dt)
    if(not pause) then
        checkBall()
        checkLeftPaddle()
        checkRightPaddle()
        movePaddles(dt)
        moveBall(dt)
    end
end

-- runs every frame AFTER update
function love.draw()
    if(showDebug == true) then debugPrint() end
    drawScores()
    drawCenterLine(16, 30, 14)
    drawPaddles()
    drawBall()
    if(pause == true) then
        love.graphics.setColor(0.5,0.5,0.5,0.25)
        love.graphics.rectangle("fill",0,0,screenWidth,screenHeight)
    end
end