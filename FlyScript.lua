-- Fly Script + Black & White Glossy GUI (Fixed Version)
-- Tombol di GUI atau tekan F = ON/OFF Fly
-- WASD = gerak | Space = naik | Ctrl = turun

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Flying = false
local Speed = 60 -- ubah angka ini kalau mau lebih cepat/lambat

local BV, BG
local Connections = {}

-- Hapus GUI lama kalau script dijalankan 2x
local guiParent
local okHui, hui = pcall(function() return gethui and gethui() end)
if okHui and hui then
	guiParent = hui
else
	guiParent = Player:WaitForChild("PlayerGui")
end

local old = guiParent:FindFirstChild("FlyMenu")
if old then old:Destroy() end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 230, 0, 150)
Main.Position = UDim2.new(0.5, -115, 0.5, -75)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 1.4
Stroke.Transparency = 0.25
Stroke.Parent = Main

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8)),
})
Gradient.Rotation = 90
Gradient.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 38)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FLY MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
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
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 56)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Text = "FLY : OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = Main

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(255, 255, 255)
BtnStroke.Thickness = 1.2
BtnStroke.Transparency = 0.4
BtnStroke.Parent = ToggleBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 6)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Main

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 20)
Info.Position = UDim2.new(0, 0, 1, -24)
Info.BackgroundTransparency = 1
Info.Text = "Tekan F juga bisa"
Info.TextColor3 = Color3.fromRGB(170, 170, 170)
Info.Font = Enum.Font.Gotham
Info.TextSize = 12
Info.Parent = Main

-- ==================== DRAG GUI ====================
do
	local dragging, dragStart, startPos

	Main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	table.insert(Connections, UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end))
end

-- ==================== FLY LOGIC ====================
local function getRoot()
	local char = Player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local char = Player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function updateButton()
	if Flying then
		ToggleBtn.Text = "FLY : ON"
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			TextColor3 = Color3.fromRGB(0, 0, 0),
		}):Play()
	else
		ToggleBtn.Text = "FLY : OFF"
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}):Play()
	end
end

local function stopFly()
	Flying = false
	if BV then BV:Destroy() BV = nil end
	if BG then BG:Destroy() BG = nil end
	local hum = getHumanoid()
	if hum then hum.PlatformStand = false end
	updateButton()
end

local function startFly()
	local root = getRoot()
	local hum = getHumanoid()
	if not root or not hum then return end

	if BV then BV:Destroy() end
	if BG then BG:Destroy() end

	BV = Instance.new("BodyVelocity")
	BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BV.Velocity = Vector3.zero
	BV.Parent = root

	BG = Instance.new("BodyGyro")
	BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BG.P = 10000
	BG.CFrame = root.CFrame
	BG.Parent = root

	hum.PlatformStand = true
	Flying = true
	updateButton()
end

local function toggleFly()
	if Flying then
		stopFly()
	else
		startFly()
	end
end

-- Gerakan saat terbang
table.insert(Connections, RunService.Heartbeat:Connect(function()
	if not Flying then return end

	local root = getRoot()
	if not root or not BV or not BG then
		stopFly()
		return
	end

	-- Pasang ulang kalau sempat terlepas
	if BV.Parent ~= root then BV.Parent = root end
	if BG.Parent ~= root then BG.Parent = root end

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
end))

-- ==================== TOMBOL & KEYBIND ====================
ToggleBtn.MouseButton1Click:Connect(toggleFly)

ToggleBtn.MouseEnter:Connect(function()
	if not Flying then
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		}):Play()
	end
end)

ToggleBtn.MouseLeave:Connect(function()
	if not Flying then
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		}):Play()
	end
end)

table.insert(Connections, UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F then
		toggleFly()
	end
end))

-- Tombol X: matikan fly lalu hapus GUI dan semua koneksi
CloseBtn.MouseButton1Click:Connect(function()
	stopFly()
	for _, c in ipairs(Connections) do
		c:Disconnect()
	end
	ScreenGui:Destroy()
end)

-- Kalau karakter mati/respawn, fly otomatis OFF
table.insert(Connections, Player.CharacterAdded:Connect(function()
	stopFly()
end))

print("Fly Menu Loaded | Fixed Version")
