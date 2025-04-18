function Init()
    m.poster = m.top.FindNode("poster")
    m.itemmask = m.top.findNode("itemMask")
end function

sub showfocus()
    'This increases the size of the tile as it gains more focus
    scale = 1 + (m.top.focusPercent * 0.08)
    m.poster.scale = [scale, scale]
end sub

sub showrowfocus()
    m.itemmask.opacity = 0.75 - (m.top.rowFocusPercent * 0.75)
end sub

sub OnContentSet()
    content = m.top.itemContent
    if content = invalid then return
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
