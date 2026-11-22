--[[
	NATURAL DISASTER  v1.2  |  by jeysar  (Black & White GUI)

	Keybind:
	  F          = Fly ON/OFF
	  N          = Noclip ON/OFF
	  J          = Infinite Jump ON/OFF
	  K          = Anti Fling ON/OFF
	  L          = Walk Fling ON/OFF
	  M          = ESP Aura ON/OFF
	  RightShift = Tampilkan / sembunyikan menu

	Fly: WASD = gerak | Space = naik | Ctrl = turun
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer

-- ==================== STATE ====================
local State = {
	Flying = false,
	Noclip = false,
	InfJump = false,
	AntiAFK = false,
	AntiFling = false,
	Fling = false,
	ESP = false,
	ESPIntensity = 70,
	FlySpeed = 60,
	WalkSpeed = 16,
	JumpPower = 50,
	WalkChanged = false,
	JumpChanged = false,
}

local BV, BG
local Connections = {}
local FlyToggle -- diisi nanti

-- ==================== HELPER KARAKTER ====================
local function getChar() return Player.Character end

local function getRoot()
	local c = getChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local c = getChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end

-- Simpan nilai asli game buat tombol Reset
local DefaultWalk, DefaultJump = 16, 50
do
	local hum = getHumanoid()
	if hum then
		DefaultWalk = hum.WalkSpeed
		DefaultJump = hum.JumpPower
	end
end
State.WalkSpeed = DefaultWalk
State.JumpPower = DefaultJump

-- ==================== PARENT GUI ====================
local guiParent
local okHui, hui = pcall(function() return gethui and gethui() end)
if okHui and hui then
	guiParent = hui
else
	guiParent = Player:WaitForChild("PlayerGui")
end

local old = guiParent:FindFirstChild("FlyHubPro")
if old then old:Destroy() end
local oldEsp = guiParent:FindFirstChild("FlyHubESP")
if oldEsp then oldEsp:Destroy() end

-- ==================== TEMA & UTILITAS UI ====================
local C = {
	Bg = Color3.fromRGB(16, 16, 16),
	Panel = Color3.fromRGB(30, 30, 30),
	Hover = Color3.fromRGB(46, 46, 46),
	Off = Color3.fromRGB(65, 65, 65),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	Dim = Color3.fromRGB(160, 160, 160),
}

local function addCorner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

local function addStroke(obj, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = C.White
	s.Transparency = transparency or 0.7
	s.Thickness = thickness or 1
	s.Parent = obj
	return s
end

local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
end

-- ==================== WINDOW ====================
local FULL_SIZE = UDim2.new(0, 400, 0, 290)
local MINI_SIZE = UDim2.new(0, 400, 0, 36)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyHubPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = FULL_SIZE
Main.Position = UDim2.new(0, 20, 0.5, -145)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
addCorner(Main, 12)
addStroke(Main, 0.25, 1.4)

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 38)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10)),
})
Gradient.Rotation = 90
Gradient.Parent = Main

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundTransparency = 1
TitleBar.Active = true
TitleBar.Parent = Main

local VERSION = "v1.2"

local TitleBox = Instance.new("Frame")
TitleBox.Size = UDim2.new(1, -90, 1, 0)
TitleBox.Position = UDim2.new(0, 14, 0, 0)
TitleBox.BackgroundTransparency = 1
TitleBox.Parent = TitleBar

local TitleLayout = Instance.new("UIListLayout")
TitleLayout.FillDirection = Enum.FillDirection.Horizontal
TitleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TitleLayout.SortOrder = Enum.SortOrder.LayoutOrder
TitleLayout.Padding = UDim.new(0, 7)
TitleLayout.Parent = TitleBox

