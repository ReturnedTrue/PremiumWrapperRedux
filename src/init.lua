--[[

	PremiumWrapper Redux
	> Written by ReturnedTrue
	> Licensed under MIT

--]]

-- Dependencies --
local PhysicsService = game:GetService("PhysicsService");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");

-- Modules --
local Connection = require(script.Connection);
local t = require(script.lib.t);

-- Constants --
local PLAYER_COLLISION_GROUP = "%s-collision-group";
local DOOR_COLLISION_GROUP = "%s-door-collision-group";
local PLAYER_REQUIRED = "the player is required on the server!";
local MEMBERSHIP_TYPE = Enum.MembershipType.Premium;

-- Variables --
local IsOptionalPlayer = t.optional(t.instanceOf("Player"));
local IsTool = t.instanceOf("Tool");
local IsDoor = t.union(
	t.instanceIsA("Model"), 
	t.instanceIsA("BasePart")
);

-- Class --
local PremiumWrapper = {};
PremiumWrapper.__index = PremiumWrapper;
PremiumWrapper.__type = "PremiumWrapper";

-- Class constructor --
--- Constructs the PremiumWrapper class, connects callbacks
function PremiumWrapper.new()
	local self: PremiumWrapper = setmetatable({}, PremiumWrapper);

	self._isClient = RunService:IsClient();
	self._functionsOnJoin = {};
	self._functionsOnChange = {};

	local function RunEachFunction(t: table, ...)
		for func in pairs(t) do
			func(...);
		end
	end

	local function PlayerAdded(player: Player)
		if (self:PlayerIsPremium(player)) then
			RunEachFunction(self._functionsOnJoin, player);
		end
	end

	local function PlayerChanged(player: Player)
		RunEachFunction(self._functionsOnChange, player, self:PlayerIsPremium(player));
	end

	self._addedConnection = Players.PlayerAdded(PlayerAdded);
	self._changedConnection = Players.PlayerMembershipChanged(PlayerChanged);

	return self;
end

-- Class methods --
--- Returns whether the player given is a premium user
function PremiumWrapper:PlayerIsPremium(player: Player)
	assert(IsOptionalPlayer(player));

	if (not player) then
		if (self._isClient) then
			return (Players.LocalPlayer.MembershipType == MEMBERSHIP_TYPE);
		else
			error(PLAYER_REQUIRED);
		end
	else
		return (player.MembershipType == MEMBERSHIP_TYPE);
	end
end

--- Binds a function to when a premium user joins, or is already in the server
function PremiumWrapper:BindOnPremiumJoin(func)
	assert(t.callback(func));

	for _, player in ipairs(Players:GetPlayers()) do
		if (self:PlayerIsPremium(player)) then
			func(player);
		end
	end

	self._functionsOnJoin[func] = true;

	return Connection.new(function()
		self._functionsOnJoin[func] = nil;
	end)
end

--- Binds a function to when a membership of a player changes with if they're a premium user
function PremiumWrapper:BindOnMembershipChange(func)
	assert(t.callback(func));

	self._functionsOnChange[func] = true;

	return Connection.new(function()
		self._functionsOnChange = nil;
	end)
end

-- Binds a tool to give to only premium users, revoked if they lose premium
function PremiumWrapper:BindExclusiveTool(tool: Tool)
	assert(IsTool(tool));

	local function GiveTool(player: Player)
		local clone1 = tool:Clone();
		clone1.Parent = player:WaitForChild("Backpack");

		local clone2 = tool:Clone();
		clone2.Parent = player:WaitForChild("StarterGear");
	end

	local function DestroyIfExistentIn(place: string, player: Player)
		local parent = player.FindFirstChild(place);
		local ownedTool = parent and parent.FindFirstChild(tool.Name);

		if (ownedTool) then
			ownedTool:Destroy();
		end
	end

	self:BindOnPremiumJoin(GiveTool);
	self:BindOnMembershipChange(function(player, isPremium)
		if (isPremium) then
			GiveTool(player)
		else
			DestroyIfExistentIn("Character", player);
			DestroyIfExistentIn("Backpack", player);
			DestroyIfExistentIn("StarterGear", player);
		end
	end)
end

--- Binds a door which only premium users can walk through
function PremiumWrapper:BindExclusiveDoor(door: Model | BasePart)
	assert(IsDoor(door));

	local function CreateIfNotExistent(name: string)
		for _, group in ipairs(PhysicsService:GetCollisionGroups()) do
			if (group.name == name) then
				return;
			end
		end

		PhysicsService:CreateCollisionGroup(name);
	end

	local function SetGroupForBasePart(instance: Instance, name: string)
		if (instance:IsA("BasePart")) then
			PhysicsService:SetPartCollisionGroup(instance, name);
		end
	end

	local doorGroup = DOOR_COLLISION_GROUP:format(door.Name);
	CreateIfNotExistent(doorGroup);

	if (door:IsA("Model")) then
		for _, instance in ipairs(door:GetDescendants()) do
			SetGroupForBasePart(instance, doorGroup);
		end
	else
		PhysicsService:SetPartCollisionGroup(door, doorGroup);
	end

	local function ApplyCollisions(player: Player)
		local playerGroup = PLAYER_COLLISION_GROUP:format(player.Name);
		CreateIfNotExistent(playerGroup);
		PhysicsService:CollisionGroupSetCollidable(doorGroup, playerGroup, false);

		local function CharacterLoaded(character: Model)
			for _, instance in ipairs(character:GetDescendants()) do
				SetGroupForBasePart(instance, playerGroup);
			end

			character.DescendantAdded:Connect(function(child)
				SetGroupForBasePart(child, playerGroup);
			end)
		end

		if (player.Character) then
			CharacterLoaded(player.Character);
		end

		player.CharacterAppearanceLoaded:Connect(CharacterLoaded);
	end

	self:BindOnPremiumJoin(ApplyCollisions);
	self:BindOnMembershipChange(function(player, isPremium)
		if (isPremium) then
			ApplyCollisions(player);
		else
			PhysicsService:CollisionGroupSetCollidable(
				doorGroup,
				PLAYER_COLLISION_GROUP:format(player.Name),
				true
			);
		end
	end)
end

--- Destroys the class instance and disconnects the internal connections
function PremiumWrapper:Destroy()
	local function DisconnectIfConnected(connection: RBXScriptConnection)
		if (connection and connection.Connected) then
			connection:Disconnect();
		end
	end

	DisconnectIfConnected(self._addedConnection);
	DisconnectIfConnected(self._changedConnection);

	self._functionsOnJoin = nil;
	self._functionsOnChange = nil;
end

-- Class metamethods --
function PremiumWrapper:__tostring()
	return self.__type;
end

-- Init --
return PremiumWrapper;