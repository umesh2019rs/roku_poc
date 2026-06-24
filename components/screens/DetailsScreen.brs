sub init()
    m.brandLabel = m.top.findNode("brandLabel")
    m.poster = m.top.findNode("poster")
    m.posterTitle = m.top.findNode("posterTitle")
    m.description = m.top.findNode("description")
    m.date = m.top.findNode("date")
    m.actionButtons = m.top.findNode("actionButtons")

    m.top.observeField("visible", "onVisibleChange")

    m.updatingButtons = false
    updateActionButtons()
end sub

sub onVisibleChange()
    if m.top.visible = true and m.actionButtons <> invalid
        restoreButtonFocus()
    end if
end sub

sub onItemDataChanged()
    data = m.top.itemData
    if data = invalid then return

    title = data.title
    if title <> invalid
        if m.brandLabel <> invalid then m.brandLabel.text = "Roku Developers"
        if m.posterTitle <> invalid then m.posterTitle.text = title
    end if

    if data.description <> invalid and m.description <> invalid
        m.description.text = data.description
    end if

    if data.releaseDate <> invalid and m.date <> invalid
        m.date.text = Left(data.releaseDate, 10)
    else if data.releasedate <> invalid and m.date <> invalid
        m.date.text = Left(data.releasedate, 10)
    end if

    posterUri = data.hdPosterURL
    if posterUri = invalid then posterUri = data.hdposterurl
    if posterUri <> invalid and m.poster <> invalid
        m.poster.uri = posterUri
    end if

    applyDetailMode()
end sub

sub applyDetailMode()
    updateActionButtons()
    restoreButtonFocus()
end sub

sub updateActionButtons()
    mode = m.top.detailMode
    if mode = invalid then mode = "movie"

    buttonTitles = ["Play"]
    if shouldShowEpisodesButton(mode)
        buttonTitles.Push("See all episodes")
    end if

    setActionButtons(buttonTitles)
end sub

sub setActionButtons(buttonTitles as Object)
    if m.actionButtons = invalid then return

    m.updatingButtons = true

    content = CreateObject("roSGNode", "ContentNode")
    for each title in buttonTitles
        item = content.createChild("ContentNode")
        item.title = title
    end for
    m.actionButtons.content = content
    m.actionButtons.itemSelected = 0

    m.updatingButtons = false
end sub

function shouldShowEpisodesButton(mode as String) as Boolean
    if mode = "series" then return true
    if mode = "movie" or mode = "short" or mode = "episode" then return false

    data = m.top.itemData
    if data = invalid then return false

    mediaType = data.mediaType
    if mediaType = invalid then mediaType = data.mediatype
    if mediaType <> invalid and LCase(mediaType) = "series" then return true

    if data.GetChildCount() > 0
        firstChild = data.GetChild(0)
        if firstChild <> invalid and firstChild.GetChildCount() > 0
            return true
        end if
    end if

    return false
end function

function getActionButtonIndex(action as String) as Integer
    if action = "episodes" then return 1
    return 0
end function

sub restoreButtonFocus()
    if m.actionButtons = invalid then return

    m.updatingButtons = true

    selectedIndex = getActionButtonIndex(m.top.focusButton)
    if m.actionButtons.content <> invalid
        if selectedIndex >= m.actionButtons.content.GetChildCount()
            selectedIndex = 0
        end if
    else
        selectedIndex = 0
    end if

    m.actionButtons.itemSelected = selectedIndex
    m.actionButtons.setFocus(true)

    m.updatingButtons = false
end sub

sub triggerActionForSelectedButton()
    if m.actionButtons = invalid or m.actionButtons.content = invalid then return

    selectedIndex = m.actionButtons.itemSelected
    item = m.actionButtons.content.GetChild(selectedIndex)
    if item = invalid or item.title = invalid then return

    title = item.title
    if title = "Play"
        triggerAction("play")
    else if title = "See all episodes"
        triggerAction("episodes")
    end if
end sub

sub triggerAction(action as String)
    m.top.actionSelected = action
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press <> true then return false
    if key = "back" then return false

    if key = "OK" and m.actionButtons <> invalid and m.actionButtons.hasFocus()
        triggerActionForSelectedButton()
        return true
    end if

    return false
end function