local Title = Instance.new("TextLabel")
Title.LayoutOrder = 1
Title.AutomaticSize = Enum.AutomaticSize.X
Title.Size = UDim2.new(0, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "NATURAL DISASTER"
Title.TextColor3 = C.White
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = TitleBox

-- Credit kecil: "by jeysar"
local Credit = Instance.new("TextLabel")
Credit.LayoutOrder = 2
Credit.AutomaticSize = Enum.AutomaticSize.X
Credit.Size = UDim2.new(0, 0, 1, 0)
Credit.BackgroundTransparency = 1
Credit.Text = "by jeysar"
Credit.TextColor3 = C.Dim
Credit.Font = Enum.Font.GothamMedium
Credit.TextSize = 10
Credit.Parent = TitleBox

-- Badge versi
local VerBadge = Instance.new("Frame")
VerBadge.LayoutOrder = 3
VerBadge.AutomaticSize = Enum.AutomaticSize.X
VerBadge.Size = UDim2.new(0, 0, 0, 16)
VerBadge.BackgroundColor3 = C.White
VerBadge.BackgroundTransparency = 0.88
VerBadge.BorderSizePixel = 0
VerBadge.Parent = TitleBox
addCorner(VerBadge, 8)
addStroke(VerBadge, 0.6, 1)

local VerPad = Instance.new("UIPadding")
VerPad.PaddingLeft = UDim.new(0, 7)
VerPad.PaddingRight = UDim.new(0, 7)
VerPad.Parent = VerBadge

local VerText = Instance.new("TextLabel")
VerText.AutomaticSize = Enum.AutomaticSize.X
VerText.Size = UDim2.new(0, 0, 1, 0)
VerText.BackgroundTransparency = 1
VerText.Text = VERSION
VerText.TextColor3 = C.White
VerText.Font = Enum.Font.GothamBold
VerText.TextSize = 10
VerText.Parent = VerBadge

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -64, 0, 4)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = C.White
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 22
MinBtn.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.White
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.Parent = TitleBar

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -24, 0, 1)
Divider.Position = UDim2.new(0, 12, 0, 36)
Divider.BackgroundColor3 = C.White
Divider.BackgroundTransparency = 0.8
Divider.BorderSizePixel = 0
Divider.Parent = Main

-- Body (disembunyikan saat minimize)
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -37)
Body.Position = UDim2.new(0, 0, 0, 37)
Body.BackgroundTransparency = 1
Body.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 92, 1, -16)
Sidebar.Position = UDim2.new(0, 10, 0, 8)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Body

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 6)
SideList.Parent = Sidebar

local PageHolder = Instance.new("Frame")
PageHolder.Size = UDim2.new(1, -118, 1, -12)
PageHolder.Position = UDim2.new(0, 108, 0, 6)
PageHolder.BackgroundTransparency = 1
PageHolder.Parent = Body

-- ==================== TOAST / NOTIFIKASI ====================
local lastToast
local function notify(text)
	if lastToast then lastToast:Destroy() end
	local T = Instance.new("TextLabel")
	T.Size = UDim2.new(0, 240, 0, 32)
	T.AnchorPoint = Vector2.new(0.5, 1)
	T.Position = UDim2.new(0.5, 0, 1, -24)
	T.BackgroundColor3 = C.Bg
	T.BackgroundTransparency = 0.1
	T.Text = text
	T.TextColor3 = C.White
	T.Font = Enum.Font.GothamMedium
	T.TextSize = 13
	T.Parent = ScreenGui
	addCorner(T, 8)
	addStroke(T, 0.5, 1)
	lastToast = T
	task.delay(1.8, function()
		if T and T.Parent then T:Destroy() end
	end)
end

-- ==================== TAB & PAGE ====================
local Tabs = {}
local CurrentTab

local function selectTab(name)
	CurrentTab = name
	for n, t in pairs(Tabs) do
		local active = (n == name)
		t.Page.Visible = active
		tween(t.Btn, {
			BackgroundColor3 = active and C.White or C.Panel,
			TextColor3 = active and C.Black or C.White,
		})
	end
end

local function createTab(name)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 0, 32)
	Btn.BackgroundColor3 = C.Panel
	Btn.AutoButtonColor = false
	Btn.Text = name
	Btn.TextColor3 = C.White
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 13
	Btn.Parent = Sidebar
	addCorner(Btn, 8)

	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 3
	Page.ScrollBarImageColor3 = C.White
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.Visible = false
	Page.Parent = PageHolder

	local List = Instance.new("UIListLayout")
	List.Padding = UDim.new(0, 8)
	List.Parent = Page

	local Pad = Instance.new("UIPadding")
	Pad.PaddingTop = UDim.new(0, 2)
	Pad.PaddingBottom = UDim.new(0, 4)
	Pad.PaddingRight = UDim.new(0, 6)
	Pad.Parent = Page

	Tabs[name] = {Btn = Btn, Page = Page}
	Btn.MouseButton1Click:Connect(function() selectTab(name) end)
	return Page
