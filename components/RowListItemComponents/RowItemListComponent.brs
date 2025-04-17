sub OnContentSet()
    content = m.top.itemContent
    if content <> invalid
        poster = m.top.FindNode("poster")
        if poster <> invalid
            if content.tile <> invalid
                poster.uri = content.tile
            end if 
        else
            print "Error: 'poster' node not found!"
        end if
    else
        print "Error: Invalid content or missing 'tile' field!"
    end if
end sub