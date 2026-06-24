sub Init()
    ' store components to m for populating them with metadata
    m.poster = m.top.FindNode("poster")
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.info = m.top.FindNode("info")
    ' set font size for title and description Labels
    m.title.font.size = 16
    m.description.font.size = 10
    m.info.font.size = 10
    print "UBR Init"
end sub

sub itemContentChanged() ' invoked when episode data is retrieved
    print "UBR itemContentChanged"
    itemContent = m.top.itemContent ' episode metadata
    if itemContent <> invalid
        ' populate components with metadata
        m.poster.uri = itemContent.hdPosterUrl
        m.title.text = itemContent.title
        divider = " | "
        episode = "E" + itemContent.episodeposition
        time = GetTime(itemContent.length)
        date = itemContent.releaseDate
        season = itemContent.titleSeason
        m.info.text = episode + divider + date + divider + time + divider + season
        m.description.text = itemContent.description
    end if
end sub

function GetTime(length as Integer) as String
    minutes = (length \ 60).ToStr()
    seconds = length MOD 60
    if seconds < 10
       seconds = "0" + seconds.ToStr()
    else
       seconds = seconds.ToStr()
    end if
    return minutes + ":" + seconds
end function
