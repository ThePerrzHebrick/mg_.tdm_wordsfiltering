if SERVER then
    include("mg_wordsfiltering/sv_words_config.lua")
    include("mg_wordsfiltering/sv_words_filtering.lua")
    AddCSLuaFile("mg_wordsfiltering/cl_words_menu.lua")
end

if CLIENT then
    AddCSLuaFile("mg_wordsfiltering/cl_words_menu.lua")
    include("mg_wordsfiltering/cl_words_menu.lua") 
end