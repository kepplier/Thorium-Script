local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", screenGui)

-- Set the frame properties
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black background

-- Create the title text
local title = Instance.new("TextLabel", frame)
title.Text = "Token"
title.Size = UDim2.new(1, 0, 0, 75) -- Increased height
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true

-- Create the text box for token input
local textBox = Instance.new("TextBox", frame)
textBox.Size = UDim2.new(0, 400, 0, 75) -- Increased size
textBox.Position = UDim2.new(0.5, -200, 0.5, -37.5) -- Adjusted position
textBox.PlaceholderText = "Enter token here..."
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- Create the login button
local loginButton = Instance.new("TextButton", frame)
loginButton.Text = "Login"
loginButton.Size = UDim2.new(0, 150, 0, 75) -- Increased size
loginButton.Position = UDim2.new(0.5, -75, 0.5, 50) -- Adjusted position
loginButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
loginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
loginButton.AutoButtonColor = false -- Keep button color on hover
loginButton.BorderSizePixel = 0
loginButton.TextScaled = true

-- Round the corners of the button
local function roundCorners(button)
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 15) -- Rounded corners
end

roundCorners(loginButton)

-- Tokens for validation
local validTokens = {
    "}lZ,C2RDsGrY@tD!r@Y{X@,A3OH.E(PB*+,DLG=e+?Q;!EyqSz",
    "Oa-CZ3c}c!W+s7eM?Xi\ray9jRuO?0wy"'oxA+.WZgb}Y.",
    "Y(b1EkBrvyx.orT9:,gu-Hvwg+T1PZCkJlzKDSUIxbX.'.]]PB"
}

-- Function to handle login
local function onLogin()
    local token = textBox.Text
    for _, validToken in ipairs(validTokens) do
        if token == validToken then
            title.Text = "Successfully logged in!"
            
            -- Tween for smooth zoom out effect
            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local goal = {Size = UDim2.new(1.5, 0, 1.5, 0), Position = UDim2.new(-0.25, 0, -0.25, 0)}
            local tween = tweenService:Create(frame, tweenInfo, goal)
            tween:Play()
            tween.Completed:Wait()
            
            wait(2)
            screenGui:Destroy()
            return
        end
    end
    
    title.Text = "Try Again"
    wait(1)
    title.Text = "Token"
end

-- Connect the button click event to the login function
loginButton.MouseButton1Click:Connect(onLogin)

-- Place this script in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = false
local CurrentTarget = nil
local PredictionTime = 0.08
local CrosshairRange = 50
local DistanceRange = 1000

local function getClosestTarget()
    local closestTarget, shortestDistance = nil, math.huge
    local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if head and humanoid and humanoid.Health > 0 then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local distFromMouse = (Vector2.new(headPos.X, headPos.Y) - mousePosition).Magnitude
                local distFromPlayer = (head.Position - LocalPlayer.Character.Head.Position).Magnitude
                if distFromMouse <= CrosshairRange and distFromPlayer <= DistanceRange then
                    if distFromPlayer < shortestDistance then
                        closestTarget, shortestDistance = player, distFromPlayer
                    end
                end
            end
        end
    end
    return closestTarget
end

local function predictPosition(target)
    local head = target.Character.Head
    return head.Position + head.Velocity * PredictionTime
end

local function aimAt(target)
    local predictedPos = predictPosition(target)
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
    else
        -- Non-shift lock mode, aim with mouse
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        local viewportPoint = Vector3.new(mousePos.X, mousePos.Y, 0.5)
        local worldPos = Camera:ViewportToWorldPoint(viewportPoint)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, worldPos)
    end
end

