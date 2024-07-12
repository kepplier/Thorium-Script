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
