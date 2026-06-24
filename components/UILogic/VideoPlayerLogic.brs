
sub ShowVideoScreen(content as Object, itemIndex as Integer)
    if content = invalid then return

    playable = ResolvePlayableContent(content)
    if playable = invalid then
        print "ShowVideoScreen: no playable content with url"
        return
    end if

    SavePreVideoNavigationState()

    m.videoPlayer = CreateObject("roSGNode", "Video")
    m.videoPlayer.width = 1920
    m.videoPlayer.height = 1080
    m.videoPlayer.translation = [0, 0]

    videoContent = CreateObject("roSGNode", "ContentNode")
    videoContent.url = GetContentUrl(playable)
    videoContent.streamFormat = NormalizeStreamFormat(GetContentStreamFormat(playable))
    if playable.title <> invalid then videoContent.title = playable.title
    if playable.length <> invalid then videoContent.length = playable.length

    m.videoPlayer.content = videoContent
    m.videoPlayer.contentIsPlaylist = false

    hideSideBar()
    ShowScreen(m.videoPlayer)
    m.videoPlayer.setFocus(true)
    m.videoPlayer.control = "play"
    m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
    m.videoPlayer.observeField("visible", "OnVideoVisibleChange")
end sub

sub OnVideoPlayerStateChange()
    if m.videoPlayer = invalid then return
    state = m.videoPlayer.state
    if state = "error" or state = "finished"
        m.videoPlayer.unObserveField("state")
        m.videoPlayer.unObserveField("visible")
        CloseScreen(m.videoPlayer)
        m.videoPlayer = invalid
    end if
end sub

sub OnVideoVisibleChange()
    if m.videoPlayer = invalid then return
    if m.videoPlayer.visible = false and m.top.visible = true
        m.videoPlayer.control = "stop"
        m.videoPlayer.content = invalid
    end if
end sub

sub SavePreVideoNavigationState()

    m.previousFocusedNode = m.top.focusedChild

    if m.rowList <> invalid then
        focusedItem = m.rowList.rowItemFocused

        if focusedItem <> invalid and focusedItem.count() >= 2 then
            m.previousRowIndex = focusedItem[0]
            m.previousItemIndex = focusedItem[1]
        end if
    end if

    print "Navigation state saved"

end sub
