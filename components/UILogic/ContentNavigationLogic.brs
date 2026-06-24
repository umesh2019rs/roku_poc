
function NormalizeMediaType(item as Object) as String
    if item = invalid then return ""
    mediaType = item.mediaType
    if mediaType = invalid then mediaType = item.mediatype
    if mediaType = invalid then return ""
    return LCase(mediaType)
end function

function IsSeriesContent(item as Object) as Boolean
    mediaType = NormalizeMediaType(item)
    if mediaType = "series" then return true
    if item <> invalid and item.GetChildCount() > 0
        firstChild = item.GetChild(0)
        if firstChild <> invalid and firstChild.GetChildCount() > 0
            return true
        end if
    end if
    return false
end function

function GetDetailsModeForItem(item as Object) as String
    mediaType = NormalizeMediaType(item)
    if mediaType = "series" or IsSeriesContent(item)
        return "series"
    else if mediaType = "shorts" or mediaType = "short" or mediaType = "shortformvideos"
        return "short"
    else if mediaType = "episode"
        return "episode"
    end if
    return "movie"
end function

function GetFirstEpisodeOfSeries(seriesItem as Object) as Object
    if seriesItem = invalid then return invalid
    seasons = seriesItem.GetChildren(-1, 0)
    if seasons = invalid or seasons.Count() = 0 then return invalid

    ' GetChildren() returns a BrightScript array (1-indexed).
    firstSeason = seasons[1]
    if firstSeason = invalid then return invalid

    episodes = firstSeason.GetChildren(-1, 0)
    if episodes = invalid or episodes.Count() = 0 then return invalid

    return episodes[1]
end function

function NormalizeStreamFormat(streamFormat as String) as String
    if streamFormat = invalid or streamFormat = "" then return "mp4"
    normalized = LCase(streamFormat)
    if normalized = "hls" or normalized = "mp4" or normalized = "dash" or normalized = "ism" or normalized = "mkv" or normalized = "mov" or normalized = "wmv"
        return normalized
    end if
    return "mp4"
end function

function GetContentUrl(item as Object) as String
    if item = invalid then return ""
    url = item.url
    if url <> invalid and url <> "" then return url
    return ""
end function

function GetContentStreamFormat(item as Object) as String
    if item = invalid then return ""
    sf = item.streamFormat
    if sf = invalid then sf = item.streamformat
    if sf <> invalid and sf <> "" then return sf
    return ""
end function

function ResolvePlayableContent(content as Object) as Object
    if content = invalid then return invalid

    if GetContentUrl(content) <> "" then return content

    firstEpisode = GetFirstEpisodeOfSeries(content)
    if firstEpisode <> invalid and GetContentUrl(firstEpisode) <> "" then return firstEpisode

    return invalid
end function
