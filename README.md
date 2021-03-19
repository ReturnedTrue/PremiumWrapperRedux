# PremiumWrapper (Redux)
PremiumWrapper is a wrapper module which makes it extremely simplistic to add benefits for premium users.

There is no documentation however, the API is marked with LuaDoc (supported by RobloxLSP) and TSDoc.
# Examples
Lua:
```lua
local PremiumWrapper = require(path.to.pw);
local wrapper = PremiumWrapper.new(); -- Creates connections, returns the wrapper

wrapper:BindOnPremiumJoin(function(player)
    print(wrapper:PlayerIsPremium(player)); -- Always true

    -- Etc
end)
```

TypeScript:
```ts
import PremiumWrapper from '@rbxts/premium-wrapper';
let wrapper = new PremiumWrapper(); // Creates connections, returns the wrapper

wrapper.BindOnPremiumJoin((player) => {
    print(wrapper.PlayerIsPremium(player)) // Always true

    // Etc
})
```

# Installation
Roblox model:
- https://www.roblox.com/library/6540573990/PremiumWrapper-Redux

GitHub releases:
- https://github.com/ReturnedTrue/PremiumWrapperRedux/releases/latest

npm (for Roblox-ts users):
```
npm i @rbxts/premium-wrapper
```