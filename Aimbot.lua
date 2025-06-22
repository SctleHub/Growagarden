local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Config
local AimbotEnabled = false
local TeamCheck = true
local WallCheck = true
local FOVRadius = 100
local ESPEnabled = false
local ESPTeamCheck = true
local HighlightColor = Color3.fromRGB(255, 0, 0)
local FOVRainbow = false
local FOVColor = Color3.fromRGB(0, 255, 0)

-- FOV Circle
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOV"
FOVCircle.Parent = ScreenGui
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
FOVCircle.BackgroundTransparency = 1

local UIStroke = Instance.new("UIStroke", FOVCircle)
UIStroke.Thickness = 2
UIStroke.Color = FOVColor

local UICorner = Instance.new("UICorner", FOVCircle)
UICorner.CornerRadius = UDim.new(1, 0)

-- FPS and Ping Display
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = ScreenGui
StatsLabel.Size = UDim2.new(0, 200, 0, 50)
StatsLabel.Position = UDim2.new(1, -210, 0, 10)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.new(1, 1, 1)
StatsLabel.TextStrokeTransparency = 0
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 18
StatsLabel.TextXAlignment = Enum.TextXAlignment.Right

local lastUpdate = tick()
RunService.RenderStepped:Connect(function()
	local fps = math.floor(1 / RunService.RenderStepped:Wait())
	if tick() - lastUpdate >= 0.3 then
		local ping = tonumber(string.match(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString(), "%d+")) or 0
		StatsLabel.Text = "FPS: " .. fps .. " | Ping: " .. ping .. "ms"
		lastUpdate = tick()
	end
end)

-- Rayfield GUI
local Window = Rayfield:CreateWindow({
	Name = "Aimbot FOV",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "By _zxmisaxz_",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "AimbotFOV",
		FileName = "settings"
	},
	KeySystem = false
})

-- Main Tab
local Tab = Window:CreateTab("Main", 4483362458)
Tab:CreateToggle({
	Name = "Enable Aimbot",
	CurrentValue = false,
	Callback = function(value)
		AimbotEnabled = value
		FOVCircle.Visible = value
	end
})
Tab:CreateToggle({
	Name = "Team Check",
	CurrentValue = true,
	Callback = function(value)
		TeamCheck = value
	end
})
Tab:CreateToggle({
	Name = "Wall Check",
	CurrentValue = true,
	Callback = function(value)
		WallCheck = value
	end
})
Tab:CreateSlider({
	Name = "FOV Size",
	Range = {50, 300},
	Increment = 5,
	CurrentValue = 100,
	Callback = function(value)
		FOVRadius = value
		FOVCircle.Size = UDim2.new(0, value * 2, 0, value * 2)
	end
})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({
	Name = "Enable Highlight",
	CurrentValue = false,
	Callback = function(value)
		ESPEnabled = value
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local highlight = player.Character and player.Character:FindFirstChild("ESPHighlight")
				if highlight then
					highlight.Enabled = value and (not ESPTeamCheck or player.Team ~= LocalPlayer.Team)
				end
			end
		end
	end
})
ESPTab:CreateToggle({
	Name = "Team Check for Highlight",
	CurrentValue = true,
	Callback = function(value)
		ESPTeamCheck = value
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local highlight = player.Character and player.Character:FindFirstChild("ESPHighlight")
				if highlight then
					highlight.Enabled = ESPEnabled and (not value or player.Team ~= LocalPlayer.Team)
				end
			end
		end
	end
})
ESPTab:CreateColorPicker({
	Name = "Highlight Color",
	Color = HighlightColor,
	Callback = function(value)
		HighlightColor = value
		for _, player in ipairs(Players:GetPlayers()) do
			local highlight = player.Character and player.Character:FindFirstChild("ESPHighlight")
			if highlight then
				highlight.OutlineColor = value
				highlight.FillColor = value
			end
		end
	end
})

-- Visual Tab
local VisualTab = Window:CreateTab("Visual", 4483362458)
VisualTab:CreateToggle({
	Name = "Rainbow FOV",
	CurrentValue = false,
	Callback = function(value)
		FOVRainbow = value
	end
})
VisualTab:CreateColorPicker({
	Name = "FOV Color",
	Color = FOVColor,
	Callback = function(value)
		FOVColor = value
		if not FOVRainbow then
			UIStroke.Color = value
		end
	end
})
VisualTab:CreateToggle({
	Name = "Slow Motion PvP",
	CurrentValue = false,
	Callback = function(enabled)
		if enabled then
			local tween = TweenService:Create(game, TweenInfo.new(0.5), {ClockTime = 0.25})
			tween:Play()
			RunService:Set3dRenderingEnabled(true)
			workspace.Gravity = 100
		else
			local tween = TweenService:Create(game, TweenInfo.new(0.5), {ClockTime = 1})
			tween:Play()
			workspace.Gravity = 196.2
		end
	end
})

