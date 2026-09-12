-- HeartAttackEffect.lua
-- Sistema de efeitos visuais de ataque cardíaco
local HeartAttackEffect = {}
HeartAttackEffect.__index = HeartAttackEffect

function HeartAttackEffect.new(character)
	local self = setmetatable({}, HeartAttackEffect)
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	self.duration = 4
	self.isActive = false
	return self
end

function HeartAttackEffect:createHeartGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HeartAttackGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game.Players:FindFirstChild(self.character.Name) and game.Players:FindFirstChild(self.character.Name):WaitForChild("PlayerGui")
	
	-- Container do coração
	local heartContainer = Instance.new("Frame")
	heartContainer.Name = "HeartContainer"
	heartContainer.Size = UDim2.new(0, 200, 0, 200)
	heartContainer.Position = UDim2.new(0.5, -100, 0.5, -100)
	heartContainer.BackgroundTransparency = 1
	heartContainer.Parent = screenGui
	
	-- Coração (vermelho)
	local heart = Instance.new("TextLabel")
	heart.Name = "Heart"
	heart.Text = "❤"
	heart.TextSize = 120
	heart.TextColor3 = Color3.fromRGB(255, 0, 0)
	heart.Size = UDim2.new(1, 0, 1, 0)
	heart.BackgroundTransparency = 1
	heart.Parent = heartContainer
	
	-- Linha branca em volta
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 3
	stroke.Parent = heart
	
	-- Efeito de visão embaraçada (blur)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 0
	blurEffect.Parent = game.Lighting
	
	return screenGui, heart, blurEffect, heartContainer
end

function HeartAttackEffect:play()
	if self.isActive then return end
	self.isActive = true
	
	local screenGui, heart, blurEffect, heartContainer = self:createHeartGui()
	local elapsed = 0
	local startTime = tick()
	
	-- Loop de animação
	while elapsed < self.duration and self.isActive do
		elapsed = tick() - startTime
		local progress = elapsed / self.duration
		
		-- Aumentar blur (visão embaraçada)
		blurEffect.Size = math.min(25 * progress, 25)
		
		-- Pulsação do coração (batida)
		local beatSpeed = math.sin(elapsed * 10) * 0.5 + 0.5
		heart.TextSize = 100 + (20 * beatSpeed)
		
		-- Aumentar opacidade do frame vermelho
		heartContainer.BackgroundTransparency = 0.7 - (0.3 * progress)
		heartContainer.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		
		task.wait(1/60)
	end
	
	-- Transição final: tela vermelha
	local redScreen = Instance.new("Frame")
	redScreen.Name = "RedScreen"
	redScreen.Size = UDim2.new(1, 0, 1, 0)
	redScreen.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	redScreen.BackgroundTransparency = 1
	redScreen.ZIndex = 100
	redScreen.Parent = screenGui
	
	-- Fade para vermelho
	for i = 1, 0, -0.05 do
		redScreen.BackgroundTransparency = i
		task.wait(0.05)
	end
	
	-- Manter tela vermelha por 1 segundo
	task.wait(1)
	
	-- Limpar
	screenGui:Destroy()
	blurEffect:Destroy()
	self.isActive = false
end

function HeartAttackEffect:stop()
	self.isActive = false
end

return HeartAttackEffect