local function renderCrosshairRange()
    local circle = Drawing.new("Circle")
    circle.Visible, circle.Transparency, circle.Thickness, circle.Filled = true, 1, 2, false
    circle.Radius = CrosshairRange
    local hue = 0
    RunService.RenderStepped:Connect(function()
        hue = (hue + 0.01) % 1
        circle.Color = Color3.fromHSV(hue, 1, 1)
        
        -- Adjust the circle position to be slightly downwards
        local mousePosition = Vector2.new(Mouse.X, Mouse.Y + 60)  -- You can adjust the offset here
        
        circle.Position = mousePosition
    end)
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then AimbotEnabled = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotEnabled, CurrentTarget = false, nil
    end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        if not CurrentTarget or (CurrentTarget.Character and CurrentTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0) then
            CurrentTarget = getClosestTarget()
        end
        if CurrentTarget then aimAt(CurrentTarget) end
    end
end)

renderCrosshairRange()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ThoriumGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Creating the Frame (Black Box)
local frame = Instance.new("Frame")
frame.Name = "GlassBox"
frame.Size = UDim2.new(1.5, 0, 1.5, 0) -- Full size
frame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centered position
frame.AnchorPoint = Vector2.new(0.5, 0.5) -- Anchor point in the middle
frame.BackgroundTransparency = 0 -- No transparency
frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05) -- Black color for glass effect
frame.BorderSizePixel = 0 -- Remove border
frame.Parent = screenGui

-- Creating the TextButton
local button = Instance.new("TextButton")
button.Name = "ThoriumButton"
button.Size = UDim2.new(0.1, 0, 0.05, 0) -- Size of the button
button.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centered in the frame
button.AnchorPoint = Vector2.new(0.5, 0.5) -- Anchor point in the middle
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White color (to show gradient better)
button.Text = "Thorium"
button.Font = Enum.Font.Fantasy -- Set the font to Fantasy
button.TextColor3 = Color3.new(0, 0, 0) -- Black color for the text
button.TextScaled = true -- Automatically scale the text to fit the button
button.Parent = frame

-- Creating UICorner for rounded edges
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0.1, 0) -- Fully rounded corners
buttonCorner.Parent = button

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0.1, 0) -- Slightly rounded corners for the frame
frameCorner.Parent = frame

-- Creating UIGradient for the rainbow gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 128)), -- Purple
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 105, 180)) -- Pink
}
gradient.Parent = button

-- Function to animate the gradient (spin)
local function animateGradient()
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1) -- Loop infinitely (-1)

    local goal = {}
    goal.Rotation = 360 -- Rotate 360 degrees

    local tween = tweenService:Create(gradient, tweenInfo, goal)
    return tween
end

local gradientTween -- Variable to store the gradient tween

-- Function to handle the button hover effect
local function buttonHover()
    local tweenService = game:GetService("TweenService")
    local initialSize = button.Size
    local newSize = UDim2.new(0.11, 0, 0.055, 0) -- Increased size when hovered

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local hoverTween = tweenService:Create(button, tweenInfo, {Size = newSize})
    hoverTween:Play()

    -- Start the gradient animation
    gradientTween = animateGradient()
    gradientTween:Play()
end

-- Function to handle the button unhover effect
local function buttonUnhover()
    local tweenService = game:GetService("TweenService")
    local initialSize = button.Size

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local unhoverTween = tweenService:Create(button, tweenInfo, {Size = UDim2.new(0.1, 0, 0.05, 0)}) -- Restore initial size
    unhoverTween:Play()

    -- Stop the gradient animation
    if gradientTween then
        gradientTween:Cancel()
    end
end

-- Connect button hover and unhover events
button.MouseEnter:Connect(buttonHover)
button.MouseLeave:Connect(buttonUnhover)

-- Function to handle the button click
local function onButtonClick()
    button.Text = "Injected!"
    local tweenService = game:GetService("TweenService")

    -- Tween for fading out the button and frame with longer duration
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) -- Smooth transition with Quart easing and longer duration
    
    local goalButton = {}
    goalButton.BackgroundTransparency = 1 -- Fully transparent
    goalButton.Size = UDim2.new(0, 0, 0, 0) -- Shrink button size
    
    local goalFrame = {}
    goalFrame.BackgroundTransparency = 1 -- Fully transparent
    goalFrame.Size = UDim2.new(0, 0, 0, 0) -- Shrink frame size

    local buttonTween = tweenService:Create(button, tweenInfo, goalButton)
    local frameTween = tweenService:Create(frame, tweenInfo, goalFrame)
    
    buttonTween:Play()
    frameTween:Play()

    -- Destroy the GUI after the tween is completed
    buttonTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

