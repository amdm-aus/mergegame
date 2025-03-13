local green = {0.22, 0.63, 0, 1}
local black = {0, 0, 0, 1}
local rowY = {}
local columnX = {}
local allNumbers = {{9, 9, 9, 9}, {9, 9, 9, 9}, {9, 9, 9, 9}, {9, 9, 9, 9}}
local winTable = {{"", "", "", ""}, {"", "", "", ""}, {"", "", "", ""}, {"", "", "", ""}}
local activeCell = {1,1}
local selectedCell = {}
local selectedNumber
local compareNumber
local i = 0
local j = 0
local blink = false
local noActive = true
local elapsedTime = 0
local loopTest = false
local makeComparison = false
local buffoon = false
local buffoonFontWidth = 0
local buffoonX = 0
local buffoonY = 0
local winCondition = false
local moveCount = 0
local winCount = 0
local distNumber = 0
local buffoonCount = 0

function generateTable()
    -- create the table of numbers
    math.randomseed(os.time())
    for i = 1, #allNumbers, 1 do
        for j = 1, #allNumbers[i], 1 do
            allNumbers[i][j] = math.random(1,9)
        end
    end
end

function generateNewNumber()
    -- create a new number in a blank square with a skewed distribution
    math.randomseed(os.time())
    distNumber = math.random()
    if distNumber < 0.25 then
        return math.random(1,9)
    else
        i = ""
        while i == "" do
            i = allNumbers[math.random(1,4)][math.random(1,4)]
        end
        return i
    end
end

function love.load()
    -- load in the font
    font = love.graphics.newFont("fonts/VCR_OSD_MONO.ttf", 48)
    buffoonFont = love.graphics.newFont("fonts/VCR_OSD_MONO.ttf", 200)
    buffoonFontWidth = buffoonFont:getWidth("BUFFOON")
    buffoonFontHeight = buffoonFont:getHeight("BUFFOON")
    numberWidth = font:getWidth("0")
    numberHeight = font:getHeight("0")
    buffoonX = (love.graphics.getWidth() - buffoonFontWidth) / 2
    buffoonY = (love.graphics.getHeight() - buffoonFontHeight) / 2
    love.graphics.setFont(font)

    generateTable()

    -- set the dimensions of the grid the numbers will appear in
    rowY[1] = love.graphics.getHeight()/9 + (numberHeight / 2)
    rowY[2] = 3*love.graphics.getHeight()/9 + (numberHeight / 2)
    rowY[3] = 5*love.graphics.getHeight()/9 + (numberHeight / 2)
    rowY[4] = 7*love.graphics.getHeight()/9 + (numberHeight / 2)
    columnX[1] = love.graphics.getWidth()/9 + (numberWidth / 2)
    columnX[2] = 3*love.graphics.getWidth()/9 + (numberWidth / 2)
    columnX[3] = 5*love.graphics.getWidth()/9 + (numberWidth / 2)
    columnX[4] = 7*love.graphics.getWidth()/9 + (numberWidth / 2)
end

function love.keypressed(key)

    -- make the direction keys move the active cell around
    -- if player is at the edge of the screen, it will loop back to the other side

    if (key == "left") then
        if activeCell[1] > 1 then
            activeCell[1] = activeCell[1] - 1
        elseif activeCell[1] == 1 then
            activeCell[1] = 4
        end
        elapsedTime = 0.5
    end
    
    if (key == "right") then
        if activeCell[1] < 4 then
            activeCell[1] = activeCell[1] + 1
        elseif activeCell[1] == 4 then
            activeCell[1] = 1
        end
        elapsedTime = 0.5
    end

    if (key == "up") then
        if activeCell[2] > 1 then
            activeCell[2] = activeCell[2] - 1
        elseif activeCell[2] == 1 then
            activeCell[2] = 4
        end
        elapsedTime = 0.5
    end

    if (key == "down") then
        if activeCell[2] < 4 then
            activeCell[2] = activeCell[2] + 1
        elseif activeCell[2] == 4 then
            activeCell[2] = 1
        end
        elapsedTime = 0.5
    end

    -- enter key makes the currently selected number active
    if (key == "return") and noActive then
        if allNumbers[activeCell[2]][activeCell[1]] == "" then -- if enter is pressed in a blank cell, a new random number is generated
            allNumbers[activeCell[2]][activeCell[1]] = generateNewNumber()
            moveCount = moveCount + 1
        else
            selectedCell[1] = activeCell[1]
            selectedCell[2] = activeCell[2]
            selectedNumber = allNumbers[activeCell[2]][activeCell[1]]
            noActive = false
        end
    elseif (key == "return") and not noActive then
        if activeCell[1] == selectedCell[1] and activeCell[2] == selectedCell[2] then -- if the enter key is pressed while still on the selected cell, it will deselect, the same as pressing backspace
            selectedCell = {}
            selectedNumber = nil
            noActive = true
        else
            compareNumber = allNumbers[activeCell[2]][activeCell[1]]
            makeComparison = true
            moveCount = moveCount + 1
        end
    end

    -- backspace key to cancel the selection
    if (key == "backspace") and (not noActive) then
        selectedCell = {}
        selectedNumber = nil
        noActive = true
    end
