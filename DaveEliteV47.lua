-- Configuration
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local SG = game:GetService("StarterGui")

local flying = false
local masterSpeed = 100
local currentJumpPower = 50
local noclipEnabled = false

-- Cleanup old UI if it exists
if player.PlayerGui:FindFirstChild("DaveWithMetalHat_V47") then
    player.PlayerGui.DaveWithMetalHat_V47:Destroy()
end

-- 1. Create Main UI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "DaveWithMetalHat_V47"

-- IMPORTANT: This line makes the menu stay after you die
screenGui.ResetOnSpawn = false 

-- Success Notification
SG:SetCore("SendNotification", {
    Title = "DAVE WITH METAL HAT";
    Text = "V47.1 Undying Version Loaded!";
    Duration = 5;
})

-- The Toggle Button
local menuBtn = Instance.new("TextButton", screenGui)
menuBtn.Size = UDim2.new(0, 120, 0, 40)
menuBtn.Position = UDim2.new(0, 10, 0.4, 0)
menuBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
menuBtn.Text = "DAVE MENU"
menuBtn.TextColor3 = Color3.new(1, 1, 1)
menuBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", menuBtn)

-- The Main Frame (STILL LOCKED IN MIDDLE)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 260, 0, 400)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0) 
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Visible = true
frame.Active = true
frame.Draggable = false 
Instance.new("UICorner", frame)

local header = Instance.new("TextLabel", frame)
header.Size = UDim2.new(1, 0, 0, 45)
header.Text = "DAVE WITH METAL HAT V47.1"
header.TextColor3 = Color3.new(1, 1, 1)
header.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
header.Font = Enum.Font.GothamBold
header.TextSize = 14
Instance.new("UICorner", header)

menuBtn.MouseButton1Click:Connect(function() 
    frame.Visible = not frame.Visible 
end)

-- FLY ENGINE
local bv, bg
local function toggleFly(state)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if state then
        flying = true; hum.PlatformStand = true
        bg = Instance.new("BodyGyro", hrp)
        bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.cframe = hrp.CFrame
        bv = Instance.new("BodyVelocity", hrp)
        bv.velocity = Vector3.new(0, 0, 0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while flying do
                local cam = workspace.CurrentCamera.CFrame
                bv.velocity = (hum.MoveDirection.Magnitude > 0) and (cam.LookVector * masterSpeed) or Vector3.new(0, 0, 0)
                bg.cframe = cam; runService.RenderStepped:Wait()
            end
        end)
    else
        flying = false; hum.PlatformStand = false
        if bv then bv:Destroy() end; if bg then bg:Destroy() end
    end
end

-- JUMP & NOCLIP
UIS.JumpRequest:Connect(function()
    if not flying and player.Character then
        player.Character.HumanoidRootPart.Velocity = Vector3.new(player.Character.HumanoidRootPart.Velocity.X, currentJumpPower, player.Character.HumanoidRootPart.Velocity.Z)
    end
end)

runService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and not flying then 
        char.Humanoid.WalkSpeed = masterSpeed 
    end
    if noclipEnabled and char then
        for _, v in pairs(char:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end
    end
end)

-- UI BUILDER TOOLS
local function createSlider(n, min, max, y, cb)
    local l = Instance.new("TextLabel", frame)
    l.Size = UDim2.new(1,0,0,20); l.Position = UDim2.new(0,0,0,y)
    l.Text = n .. ": " .. min; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
    local bgS = Instance.new("Frame", frame)
    bgS.Size = UDim2.new(0.8,0,0,10); bgS.Position = UDim2.new(0.1,0,0,y+25); bgS.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local k = Instance.new("TextButton", bgS)
    k.Size = UDim2.new(0,20,1,10); k.Position = UDim2.new(0,0,0.5,-10); k.Text = ""; k.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    Instance.new("UICorner", k)

    k.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            local c; c = runService.RenderStepped:Connect(function() 
                local r = math.clamp((UIS:GetMouseLocation().X - bgS.AbsolutePosition.X) / bgS.AbsoluteSize.X, 0, 1)
                k.Position = UDim2.new(r, -10, 0.5, -10)
                local v = math.floor(min + (max - min) * r); l.Text = n .. ": " .. v; cb(v) 
            end)
            UIS.InputEnded:Connect(function(ip) if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then c:Disconnect() end end)
        end 
    end)
end

local function createToggle(n, y, cb)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.8,0,0,40); b.Position = UDim2.new(0.1,0,0,y)
    b.Text = n .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(150,0,0); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    local s = false; b.MouseButton1Click:Connect(function() 
        s = not s; b.Text = n .. (s and ": ON" or ": OFF")
        b.BackgroundColor3 = s and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0); cb(s) 
    end)
end

createSlider("Master Speed", 16, 10000, 60, function(v) masterSpeed = v end)
createSlider("Jump Power", 50, 1000, 115, function(v) currentJumpPower = v end)
createToggle("FLY MODE", 180, function(s) toggleFly(s) end)
createToggle("NOCLIP", 230, function(s) noclipEnabled = s end)
