function Init()
    m.poster = m.top.FindNode("poster")
    m.scaleAnimation = m.top.FindNode("scaleAnimation")

    ' Initialize default scale (important for consistency)
    m.poster.scale = [1.0, 1.0]

    m.top.ObserveField("focused", "onFocusChange")
end function

sub onFocusChange()
    if m.top.focused
        print "Item focused, starting animation"
        m.scaleAnimation.control = "start"
    else
        print "Item unfocused, resetting scale"
        m.scaleAnimation.control = "stop"
        m.poster.scale = [1.0, 1.0]
    end if
end sub

sub OnContentSet()
    content = m.top.itemContent
    if content = invalid then return

    if m.poster <> invalid
        if content.tile <> invalid
            m.poster.uri = content.tile
        end if
    else
        print "Error: 'poster' node not found!"
    end if
end sub