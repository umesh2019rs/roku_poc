sub init()
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.top.observeField("videoUrl", "onVideoUrlChanged")
    m.top.setFocus(true)
end sub

sub onVideoUrlChanged()
    if m.top.videoUrl <> invalid and m.top.videoUrl <> ""
        videoContent = CreateObject("roSGNode", "ContentNode")
        videoContent.url = m.top.videoUrl
        videoContent.streamFormat = "mp4"

        m.videoPlayer.content = videoContent
        m.videoPlayer.control = "play"
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    print "Key Pressed in Video Player: "; key
    
    if press
        if key = "back"
            print "Back button pressed! Stopping video."
            m.videoPlayer.control = "stop"
            m.top.removeChild(m.videoPlayer)
            m.top.backPressed = true
            return true
        end if
    end if
    return false
end function

