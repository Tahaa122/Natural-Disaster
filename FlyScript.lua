-- Simple Fly Script
-- Tombol F = ON/OFF Fly
-- WASD + Space/Ctrl = gerak

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local Flying = false
local Speed = 60 -- ubah angka ini kalau mau lebih cepat/lambat

local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(0, 0, 0)
BV.Velocity = Vector3.new(0, 0, 0)
BV.Parent = Root

local BG = Instance.new("BodyGyro")
BG.MaxTorque = Vector3.new(0, 0, 0)
BG.P = 10000
BG.Parent = Root

-- Toggle Fly (tombol F)
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F then
		Flying = not Flying
		
		if Flying then
			BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			Humanoid.PlatformStand = true
		else
			BV.MaxForce = Vector3.new(0, 0, 0)
			BG.MaxTorque = Vector3.new(0, 0, 0)
			Humanoid.PlatformStand = false
		end
	end
end)

-- Gerakan saat terbang
RunService.Heartbeat:Connect(function()
	if not Flying then return end
	
	local cam = workspace.CurrentCamera
	local move = Vector3.zero
	
	if UIS:IsKeyDown(Enum.KeyCode.W) then
		move = move + cam.CFrame.LookVector
	end
	if UIS:IsKeyDown(Enum.KeyCode.S) then
		move = move - cam.CFrame.LookVector
	end
	if UIS:IsKeyDown(Enum.KeyCode.A) then
		move = move - cam.CFrame.RightVector
	end
	if UIS:IsKeyDown(Enum.KeyCode.D) then
		move = move + cam.CFrame.RightVector
	end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then
		move = move + Vector3.new(0, 1, 0)
	end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
		move = move - Vector3.new(0, 1, 0)
	end
	
	if move.Magnitude > 0 then
		BV.Velocity = move.Unit * Speed
	else
		BV.Velocity = Vector3.zero
	end
	
	BG.CFrame = cam.CFrame
end)

-- Biar tetap kerja kalau character di-reset
Player.CharacterAdded:Connect(function(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Root = char:WaitForChild("HumanoidRootPart")
	
	BV.Parent = Root
	BG.Parent = Root
	Flying = false
	BV.MaxForce = Vector3.new(0, 0, 0)
	BG.MaxTorque = Vector3.new(0, 0, 0)
end)

print("Fly Script Loaded | Tekan F untuk ON/OFF")
