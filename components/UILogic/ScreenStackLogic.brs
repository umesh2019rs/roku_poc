
sub InitScreenStack()
    m.screenStack = []
    m.screenContainer = m.top.findNode("contentArea")
end sub

sub ShowScreen(node as Object)
    prev = m.screenStack.Peek()
    if prev <> invalid
        prev.visible = false
    end if
    if m.screenContainer <> invalid
        m.screenContainer.appendChild(node)
    end if
    node.visible = true
    node.setFocus(true)
    m.screenStack.Push(node)
end sub

sub CloseScreen(node as Object)
    peekNode = m.screenStack.Peek()
    if node = invalid or (peekNode <> invalid and peekNode.isSameNode(node))
        last = m.screenStack.Pop()
        lastWasVideo = false
        if last <> invalid
            if last.subtype() = "Video"
                lastWasVideo = true
            end if
            last.visible = false
            parent = last.getParent()
            if parent <> invalid
                parent.removeChild(last)
            end if
        end if

        prev = m.screenStack.Peek()
        if prev <> invalid
            prev.visible = true
            prev.setFocus(true)
            if prev.subtype() = "DetailsScreen"
                RestoreDetailsButtonFocus(prev)
            end if
        end if
        if lastWasVideo
            RestorePostVideoNavigationState()
        end if
        OnScreenStackChanged()
    end if
end sub

sub OnScreenStackChanged()
    if m.screenStack = invalid or m.screenStack.Count() <> 1 then return
    root = m.screenStack.Peek()
    if root <> invalid and root.subtype() = "HomeScreen"
        showSideBar()
        if m.menuList <> invalid
            m.menuList.setFocus(true)
            m.currentFocus = "menu"
        end if
    end if
end sub

sub RestorePostVideoNavigationState()
    ' Focus restoration handled by ShowScreen/CloseScreen stack.
end sub

sub RestoreDetailsButtonFocus(detailsScreen as Object)
    if detailsScreen = invalid then return

    actionButtons = detailsScreen.findNode("actionButtons")
    if actionButtons = invalid then return

    selectedIndex = 0
    if detailsScreen.focusButton = "episodes" and actionButtons.content <> invalid
        if actionButtons.content.GetChildCount() > 1
            selectedIndex = 1
        end if
    end if

    actionButtons.itemSelected = selectedIndex
    actionButtons.setFocus(true)
end sub

sub ReplaceRootScreen(node as Object)
    while m.screenContainer <> invalid and m.screenContainer.getChildCount() > 0
        ch = m.screenContainer.getChild(0)
        m.screenContainer.removeChild(ch)
    end while
    m.screenStack = []
    ShowScreen(node)
end sub
