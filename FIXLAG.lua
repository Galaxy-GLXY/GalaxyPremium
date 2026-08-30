-- [GALAXY FFLAG - SMOOTH PLASTIC & NO TEXTURE / LOW POLY]

-- 1. CẤU HÌNH FFLAG ÉP ENGINE XÓA HOA VĂN / CHI TIẾT MẪU (TEXTURE MIPS)
pcall(function()
    if setfflag then
        setfflag("FIntDebugTextureManagerSkipMips", "8") -- Bỏ sạch chất liệu hoa văn, ép bề mặt phẳng lì
        setfflag("FFlagDebugDisableMaterials", "True")      -- Tắt toàn bộ chất liệu chi tiết gốc
        setfflag("FIntRenderMeshLODQuality", "0")          -- Ép hình khối về dạng phẳng đơn giản nhất
        setfflag("FFlagDebugDisableShadows", "True")       -- Tắt bóng đổ
        setfflag("FFlagEnableGlobalShadows", "False")
    end
end)

-- 2. BIẾN TOÀN BỘ VẬT THỂ THÀNH KHỐI PHẲNG (SMOOTH PLASTIC) & XÓA CHI TIẾT
local function MakeObjectSmooth(obj)
    pcall(function()
        -- Nếu là khối (Part/MeshPart), ép về chất liệu SmoothPlastic (Nhựa trơn phẳng lì)
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0 -- Bỏ độ phản chiếu gây lóa
        end
        
        -- Xóa bỏ các tấm hình dán/hoa văn bề mặt (Decal, Texture, SurfaceAppearance)
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
            obj:Destroy()
        end
        
        -- Nếu là cỏ tự nhiên của game, tắt chiều cao để phẳng xuống mặt đất
        if obj:IsA("Terrain") then
            obj.WaterWaveSize = 0
            obj.WaterWaveSpeed = 0
            obj.WaterReflectance = 0
            obj.WaterTransparency = 1
        end
    end)
end

-- Quét toàn bộ bản đồ hiện tại
for _, item in pairs(workspace:GetDescendants()) do
    MakeObjectSmooth(item)
end

-- Quét tự động cho các khối/vật thể mới sinh ra trong lúc chơi
workspace.DescendantAdded:Connect(function(newItem)
    task.wait(0.1)
    MakeObjectSmooth(newItem)
end)

-- 3. GIẢM BỚT ĐỘ SÁNG CHÓI CỦA ĐÈN / CHIẾU SÁNG
pcall(function()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    
    -- Xóa các hiệu ứng lóa sáng, sương mù
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
end)

-- Thông báo hoàn thành
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "GALAXY FFlag",
        Text = "Đã chuyển toàn bộ khối thành phẳng trơn (Smooth Plastic)!",
        Duration = 3
    })
end)
