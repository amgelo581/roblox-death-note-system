-- DeathNoteUI.lua
-- Menu flutuante com temática Death Note
local DeathNoteUI = {}
DeathNoteUI.__index = DeathNoteUI

function DeathNoteUI.new(player)
	local self = setmetatable({}, DeathNoteUI)
	self.player = player
	self.playerGui = player:WaitForChild("PlayerGui")
	self.isOpen = false
	self.names = {}
	self.maxLines = 10
	return self
end

function DeathNoteUI:createUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DeathNoteMenu"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = self.playerGui
	
	-- Container principal (Death Note Notebook)
	local noteContainer = Instance.new("Frame")
	noteContainer.Name = "NoteContainer"
	noteContainer.Size = UDim2.new(0, 500, 0, 600)
	noteContainer.Position = UDim2.new(0.5, -250, 0.5, -300)
	noteContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	noteContainer.BorderColor3 = Color3.fromRGB(200, 0, 0)
	noteContainer.BorderSizePixel = 3
	noteContainer.Visible = false
	noteContainer.Parent = screenGui
	
	-- Efeito de sombra
	local shadow = Instance.new("UICorner")
	shadow.CornerRadius = UDim.new(0, 10)
	shadow.Parent = noteContainer
	
	-- Header (Abas do Death Note)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	header.BorderSizePixel = 0
	header.Parent = noteContainer
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 10)
	headerCorner.Parent = header
	
	-- Título
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = "DEATH NOTE"
	title.TextSize = 24
	title.TextColor3 = Color3.fromRGB(200, 0, 0)
	title.Font = Enum.Font.GothamBold
	title.Size = UDim2.new(1, -20, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Parent = header
	
	-- ScrollingFrame para os textboxes
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.Size = UDim2.new(1, -20, 1, -80)
	scrollFrame.Position = UDim2.new(0, 10, 0, 70)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.maxLines * 50)
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.Parent = noteContainer
	
	-- UIListLayout para organizar textboxes
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollFrame
	
	-- Criar textboxes
	for i = 1, self.maxLines do
		local textboxContainer = Instance.new("Frame")
		textboxContainer.Name = "Line_" .. i
		textboxContainer.Size = UDim2.new(1, -15, 0, 40)
		textboxContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		textboxContainer.BorderColor3 = Color3.fromRGB(100, 100, 120)
		textboxContainer.BorderSizePixel = 1
		textboxContainer.LayoutOrder = i
		textboxContainer.Parent = scrollFrame
		
		local textboxCorner = Instance.new("UICorner")
		textboxCorner.CornerRadius = UDim.new(0, 5)
		textboxCorner.Parent = textboxContainer
		
		-- Número da linha
		local lineNumber = Instance.new("TextLabel")
		lineNumber.Name = "LineNumber"
		lineNumber.Text = tostring(i) .. "."
		lineNumber.TextSize = 14
		lineNumber.TextColor3 = Color3.fromRGB(150, 150, 150)
		lineNumber.Font = Enum.Font.Gotham
		lineNumber.Size = UDim2.new(0, 30, 1, 0)
		lineNumber.BackgroundTransparency = 1
		lineNumber.Parent = textboxContainer
		
		-- TextBox para nome
		local textBox = Instance.new("TextBox")
		textBox.Name = "NameInput"
		textBox.PlaceholderText = "Escreva um nome..."
		textBox.TextSize = 14
		textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
		textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
		textBox.Font = Enum.Font.Gotham
		textBox.Size = UDim2.new(1, -40, 1, 0)
		textBox.Position = UDim2.new(0, 35, 0, 0)
		textBox.BackgroundTransparency = 1
		textBox.BorderSizePixel = 0
		textBox.Parent = textboxContainer
		
		-- Armazenar textbox
		table.insert(self.names, textBox)
		
		-- Conectar evento de FocusLost (Enter)
		textBox.FocusLost:Connect(function(enterPressed)
			if enterPressed and textBox.Text ~= "" then
				self:onNameWritten(textBox.Text)
				textBox.Text = ""
			end
		end)
	end
	
	-- Botão fechar
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Text = "X"
	closeBtn.TextSize = 20
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -45, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = noteContainer
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 5)
	closeBtnCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		self:close()
	end)
	
	-- Botão flutuante para abrir (bolinha vermelha)
	local floatingBtn = Instance.new("TextButton")
	floatingBtn.Name = "FloatingBtn"
	floatingBtn.Text = "📓"
	floatingBtn.TextSize = 30
	floatingBtn.Size = UDim2.new(0, 60, 0, 60)
	floatingBtn.Position = UDim2.new(1, -80, 1, -80)
	floatingBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	floatingBtn.BorderSizePixel = 0
	floatingBtn.Parent = screenGui
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0.5, 0)
	btnCorner.Parent = floatingBtn
	
	floatingBtn.MouseButton1Click:Connect(function()
		self:toggle()
	end)
	
	return screenGui, noteContainer, floatingBtn
end

function DeathNoteUI:onNameWritten(name)
	-- Emitir sinal para o DeathHandler processar
	local event = Instance.new("RemoteEvent")
	event.Name = "NameWritten_" .. tostring(tick())
	
	-- Dispatch para matar o personagem
	game:GetService("ReplicatedStorage"):FindFirstChild("DeathNoteEvent") or Instance.new("RemoteEvent")
	if not game:GetService("ReplicatedStorage"):FindFirstChild("DeathNoteEvent") then
		local evt = Instance.new("RemoteEvent")
		evt.Name = "DeathNoteEvent"
		evt.Parent = game:GetService("ReplicatedStorage")
	end
	
	game:GetService("ReplicatedStorage"):FindFirstChild("DeathNoteEvent"):FireServer(name)
end

function DeathNoteUI:toggle()
	if self.isOpen then
		self:close()
	else
		self:open()
	end
end

function DeathNoteUI:open()
	if not self.screenGui then
		self.screenGui, self.noteContainer, self.floatingBtn = self:createUI()
	end
	self.noteContainer.Visible = true
	self.isOpen = true
	self.names[1]:CaptureFocus()
end

function DeathNoteUI:close()
	if self.noteContainer then
		self.noteContainer.Visible = false
	end
	self.isOpen = false
end

return DeathNoteUI
