MG_TDM_WORDS_FILTERING = MG_TDM_WORDS_FILTERING or {}
MG_TDM_WORDS_BLACKLIST = MG_TDM_WORDS_BLACKLIST or {}
MG_TDM_WORDS_MUTED_PLAYERS = MG_TDM_MUTED_PLAYERS or {}

-- Networking
util.AddNetworkString("MG_WORDS_MENU")

-- The function net.Receive registers a receive handler for the network packet named "MG_WORDS_MENU".
net.Receive("MG_WORDS_MENU", function() 
    -- Read the player object from the network packet.
    local ply = net.ReadEntity()
    -- Read the type from the network packet.
    local type = net.ReadString()
    -- Check has player Permission
    if not (ply:IsSuperAdmin()) then return end

    -- Check if the type is "add" to add a word to the blacklist.
    if (type == "add") then 
        -- Check if the player object is valid.
        if not IsValid(ply) then return end
        -- Read the word from the network packet.
        local word = net.ReadString()
        -- Add the word to the blacklist by calling a function "AddWordToBlacklist".
        MG_TDM_WORDS_FILTERING.AddWordToBlacklist(word)
        
        -- Send an update message to the client.
        net.Start("MG_WORDS_MENU")
          net.WriteString("refresh")
          net.WriteTable(MG_TDM_WORDS_BLACKLIST)
        net.Send(ply)
    end
    
    -- Check if the type is "remove" to remove a word from the blacklist.
    if (type == "remove") then 
        -- Check if the player object is valid.
        if not IsValid(ply) then return end
        -- Read the word from the network packet.
        local word = net.ReadString()
        -- Remove the word from the blacklist by calling a function "RemoveWordFromBlacklist".
        MG_TDM_WORDS_FILTERING.RemoveWordFromBlacklist(word)
        
        -- Send an update message to the client.
        net.Start("MG_WORDS_MENU")
          net.WriteString("refresh")
          net.WriteTable(MG_TDM_WORDS_BLACKLIST)
        net.Send(ply)
    end
end)

-- Function to save a table to a file
function MG_TDM_WORDS_FILTERING.SaveWords()
    local jsonData = util.TableToJSON(MG_TDM_WORDS_BLACKLIST, true)
    file.Write("blacklist_words.txt", jsonData)
end

-- Function to load a table from a file
function MG_TDM_WORDS_FILTERING.LoadWords()
    if file.Exists("blacklist_words.txt", "DATA") then
        local jsonData = file.Read("blacklist_words.txt", "DATA")
        MG_TDM_WORDS_BLACKLIST = util.JSONToTable(jsonData)
        if MG_TDM_WORDS_BLACKLIST then
            print("Data loaded from " .. "blacklist_words.txt")
            return MG_TDM_WORDS_BLACKLIST
        else
            print("Failed to parse JSON data.")
        end
    else
        print("File does not exist.")
    end
    return nil
end

-- Function to add a word to the blacklist
function MG_TDM_WORDS_FILTERING.AddWordToBlacklist(word)
    -- Check if the word is already in the table
    if (MG_TDM_WORDS_FILTERING.IsWordInBlacklist(word)) then return end
    -- Add the word to the blacklist
    table.insert(MG_TDM_WORDS_BLACKLIST, word)
    MG_TDM_WORDS_FILTERING.SaveWords()
    MG_TDM_WORDS_FILTERING.LoadWords()
end

-- Function to remove a word from the blacklist
function MG_TDM_WORDS_FILTERING.RemoveWordFromBlacklist(word)
    for i, v in ipairs(MG_TDM_WORDS_BLACKLIST) do
        if v == word then
            table.remove(MG_TDM_WORDS_BLACKLIST, i)
            MG_TDM_WORDS_FILTERING.SaveWords()
            MG_TDM_WORDS_FILTERING.LoadWords()
            return
        end
    end
end

-- Function to check if a word is in the blacklist
function MG_TDM_WORDS_FILTERING.IsWordInBlacklist(word)
    for _, v in ipairs(MG_TDM_WORDS_BLACKLIST) do
        if v == word then
            return true
        end
    end
    return false
end

-- Function to add a steamid to the mutelist
function MG_TDM_WORDS_FILTERING.AddSteamIDToMute(steamID, intTime)
    -- Check if the steamid is already in the table
    if (MG_TDM_WORDS_FILTERING.IsSteamIDMuted(steamID)) then return end
    -- Add the steamid to the blacklist
    table.insert(MG_TDM_WORDS_MUTED_PLAYERS, 
    {
        steamID = steamID, 
        waitingTime = CurTime() + intTime
    })
