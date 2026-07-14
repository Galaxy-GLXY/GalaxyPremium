local Lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")

local function ApplyOptimization()
    -- Thiết lập môi trường tối giản
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0.5
    Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
    Lighting.ClockTime = 0
    Lighting.ExposureCompensation = -0.5
    Lighting.FogEnd = 9e9
    
    -- Hàm tối ưu hóa vật thể
    local function Optimize(obj)
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic -- Chuyển về nhựa trơn để giảm tải GPU
            obj.CastShadow = false -- Tắt đổ bóng từng vật thể
            if obj.Name:lower():find("effect") or obj.Parent.Name:lower():find("fx") then
                obj.Transparency = 0.7
            end
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy() end -- Xóa họa tiết thừa
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Explosion") then
            obj.Enabled = false -- Tắt hiệu ứng hạt gây lag
        end
    end

    -- Chạy cho các vật thể hiện có
    for _, v in pairs(workspace:GetDescendants()) do 
        Optimize(v) 
    end
    
    -- Tự động tối ưu khi vật thể mới xuất hiện
    workspace.DescendantAdded:Connect(Optimize)
    
    print("Optimization Applied: Graphics Minimalist Mode")
end

ApplyOptimization()
