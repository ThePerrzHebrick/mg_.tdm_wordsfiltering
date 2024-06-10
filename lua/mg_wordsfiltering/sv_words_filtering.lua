MG_TDM_WORDS_FILTERING = MG_TDM_WORDS_FILTERING or {}

-- Function to check if a message contains any filtered words
function MG_TDM_WORDS_FILTERING.containsFilteredWord(message)
    for _, word in ipairs(MG_TDM_WORDS_BLACKLIST) do
        if string.find(string.lower(message), string.lower(word)) then
            return true
        end
    end
    return false
end

-- Hook into the PlayerSay event to filter chat messages
hook.Add("PlayerSay", "MG_TDM:WordFilter", function(ply, text)
    if MG_TDM_WORDS_FILTERING.containsFilteredWord(text) then

        if not (IsValid(ply)) then return end

        ply:ChatPrint("Du kannst sowas doch nicht reinschreiben, dafür muss ich dich jetzt bestrafen!")
        DarkRP.notify(ply, 3, 4, "Du wurdest für 10 Minuten gemuted!") 

        -- Your courage is rebuilt, which is why I can't set a time for myself
        RunConsoleCommand("ulx", "mute", ply:Nick(), 600)

        -- Possibly add a watchlist entry from here
        return ""
    end
end)