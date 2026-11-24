
--==================================================
-- BIG HITBOX SYSTEM | Q TOGGLE
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- CONFIG
local KEYBIND = Enum.KeyCode.R
local HITBOX_SIZE = Vector3.new(5,6,5)
local MAX_DISTANCE = 30

-- STATE
local Enabled = false
local CurrentTarget = nil
local CurrentHitbox = nil

--==================================================
-- GET NEAREST PLAYER
--==================================================

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

--==================================================
-- CREATE HITBOX
--==================================================
local function CreateHitbox(Character)
    if not Character then return end

    local Head = Character:FindFirstChild("Head")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Head or not Humanoid then return end
    if Humanoid.Health <= 0 then return end

    -- ลบ Hitbox เก่า
    local Old = Character:FindFirstChild("HIT")
    if Old then Old:Destroy() end

    -- สร้าง Hitbox
    local Part = Head:Clone()
    Part.Name = "HIT"
    Part.Size = Vector3.new(1, 1, 1)
    Part.Transparency = 1
    Part.Anchored = false
    Part.CanCollide = false
    Part.CanTouch = false
    Part.CanQuery = true
    Part.Massless = true
    Part.CFrame = Head.CFrame
    Part.Parent = Character

    -- Weld
    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = Head
    Weld.Part1 = Part
    Weld.Parent = Part

    CurrentHitbox = Part
    CurrentTarget = Character

    -- ปรับขนาดหัว
    Head.Transparency = 1
    Head.Size = HITBOX_SIZE
    Head.CanCollide = false

    local OriginalSize = Head:FindFirstChild("OriginalSize")

    if OriginalSize and OriginalSize:IsA("Vector3Value") then
        OriginalSize.Value = HITBOX_SIZE
    end

    -- ตรวจจับเลือด
    local Connection

    local function Cleanup()
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end

        if Head and Head.Parent then
            Head.Size = Vector3.new(1, 1, 1)
            Head.Transparency = 0
            Head.CanCollide = false

            if OriginalSize and OriginalSize.Parent then
                OriginalSize.Value = Vector3.new(1, 1, 1)
            end
        end

        if Part and Part.Parent then
            Part:Destroy()
        end

        if CurrentTarget == Character then
            CurrentHitbox = nil
            CurrentTarget = nil
        end
    end

    Connection = Humanoid.HealthChanged:Connect(function(Health)
        if Health <= 0 then
            Cleanup()
        end
    end)

    Humanoid.Died:Once(Cleanup)
end
--==================================================
-- REMOVE HITBOX
--==================================================

local function RemoveHitbox()

    if CurrentHitbox then
        CurrentHitbox:Destroy()
    end

    CurrentHitbox = nil
    CurrentTarget = nil
end

--==================================================
-- UPDATE SYSTEM
--==================================================

task.spawn(function()

    while true do

        task.wait(0.2)

        if Enabled then

            local Target = GetNearestPlayer()

            if Target ~= CurrentTarget then

                RemoveHitbox()

                if Target then
                    CreateHitbox(Target)
                end

            elseif Target and not CurrentHitbox then

                CreateHitbox(Target)
            end
        end
    end
end)

--==================================================
-- Q TOGGLE
--==================================================

UserInputService.InputBegan:Connect(function(Input, GameProcessed)

    if GameProcessed then return end

    if Input.KeyCode == KEYBIND then

        Enabled = not Enabled

        if Enabled then

            local Target = GetNearestPlayer()

            if Target then
                CreateHitbox(Target)
            end

            print("[BigHitbox] ENABLED")

        else

            RemoveHitbox()

            print("[BigHitbox] DISABLED")
        end
    end
end)

--==================================================
-- CLEANUP
--==================================================

LocalPlayer.CharacterRemoving:Connect(function()
    RemoveHitbox()
end)
