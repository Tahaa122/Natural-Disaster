-- Fly Script + Black & White Glossy GUI (Clean Version)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Flying = false
local Speed = 60

local Character, Humanoid, Root, BV, BG

-- ==================== SETUP CHARACTER ====================
local function setupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Root = char:WaitForChild("HumanoidRootPart")

	if BV then BV:Destroy() end
	if BG then BG:Destroy() end

	BV = Instance.new("BodyVelocity")
	BV.MaxForce = Vector3.new(0, 0, 0)
	BV.Velocity = Vector3.zero
	BV.Parent = Root

	BG = Instance.new("BodyGyro")
	BG.MaxTorque = Vector3.new(0, 0, 0)
	BG.P = 10000
	BG.Parent = Root

	Flying = false
end

if Player.Character then
	setupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(setupCharacter)

-- ==================== FLY LOGIC ====================
local function setFly(state)
	if not Root or not Humanoid then return end

	Flying = state

	if Flying then
		BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		Humanoid.PlatformStand = true
	else
		BV.MaxForce = Vector3.new(0, 0, 0)
		BG.MaxTorque = Vector3.new(0, 0, 0)
		Humanoid.PlatformStand = false
		BV.Velocity = Vector3.zero
	end
end

RunService.Heartbeat:Connect(function()
	if not Flying or not Root then return end

	local cam = workspace.CurrentCamera
	local move = Vector3.zero

	if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

	if move.Magnitude > 0 then
		BV.Velocity = move.Unit * Speed
	else
		BV.Velocity = Vector3.zero
	end

	BG.CFrame = cam.CFrame
end)

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 230, 0, 150)
Main.Position = UDim2.new(0.5, -115, 0.35, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 1.4
Stroke.Transparency = 0.25
Stroke.Parent = Main

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 12, 12)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
})
Gradient.Rotation = 90
Gradient.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundTransparency = 1
Title.Text = "FLY MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.85, 0, 0, 1)
Line.Position = UDim2.new(0.075, 0, 0, 38)
Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line.BackgroundTransparency = 0.7
Line.BorderSizePixel = 0
Line.Parent = Main

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Toggle"
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 42)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.42, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Text = "FLY : OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.TextSize = 16
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Main

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(220, 220, 220)
BtnStroke.Thickness = 1.2
BtnStroke.Transparency = 0.4
BtnStroke.Parent = ToggleBtn

ToggleBtn.MouseEnter:Connect(function()
	TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	}):Play()
end)

ToggleBtn.MouseLeave:Connect(function()
	TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	}):Play()
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

-- ==================== TOGGLE ====================
local function updateButton()
	if Flying then
		ToggleBtn.Text = "FLY : ON"
		BtnStroke.Color = Color3.fromRGB(255, 255, 255)
		BtnStroke.Transparency = 0.15
	else
		ToggleBtn.Text = "FLY : OFF"
		BtnStroke.Color = Color3.fromRGB(180, 180, 180)
		BtnStroke.Transparency = 0.45
	end
end

ToggleBtn.MouseButton1Click:Connect(function()
	setFly(not Flying)
	updateButton()
end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F then
		setFly(not Flying)
		updateButton()
	end
end)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 20)
Info.Position = UDim2.new(0, 0, 1, -24)
Info.BackgroundTransparency = 1
Info.Text = "Tekan F juga bisa"
Info.TextColor3 = Color3.fromRGB(160, 160, 160)
Info.Font = Enum.Font.Gotham
Info.TextSize = 12
Info.Parent = Main

print("Fly Menu Loaded | Clean Version")
