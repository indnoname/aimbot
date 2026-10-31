local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- CONFIG

local KEYBIND = Enum.KeyCode.Q
local BIG_SIZE = Vector3.new(3, 7, 3)

-- STATE
local Enabled = false
local TargetCharacter
local CloneHead
local OriginalSize
local OriginalTransparency
MAX_DISTANCE = 20

local function GetNearestPlayer()

    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        return nil
    end

    local NearestPlayer = nil
    local NearestDistance = MAX_DISTANCE

    for _, Target in ipairs(Players:GetPlayers()) do

        if Target ~= LocalPlayer then

            local Model = workspace:FindFirstChild(Target.Name)

            if Model then

                local TargetRoot = Model:FindFirstChild("HumanoidRootPart")
                local Head = Model:FindFirstChild("Head")
                local Humanoid = Model:FindFirstChildOfClass("Humanoid")

                if TargetRoot and Head and Humanoid and Humanoid.Health > 0 then

                    local Distance = (Root.Position - TargetRoot.Position).Magnitude

                    if Distance < NearestDistance then
                        NearestDistance = Distance
                        NearestPlayer = Model
                    end
                end
            end
        end
    end

    return NearestPlayer
end

local function GetName()
    local Target = GetNearestPlayer()
    if Target then
        return Target
    end
    return nil
end    
local Enabled = false
local TARGET_PLAYER =  GetName()

-- FIND PLAYER
local function GetTarget()
    local Target = GetName()
    if not Target or Target == LocalPlayer then
        return nil
    end
    return Target.Character
end

-- ENABLE
local function Enable()
    local Character = GetTarget()
    if not Character then
        warn("[HEAD] Player not found")
        return
    end

    local Head = Character:FindFirstChild("Head")
    if not Head then return end

    TargetCharacter = Character

    OriginalSize = Head.Size
    OriginalTransparency = Head.Transparency

    CloneHead = Head:Clone()
    CloneHead.Name = "CloneHead"
    CloneHead.Anchored = true
    CloneHead.CanCollide = false
    CloneHead.CanTouch = false
    CloneHead.CanQuery = false
    CloneHead.Parent = Character

    Head.Size = BIG_SIZE
    Head.Transparency = 1

    Enabled = true

    print("[HEAD] เปิดแล้ว | " .. TARGET_PLAYER)
end

-- DISABLE
local function Disable()
    if not TargetCharacter then return end

    local Head = TargetCharacter:FindFirstChild("Head")

    if Head then
        Head.Size = OriginalSize
        Head.Transparency = OriginalTransparency
    end

    if CloneHead then
        CloneHead:Destroy()
        CloneHead = nil
    end

    Enabled = false
    TargetCharacter = nil

    print("[HEAD] ปิดแล้ว | " .. TARGET_PLAYER)
end

-- Q TOGGLE
UIS.InputBegan:Connect(function(Input, Processed)
    if Processed then return end

    if Input.KeyCode == KEYBIND then
        if Enabled then
            Disable()
        else
            Enable()
        end
    end
end)

-- FOLLOW CLONE HEAD
RunService.RenderStepped:Connect(function()
    if not Enabled then return end

    local Head = TargetCharacter
        and TargetCharacter:FindFirstChild("Head")

    if Head and CloneHead and CloneHead.Parent then
        CloneHead.CFrame = Head.CFrame
    end
end)

print("[HEAD] System Loaded | Press Q")
