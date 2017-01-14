local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")

local Grid2 = Grid2

local UnitClass = UnitClass
local UnitGUID = UnitGUID
local getGroupRole = getGroupRole
local UnitIsEnemy = UnitIsEnemy
local UnitHasVehicleUI = UnitHasVehicleUI


function GroupInSpecTInterface(unit, default)
    -- Use in GroupInSpecT to determine a unit's detailed role

    local info = LGIST:GetCachedInfo(UnitGUID(unit))

    if info.spec_role_detailed == nil then
        -- Can't get anymore info
        return default
    else if info.spec_role_detailed == "tank" then
        return TANK
    else if info.spec_role_detailed == "healer" then
        return HEALER
    else if info.spec_role_detailed == "melee" then
        return MELEE
    else if info.spec_role_detailed == "range" then
        return RANGE
    end
end


function getDetailedRole(unit)
    -- determine a unit's detailed role. Attempts to do this using
    -- only group role and class, but falls back to GroupInSpecT if 
    -- this is insufficent

    local _, class = UnitClass(unit)

    if class == "MAGE" or class == "WARLOCK" then
        return RANGE
    else if class == "ROGUE" then
        return MELEE
    else if class == "WARRIOR" or class == "DEATHKNIGHT" or class == "DEMONHUNTER" then
        if getGroupRole(unit) == "TANK" then
            return TANK
        else
            return MELEE
        end
    else if class = "PALADIN" or class == "MONK" then
        local groupRole = getGroupRole(unit)
        if groupRole == "TANK" then
            return TANK
        else if groupRole == "HEALER" then
            return HEALER
        else
            return MELEE
        end
    else if class == "HUNTER" then
        return GroupInSpecTInterface(unit, DAMAGER)
    else if class == "PRIEST" then
        if groupRole == "HEALER" then
            return HEALER
        else
            return RANGE
        end
    else if class == "SHAMAN" then
        if getGroupRole(unit) == "HEALER" then
            return HEALER
        else
            return GroupInSpecTInterface(unit, DAMAGER)
        end
    else if class == "DRUID" then
        local groupRole = getGroupRole(unit)
        if groupRole == "TANK" then
            return TANK
        else if groupRole == "HEALER" then
            return HEALER
        else
            return GroupInSpecTInterface(unit, DAMAGER)
        end
    else
        return UNKNOWN
    end
end


local Lib = Grid2.statusPrototype:new("detailedrolecolor")

Lib.IsActive = Grid2.statusLibrary.IsActive


function Lib:UpdateUnit(_, unit)
    if unit then 
        self:UpdateIndicators(unit) 
    end	
end


function Lib:OnEnable()
    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "UpdateUnit")
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnit")
    self:RegisterEvent("UNIT_FLAGS", "UpdateUnit")
    self:RegisterEvent("UNIT_FACTION", "UpdateUnit")
end


function Lib:OnDisable()
    self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
    self:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
    self:UnregisterEvent("UNIT_FLAGS")
    self:UnregisterEvent("UNIT_FACTION")
end


function Lib:GetColor(unit)
    local c = nil
    local p = self.dbx

    if p.colorHostile and UnitIsCharmed(unit) and UnitIsEnemy("player", unit) then
        c = p.colors.HOSTILE
    else
        c = p.colors[getDetailedRole(unit)] or p.colors.UNKNOWN_UNIT
    end

    return c.r, c.g, c.b, c.a
end


Grid2.setupFunc["detailedrolecolor"] = function(baseKey, dbx)
    Grid2:RegisterStatus(Lib, {"color"}, baseKey, dbx)
    return Lib
end


Grid2:DbSetStatusDefaultValue( "detailedrolecolor", { type = "detailedrolecolor", colorHostile = true, colors= {
    HOSTILE = { r = 1, g = 0.1, b = 0.1, a = 1 },
    UNKNOWN = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
    MELEE = { r = 0.94, g = 0.75, b = 0.28, a = 1 },
    RANGE = { r = 0.5, g = 0.25, b = 0.69, a = 1 },
    DAMAGER = { r = 0.5, g = 0.25, b = 0.69, a = 1 },
    TANK = { r = 0.92, g = 0.67, b = 0.85, a = 1 },
    HEALER = { r = 0.1, g = 0.3, b = 0.9, a = 1 }, }
})
