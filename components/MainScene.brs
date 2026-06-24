
sub Init()
    m.top.backgroundColor = "0x662D91"
    m.top.backgroundUri = "pkg:/images/background.jpg"

    InitScreenStack()
    SetupDrawerNodes()

    if IsUserLoggedIn() = true
        LoadHome()
    else
        hideSideBar()
        LoadRootScreen("LoginScreen")
    end if

    m.top.observeField("signal", "OnSignalReceived")
    m.top.signalBeacon("AppLaunchComplete")
end sub

function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        if key = "back"
            if m.screenStack <> invalid and m.screenStack.Count() > 1
                CloseScreen(invalid)
                result = true
            else if m.drawerContainer.visible = false and m.screenStack <> invalid and m.screenStack.Count() = 1
                peek = m.screenStack.Peek()
                if peek <> invalid and (peek.subtype() = "DetailsScreen" or peek.subtype() = "EpisodesScreen")
                    CloseScreen(invalid)
                    result = true
                else
                    ShowExitDialog()
                    result = true
                end if
            else
                ShowExitDialog()
                result = true
            end if
        else if key = "left" and m.drawerContainer.visible = true and IsFocusInContentArea()
            m.menuList.setFocus(true)
            m.currentFocus = "menu"
            result = true
        else if key = "right" and m.drawerContainer.visible = true and m.menuList.hasFocus()
            FocusActiveContentScreen()
            m.currentFocus = "content"
            result = true
        end if
    end if
    return result
end function

function IsFocusInContentArea() as Boolean
    if m.contentArea = invalid then return false
    node = m.top.focusedChild
    while node <> invalid
        if node.isSameNode(m.contentArea) then return true
        node = node.getParent()
    end while
    return false
end function

sub FocusActiveContentScreen()
    root = m.screenStack.Peek()
    if root = invalid then return
    rl = root.findNode("rowList")
    if rl <> invalid
        rl.setFocus(true)
        return
    end if
    poster = root.findNode("dynamicPoster")
    if poster <> invalid
        poster.setFocus(true)
        return
    end if
    logOutBtn = root.findNode("logOutButton")
    if logOutBtn <> invalid
        logOutBtn.setFocus(true)
        return
    end if
    actionButtons = root.findNode("actionButtons")
    if actionButtons <> invalid
        actionButtons.setFocus(true)
        return
    end if
    seasonList = root.findNode("seasonList")
    if seasonList <> invalid
        seasonList.setFocus(true)
        return
    end if
    root.setFocus(true)
end sub

sub OnSignalReceived()
    if m.top.signal = "exit"
        print "Received exit signal."
    end if
end sub