-- Soft Sky PvP Mode
local Lighting = game:GetService("Lighting")
local StarsGui
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient
local OriginalBrightness = Lighting.Brightness
local OriginalClockTime = Lighting.ClockTime
local OriginalSky = Lighting:FindFirstChildOfClass("Sky")

VisualTab:CreateToggle({
	Name = "Soft PvP Sky Mode",
	CurrentValue = false,
	Callback = function(value)
		if value then
			Lighting.Ambient = Color3.fromRGB(120, 130, 140)
			Lighting.OutdoorAmbient = Color3.fromRGB(90, 100, 110)
			Lighting.Brightness = 1.5
			Lighting.ClockTime = 18.5
			
			if OriginalSky then OriginalSky.Enabled = false end
			local PvPSky = Instance.new("Sky")
			PvPSky.Name = "PvPSky"
			PvPSky.SkyboxBk = "rbxassetid://1022207611"
			PvPSky.SkyboxDn = "rbxassetid://1022207683"
			PvPSky.SkyboxFt = "rbxassetid://1022207746"
			PvPSky.SkyboxLf = "rbxassetid://1022207814"
			PvPSky.SkyboxRt = "rbxassetid://1022207886"
			PvPSky.SkyboxUp = "rbxassetid://1022207958"
			PvPSky.Parent = Lighting
			
			StarsGui = Instance.new("ScreenGui", game.CoreGui)
			StarsGui.Name = "StarsGui"
			StarsGui.IgnoreGuiInset = true
			StarsGui.ResetOnSpawn = false
			
			for i = 1, 50 do
				local star = Instance.new("Frame")
				star.Size = UDim2.new(0, 2, 0, 2)
				star.Position = UDim2.new(math.random(), 0, math.random(), 0)
				star.BackgroundColor3 = Color3.new(1, 1, 1)
				star.BackgroundTransparency = 0.7
				star.BorderSizePixel = 0
				star.AnchorPoint = Vector2.new(0.5, 0.5)
				star.Parent = StarsGui

				coroutine.wrap(function()
					while StarsGui and StarsGui.Parent do
						star.BackgroundTransparency = 0.5 + math.sin(tick() * math.random(1,3)) * 0.4
						wait(0.1)
					end
				end)()
			end
		else
			Lighting.Ambient = OriginalAmbient
			Lighting.OutdoorAmbient = OriginalOutdoorAmbient
			Lighting.Brightness = OriginalBrightness
			Lighting.ClockTime = OriginalClockTime

			local PvPSky = Lighting:FindFirstChild("PvPSky")
			if PvPSky then PvPSky:Destroy() end
			if OriginalSky then OriginalSky.Enabled = true end

			if StarsGui then
				StarsGui:Destroy()
				StarsGui = nil
			end
		end
	end
})

-- Optimization Tab
local OptimTab = Window:CreateTab("Optimization", 4483362458)

OptimTab:CreateButton({
	Name = "Optimize FPS (improve performance)",
	Callback = function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
			elseif v:IsA("Decal") then
				v.Transparency = 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
				v.Enabled = false
			end
		end
	end
})

local FPSUnlockerEnabled = false

OptimTab:CreateToggle({
	Name = "FPS Unlocker (no 60 FPS cap)",
	CurrentValue = false,
	Callback = function(value)
		FPSUnlockerEnabled = value
		if value then
			setfpscap(1000)
		else
			setfpscap(60)
		end
	end
})

OptimTab:CreateButton({
	Name = "Optimize Ping (reduce network usage)",
	Callback = function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				obj.Enabled = false
			elseif obj:IsA("Explosion") then
				obj.Visible = false
			end
		end

		settings().Physics.AllowSleep = true
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Default

		game:GetService("Lighting").GlobalShadows = false
		game:GetService("Lighting").FogEnd = 100000

		workspace.Terrain.WaterWaveSize = 0
		workspace.Terrain.WaterWaveSpeed = 0
		workspace.Terrain.WaterReflectance = 0
		workspace.Terrain.WaterTransparency = 1

		for _, gui in ipairs(game.CoreGui:GetDescendants()) do
			if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
				gui.ImageTransparency = 0.2
			end
		end

		Rayfield:Notify({
			Title = "Ping Optimized",
			Content = "Network usage reduction applied. May help in PvP.",
			Duration = 5
		})
	end
})

OptimTab:CreateButton({
	Name = "PvP Skybox (bright style)",
	Callback = function()
		local Lighting = game:GetService("Lighting")
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("Sky") then v:Destroy() end
		end

		local sky = Instance.new("Sky", Lighting)
		sky.SkyboxBk = "rbxassetid://159454299"
		sky.SkyboxDn = "rbxassetid://159454296"
		sky.SkyboxFt = "rbxassetid://159454293"
		sky.SkyboxLf = "rbxassetid://159454286"
		sky.SkyboxRt = "rbxassetid://159454300"
		sky.SkyboxUp = "rbxassetid://159454288"
		sky.StarCount = 3000
		sky.SunAngularSize = 0
		sky.MoonAngularSize = 11
		Lighting.TimeOfDay = "18:00:00"
	end
})