end

-- ==================== KOMPONEN UI ====================
local function newRow(parent, height)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, height)
	Row.BackgroundColor3 = C.Panel
	Row.BorderSizePixel = 0
	Row.Parent = parent
	addCorner(Row, 8)
	return Row
end

local function createToggle(parent, text, default, callback)
	local Row = newRow(parent, 38)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -70, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = C.White
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Row

	local Switch = Instance.new("Frame")
	Switch.Size = UDim2.new(0, 40, 0, 20)
	Switch.Position = UDim2.new(1, -52, 0.5, -10)
	Switch.BackgroundColor3 = C.Off
	Switch.BorderSizePixel = 0
	Switch.Parent = Row
	addCorner(Switch, 10)

	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0, 16, 0, 16)
	Knob.Position = UDim2.new(0, 2, 0.5, -8)
	Knob.BackgroundColor3 = C.White
	Knob.BorderSizePixel = 0
	Knob.Parent = Switch
	addCorner(Knob, 8)

	local Click = Instance.new("TextButton")
	Click.Size = UDim2.new(1, 0, 1, 0)
	Click.BackgroundTransparency = 1
	Click.Text = ""
	Click.Parent = Row

	local state = false
	local obj = {}

	function obj.Set(v, silent)
		state = v
		tween(Switch, {BackgroundColor3 = v and C.White or C.Off})
		tween(Knob, {
			Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
			BackgroundColor3 = v and C.Black or C.White,
		})
		if not silent then callback(v) end
	end

	function obj.Get() return state end

	Click.MouseButton1Click:Connect(function() obj.Set(not state) end)
	obj.Set(default, true)
	return obj
end

local function createSlider(parent, text, minV, maxV, default, callback)
	local Row = newRow(parent, 58)

	local Name = Instance.new("TextLabel")
	Name.Size = UDim2.new(0.6, 0, 0, 20)
	Name.Position = UDim2.new(0, 12, 0, 6)
	Name.BackgroundTransparency = 1
	Name.Text = text
	Name.TextColor3 = C.White
	Name.Font = Enum.Font.GothamMedium
	Name.TextSize = 13
	Name.TextXAlignment = Enum.TextXAlignment.Left
	Name.Parent = Row

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Size = UDim2.new(0.4, -12, 0, 20)
	ValueLabel.Position = UDim2.new(0.6, 0, 0, 6)
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.TextColor3 = C.Dim
	ValueLabel.Font = Enum.Font.GothamBold
	ValueLabel.TextSize = 13
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.Parent = Row

	local Track = Instance.new("Frame")
	Track.Size = UDim2.new(1, -24, 0, 22)
	Track.Position = UDim2.new(0, 12, 0, 30)
	Track.BackgroundTransparency = 1
	Track.Active = true
	Track.Parent = Row

	local Bar = Instance.new("Frame")
	Bar.Size = UDim2.new(1, 0, 0, 6)
	Bar.Position = UDim2.new(0, 0, 0.5, -3)
	Bar.BackgroundColor3 = C.Off
	Bar.BorderSizePixel = 0
	Bar.Parent = Track
	addCorner(Bar, 3)

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new(0, 0, 1, 0)
	Fill.BackgroundColor3 = C.White
	Fill.BorderSizePixel = 0
	Fill.Parent = Bar
	addCorner(Fill, 3)

	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.new(0, 14, 0, 14)
	Knob.AnchorPoint = Vector2.new(0.5, 0.5)
	Knob.Position = UDim2.new(1, 0, 0.5, 0)
	Knob.BackgroundColor3 = C.White
	Knob.BorderSizePixel = 0
	Knob.Parent = Fill
	addCorner(Knob, 7)

	local obj = {}

	function obj.Set(v, silent)
		v = math.clamp(math.floor(v + 0.5), minV, maxV)
		local rel = (v - minV) / (maxV - minV)
		Fill.Size = UDim2.new(rel, 0, 1, 0)
		ValueLabel.Text = tostring(v)
		if not silent then callback(v) end
	end

	local sliding = false

	local function fromX(x)
		local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		obj.Set(minV + (maxV - minV) * rel)
	end

	Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			fromX(input.Position.X)
		end
	end)

	table.insert(Connections, UIS.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end))

	table.insert(Connections, UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end))

	obj.Set(default, true)
	return obj
