' entry point for main scne

sub Init()
    ' set background
    m.top.backgroundColor = "#000000"
    m.top.backgroundUri = "pkg:/images/background.jpg"

    ' store loading indicator
    m.loadingIndicator = m.top.FindNode("loadingIndicator")

    InitScreenStack()
    ShowGridScreen()

    ' retrieve metadata
    RunContentTask()

end sub