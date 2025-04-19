' entry point of GridScreen

sub Init()
    ' store variables
    m.rowList = m.top.FindNode("rowList")
    m.rowList.SetFocus(true)
    m.titleLabel = m.top.FindNode("titleLabel")
    
    ' rowItemFocused event handler
    m.rowList.ObserveField("rowItemFocused", "OnItemFocused")
end sub 
    

sub OnItemFocused()
    focusedIndex = m.rowList.rowItemFocused
    row = m.rowList.content.GetChild(focusedIndex[0])
    item = row.GetChild(focusedIndex[1])
    m.titleLabel.text = item.title
end sub

