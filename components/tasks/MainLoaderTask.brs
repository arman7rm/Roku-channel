sub Init()
    m.top.functionName = "GetContent"
end sub

function GetContent() as void
    response = GetResponse("https://cd-static.bamgrid.com/dp-117731241344/home.json")
    if response = invalid
        print "Error fetching content: Invalid response recieved."
        return
    end if

    rootChildren = []
    
    containers = GetContainers(response)
    if containers = invalid
        print "Error fetching content: Invalid response structure. Failed to get containers."
    end if

    for each container in containers
        items = container.set.items
        if items <> invalid
            row = {}
            row.title = container.set.text.title.full.set.default.content
            row.children = []
            for each item in items
                itemData = GetItemData(item)
                row.children.Push(itemData)
            end for
            rootChildren.Push(row)
        end if
    end for

    ' set up a root ContentNode to represent rowList on the GridScreen
    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({
        children: rootChildren
    }, true)

    ' populate content field with root content node.
    ' Observer(see OnMainContentLoaded in ContentTaskLogic.brs) is invoked at that moment
    m.top.content = contentNode
end function

function GetResponse(url as string) as dynamic
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL(url)
    xfer.RetainBodyOnError(true)
    xfer.InitClientCertificates()

    response = xfer.GetToString()
    if response = invalid or response = ""
        print "Error fetching URL: " + url
        return invalid
    end if

    return response
end function

function GetContainers(rsp as Dynamic) as Dynamic
    if rsp = invalid then return invalid

    json = ParseJson(rsp)
    if json = invalid then return invalid

    return json?.data?.StandardCollection?.containers
end function

function GetItemData(video as object)
    item = {}
    item.full = video.text.title.full
    for each key in item.full
        format = item.full[key]
        if format <> invalid
            default = format.default
            if default <> invalid
                item.title = default.content
            end if
        end if
        exit for
    end for

    item.tile = GetImage(video)
    item.contentId = video.contentId
    item.videoArt = []

    for each media in video.videoArt
        urls = media.urls
        if urls <> invalid and urls.Count() > 0
            item.videoArt.Push(media.urls[0])
        end if
    end for
    return item
end function

function GetImage(video as object)
    if video = invalid or video.image = invalid
        print "Error: Video is invalid or does not contain images"
        return ""
    end if

    tile = video.image.tile
    if tile = invalid
        print "Error: Does not contain tile"
        return ""
    end if

    aspectRatio1_78 = tile["1.78"]
    if aspectRatio1_78 = invalid
        print "Error: Does not contain image in aspect ration 1.78"
        return ""
    end if

    ' Check for either "series" or other possible parent objects
    contentParent = invalid
    for each key in aspectRatio1_78
        if aspectRatio1_78[key] <> invalid
            contentParent = aspectRatio1_78[key]
            exit for
        end if
    end for

    if contentParent = invalid
        print "Error: Does not contain image in aspect ration 1.78"
        return ""
    end if

    default = contentParent.default
    if default = invalid
        print "Error: Does not contain default image"
        return ""
    end if

    url = default.url
    if url <> invalid then return url

    return ""
end function

sub GetRefSet(refID as string)
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL("https://cd-static.bamgrid.com/dp-117731241344/sets/" + refID + ".json")
    response = xfer.GetToString()
    json = ParseJson(response)
end sub
