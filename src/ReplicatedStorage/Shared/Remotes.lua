local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:FindFirstChild("Shared") or Instance.new("Folder")
Shared.Name = "Shared"
Shared.Parent = ReplicatedStorage

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
RemotesFolder.Name = "Remotes"
RemotesFolder.Parent = ReplicatedStorage

local function ensureRemote(name)
    local remote = RemotesFolder:FindFirstChild(name)
    if remote then
        return remote
    end

    remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = RemotesFolder
    return remote
end

return {
    Shoot = ensureRemote("Shoot"),
    Hud = ensureRemote("Hud"),
    Round = ensureRemote("Round"),
    MatchState = ensureRemote("MatchState")
}
