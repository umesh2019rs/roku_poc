sub init()
    if m.initialized = true then return
    m.initialized = true

    m.usernameField = m.top.findNode("usernameField")
    m.passwordField = m.top.findNode("passwordField")
    m.loginButton = m.top.findNode("loginButton")
    m.loginButtonBg = m.top.findNode("loginButtonBg")
    m.focusIndicatorLabel = m.top.findNode("focusIndicatorLabel")
    m.keyboard = m.top.findNode("loginMiniKeyboard")
    m.keyboardDoneButton = m.top.findNode("keyboardDoneButton")
    m.keyboardDoneBg = m.top.findNode("keyboardDoneBg")
    m.layoutContainer = m.top.findNode("layoutContainer")
    if m.layoutContainer <> invalid
        m.layoutDefaultTranslation = m.layoutContainer.translation
    end if

    m.focusNodes = [m.usernameField, m.passwordField, m.loginButton]
    m.maxFocusIndex = 2

    m.usernameField.observeField("text", "onUsernameTextChanged")
    m.passwordField.observeField("text", "onPasswordTextChanged")
    m.loginButton.observeField("buttonSelected", "onLoginButtonClicked")
    if m.keyboard <> invalid
        m.keyboard.observeField("text", "onKeyboardTextChanged")
    end if
    if m.keyboardDoneButton <> invalid
        m.keyboardDoneButton.observeField("buttonSelected", "onKeyboardDone")
    end if

    if m.top.usernameValue = invalid then m.top.usernameValue = ""
    if m.top.passwordValue = invalid then m.top.passwordValue = ""
    m.usernameField.text = m.top.usernameValue
    m.passwordField.text = m.top.passwordValue

    if m.top.focusIndex = invalid then m.top.focusIndex = 0
    setFocusIndex(m.top.focusIndex)
    m.top.setFocus(true)
end sub

sub onUsernameTextChanged(event as Object)
    m.top.usernameValue = event.getData()
end sub

sub onPasswordTextChanged(event as Object)
    m.top.passwordValue = event.getData()
end sub

sub setFocusIndex(index as Integer)
    nextIndex = index
    if nextIndex < 0 then nextIndex = 0
    if nextIndex > m.maxFocusIndex then nextIndex = m.maxFocusIndex

    m.top.focusIndex = nextIndex
    m.focusIndex = nextIndex

    node = m.focusNodes[nextIndex]
    if node <> invalid
        node.setFocus(true)
    end if
    updateFocusVisuals()
end sub

sub updateFocusVisuals()
    focusText = "Focused: Unknown"
    if m.focusIndex = 0
        focusText = "Focused: Username"
    else if m.focusIndex = 1
        focusText = "Focused: Password"
    else if m.focusIndex = 2
        focusText = "Focused: Login"
    end if

    if m.keyboard <> invalid and m.keyboard.visible = true
        if m.keyboardFocusPart = "done"
            focusText = "Focused: Keyboard Done"
        else if m.activeFieldIndex = 0
            focusText = "Focused: Keyboard (Username)"
        else if m.activeFieldIndex = 1
            focusText = "Focused: Keyboard (Password)"
        else
            focusText = "Focused: Keyboard"
        end if
    end if

    if m.focusIndicatorLabel <> invalid
        m.focusIndicatorLabel.text = focusText
    end if

    if m.loginButtonBg <> invalid and m.loginButton <> invalid
        if m.loginButton.hasFocus()
            m.loginButtonBg.color = "0x3FA9F5FF"
        else
            m.loginButtonBg.color = "0x1E90FFFF"
        end if
    end if
end sub

sub updateKeyboardDoneVisuals()
    if m.keyboardDoneBg = invalid then return
    if m.keyboardDoneButton <> invalid and m.keyboardDoneButton.hasFocus()
        m.keyboardDoneBg.color = "0x3CB371FF"
    else
        m.keyboardDoneBg.color = "0x2E8B57FF"
    end if
    updateFocusVisuals()
end sub

sub moveFocusUp()
    setFocusIndex(m.focusIndex - 1)
end sub

sub moveFocusDown()
    setFocusIndex(m.focusIndex + 1)
end sub

sub setKeyboardActiveField(index as Integer)
    nextIndex = index
    if nextIndex < 0 then nextIndex = 0
    if nextIndex > 1 then nextIndex = 1

    m.activeFieldIndex = nextIndex
    m.focusIndex = nextIndex
    m.top.focusIndex = nextIndex

    if nextIndex = 0
        m.activeTextField = m.usernameField
    else
        m.activeTextField = m.passwordField
    end if

    if m.keyboard <> invalid and m.activeTextField <> invalid
        m.keyboard.text = m.activeTextField.text
    end if
    updateFocusVisuals()
