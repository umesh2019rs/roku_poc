
sub SetupDrawerNodes()
    m.menuList = m.top.findNode("menuList")
    m.profileImage = m.top.findNode("profileImage")
    LoadProfileImage()
    m.drawerContainer = m.top.findNode("drawerContainer")
    m.drawerBG = m.top.findNode("rectBG")
    m.contentArea = m.top.findNode("contentArea")
end sub

sub LoadProfileImage()
    reg = CreateObject("roRegistrySection", "UserAuth")
    imageUrl = reg.read("image")

    if imageUrl <> invalid and imageUrl <> "" then
        m.profileImage.uri = imageUrl
    else
        m.profileImage.uri = "pkg:/images/profile.jpg"
    end if
end sub

sub ResetDrawerMenuToHome()
    if m.menuList = invalid then return
    if m.menuListObserved = true
        m.menuList.unObserveField("itemSelected")
    end if
    ' LabelList often does not repaint focusedColor when itemSelected stays the same value.
    ' Nudge selection away then back to Home while unobserved so no extra screen loads.
    m.menuList.itemSelected = 1
    m.menuList.itemSelected = 0
    if m.menuListObserved = true
        m.menuList.observeField("itemSelected", "OnMenuItemSelected")
    end if
end sub

sub LoadHome()
    showSideBar()
    SetupMenuOnce()
    ResetDrawerMenuToHome()
    LoadRootScreen("HomeScreen")
    LoadProfileImage()
    m.menuList.setFocus(true)
    m.currentFocus = "menu"
end sub

sub SetupMenuOnce()
    if m.menuListObserved = true then return
    m.menuListObserved = true

    menuContent = CreateObject("roSGNode", "ContentNode")

    homeNode = menuContent.createChild("ContentNode")
    homeNode.title = "Home"

    searchNode = menuContent.createChild("ContentNode")
    searchNode.title = "Search"

    accountNode = menuContent.createChild("ContentNode")
    accountNode.title = "Account"

    m.menuList.content = menuContent
    m.menuList.observeField("itemSelected", "OnMenuItemSelected")
end sub

function IsUserLoggedIn() as Boolean
    reg = CreateObject("roRegistrySection", "UserAuth")
    loggedInStatus = reg.read("loggedInStatus")
    return loggedInStatus = "true"
end function

sub OnMenuItemSelected()
    selectedIndex = m.menuList.itemSelected
    selectedTitle = m.menuList.content.getChild(selectedIndex).title

    if selectedTitle = "Home"
        LoadRootScreen("HomeScreen")
    else if selectedTitle = "Search"
        LoadRootScreen("SearchScreen")
    else if selectedTitle = "Account"
        LoadRootScreen("AccountScreen")
    end if
end sub

sub LoadRootScreen(componentName as String)
    newScreen = CreateObject("roSGNode", componentName)
    ReplaceRootScreen(newScreen)
    WireRootScreenObservers(componentName, newScreen)
end sub

sub WireRootScreenObservers(componentName as String, newScreen as Object)
    m.newScreen = newScreen
    if m.drawerContainer <> invalid and m.drawerContainer.visible = true
        m.menuList.setFocus(true)
        m.currentFocus = "menu"
    else
        newScreen.setFocus(true)
        newScreen.focus = true
    end if

    if componentName = "LoginScreen"
        newScreen.observeField("loginSuccess", "OnLoginSuccess")
    else if componentName = "HomeScreen"
        newScreen.observeField("itemSelected", "OnHomeItemSelected")
    else if componentName = "AccountScreen"
        newScreen.observeField("logOutSuccess", "OnLogOutSuccess")
    end if
end sub

sub OnHomeItemSelected()
    rowContent = m.newScreen.itemSelected
    if rowContent = invalid then return
    OpenDetailsScreen(rowContent, GetDetailsModeForItem(rowContent))
end sub

sub OpenDetailsScreen(content as Object, mode as String)
    if content = invalid then return

    if m.activeDetailsScreen <> invalid
        m.activeDetailsScreen.unobserveField("actionSelected")
    end if

    screen = CreateObject("roSGNode", "DetailsScreen")
    screen.focusButton = "play"
    screen.detailMode = mode
    screen.itemData = content
    screen.observeField("actionSelected", "OnDetailsActionSelected")
    m.activeDetailsScreen = screen

    hideSideBar()
    ShowScreen(screen)
end sub

sub OnDetailsActionSelected(event as Object)
    action = event.getData()
    if action = invalid or m.activeDetailsScreen = invalid then return

    content = m.activeDetailsScreen.itemData
    mode = m.activeDetailsScreen.detailMode

    if action = "play"
        ShowVideoScreen(content, 0)
    else if action = "episodes" and mode = "series"
        m.activeDetailsScreen.focusButton = "episodes"
        OpenEpisodesScreen(content)
    end if
end sub

sub OpenEpisodesScreen(seriesContent as Object)
    if seriesContent = invalid then return

    if m.activeEpisodesScreen <> invalid
        m.activeEpisodesScreen.unobserveField("episodeSelected")
    end if

    screen = CreateObject("roSGNode", "EpisodesScreen")
    screen.itemData = seriesContent
    screen.observeField("episodeSelected", "OnEpisodeSelected")
    m.activeEpisodesScreen = screen
    ShowScreen(screen)
end sub

sub OnEpisodeSelected(event as Object)
    episode = event.getData()
    if episode = invalid then return
    OpenDetailsScreen(episode, "episode")
end sub

sub hideSideBar()
    m.drawerContainer.visible = false
    m.drawerBG.visible = false
    m.contentArea.translation = [0, 0]
end sub

sub showSideBar()
    m.drawerContainer.visible = true
    m.drawerBG.visible = true
    m.contentArea.translation = [300, 0]
end sub

sub OnLoginSuccess(event as Object)
    status = event.getData()
    if status <> invalid and status = true
        LoadHome()
    end if
end sub

sub OnLogOutSuccess(event as Object)
    status = event.getData()
    if status <> invalid and status = true
        ClearUserSession()
        LoadLogin()
    end if
end sub

sub ClearUserSession()
    reg = CreateObject("roRegistrySection", "UserAuth")
    reg.Delete("loggedInStatus")
    reg.Delete("email")
    reg.Delete("firstName")
    reg.Delete("lastName")
    reg.Delete("image")
    reg.Delete("accessToken")
    reg.Delete("refreshToken")
    reg.Delete("username")
    reg.Write("loggedInStatus", "false")
    reg.Flush()
end sub

sub LoadLogin()
    hideSideBar()
    if m.menuListObserved = true and m.menuList <> invalid
        m.menuList.unObserveField("itemSelected")
        m.menuListObserved = false
    end if
    LoadRootScreen("LoginScreen")
end sub

sub ShowExitDialog()
    m.dialog = CreateObject("roSGNode", "Dialog")
    m.dialog.backgroundUri = "pkg:/images/rsgde_dlg_bg_hd.9.png"
    m.dialog.title = "Exit App"
    m.dialog.optionsDialog = true
    m.dialog.message = "Are you sure you want to quit?"
    m.dialog.buttons = ["Yes", "No"]
    m.dialog.observeField("buttonSelected", "OnExitDialogResponse")

    m.top.dialog = m.dialog
    m.dialog.control = "show"
end sub

sub OnExitDialogResponse(event as Object)
    response = event.getData()

    if response = 0
        m.dialog.close = true
        EndApp()
    else
        m.dialog.close = true
    end if

    m.top.dialog = invalid
end sub

sub EndApp()
    appManager = CreateObject("roAppManager")
    appManager.Stop()
end sub
