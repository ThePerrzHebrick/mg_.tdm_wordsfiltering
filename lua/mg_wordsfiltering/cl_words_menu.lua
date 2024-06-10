local MG_WORDS_MENU = MG_WORDS_MENU or {}

net.Receive("MG_WORDS_MENU", function()
    if not IsValid(LocalPlayer()) then
        return
    end

    local type = net.ReadString()

    if (type == "open") then
        if IsValid(MG_WORDS_MENU.Menu) then
            MG_WORDS_MENU.Menu:Remove()
        end

        MG_WORDS_MENU.Table = net.ReadTable()
        MG_WORDS_MENU.Menu = vgui.Create("DFrame")
        MG_WORDS_MENU.Menu:SetSize(math.max(ScrW() * 0.1, 430), math.max(ScrH() * 0.5, 400))
        MG_WORDS_MENU.Menu:SetTitle("Wort Filter Menü")
        MG_WORDS_MENU.Menu:Center()
        MG_WORDS_MENU.Menu:SetDraggable(false)
        MG_WORDS_MENU.Menu:MakePopup()
        MG_WORDS_MENU.Menu:ParentToHUD()
        MG_WORDS_MENU.Menu:ShowCloseButton(true)

        -- Create the "Hinzufügen" button
        MG_WORDS_MENU.addButton = vgui.Create("DButton", MG_WORDS_MENU.Menu)
        MG_WORDS_MENU.addButton:SetSize(100, 25)
        MG_WORDS_MENU.addButton:SetPos(MG_WORDS_MENU.Menu:GetWide() / 2 + MG_WORDS_MENU.addButton:GetWide() / 2, MG_WORDS_MENU.Menu:GetTall() * 0.35)
        MG_WORDS_MENU.addButton:SetText("Hinzufügen")
        MG_WORDS_MENU.addButton:SetDisabled(true)

        -- Create the "Entfernen" button
        MG_WORDS_MENU.remButton = vgui.Create("DButton", MG_WORDS_MENU.Menu)
        MG_WORDS_MENU.remButton:SetSize(100, 25)
        MG_WORDS_MENU.remButton:SetPos(MG_WORDS_MENU.Menu:GetWide() / 2 + MG_WORDS_MENU.remButton:GetWide() / 2, MG_WORDS_MENU.Menu:GetTall() * 0.41)
        MG_WORDS_MENU.remButton:SetText("Entfernen")
        MG_WORDS_MENU.remButton:SetDisabled(true)

        -- Create the text entry
        MG_WORDS_MENU.dText2 = vgui.Create("DTextEntry", MG_WORDS_MENU.Menu)
        MG_WORDS_MENU.dText2:SetSize(100, 25)
        MG_WORDS_MENU.dText2:SetPos(MG_WORDS_MENU.Menu:GetWide() / 2 + MG_WORDS_MENU.dText2:GetWide() / 2, MG_WORDS_MENU.Menu:GetTall() * 0.27)

        -- Enable buttons when there's text in the text entry
        MG_WORDS_MENU.dText2.OnChange = function()
            local text = MG_WORDS_MENU.dText2:GetValue()
            local enabled = text ~= ""
            MG_WORDS_MENU.addButton:SetDisabled(not enabled)
            MG_WORDS_MENU.remButton:SetDisabled(not enabled)
        end

        -- Handle add button click
        MG_WORDS_MENU.addButton.DoClick = function()
            local word = MG_WORDS_MENU.dText2:GetValue()
            surface.PlaySound("ui/buttonclick.wav")
            net.Start("MG_WORDS_MENU")
                net.WriteEntity(LocalPlayer())
                net.WriteString("add")
                net.WriteString(word)
            net.SendToServer()
        end

        -- Handle remove button click
        MG_WORDS_MENU.remButton.DoClick = function()
            local word = MG_WORDS_MENU.dText2:GetValue()
            surface.PlaySound("ui/buttonclick.wav")
            net.Start("MG_WORDS_MENU")
                net.WriteEntity(LocalPlayer())
                net.WriteString("remove")
                net.WriteString(word)
            net.SendToServer()
        end

        -- Create the blacklist list view
        MG_WORDS_MENU.WordsBlackList = MG_WORDS_MENU.Menu:Add("DListView")
        MG_WORDS_MENU.WordsBlackList:SetPos(10, 30)
        MG_WORDS_MENU.WordsBlackList:SetMultiSelect(false)
        MG_WORDS_MENU.WordsBlackList:AddColumn("Wort")
        MG_WORDS_MENU.WordsBlackList:SetWidth(MG_WORDS_MENU.Menu:GetWide() * 0.5)
        MG_WORDS_MENU.WordsBlackList:SetTall(MG_WORDS_MENU.Menu:GetTall() - 35)

        for _, data in ipairs(MG_WORDS_MENU.Table) do
            MG_WORDS_MENU.WordsBlackList:AddLine(data)
        end

        -- Create the scroll panel
        MG_WORDS_MENU.ScrollRight = vgui.Create("DScrollPanel", MG_WORDS_MENU.Menu)
        MG_WORDS_MENU.ScrollRight:SetPos(MG_WORDS_MENU.Menu:GetWide() - MG_WORDS_MENU.Menu:GetWide() * 0.25 + 10 - 5, 30)
        MG_WORDS_MENU.ScrollRight:SetSize(MG_WORDS_MENU.Menu:GetWide() * 0.25 - 10, MG_WORDS_MENU.Menu:GetTall() * 0.5)
        MG_WORDS_MENU.ScrollRight:GetVBar().btnUp.Paint = function() end
        MG_WORDS_MENU.ScrollRight:GetVBar().btnDown.Paint = function() end
        MG_WORDS_MENU.ScrollRight:GetVBar().btnGrip.Paint = function(slf, w, h)
            draw.RoundedBox(2, 0, 0, w, h, Color(60, 60, 60))
        end
    end

    if (type == "refresh") then
        if not IsValid(MG_WORDS_MENU.Menu) then return end
        MG_WORDS_MENU.Table = net.ReadTable()
        MG_WORDS_MENU.WordsBlackList:Clear()
        for _, data in ipairs(MG_WORDS_MENU.Table) do
            MG_WORDS_MENU.WordsBlackList:AddLine(data)
        end
    end

    function MG_WORDS_MENU.Menu:OnClose()
        net.Start("MG_WORDS_MENU")
            net.WriteString("close")
        net.SendToServer()
    end
end)