end

-- Function to remove a steamid from muted list
function MG_TDM_WORDS_FILTERING.RemoveSteamIDFromMuted(steamID)
    if not (MG_TDM_WORDS_FILTERING.IsSteamIDMuted(steamID)) then return end
    for i, v in ipairs(MG_TDM_WORDS_MUTED_PLAYERS) do
        if v.steamID == steamID then
            table.remove(MG_TDM_WORDS_MUTED_PLAYERS, i)
            return
        end
    end
end

-- Function to check if a steamID muted
function MG_TDM_WORDS_FILTERING.IsSteamIDMuted(steamID)
    for _, v in ipairs(MG_TDM_WORDS_MUTED_PLAYERS) do
        if v.steamID == steamID then
            return true
        end
    end
    return false
end

-- Function check if steamid waiting time over
function MG_TDM_WORDS_FILTERING.checkSteamIDMuted(ply)
    if not IsValid(ply) then return end
    if not (MG_TDM_WORDS_FILTERING.IsSteamIDMuted(ply:SteamID())) then return end
    for _, v in ipairs(MG_TDM_WORDS_MUTED_PLAYERS) do
        if v.steamID == ply:SteamID() then
            if v.waitingTime < CurTime() then
                MG_TDM_WORDS_FILTERING.RemoveSteamIDFromMuted(ply:SteamID())
            else 
                local total_seconds = v.waitingTime - CurTime()
                local minutes = math.floor(total_seconds / 60)
                local seconds = total_seconds % 60
                DarkRP.notify(ply, 3, 4, "Du musst noch " .. string.format("%02d:%02d", minutes, seconds) .. " warten!") 
            end
        end
    end
end

-- Function to check if a message contains any filtered words
function MG_TDM_WORDS_FILTERING.containsFilteredWord(message)
    for _, word in ipairs(MG_TDM_WORDS_BLACKLIST) do
        if string.find(string.lower(message), string.lower(word)) then
            return true
        end
    end
    return false
end

-- get all arguments from text
function MG_TDM_WORDS_FILTERING.extractArguments(input)
    local args = {}
    for word in string.gmatch(input, "%S+") do
        table.insert(args, word)
    end
    return args
end

-- Hooks
-- Initialize hook
hook.Add("Initialize", "LoadDataOnInit", function()
    -- Load the data at initialization
    MG_TDM_WORDS_FILTERING.LoadWords()
end)

-- Hook into the PlayerSay event to filter chat messages
hook.Add("PlayerSay", "MG_TDM:WordFilter", function(ply, text)
    if MG_TDM_WORDS_FILTERING.containsFilteredWord(text) then

        if not (IsValid(ply)) then return end
        if (MG_TDM_WORDS_FILTERING.IsSteamIDMuted(ply:SteamID())) then return end

        ply:ChatPrint("Du kannst sowas doch nicht reinschreiben, dafür muss ich dich jetzt bestrafen!")
        DarkRP.notify(ply, 3, 4, "Du wurdest für 10 Minuten gemuted!") 

        -- ulx has not used
        MG_TDM_WORDS_FILTERING.AddSteamIDToMute(ply:SteamID(), 600)
        
        -- Possibly add a watchlist entry from here
        return ""
    end
end)

-- Hook into the PlayerSay event to open GUI for this system
hook.Add("PlayerSay", "MG_TDM:WordMenuCommand", function(ply, text)
    -- Extract the arguments from the player's chat message
    local args = MG_TDM_WORDS_FILTERING.extractArguments(text)
        
    -- Check if the command is "/wordmenu"
    if string.lower(args[1]) == "/wordmenu" then
        net.Start("MG_WORDS_MENU")
          net.WriteString("open")
          net.WriteTable(MG_TDM_WORDS_BLACKLIST)
        net.Send(ply)
    end
end)

-- Hook into the PlayerSay event to open GUI for this system
hook.Add("PlayerSay", "MG_TDM:MutedPlayers", function(ply, text)
    MG_TDM_WORDS_FILTERING.checkSteamIDMuted(ply)
    if (MG_TDM_WORDS_FILTERING.IsSteamIDMuted(ply:SteamID())) then return "" end
end)
