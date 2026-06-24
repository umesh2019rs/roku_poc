sub init()
    m.logOutButton = m.top.findNode("logOutButton")
    m.logOutButtonBg = m.top.findNode("logOutButtonBg")
    m.logOutButton.observeField("buttonSelected", "onLogOutButtonClicked")
    m.logOutButton.observeField("focused", "onLogoutFocusChanged")
    updateLogoutButtonVisuals()
end sub

sub updateLogoutButtonVisuals()
    if m.logOutButtonBg = invalid or m.logOutButton = invalid then return
    if m.logOutButton.hasFocus()
        m.logOutButtonBg.color = "0xE74C3CFF"
    else
        m.logOutButtonBg.color = "0xC0392BFF"
    end if
end sub

sub onLogoutFocusChanged()
    updateLogoutButtonVisuals()
end sub

sub onLogOutButtonClicked(event as Object)
    print "Logout requested"
    m.top.logOutSuccess = false
    m.top.logOutSuccess = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press <> true then return false

    if key = "OK" and m.logOutButton <> invalid and m.logOutButton.hasFocus()
        onLogOutButtonClicked(invalid)
        return true
    end if

    return false
end function
