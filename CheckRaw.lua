local parent = gethui and gethui() or game:GetService("CoreGui")

-- Xóa các bảng cũ nếu đã chạy trước đó
if parent:FindFirstChild("RawScriptCheckerInput") then parent.RawScriptCheckerInput:Destroy() end
if parent:FindFirstChild("RawScriptViewer") then parent.RawScriptViewer:Destroy() end

-- BẢNG BƯỚC 1: KHUNG NHẬP DÁN LOADSTRING
local inputGui = Instance.new("ScreenGui")
inputGui.Name = "RawScriptCheckerInput"
inputGui.ResetOnSpawn = false
inputGui.IgnoreGuiInset = true
inputGui.Parent = parent

local inputFrame = Instance.new("Frame", inputGui)
inputFrame.Size = UDim2.new(0, 450, 0, 260)
inputFrame.Position = UDim2.new(0.5, -225, 0.5, -130)
inputFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
inputFrame.BorderSizePixel = 0
inputFrame.Active = true
inputFrame.Draggable = true

local inputCorner = Instance.new("UICorner", inputFrame)
inputCorner.CornerRadius = UDim.new(0, 8)

local inputTitle = Instance.new("TextLabel", inputFrame)
inputTitle.Size = UDim2.new(1, -50, 0, 35)
inputTitle.Position = UDim2.new(0, 12, 0, 0)
inputTitle.BackgroundTransparency = 1
inputTitle.Text = "NHẬP LOADSTRING ĐỂ CHECK RAW"
inputTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
inputTitle.Font = Enum.Font.Code
inputTitle.TextSize = 13
inputTitle.TextXAlignment = Enum.TextXAlignment.Left

local inputClose = Instance.new("TextButton", inputFrame)
inputClose.Size = UDim2.new(0, 35, 0, 35)
inputClose.Position = UDim2.new(1, -38, 0, 0)
inputClose.BackgroundTransparency = 1
inputClose.Text = "X"
inputClose.TextColor3 = Color3.fromRGB(255, 90, 90)
inputClose.Font = Enum.Font.Code
inputClose.TextSize = 18
inputClose.MouseButton1Click:Connect(function() inputGui:Destroy() end)

local inputBox = Instance.new("TextBox", inputFrame)
inputBox.Size = UDim2.new(1, -24, 0, 120)
inputBox.Position = UDim2.new(0, 12, 0, 40)
inputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
inputBox.TextColor3 = Color3.fromRGB(230, 230, 230)
inputBox.PlaceholderText = 'Dán loadstring(game:HttpGet("https://..."))() vào đây...'
inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
inputBox.Font = Enum.Font.Code
inputBox.TextSize = 13
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.TextYAlignment = Enum.TextYAlignment.Top
inputBox.ClearTextOnFocus = false
inputBox.MultiLine = true
inputBox.TextWrapped = true
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

local checkBtn = Instance.new("TextButton", inputFrame)
checkBtn.Size = UDim2.new(1, -24, 0, 40)
checkBtn.Position = UDim2.new(0, 12, 0, 175)
checkBtn.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
checkBtn.Text = "CHECK RAW"
checkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
checkBtn.Font = Enum.Font.Code
checkBtn.TextSize = 14
Instance.new("UICorner", checkBtn).CornerRadius = UDim.new(0, 6)

-- XỬ LÝ KHI BẤM NÚT CHECK
checkBtn.MouseButton1Click:Connect(function()
	local input = inputBox.Text
	-- Tách link nằm trong " " hoặc ' ' hoặc lấy nguyên đường dẫn HTTP
	local extractedUrl = input:match('"([^"]+)"') or input:match("'([^']+)'") or input:match("https?://%S+")
	
	if not extractedUrl then
		checkBtn.Text = "KHÔNG TÌM THẤY LINK HỢP LỆ!"
		checkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		task.wait(1.5)
		checkBtn.Text = "CHECK RAW"
		checkBtn.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
		return
	end

	-- Xóa bảng nhập
	inputGui:Destroy()

	-- BẮT ĐẦU CHẠY ĐÚNG ĐOẠN MA CỦA BẠN VỚI LINK VỪA LẤY ĐƯỢC
	local url = extractedUrl

	-- Chỉ tải source, KHÔNG loadstring / chạy source
	local success, raw = pcall(function()
		return game:HttpGet(url)
	end)

	if not success then
		raw = "Không thể tải raw source:\n" .. tostring(raw)
	end

	-- Xóa bảng cũ nếu đã chạy trước đó
	local oldGui = parent:FindFirstChild("RawScriptViewer")
	if oldGui then
		oldGui:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "RawScriptViewer"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = parent

	local frame = Instance.new("Frame")
	frame.Parent = gui
	frame.Size = UDim2.new(0.8, 0, 0.72, 0)
	frame.Position = UDim2.new(0.1, 0, 0.14, 0)
	frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Parent = frame
	title.Size = UDim2.new(1, -120, 0, 38)
	title.Position = UDim2.new(0, 12, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "RAW SCRIPT EDITOR  "
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.Code
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left

	-- Nút Bật/Tắt Tự động xuống dòng (TextWrapped)
	local wrapBtn = Instance.new("TextButton")
	wrapBtn.Parent = frame
	wrapBtn.Size = UDim2.new(0, 60, 0, 26)
	wrapBtn.Position = UDim2.new(1, -105, 0, 6)
	wrapBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	wrapBtn.Text = "WRAP"
	wrapBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	wrapBtn.Font = Enum.Font.Code
	wrapBtn.TextSize = 12

	local wrapCorner = Instance.new("UICorner")
	wrapCorner.CornerRadius = UDim.new(0, 4)
	wrapCorner.Parent = wrapBtn

	local close = Instance.new("TextButton")
	close.Parent = frame
	close.Size = UDim2.new(0, 38, 0, 38)
	close.Position = UDim2.new(1, -42, 0, 0)
	close.BackgroundTransparency = 1
	close.Text = "X"
	close.TextColor3 = Color3.fromRGB(255, 90, 90)
	close.Font = Enum.Font.Code
	close.TextSize = 20
	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	local scrolling = Instance.new("ScrollingFrame")
	scrolling.Parent = frame
	scrolling.Size = UDim2.new(1, -20, 1, -55)
	scrolling.Position = UDim2.new(0, 10, 0, 45)
	scrolling.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	scrolling.BorderSizePixel = 0
	scrolling.ScrollBarThickness = 8
	scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrolling.CanvasSize = UDim2.new()

	local source = Instance.new("TextBox")
	source.Parent = scrolling
	source.Size = UDim2.new(1, -12, 0, 0)
	source.Position = UDim2.new(0, 6, 0, 6)
	source.AutomaticSize = Enum.AutomaticSize.Y
	source.BackgroundTransparency = 1
	source.ClearTextOnFocus = false
	source.MultiLine = true
	source.TextEditable = true -- Đã cho phép gõ / xóa / sửa chữ trực tiếp
	source.Text = raw
	source.TextColor3 = Color3.fromRGB(230, 230, 230)
	source.Font = Enum.Font.Code
	source.TextSize = 14
	source.TextXAlignment = Enum.TextXAlignment.Left
	source.TextYAlignment = Enum.TextYAlignment.Top
	source.TextWrapped = false

	-- Sự kiện nhấn nút WRAP để đổi chế độ ngắt dòng
	local isWrapped = false
	wrapBtn.MouseButton1Click:Connect(function()
		isWrapped = not isWrapped
		source.TextWrapped = isWrapped
		wrapBtn.TextColor3 = isWrapped and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
	end)
end)