end

local function createButton(parent, text, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 0, 36)
	Btn.BackgroundColor3 = C.Panel
	Btn.AutoButtonColor = false
	Btn.Text = text
	Btn.TextColor3 = C.White
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 13
	Btn.Parent = parent
	addCorner(Btn, 8)
	addStroke(Btn, 0.6, 1)

	Btn.MouseEnter:Connect(function() tween(Btn, {BackgroundColor3 = C.Hover}) end)
	Btn.MouseLeave:Connect(function() tween(Btn, {BackgroundColor3 = C.Panel}) end)
	Btn.MouseButton1Click:Connect(callback)
	return Btn
end

local function createInfo(parent, text, height)
	local Row = newRow(parent, height)
	local L = Instance.new("TextLabel")
	L.Size = UDim2.new(1, -24, 1, -12)
	L.Position = UDim2.new(0, 12, 0, 6)
	L.BackgroundTransparency = 1
	L.Text = text
	L.TextColor3 = C.Dim
	L.Font = Enum.Font.Gotham
	L.TextSize = 12
	L.TextWrapped = true
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.TextYAlignment = Enum.TextYAlignment.Top
	L.Parent = Row
	return L
end

-- ==================== FLY LOGIC ====================
local function stopFly()
	State.Flying = false
	if BV then BV:Destroy() BV = nil end
	if BG then BG:Destroy() BG = nil end
	local hum = getHumanoid()
	if hum then hum.PlatformStand = false end
	if FlyToggle then FlyToggle.Set(false, true) end
end

local function startFly()
	local root = getRoot()
	local hum = getHumanoid()
	if not root or not hum then return false end

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
	State.Flying = true
	return true
end

-- ==================== ANTI FLING ====================
local FlingModified = setmetatable({}, {__mode = "k"})

local function restoreFling()
	for part in pairs(FlingModified) do
		if part and part.Parent then
			part.CanCollide = true
		end
	end
	table.clear(FlingModified)
end

-- ==================== ESP AURA ====================
local ESP_COLOR = Color3.fromRGB(255, 0, 0)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FlyHubESP"
ESPFolder.Parent = guiParent

local ESPObjects = {}

-- Intensitas 5-100: makin tinggi makin pekat (fill) & outline makin jelas
local function styleESP(h)
	local i = State.ESPIntensity / 100
	h.FillColor = ESP_COLOR
	h.OutlineColor = ESP_COLOR
	h.FillTransparency = 1 - i
	h.OutlineTransparency = (1 - i) * 0.5
end

local function removeESP(plr)
	local h = ESPObjects[plr]
	if h then
		h:Destroy()
		ESPObjects[plr] = nil
	end
end

local function addESP(plr)
	if plr == Player then return end
	removeESP(plr)
	local char = plr.Character
	if not char then return end
	local h = Instance.new("Highlight")
	h.Name = "ESP_" .. plr.Name
	h.Adornee = char
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- tembus tembok
	styleESP(h)
	h.Parent = ESPFolder
	ESPObjects[plr] = h
end

local function refreshAllESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		addESP(plr)
	end
end

local function clearESP()
	for plr in pairs(ESPObjects) do
		removeESP(plr)
	end
end

local function hookESPPlayer(plr)
	if plr == Player then return end
	table.insert(Connections, plr.CharacterAdded:Connect(function()
		if State.ESP then addESP(plr) end
	end))
end

for _, plr in ipairs(Players:GetPlayers()) do hookESPPlayer(plr) end

table.insert(Connections, Players.PlayerAdded:Connect(function(plr)
	hookESPPlayer(plr)
end))

table.insert(Connections, Players.PlayerRemoving:Connect(removeESP))

-- ==================== PAGES ====================
local MainPage = createTab("Main")
local PlayerPage = createTab("Player")
local ESPPage = createTab("ESP")
local MiscPage = createTab("Misc")

-- ---- Main ----
FlyToggle = createToggle(MainPage, "Fly  [F]", false, function(v)
	if v then
		if not startFly() then
			FlyToggle.Set(false, true)
			return
		end
		notify("Fly: ON")
	else
		stopFly()
		notify("Fly: OFF")
	end
end)

