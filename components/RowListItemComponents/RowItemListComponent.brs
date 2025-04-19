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
    if m.poster <> invalid
        if content.tile <> invalid
            m.poster.uri = content.tile
        else
            m.poster.uri = "pkg:/images/error-image.png"
        end if
    else
        print "Error: 'poster' node not found!"
    end if
end sub
