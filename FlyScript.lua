-- Fly Menu v2 (Black & White Glossy GUI)
-- F = ON/OFF Fly | WASD = gerak | Space = naik | Ctrl = turun
-- Tombol "-" = kecilin menu | Tombol X = tutup & matikan semua
-- Slider: atur Fly Speed dan Jump Power

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Flying = false
local Speed = 60            -- kecepatan terbang (bisa diubah dari slider)
local JumpPowerValue = 50   -- tinggi lompat (bisa diubah dari slider)
local JumpChanged = false   -- jump baru diubah kalau slider disentuh

local BV, BG
local Connections = {}

-- ==================== PARENT GUI ====================
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
local FULL_SIZE = UDim2.new(0, 240, 0, 214)
local MINI_SIZE = UDim2.new(0, 240, 0, 38)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = FULL_SIZE
Main.Position = UDim2.new(0, 20, 0.5, -107)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
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

-- Title bar (area buat drag)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundTransparency = 1
TitleBar.Active = true
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FLY MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -62, 0, 5)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 22
MinBtn.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

-- Isi menu (disembunyiin waktu minimize)
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -38)
Content.Position = UDim2.new(0, 0, 0, 38)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.85, 0, 0, 1)
Line.Position = UDim2.new(0.075, 0, 0, 0)
Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line.BackgroundTransparency = 0.7
Line.BorderSizePixel = 0
Line.Parent = Content

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Toggle"
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 12)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Text = "FLY : OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = Content

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(255, 255, 255)
BtnStroke.Thickness = 1.2
BtnStroke.Transparency = 0.4
BtnStroke.Parent = ToggleBtn

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 18)
Info.Position = UDim2.new(0, 0, 1, -22)
Info.BackgroundTransparency = 1
Info.Text = "Tekan F juga bisa"
Info.TextColor3 = Color3.fromRGB(170, 170, 170)
Info.Font = Enum.Font.Gotham
Info.TextSize = 12
Info.Parent = Content

-- ==================== SLIDER ====================
local function makeSlider(labelText, yPos, minV, maxV, defaultV, onChange)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.8, 0, 0, 18)
	Label.Position = UDim2.new(0.1, 0, 0, yPos)
	Label.BackgroundTransparency = 1
	Label.Text = labelText .. ": " .. defaultV
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Content

	local Track = Instance.new("Frame")
	Track.Size = UDim2.new(0.8, 0, 0, 22)
	Track.Position = UDim2.new(0.1, 0, 0, yPos + 20)
	Track.BackgroundTransparency = 1
	Track.Active = true
	Track.Parent = Content

	local Bar = Instance.new("Frame")
	Bar.Size = UDim2.new(1, 0, 0, 6)
	Bar.Position = UDim2.new(0, 0, 0.5, -3)
	Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Bar.BorderSizePixel = 0
	Bar.Parent = Track
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((defaultV - minV) / (maxV - minV), 0, 1, 0)
	Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Fill.BorderSizePixel = 0
	Fill.Parent = Bar
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0, 14, 0, 14)
	Knob.AnchorPoint = Vector2.new(0.5, 0.5)
	Knob.Position = UDim2.new(1, 0, 0.5, 0)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Knob.BorderSizePixel = 0
	Knob.Parent = Fill
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

	local sliding = false

	local function setFromX(x)
		local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		local value = math.floor(minV + (maxV - minV) * rel + 0.5)
		Fill.Size = UDim2.new(rel, 0, 1, 0)
		Label.Text = labelText .. ": " .. value
		onChange(value)
	end

	Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			setFromX(input.Position.X)
		end
	end)

	table.insert(Connections, UIS.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end))

	table.insert(Connections, UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end))
end

-- ==================== DRAG GUI (lewat title bar) ====================
do
	local dragging, dragStart, startPos

	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
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

	table.insert(Connections, UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

-- ==================== HELPER KARAKTER ====================
local function getRoot()
	local char = Player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local char = Player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function applyJump()
	if not JumpChanged then return end
	local hum = getHumanoid()
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = JumpPowerValue
	end
end

-- Slider (Fly Speed & Jump Power)
makeSlider("Fly Speed", 62, 10, 300, Speed, function(v)
	Speed = v
end)

makeSlider("Jump Power", 106, 20, 250, JumpPowerValue, function(v)
	JumpPowerValue = v
	JumpChanged = true
	applyJump()
end)

-- ==================== FLY LOGIC ====================
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

table.insert(Connections, RunService.Heartbeat:Connect(function()
	if not Flying then return end

	local root = getRoot()
	if not root or not BV or not BG then
		stopFly()
		return
	end

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

-- ==================== MINIMIZE ====================
local Minimized = false

local function setMinimized(state)
	Minimized = state
	if Minimized then
		MinBtn.Text = "+"
		Content.Visible = false
		TweenService:Create(Main, TweenInfo.new(0.2), {Size = MINI_SIZE}):Play()
	else
		MinBtn.Text = "-"
		TweenService:Create(Main, TweenInfo.new(0.2), {Size = FULL_SIZE}):Play()
		task.delay(0.15, function()
			if not Minimized then Content.Visible = true end
		end)
	end
end

MinBtn.MouseButton1Click:Connect(function()
	setMinimized(not Minimized)
end)

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

-- Tombol X: matikan fly, hapus GUI dan semua koneksi
CloseBtn.MouseButton1Click:Connect(function()
	stopFly()
	for _, c in ipairs(Connections) do
		c:Disconnect()
	end
	ScreenGui:Destroy()
end)

-- Respawn: fly OFF, jump power dipasang ulang
table.insert(Connections, Player.CharacterAdded:Connect(function(char)
	stopFly()
	char:WaitForChild("Humanoid")
	applyJump()
end))

print("Fly Menu v2 Loaded | Minimize + Speed + Jump")