-- Connect the button click event to the function
button.MouseButton1Click:Connect(onButtonClick)

-- hadioftugoiadfg

-- ioudfghiouadfhgiudhf

local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkGrayBoxGui"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local darkGrayBox = Instance.new("Frame", screenGui)
    darkGrayBox.AnchorPoint = Vector2.new(0.5, 0.5)
    darkGrayBox.Size = UDim2.new(0.3, 0, 0.3, 0)
    darkGrayBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    darkGrayBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    darkGrayBox.Visible = false

    local uiCorner = Instance.new("UICorner", darkGrayBox)
    uiCorner.CornerRadius = UDim.new(0, 10)

    local keyBindsLabel = Instance.new("TextLabel", darkGrayBox)
    keyBindsLabel.Size = UDim2.new(1, 0, 0.1, 0)
    keyBindsLabel.Position = UDim2.new(0, 0, 0, 0)
    keyBindsLabel.Text = "KeyBinds"
    keyBindsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBindsLabel.TextScaled = true
    keyBindsLabel.Font = Enum.Font.SourceSans
    keyBindsLabel.TextXAlignment = Enum.TextXAlignment.Left

    local keybinds = {
        {"Highlight Keybind: G", 0.2},
        {"Aimlock Keybind: Right Click", 0.3},
        {"Teleport Keybind: V", 0.4},
        {"Teleport up Keybind: L (hold down)", 0.5},
        {"Speed Keybind: C (hold down)", 0.6}
    }

    for i, data in ipairs(keybinds) do
        local label = Instance.new("TextLabel", darkGrayBox)
        label.Size = UDim2.new(1, 0, 0.1, 0)
        label.Position = UDim2.new(0, 0, data[2], 0)
        label.Text = data[1]
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
    end

    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local initialSize = UDim2.new(0, 0, 0, 0)

    local function toggleDarkGrayBox()
        print("Toggling DarkGrayBox")
        if darkGrayBox.Visible then
            local hideTween = tweenService:Create(darkGrayBox, tweenInfo, {Size = initialSize})
            hideTween:Play()
            hideTween.Completed:Connect(function()
                darkGrayBox.Visible = false
                print("DarkGrayBox hidden")
            end)
        else
            darkGrayBox.Size = initialSize
            darkGrayBox.Visible = true
            local showTween = tweenService:Create(darkGrayBox, tweenInfo, {Size = UDim2.new(0.3, 0, 0.3, 0)})
            showTween:Play()
            print("DarkGrayBox shown")
        end
    end

    local userInputService = game:GetService("UserInputService")
    userInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.U then
            toggleDarkGrayBox()
        end
    end)
end

local player = game.Players.LocalPlayer
player.CharacterAdded:Connect(function()
    print("Character added")
    createGui()
end)

-- Create GUI when the script runs for the first time
if player.Character then
    print("Character already exists")
    createGui()
end

-- teleporting thingy

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local teleportDistance = 1.7 -- Set the teleport distance to 0.85 studs

local function teleportPlayer()
    local direction = humanoid.MoveDirection -- Get the direction the player is moving
    if direction ~= Vector3.new(0, 0, 0) then -- Check if the player is moving
        direction = direction.unit -- Normalize the direction vector
        local newPosition = character.HumanoidRootPart.Position + direction * teleportDistance
        character:SetPrimaryPartCFrame(CFrame.new(newPosition))
    end
end

local function onInput(input, isProcessed)
    if input.KeyCode == Enum.KeyCode.C and not isProcessed then
        while game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.C) do
            teleportPlayer()
            wait(0.1) -- Adjust this value to control teleportation frequency
        end
    end
end

game:GetService("UserInputService").InputBegan:Connect(onInput)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
end)

-- Teleporting Script

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local teleportDistance = 4 -- Set the teleport distance to 4 studs