end    

function love.update(dt)
    for i = 1, #allNumbers, 1 do
        for j = 1, #allNumbers[i], 1 do
            if allNumbers[i][j] ~= "" then
                winCondition = false
                goto loopExit
            else
                winCondition = true
                blink = false
            end
        end
    end
    ::loopExit::

    elapsedTime = elapsedTime + dt
    -- keeps switching the blink boolean in order to simulate a blinking effect in the love.draw() function
    if not buffoon and not winCondition then
        if elapsedTime > 0.5 and elapsedTime < 1 then
            blink = true
        elseif elapsedTime > 1 then
            blink = false
            elapsedTime = 0
        end
    elseif buffoon and not winCondition then
        if elapsedTime > 2 then
            elapsedTime = 0
            buffoon = false
            buffoonCount = buffoonCount + 1
        end
    elseif winCondition then
        if elapsedTime > 3 then
            elapsedTime = 0
            winCondition = false
            winCount = winCount + 1
            moveCount = 0
            generateTable()
            activeCell = {1,1}
        end
    end
    
    -- compares the numbers. if they are the same, increments one number by one and deletes the other. if they are different, insults the player.
    if makeComparison then
        if selectedNumber == compareNumber then
            allNumbers[activeCell[2]][activeCell[1]] = allNumbers[activeCell[2]][activeCell[1]] + 1
            if allNumbers[activeCell[2]][activeCell[1]] > 9 then
                allNumbers[activeCell[2]][activeCell[1]] = ""
            end
            allNumbers[selectedCell[2]][selectedCell[1]] = ""
            selectedCell = {}
            selectedNumber = nil
            compareNumber = nil
            noActive = true
            makeComparison = false
        else
            buffoon = true
            selectedCell = {}
            selectedNumber = nil
            compareNumber = nil
            noActive = true
            makeComparison = false
        end
    end
end

function love.draw()
    love.graphics.setColor(green)
    -- love.graphics.print("Active Cell: " .. activeCell[1] .. activeCell[2])
    -- if #selectedCell > 0 then
    --     love.graphics.print("\nSelected Cell: " .. selectedCell[1] .. selectedCell[2])
    --     love.graphics.print("\n\nSelected Number: " .. selectedNumber)
    -- end
    -- love.graphics.print("                         ".. distNumber)
    
    love.graphics.print("Move count: " .. moveCount)
    love.graphics.print("\nWin count: " .. winCount)

    if buffoonCount > 0 then
        love.graphics.print("Buffoon count: " .. buffoonCount, 0, love.graphics.getHeight() - 2 * numberHeight)
    end

    for i = 1, #columnX, 1 do
        for j = 1, #rowY, 1 do
            love.graphics.print(allNumbers[j][i], columnX[i], rowY[j])
        end
    end

    if blink and not buffoon then
        love.graphics.rectangle("fill", columnX[activeCell[1]], rowY[activeCell[2]], 30, 50)
        love.graphics.setColor(black)
        love.graphics.print(allNumbers[activeCell[2]][activeCell[1]], columnX[activeCell[1]], rowY[activeCell[2]])
        love.graphics.setColor(green)
    end

    if not noActive then
        love.graphics.rectangle("fill", columnX[selectedCell[1]], rowY[selectedCell[2]], 30, 50)
        love.graphics.setColor(black)
        love.graphics.print(allNumbers[selectedCell[2]][selectedCell[1]], columnX[selectedCell[1]], rowY[selectedCell[2]])
        love.graphics.setColor(green)
    end

    if buffoon then
        love.graphics.rectangle("fill", buffoonX - 80, buffoonY - 80, buffoonFontWidth + 160, buffoonFontHeight + 160)
        love.graphics.setColor(black)
        love.graphics.rectangle("fill", buffoonX - 60, buffoonY - 60, buffoonFontWidth + 120, buffoonFontHeight + 120)
        love.graphics.setColor(green)
        love.graphics.setFont(buffoonFont)
        love.graphics.print("BUFFOON", buffoonX, buffoonY)
        love.graphics.setFont(font)
    end

    if winCondition then
        love.graphics.rectangle("fill", buffoonX - 80, buffoonY - 80, buffoonFontWidth + 160, buffoonFontHeight + 160)
        love.graphics.setColor(black)
        love.graphics.rectangle("fill", buffoonX - 60, buffoonY - 60, buffoonFontWidth + 120, buffoonFontHeight + 120)
        love.graphics.setColor(green)
        love.graphics.setFont(buffoonFont)
        love.graphics.print("WINNER!", buffoonX, buffoonY)
        love.graphics.setFont(font)
    end
end