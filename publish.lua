--[[
    publish.lua, ran by remodel to publish PremiumWrapper to Roblox
--]]

-- Constants --
local ASSET_ID = "6540573990";

-- Functions --
function Main()
    local file = remodel.readPlaceFile("place.rbxlx");
    local module = file.ServerScriptService.PremiumWrapper;

    remodel.writeModelFile(module, "PremiumWrapper.rbxmx");
    remodel.writeExistingModelAsset(module, ASSET_ID);
end

-- Init --
Main();