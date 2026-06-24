sub init()
    m.seriesTitle = m.top.findNode("seriesTitle")
    m.seasonList = m.top.findNode("seasonList")
    m.episodeList = m.top.findNode("episodeList")

    m.episodeList.observeField("rowItemSelected", "onEpisodeRowSelected")
    m.seasonList.observeField("itemSelected", "onSeasonSelected")

    m.allSeasons = []
    m.selectedSeasonIndex = 0
end sub

sub onItemDataChanged()
    data = m.top.itemData
    if data = invalid then return

    if m.seriesTitle <> invalid and data.title <> invalid
        m.seriesTitle.text = data.title
    end if

    m.allSeasons = data.GetChildren(-1, 0)
    if m.allSeasons = invalid then m.allSeasons = []

    seasonItems = []
    for each season in m.allSeasons
        title = season.title
        if title = invalid then title = "Season"
        seasonItems.push({ title: title })
    end for

    if m.seasonList <> invalid
        m.seasonList.content = ContentListToSimpleNode(seasonItems)
        m.seasonList.itemSelected = 0
    end if

    if m.allSeasons.Count() > 0
        loadEpisodesForSeason(m.allSeasons[1])
    end if

    if m.seasonList <> invalid
        m.seasonList.setFocus(true)
    end if
end sub

function ContentListToSimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object
    result = CreateObject("roSGNode", nodeType)
    if result <> invalid
        for each itemAA in contentList
            item = CreateObject("roSGNode", nodeType)
            item.SetFields(itemAA)
            result.AppendChild(item)
        end for
    end if
    return result
end function

sub loadEpisodesForSeason(season as Object)
    if season = invalid or m.episodeList = invalid then return

    episodes = []
    if season.GetChildCount() > 0
        for each episode in season.GetChildren(-1, 0)
            episodes.push(buildEpisodeItemFields(episode))
        end for
    end if

    contentNode = CreateObject("roSGNode", "ContentNode")
    for each ep in episodes
        rowNode = contentNode.createChild("ContentNode")
        item = rowNode.createChild("SimpleRowListItemData")
        item.SetFields(ep)
    end for

    rowCount = episodes.Count()
    if rowCount < 1 then rowCount = 1

    m.episodeList.content = contentNode
    m.episodeList.numRows = rowCount
    rowHeights = []
    rowItemSizes = []
    for i = 0 to rowCount - 1
        rowHeights.push(170)
        rowItemSizes.push([380, 160])
    end for
    m.episodeList.rowHeights = rowHeights
    m.episodeList.rowItemSize = rowItemSizes
    m.episodeList.itemSize = [400, 170 * rowCount + 24 * (rowCount - 1)]
    m.episodeList.itemSpacing = [0, 24]
end sub

function buildEpisodeItemFields(episodeNode as Object) as Object
    fields = {}
    if episodeNode.title <> invalid then fields.title = episodeNode.title
    if episodeNode.description <> invalid then fields.description = episodeNode.description
    uri = episodeNode.hdPosterURL
    if uri = invalid then uri = episodeNode.hdposterurl
    if uri <> invalid then fields.hdPosterUrl = uri
    if episodeNode.id <> invalid then fields.id = episodeNode.id
    if episodeNode.url <> invalid then fields.url = episodeNode.url
    sf = episodeNode.streamFormat
    if sf = invalid then sf = episodeNode.streamformat
    if sf <> invalid
        fields.streamformat = LCase(sf)
    end if
    if episodeNode.length <> invalid then fields.length = episodeNode.length
    if episodeNode.releaseDate <> invalid
        fields.releaseDate = episodeNode.releaseDate
    else if episodeNode.releasedate <> invalid
        fields.releaseDate = episodeNode.releasedate
    end if
    if episodeNode.titleSeason <> invalid
        fields.titleseason = episodeNode.titleSeason
    else if episodeNode.titleseason <> invalid
        fields.titleseason = episodeNode.titleseason
    end if
    if episodeNode.episodePosition <> invalid
        fields.episodeposition = episodeNode.episodePosition
    else if episodeNode.episodeposition <> invalid
        fields.episodeposition = episodeNode.episodeposition
    end if
    if episodeNode.mediaType <> invalid
        fields.mediatype = episodeNode.mediaType
    else if episodeNode.mediatype <> invalid
        fields.mediatype = episodeNode.mediatype
    end if
    return fields
end function

sub onSeasonSelected()
    if m.seasonList = invalid or m.allSeasons = invalid then return
    selectedIndex = m.seasonList.itemSelected
    seasonArrayIndex = selectedIndex + 1
    if selectedIndex <> invalid and seasonArrayIndex <= m.allSeasons.Count()
        m.selectedSeasonIndex = selectedIndex
        loadEpisodesForSeason(m.allSeasons[seasonArrayIndex])
    end if
end sub

sub onEpisodeRowSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    if selectedIndex = invalid or grid = invalid or grid.content = invalid then return
    rowContent = grid.content.GetChild(selectedIndex[0]).GetChild(selectedIndex[1])
    m.top.episodeSelected = rowContent
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press <> true then return false

    if key = "back"
        return false
    end if

    if key = "right" and m.seasonList <> invalid and m.seasonList.hasFocus()
        if m.episodeList <> invalid
            m.episodeList.setFocus(true)
            return true
        end if
    else if key = "left" and m.episodeList <> invalid and m.episodeList.hasFocus()
        if m.seasonList <> invalid
            m.seasonList.setFocus(true)
            return true
        end if
    else if key = "down" and m.seasonList <> invalid and m.seasonList.hasFocus()
        if m.episodeList <> invalid
            m.episodeList.setFocus(true)
            return true
        end if
    else if key = "up" and m.episodeList <> invalid and m.episodeList.hasFocus()
        if m.seasonList <> invalid
            m.seasonList.setFocus(true)
            return true
        end if
    else if key = "OK" and m.episodeList <> invalid and m.episodeList.hasFocus()
        focused = m.episodeList.rowItemFocused
        if focused <> invalid and focused.Count() >= 2
            rowContent = m.episodeList.content.GetChild(focused[0]).GetChild(focused[1])
            m.top.episodeSelected = rowContent
            return true
        end if
    end if

    return false
end function