local function teleportPlayer()
    local direction = humanoid.MoveDirection -- Get the direction the player is moving
    if direction ~= Vector3.new(0, 0, 0) then -- Check if the player is moving
        direction = direction.unit -- Normalize the direction vector
        local newPosition = character.HumanoidRootPart.Position + direction * teleportDistance
        character:SetPrimaryPartCFrame(CFrame.new(newPosition))
    end
end

local function onInput(input, isProcessed)
    if input.KeyCode == Enum.KeyCode.V and not isProcessed then
        teleportPlayer()
    end
end

game:GetService("UserInputService").InputBegan:Connect(onInput)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
end)

-- Teleporting Script

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local verticalOffset = 6 -- Set the vertical offset to 1 stud
local isTeleporting = false -- Flag to control teleportation spam

local function teleportPlayer()
    local newPosition = character.HumanoidRootPart.Position + Vector3.new(0, verticalOffset, 0)
    character:SetPrimaryPartCFrame(CFrame.new(newPosition))
end

local function onInput(input, isProcessed)
    if input.KeyCode == Enum.KeyCode.L and not isProcessed then
        isTeleporting = true
        spawn(function()
            while isTeleporting do
                teleportPlayer()
                wait(0.1) -- Adjust this value to control teleportation frequency
            end
        end)
    end
end

local function onInputEnded(input, isProcessed)
    if input.KeyCode == Enum.KeyCode.L and not isProcessed then
        isTeleporting = false
    end
end

game:GetService("UserInputService").InputBegan:Connect(onInput)
game:GetService("UserInputService").InputEnded:Connect(onInputEnded)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
end)

-- Ensure these variables are properly initialized and in the correct scope
local highlightInstances = {}
local highlightsEnabled = false

-- Services
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Function to toggle highlights
local function toggleHighlights()
    highlightsEnabled = not highlightsEnabled
    for player, highlight in pairs(highlightInstances) do
        if highlight and highlight.Parent then
            highlight.Enabled = highlightsEnabled
        end
    end
    StarterGui:SetCore("SendNotification", {
        Title = highlightsEnabled and "Highlights Enabled" or "Highlights Disabled",
        Text = highlightsEnabled and "You've enabled highlights." or "You've disabled highlights.",
        Duration = 5
    })
end

-- Event listener for input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.G and not gameProcessed then
        toggleHighlights()
    end
end)

-- Function to create highlights for all players (you need to define this)
local function highlightAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        -- Create or get highlight instance for the player
        -- This part is just an example, adjust according to your actual implementation
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character or player.CharacterAdded:Wait()
        highlight.Enabled = highlightsEnabled
        highlightInstances[player] = highlight
    end
end

-- Call the function to highlight all players
highlightAllPlayers()

-- Listen for new players joining and create highlights for them
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.Enabled = highlightsEnabled
        highlightInstances[player] = highlight
    end)
end)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Function to remove existing tags and replace the name
local function replaceName(character)
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA("BillboardGui") then
                    child:Destroy()
                end
            end

            -- Create a new BillboardGui
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Adornee = head
            billboardGui.Size = UDim2.new(0, 200, 0, 60)  -- Fixed size in pixels
            billboardGui.StudsOffset = Vector3.new(0, 2, 0)
            billboardGui.AlwaysOnTop = true

            -- Create a new Frame to act as the black box
            local frame = Instance.new("Frame")
            frame.Parent = billboardGui
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.new(0, 0, 0)  -- Black color

            -- Create a UICorner to round the corners of the frame
            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(0.1, 0)  -- Adjust the corner radius as needed
            uiCorner.Parent = frame

            -- Create a new TextLabel
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = frame
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "Thorium User"
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.TextStrokeTransparency = 0.5
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextScaled = true

            billboardGui.Parent = head
        end
    end
end

-- Connect to CharacterAdded event
player.CharacterAdded:Connect(function(character)
    replaceName(character)
end)

-- Check if character is already loaded
if player.Character then
    replaceName(player.Character)
end
