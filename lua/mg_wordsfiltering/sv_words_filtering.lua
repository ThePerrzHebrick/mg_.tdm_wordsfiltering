MG_TDM_WORDS_FILTER = MG_TDM_WORDS_FILTER or {}

-- Function to check if a message contains any filtered words
function MG_TDM_WORDS_FILTER.containsFilteredWord(message)
    for _, word in ipairs(MG_TDM_WORDS_BLACKLIST) do
        if string.find(string.lower(message), string.lower(word)) then
            return true
        end
    end
    return false
end

-- Hook into the PlayerSay event to filter chat messages
hook.Add("PlayerSay", "MG_TDM:WordInsultFilter", function(ply, text)
    if MG_TDM_WORDS_FILTER.containsFilteredWord(text) then

        if not (IsValid(ply)) then return end
        -- if (ply:IsMuted()) then return end | IsMuted, I didn't find any variables for querying, or none worked with my ULX

        ply:ChatPrint("Du kannst sowas doch nicht reinschreiben, dafür muss ich dich jetzt bestrafen!")
        DarkRP.notify(ply, 3, 4, "Du wurdest für 10 Minuten gemuted!") 

        -- Your courage is rebuilt, which is why I can't set a time for myself
        RunConsoleCommand("ulx", "mute", ply:Nick(), 600) -- ulx.mute( calling_ply, target_plys, should_unmute )

        -- Possibly add a watchlist entry from here
        return ""
    end
end)