local FlySlider = createSlider(MainPage, "Fly Speed", 10, 300, State.FlySpeed, function(v)
	State.FlySpeed = v
end)

local NoclipToggle = createToggle(MainPage, "Noclip  [N]", false, function(v)
	State.Noclip = v
	notify("Noclip: " .. (v and "ON" or "OFF"))
end)

local InfJumpToggle = createToggle(MainPage, "Infinite Jump  [J]", false, function(v)
	State.InfJump = v
	notify("Infinite Jump: " .. (v and "ON" or "OFF"))
end)

local AntiFlingToggle = createToggle(MainPage, "Anti Fling  [K]", false, function(v)
	State.AntiFling = v
	if not v then restoreFling() end
	notify("Anti Fling: " .. (v and "ON" or "OFF"))
end)

local FlingToggle = createToggle(MainPage, "Walk Fling  [L]", false, function(v)
	State.Fling = v
	if v then
		-- fling butuh tabrakan, jadi Noclip & Anti Fling dimatikan dulu
		if NoclipToggle.Get() then NoclipToggle.Set(false) end
		if AntiFlingToggle.Get() then AntiFlingToggle.Set(false) end
	end
	notify("Walk Fling: " .. (v and "ON (jalan nabrak orang)" or "OFF"))
end)

-- ---- Player ----
local WalkSlider = createSlider(PlayerPage, "Walk Speed", 8, 200,
	math.clamp(DefaultWalk, 8, 200), function(v)
		State.WalkSpeed = v
		State.WalkChanged = true
	end)

local JumpSlider = createSlider(PlayerPage, "Jump Power", 20, 250,
	math.clamp(DefaultJump, 20, 250), function(v)
		State.JumpPower = v
		State.JumpChanged = true
	end)

createButton(PlayerPage, "Reset Walk & Jump", function()
	State.WalkChanged = false
	State.JumpChanged = false
	State.WalkSpeed = DefaultWalk
	State.JumpPower = DefaultJump
	WalkSlider.Set(math.clamp(DefaultWalk, 8, 200), true)
	JumpSlider.Set(math.clamp(DefaultJump, 20, 250), true)
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = DefaultWalk
		hum.JumpPower = DefaultJump
	end
	notify("Walk & Jump di-reset")
end)

-- ---- ESP ----
local ESPToggle = createToggle(ESPPage, "ESP Aura  [M]", false, function(v)
	State.ESP = v
	if v then refreshAllESP() else clearESP() end
	notify("ESP Aura: " .. (v and "ON" or "OFF"))
end)

createSlider(ESPPage, "Intensitas Aura", 5, 100, State.ESPIntensity, function(v)
	State.ESPIntensity = v
	for _, h in pairs(ESPObjects) do styleESP(h) end
end)

createInfo(ESPPage, "Aura merah di semua pemain lain, tembus tembok.\nGeser slider buat atur pekat/tipisnya aura.", 60)

-- ---- Misc ----
local AFKToggle = createToggle(MiscPage, "Anti AFK", false, function(v)
	State.AntiAFK = v
	notify("Anti AFK: " .. (v and "ON" or "OFF"))
end)

createInfo(MiscPage,
	"Keybind:\nF = Fly\nN = Noclip\nJ = Infinite Jump\nK = Anti Fling\nL = Walk Fling\nM = ESP Aura\nRightShift = Tampil/sembunyi menu\n\nFly: WASD + Space (naik) + Ctrl (turun)",
	160)

local function unload()
	stopFly()
	restoreFling()
	clearESP()
	ESPFolder:Destroy()
	for _, c in ipairs(Connections) do
		c:Disconnect()
	end
	ScreenGui:Destroy()
end

createButton(MiscPage, "Unload Script", unload)

selectTab("Main")

-- ==================== LOOP UTAMA ====================
-- Fly + enforce walk/jump
table.insert(Connections, RunService.Heartbeat:Connect(function()
	local hum = getHumanoid()
	if hum then
		if State.WalkChanged and hum.WalkSpeed ~= State.WalkSpeed then
			hum.WalkSpeed = State.WalkSpeed
		end
		if State.JumpChanged then
			if not hum.UseJumpPower then hum.UseJumpPower = true end
			if hum.JumpPower ~= State.JumpPower then
				hum.JumpPower = State.JumpPower
			end
		end
	end

	if not State.Flying then return end

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
		BV.Velocity = move.Unit * State.FlySpeed
	else
		BV.Velocity = Vector3.zero
	end

	BG.CFrame = cam.CFrame
end))

