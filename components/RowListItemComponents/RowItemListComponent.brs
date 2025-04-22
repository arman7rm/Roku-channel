function Init()
    m.poster = m.top.FindNode("poster")
    m.fallBack = m.top.FindNode("fallback")
    m.fallBackText = m.top.FindNode("fallbackText")
end function

sub showfocus()
    'This increases the size of the tile as it gains more focus
    scaleFactor = 0.20
    scale = 1 + (m.top.focusPercent * scaleFactor)
    m.poster.scale = [scale, scale]
    m.fallBack.scale = [scale, scale]
end sub

sub showrowfocus()
    defaultposterWidth = 200
    defaultposterHeight = 112
    widthFocusOffset = 131
    heightFocusOffset = 67
    fallbackTextTranslationOffsetX = 75
    fallbackTextTranslationOffsetY = 48
    
    m.poster.width = defaultposterWidth + (widthFocusOffset * m.top.rowFocusPercent)
    m.poster.height = defaultposterHeight + (heightFocusOffset * m.top.rowFocusPercent)

    m.fallBack.width = defaultposterWidth + (widthFocusOffset * m.top.rowFocusPercent)
    m.fallBack.height = defaultposterHeight + (heightFocusOffset * m.top.rowFocusPercent)

    m.fallBackText.translation = [10 + fallbackTextTranslationOffsetX*m.top.rowFocusPercent, 10 + fallbackTextTranslationOffsetY*m.top.rowFocusPercent]
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

' Handle broken image
sub OnPosterLoadStatusChanged(event as object)
    loadStatus = event.GetData()
    if loadStatus = "failed"
        print "Error: "+ m.top.itemContent.title
        print "Image failed to load: " + m.poster.uri
        m.poster.visible = false
        m.fallBack.visible = true
        m.fallBackText.text = m.top.itemContent.title
    end if
    ' Clean up the observer
    m.poster.UnobserveField("loadStatus")
    m.imageLoadObserver = invalid
end sub