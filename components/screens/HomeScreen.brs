sub init()
    m.poster = m.top.findNode("dynamicPoster")
    m.timer = CreateObject("roSGNode", "Timer")
    m.timer.duration = 5 ' Change image every 5 seconds
    m.timer.repeat = true
    m.timer.observeField("fire", "updatePosterImage")
    m.timer.control = "start"
    m.imageList = [
        "pkg:/images/rsgesplash.jpg",
        "pkg:/images/splash_hd.jpg",
        "pkg:/images/rde_mm_focus_sd.jpg"
    ]
    m.currentIndex = 0
    updatePosterImage()

    m.rowList = m.top.findNode("rowList")
    configureRowListLayout(3)
    m.rowList.visible = true
    m.poster.observeField("focusedChild", "onFocusChanged")
    m.rowList.observeField("focusedChild", "onFocusChanged")
    m.rowList.ObserveField("rowItemSelected", "OnGridScreenItemSelected")

    m.homeDataTask = CreateObject("roSGNode", "HomeDataTask")
    m.homeDataTask.url = "https://jonathanbduval.com/roku/feeds/roku-developers-feed-v1.json"
    m.homeDataTask.observeField("fetchComplete", "onDataLoaded")
    m.homeDataTask.control = "RUN" 
end sub

sub onDataLoaded()
    if m.homeDataTask.fetchComplete
        jsonString = m.homeDataTask.responseData

        ' Check if jsonString is valid
        if jsonString = invalid or jsonString = ""
            print "Error: Empty or invalid API response"
            return
        end if

        rootChildren = []
        rows = {}
        ' Parse JSON string to object
        json = ParseJson(jsonString)

        if json <> invalid
            for each category in json
                value = json.Lookup(category)
                if Type(value) = "roArray" ' if parsed key value having other objects in it   
                    row = {}
                    row.title = category
                    row.children = []
                    for each item in value ' parse items and push them to row
                        itemData = GetItemData(item)
                        seasons = GetSeasonData(item.seasons)
                        itemData.mediaType = category
                        if seasons <> invalid and seasons.Count() > 0
                            itemData.children = seasons
                        end if
                            row.children.Push(itemData)
                    end for
                    rootChildren.Push(row)
                end if
            end for
            
            contentNode = CreateObject("roSGNode", "ContentNode")
            contentNode.Update({
                children: rootChildren
            }, true)
            m.rowList.content = contentNode
            configureRowListLayout(rootChildren.Count())
        end if  
    end if
end sub

sub configureRowListLayout(rowCount as Integer)
    if m.rowList = invalid then return
    if rowCount < 1 then rowCount = 1

    itemWidth = 380
    posterHeight = 156
    rowLabelOffsetY = 21
    rowGap = 40

    ' itemSize height must include posters, focus ring, and row title text.
    ' itemSpacing is added between rows on top of itemSize (do not undersize itemSize).
    rowBandHeight = 300
    listWidth = itemWidth * 3 + 20 * 2

    rowHeights = []
    rowItemSizes = []
    rowLabelOffsets = []
    showRowLabels = []
    showRowCounters = []
    rowItemSpacings = []

    for i = 1 to rowCount
        rowHeights.Push(posterHeight + 14)
        rowItemSizes.Push([itemWidth, posterHeight])
        rowLabelOffsets.Push([0, rowLabelOffsetY])
        showRowLabels.Push(true)
        showRowCounters.Push(false)
        rowItemSpacings.Push([20, 0])
    end for

    m.rowList.numRows = rowCount
    m.rowList.itemSize = [listWidth, rowBandHeight]
    m.rowList.rowHeights = rowHeights
    m.rowList.rowItemSize = rowItemSizes
    m.rowList.itemSpacing = [0, rowGap]
    m.rowList.rowLabelOffset = rowLabelOffsets
    m.rowList.rowItemSpacing = rowItemSpacings
    m.rowList.showRowLabel = showRowLabels
    m.rowList.showRowCounter = showRowCounters
end sub

function GetItemData(video as Object) as Object
    item = {}

    if video.longDescription <> invalid
        item.description = video.longDescription
    else
        item.description = video.shortDescription
    end if
    item.hdPosterURL = video.thumbnail
    item.title = video.title
    item.releaseDate = video.releaseDate
    item.id = video.id
    if video.episodeNumber <> invalid
        item.episodePosition = video.episodeNumber.ToStr()
    end if
    if video.content <> invalid
        ' populate length of content to be displayed on the GridScreen
        item.length = video.content.duration
        ' populate meta-data for playback
        item.url = video.content.videos[0].url
        videoType = video.content.videos[0].videoType
        if videoType <> invalid
            item.streamFormat = LCase(videoType)
        end if
    end if
    return item
end function

function GetSeasonData(seasons as Object) as Object
    seasonsArray = []
    if seasons <> invalid
        episodeCounter = 0
        for each season in seasons 
            if season.episodes <> invalid
                episodes = []
                for each episode in season.episodes
                    episodeData = GetItemData(episode)
                    ' save season title for element to represent it on the episodes screen
                    episodeData.titleSeason = season.title
                    episodeData.numEpisodes = episodeCounter
                    episodeData.mediaType = "episode"
                    episodes.Push(episodeData)
                    episodeCounter ++
                end for
                seasonData = GetItemData(season)
                ' populate season's children field with its episodes
                ' as a result season's ContentNode will contain episode's nodes
                seasonData.children = episodes
                ' set content type for season object to represent it on the screen as section with episodes
                seasonData.contentType = "section"
                seasonsArray.Push(seasonData)
            end if
        end for
    end if
    return seasonsArray
end function

sub updatePosterImage()
    if m.imageList.count() > 0 then
        m.poster.uri = m.imageList[m.currentIndex]
        m.currentIndex = (m.currentIndex + 1) mod m.imageList.count()
    end if
end sub

sub onFocusChanged()
    ' Check which element has focus
    if m.poster.hasFocus()
        print "Focus is now on Poster"
    else if m.rowList.hasFocus()
        print "Focus is now on RowList"
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        print "Key Pressed: "; key

        ' Move focus from Poster to RowList
        if key = "down" and m.poster.hasFocus() then
            print "Switching focus to RowList"
            m.rowList.setFocus(true)
            return true

        ' Move focus from RowList to Poster
        else if key = "up" and m.rowList.hasFocus() then
            print "Switching focus back to Poster"
            m.poster.setFocus(true)
            return true

        ' Let MainScene move focus back to the sidebar
        else if key = "left" then
            return false
        end if
    end if

    return false
end function

sub OnGridScreenItemSelected(event as Object)
    grid = event.GetRoSGNode()
    m.selectedIndex = event.GetData()
    rowContent = grid.content.GetChild(m.selectedIndex[0]).GetChild(m.selectedIndex[1])  
    m.top.itemSelected = rowContent
end sub


