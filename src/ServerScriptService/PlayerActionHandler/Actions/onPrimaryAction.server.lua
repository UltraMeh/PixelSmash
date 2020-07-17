local FixerPrimaryAction = game.ServerScriptService.PlayerActionHandler.FixerPrimaryAction
local SmasherPrimaryAction = game.ServerScriptService.PlayerActionHandler.SmasherPrimaryAction

-- Settings
local GameSettings = game.ReplicatedStorage.GameSettings

local function findWaypointsInRadius(locationCFrame, radius)

    local function getRadiusOfModel(model)
        if not model:IsA("BasePart") then return nil end
        return (model.Size.X + model.Size.Z) / 4  -- I condense this to (x+y)/4 because the original formula would be ((x+y)/2)/2
    end

    local LoadedMap = game.Workspace:FindFirstChild("LoadedMap")
    if not LoadedMap then return {} end

    -- Grab the waypoints and loop through them
    local MapWaypoints = LoadedMap:FindFirstChild("Waypoints")
    if not MapWaypoints then return {} end

    local WaypointsInRadius = {}
    for _,Waypoint in ipairs(MapWaypoints:GetChildren()) do

        local Configuration = Waypoint:FindFirstChild("Configuration") 
        if Configuration then
            local Model = Configuration:FindFirstChild("Model")
            if Model then
                if Model.Value then
                    local ModelPosition = Model.Value.CFrame.p
                    local ModelRadius = getRadiusOfModel(Model.Value)
                    
                    if (ModelPosition - locationCFrame.p).magnitude <= radius + ModelRadius then
                        table.insert(WaypointsInRadius, Waypoint)
                    end
                end
            end
        end
    end

    return WaypointsInRadius
end

FixerPrimaryAction.OnInvoke = function(player)

    local DataModel = player:FindFirstChild("PlayerData")
    if not DataModel then
        warn("DataModel not found. Can not invoke Smasher Action", player)
        return false
    end

    local PrimaryActionCooldown = DataModel:FindFirstChild("PrimaryActionCooldown")
    if not PrimaryActionCooldown then
        warn("PrimaryActionCooldown not found. Can not invoke Smasher Action", player)
        return false
    end

    if PrimaryActionCooldown.Value > 0 then
        return false
    end

    local Character = player.Character
    if not Character then return end

    -- Play the animation

    -- Find waypoints in radius
    local WaypointsInRadius = findWaypointsInRadius(Character.HumanoidRootPart.CFrame, GameSettings.FixerDefaultRadius.Value)

    -- Apply appropiate effects
    for _,Waypoint in ipairs(WaypointsInRadius) do
        local Configuration = Waypoint:FindFirstChild("Configuration")
        if Configuration then
            local Health = Configuration:FindFirstChild("Health")
            if Health then
                Health.Value = Health.Value + GameSettings.FixerFixAmount.Value
            end
        end
    end

    PrimaryActionCooldown.Value = GameSettings.FixerCooldown.Value

end

SmasherPrimaryAction.OnInvoke = function(player)
    
    local DataModel = player:FindFirstChild("PlayerData")
    if not DataModel then
        warn("DataModel not found. Can not invoke Smasher Action", player)
        return false
    end

    local PrimaryActionCooldown = DataModel:FindFirstChild("PrimaryActionCooldown")
    if not PrimaryActionCooldown then
        warn("PrimaryActionCooldown not found. Can not invoke Smasher Action", player)
        return false
    end

    if PrimaryActionCooldown.Value > 0 then
        return false
    end

    local Character = player.Character
    if not Character then return false end
    
    -- Play the animation and effects
    local SlamEffect = game.ReplicatedStorage.Effects.SlamEffect:Clone()
    SlamEffect.Radius.Value = GameSettings.SmasherDefaultRadius.Value
    SlamEffect.SlamRing.CFrame = Character.HumanoidRootPart.CFrame - Vector3.new(0,4.25,0)        -- NOTE: Adjust for player size later
    SlamEffect.Parent = game.Workspace.temp

    -- Find waypoints in radius
    local WaypointsInRadius = findWaypointsInRadius(Character.HumanoidRootPart.CFrame, GameSettings.SmasherDefaultRadius.Value)

    -- Apply appropiate effects
    for _,Waypoint in ipairs(WaypointsInRadius) do
        local Configuration = Waypoint:FindFirstChild("Configuration")
        if Configuration then
            local Health = Configuration:FindFirstChild("Health")
            if Health then
                Health.Value = Health.Value - GameSettings.SmasherDamageAmount.Value
            end
        end
    end

    PrimaryActionCooldown.Value = GameSettings.SmasherCooldown.Value

    return true
end