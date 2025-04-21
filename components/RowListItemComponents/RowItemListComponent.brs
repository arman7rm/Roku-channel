function Init()
    m.poster = m.top.FindNode("poster")
end function

sub showfocus()
    'This increases the size of the tile as it gains more focus
    scale = 1 + (m.top.focusPercent * 0.20)
    m.poster.scale = [scale, scale]
end sub

sub showrowfocus()
    m.poster.width = 200 + (131 * m.top.rowFocusPercent)
    m.poster.height = 112 + (67 * m.top.rowFocusPercent)
end sub

sub OnContentSet()
    content = m.top.itemContent
    if content = invalid
        print "Error: Failed to load content."
        return
    end if

    if m.poster = invalid
        print "Error: 'poster' node not found!"
        return
    end if

    ' Set the image (or fallback if tile is invalid)
    if content.tile <> invalid
        m.poster.uri = content.tile
        m.imageLoadObserver = m.poster.ObserveField("loadStatus", "OnPosterLoadStatusChanged")
    else
        m.poster.uri = "pkg:/images/fallback-image.png"
    end if
end sub

sub OnPosterLoadStatusChanged(event as object)
    loadStatus = event.GetData()
    if loadStatus = "failed"
        print "Error: "+ m.top.itemContent.title
        print "Image failed to load: " + m.poster.uri
        m.poster.uri = "pkg:/images/fallback-image.png"
    end if
    ' Clean up the observer
    m.poster.UnobserveField("loadStatus")
    m.imageLoadObserver = invalid
end sub