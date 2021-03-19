--[[

	PremiumWrapper Redux
	> Written by ReturnedTrue
	> Licensed under MIT

--]]

-- Class --
local Connection = {};
Connection.__index = Connection;
Connection.__type = "Connection";

-- Class constructor --
function Connection.new(func)
    local self: Connection = setmetatable({}, Connection);

    self._func = func;
    self.isConnected = true;

    return self;
end

-- Class methods --
--- Disconnects the connection, prevents it from running anymore
function Connection:Disconnect()
    if (self.isConnected) then
        self._func();
    end
end

-- Class metamethods --
function Connection:__tostring()
    return self.__type;
end

-- Init --
return Connection;