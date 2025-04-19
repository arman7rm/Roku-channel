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
        items = container?.set?.items
        if items <> invalid
            row = {}
            row.title = container?.set?.text?.title?.full?.set?.default?.content
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
    port = CreateObject("roMessagePort")
    xfer.SetPort(port)

    response = xfer.GetToString()
    if xfer.AsyncGetToString()
        msg = wait(3000, port)
        if type(msg) = "roUrlEvent"
            status = msg.GetResponseCode()
            if status = 200
                return response
            ' Can add logic to handle other response codes here
            else
                print "Error fetching URL: " + url
                print "Status Code: "+ status.ToStr()
                return invalid
            end if
        end if
    end if
end function

function GetContainers(rsp as dynamic) as dynamic
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

    return item
end function

function GetImage(video as object)
    aspectRatio1_78 = video?.image?.tile["1.78"]

    if aspectRatio1_78 = invalid
        print "Error: Does not contain image in aspect ration 1.78"
        return invalid
    end if

    ' Check for either "series" or other possible parent objects
    contentParent = aspectRatio1_78
    for each key in aspectRatio1_78
        if aspectRatio1_78[key] <> invalid
            contentParent = aspectRatio1_78[key]
            exit for
        end if
    end for

    url = contentParent?.default?.url

    if url <> invalid
        if GetResponse(url) <> invalid
            return url
        else
            return invalid
        end if
    end if
    return invalid
end function

sub GetRefSet(refID as string)
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL("https://cd-static.bamgrid.com/dp-117731241344/sets/" + refID + ".json")
    response = xfer.GetToString()
    json = ParseJson(response)
end sub
