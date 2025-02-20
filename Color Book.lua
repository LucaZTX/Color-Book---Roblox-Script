----ENTER THE MAP, AFTER THAT CHANGE DE MAP NAME IN THIS CODE (LINE 8) LITERALLY WRITE THE SAME NAME WITH CAPITAL LETTERS AND EVERYTHING
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local VirtualInputManager = game:GetService("VirtualInputManager")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local mapName = "Village By Waterfall" -- MAP NAME!!!!!!!!!!!!!!!!!!!!!
local highlightColor = Color3.fromRGB(255, 0, 0) -- Rojo para resaltar partes no pintadas
local highlights = {} -- Almacena los highlights creados

-- Ángulos de visión para pintar
local angles = {
    {yaw = 0, pitch = 0}, {yaw = 90, pitch = 0}, {yaw = -90, pitch = 0}, {yaw = 180, pitch = 0},
    {yaw = 0, pitch = -90}, {yaw = 0, pitch = 90}, {yaw = 45, pitch = -45}, {yaw = -45, pitch = -45},
    {yaw = 30, pitch = 0}, {yaw = -30, pitch = 0}, {yaw = 0, pitch = -30}, {yaw = 0, pitch = 30},
    {yaw = 15, pitch = 0}, {yaw = -15, pitch = 0}, {yaw = 45, pitch = 45}, {yaw = -45, pitch = 45}
}

local function isUnpainted(part)
    return part:FindFirstChild("SelectionBox") ~= nil -- Verifica si la parte tiene SelectionBox
end

local function moveCameraToAngle(part, yaw, pitch)
    camera.CameraType = Enum.CameraType.Scriptable
    local offset = CFrame.Angles(math.rad(pitch), math.rad(yaw), 0) * Vector3.new(4, 2, 4)
    camera.CFrame = CFrame.new(part.Position + offset, part.Position)
end

local function equipPaintTool()
    if character and not character:FindFirstChildOfClass("Tool") then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
    end
end

local function clickPart(part)
    local screenPoint, onScreen = camera:WorldToViewportPoint(part.Position)
    if onScreen and isUnpainted(part) then
        VirtualInputManager:SendMouseButtonEvent(screenPoint.X, screenPoint.Y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(screenPoint.X, screenPoint.Y, 0, false, game, 0)
    end
end

local function findUnpaintedParts()
    local map = workspace:FindFirstChild(mapName)
    if not map then
        warn("⚠ No se encontró el mapa: " .. mapName)
        return {}
    end

    local partsToPaint = {}
    for _, model in ipairs(map:GetChildren()) do
        if model:IsA("Model") then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("Part") and isUnpainted(part) then
                    table.insert(partsToPaint, part)
                end
            end
        end
    end

    return partsToPaint
end

local function highlightUnpaintedParts(parts)
    for _, part in ipairs(parts) do
        local highlight = Instance.new("Highlight")
        highlight.Parent = part
        highlight.Adornee = part
        highlight.FillColor = highlightColor
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = highlightColor
        highlight.OutlineTransparency = 0
        highlights[#highlights + 1] = highlight
    end
end

task.spawn(function()
    equipPaintTool()

    for _, angle in ipairs(angles) do
        local partsToPaint = findUnpaintedParts()
        if #partsToPaint == 0 then break end

        print("🎨 Pintando desde ángulo: Yaw", angle.yaw, "Pitch", angle.pitch)

        for _, part in ipairs(partsToPaint) do
            moveCameraToAngle(part, angle.yaw, angle.pitch)
            clickPart(part)
            task.wait(0.02)
        end

        task.wait(0.2)
    end

    local remainingParts = findUnpaintedParts()
    if #remainingParts > 0 then
        print("⚠ No se pudieron pintar algunas partes. Resaltándolas...")
        highlightUnpaintedParts(remainingParts)
    else
        print("✅ ¡Todo el mapa ha sido pintado!")
    end

    camera.CameraType = Enum.CameraType.Custom
end)