end sub

sub showKeyboardDialog(textField as Object, fieldIndex as Integer)
    if textField = invalid or m.keyboard = invalid then return

    m.activeTextField = textField
    m.activeFieldIndex = fieldIndex
    m.focusIndex = fieldIndex
    m.top.focusIndex = fieldIndex
    m.keyboardFocusPart = "keys"
    m.keyboard.text = textField.text
    m.keyboard.visible = true
    if m.keyboardDoneButton <> invalid
        m.keyboardDoneButton.visible = true
    end if

    if m.layoutContainer <> invalid and m.layoutDefaultTranslation <> invalid
        m.layoutContainer.translation = [m.layoutDefaultTranslation[0], 220]
    end if

    m.keyboard.setFocus(true)
    updateKeyboardDoneVisuals()
end sub

sub onKeyboardTextChanged(event as Object)
    newText = event.getData()
    if m.activeTextField <> invalid
        m.activeTextField.text = newText
    end if
end sub

sub onKeyboardDone(event as Object)
    lastIndex = m.activeFieldIndex
    hideKeyboard()

    if lastIndex = 0
        setFocusIndex(1)
        showKeyboardDialog(m.passwordField, 1)
    else if lastIndex = 1
        setFocusIndex(2)
    end if
end sub

sub hideKeyboard()
    if m.keyboard <> invalid
        m.keyboard.visible = false
    end if
    if m.keyboardDoneButton <> invalid
        m.keyboardDoneButton.visible = false
    end if
    m.keyboardFocusPart = "keys"
    if m.layoutContainer <> invalid and m.layoutDefaultTranslation <> invalid
        m.layoutContainer.translation = m.layoutDefaultTranslation
    end if
    updateKeyboardDoneVisuals()
end sub

sub handleOKPress()
    if m.focusIndex = 0
        showKeyboardDialog(m.usernameField, 0)
        return
    end if
    if m.focusIndex = 1
        showKeyboardDialog(m.passwordField, 1)
        return
    end if
    if m.focusIndex = 2
        onLoginButtonClicked(invalid)
        return
    end if
end sub

sub onLoginButtonClicked(event as Object)
    username = m.top.usernameValue
    password = m.top.passwordValue
    if username = invalid then username = ""
    if password = invalid then password = ""

    if username = "" or password = "" then
        print "Username or password cannot be empty"
        return
    end if

    loginTask = CreateObject("roSGNode", "LoginTask")
    loginTask.url = "https://dummyjson.com/auth/login"
    loginTask.username = username
    loginTask.password = password
    loginTask.observeField("loginSuccess", "OnLoginSuccess")
    loginTask.control = "RUN"
end sub

sub OnLoginSuccess(event as Object)
    status = event.GetData()
    m.top.loginSuccess = status
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press <> true then return false

    keyboardOpen = m.keyboard <> invalid and m.keyboard.visible = true
    if keyboardOpen
        if key = "back"
            hideKeyboard()
            setFocusIndex(m.activeFieldIndex)
            return true
        else if key = "right"
            if m.keyboardDoneButton <> invalid
                m.keyboardDoneButton.setFocus(true)
                m.keyboardFocusPart = "done"
                updateKeyboardDoneVisuals()
                return true
            end if
        else if key = "left"
            if m.keyboard <> invalid
                m.keyboard.setFocus(true)
                m.keyboardFocusPart = "keys"
                updateKeyboardDoneVisuals()
                return true
            end if
        else if key = "OK"
            if m.keyboardFocusPart = "done"
                onKeyboardDone(invalid)
                return true
            end if
        else if key = "up"
            if m.keyboardFocusPart = "done"
                m.keyboard.setFocus(true)
                m.keyboardFocusPart = "keys"
                updateKeyboardDoneVisuals()
                return true
            end if
            setKeyboardActiveField(0)
            m.keyboard.setFocus(true)
            return true
        else if key = "down"
            if m.keyboardFocusPart = "done"
                onKeyboardDone(invalid)
                return true
            end if
            if m.activeFieldIndex = 0
                setKeyboardActiveField(1)
                m.keyboard.setFocus(true)
                return true
            end if
            hideKeyboard()
            setFocusIndex(2)
            return true
        end if
        updateKeyboardDoneVisuals()
        return false
    end if

    if key = "up"
        moveFocusUp()
        return true
    else if key = "down"
        moveFocusDown()
        return true
    else if key = "OK"
        handleOKPress()
        return true
    else if key = "left" or key = "right"
        return false
    end if

    return false
end function

function onFousChanged(event as Object)
    focused = event.getData()
    if focused = true
        setFocusIndex(m.top.focusIndex)
    end if
end function