-- Noclip
table.insert(Connections, RunService.Stepped:Connect(function()
	if not State.Noclip then return end
	local char = getChar()
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			part.CanCollide = false
		end
	end
end))

-- Anti Fling
-- 1) Karakter pemain lain tidak bisa nabrak kamu (CanCollide dimatikan di sisi kamu)
table.insert(Connections, RunService.Stepped:Connect(function()
	if not State.AntiFling then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Player and plr.Character then
			for _, part in ipairs(plr.Character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
					FlingModified[part] = true
				end
			end
		end
	end
end))

-- 2) Kalau tetap terdorong terlalu kencang atau berputar liar, langsung ditahan
table.insert(Connections, RunService.Heartbeat:Connect(function()
	if not State.AntiFling then return end
	local root = getRoot()
	if not root then return end

	if root.AssemblyAngularVelocity.Magnitude > 30 then
		root.AssemblyAngularVelocity = Vector3.zero
	end

	if not State.Flying then
		local v = root.AssemblyLinearVelocity
		local horizontal = Vector3.new(v.X, 0, v.Z)
		local limit = math.max(120, State.WalkSpeed * 4)
		if horizontal.Magnitude > limit then
			root.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
		end
	end
end))

-- Walk Fling (loop sendiri, berhenti otomatis kalau GUI di-unload)
task.spawn(function()
	while ScreenGui.Parent do
		RunService.Heartbeat:Wait()
		if State.Fling then
			local root = getRoot()
			if root then
				local vel = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
				RunService.RenderStepped:Wait()
				if root.Parent then root.AssemblyLinearVelocity = vel end
				RunService.Stepped:Wait()
				if root.Parent then root.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0) end
			end
		end
	end
end)

-- Infinite Jump
table.insert(Connections, UIS.JumpRequest:Connect(function()
	if not State.InfJump then return end
	local hum = getHumanoid()
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end))

-- Anti AFK
table.insert(Connections, Player.Idled:Connect(function()
	if not State.AntiAFK then return end
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end))

-- ==================== KEYBIND ====================
table.insert(Connections, UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	local k = input.KeyCode
	if k == Enum.KeyCode.F then
		FlyToggle.Set(not FlyToggle.Get())
	elseif k == Enum.KeyCode.N then
		NoclipToggle.Set(not NoclipToggle.Get())
	elseif k == Enum.KeyCode.J then
		InfJumpToggle.Set(not InfJumpToggle.Get())
	elseif k == Enum.KeyCode.K then
		AntiFlingToggle.Set(not AntiFlingToggle.Get())
	elseif k == Enum.KeyCode.L then
		FlingToggle.Set(not FlingToggle.Get())
	elseif k == Enum.KeyCode.M then
		ESPToggle.Set(not ESPToggle.Get())
	elseif k == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end))

-- ==================== DRAG ====================
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

-- ==================== MINIMIZE & CLOSE ====================
local Minimized = false

MinBtn.MouseButton1Click:Connect(function()
	Minimized = not Minimized
	if Minimized then
		MinBtn.Text = "+"
		Body.Visible = false
		Divider.Visible = false
		tween(Main, {Size = MINI_SIZE}, 0.2)
	else
		MinBtn.Text = "-"
		Divider.Visible = true
		tween(Main, {Size = FULL_SIZE}, 0.2)
		task.delay(0.12, function()
			if not Minimized then Body.Visible = true end
		end)
	end
end)

CloseBtn.MouseButton1Click:Connect(unload)

-- ==================== RESPAWN ====================
table.insert(Connections, Player.CharacterAdded:Connect(function(char)
	stopFly()
	local hum = char:WaitForChild("Humanoid")
	DefaultWalk = hum.WalkSpeed
	DefaultJump = hum.JumpPower
end))

notify("Natural Disaster " .. VERSION .. " by jeysar loaded")
print("Natural Disaster " .. VERSION .. " by jeysar Loaded | F = Fly, N = Noclip, J = Inf Jump, K = Anti Fling, L = Walk Fling, M = ESP, RightShift = Hide")
