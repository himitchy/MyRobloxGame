# MyRobloxGame

Roblox game project using Rojo for file sync.

## Folder structure

* src/ServerScriptService/ → server Scripts
* src/ReplicatedStorage/ → shared ModuleScripts
* src/StarterPlayer/StarterPlayerScripts/ → client LocalScripts
* src/StarterGui/ → UI LocalScripts

## Coding rules

* All scripts must be valid Luau (not Lua 5.1)
* Use task.wait() not wait()
* Use game:GetService() for all services
* Use --!strict at the top of every script
* RemoteEvents go in ReplicatedStorage/Remotes/



\## Rojo model file format

Non-script instances like RemoteEvents use .model.json files.

The correct format is:

{

&#x20; "className": "RemoteEvent"

}

Never add extra fields like "name" or "properties" unless 

specifically needed. className must be camelCase exactly 

as Roblox names it.

