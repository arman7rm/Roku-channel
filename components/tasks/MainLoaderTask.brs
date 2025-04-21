sub Init()
    m.top.functionName = "GetContent"
end sub

function GetContent() as void
    response = GetResponse(m.top.inputUrl)
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
    maxRetries = 3
    retryCount = 0
    response = invalid

    while retryCount < maxRetries
        xfer = CreateObject("roURLTransfer")
        xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        xfer.SetURL(url)
        xfer.RetainBodyOnError(true)
        xfer.InitClientCertificates()
        port = CreateObject("roMessagePort")
        xfer.SetPort(port)

        if xfer.AsyncGetToString()
            msg = wait(3000, port)
            if type(msg) = "roUrlEvent"
                status = msg.GetResponseCode()
                if status = 200
                    response = msg.GetString()
                    exit while ' Success - exit retry loop
                else
                    print "Error fetching URL: "; url; " Status: "; status.ToStr(); " (Attempt "; retryCount + 1; " of "; maxRetries; ")"
                end if
            else if msg = invalid ' timeout
                print "Request timed out for: "; url; " (Attempt "; retryCount + 1; " of "; maxRetries; ")"
            end if
        else
            print "Failed to initiate async request for: "; url; " (Attempt "; retryCount + 1; " of "; maxRetries; ")"
        end if

        retryCount = retryCount + 1
        if retryCount < maxRetries
            sleep(1000) ' Add a small delay between retries
        end if
    end while

    return response
end function

function GetContainers(rsp as dynamic) as dynamic
    if rsp = invalid then return invalid

    json = ParseJson(rsp)
    if json = invalid then return invalid

    return json?.data?.StandardCollection?.containers
end function

function GetItemData(item as object)
    data = {
        title: ""
        tile: ""
        contentId: ""
    }

    data.full = item?.text?.title?.full
    if data.full <> invalid
        for each key in data.full
            data.title = data.full[key]?.default?.content
            exit for
        end for
    end if

    data.tile = GetImageUrl(item, "1.78")
    data.contentId = item.contentId
    return data

end function

function GetImageUrl(data as object, size as string)
    aspectRatio = data?.image?.tile[size]
    if aspectRatio = invalid
        print "No image found for size: "; size
        return invalid
    end if

    ' Return first available URL without checking
    for each key in aspectRatio
        url = aspectRatio[key]?.default?.url
        if url <> invalid then return url
    end for
    return invalid
end function

sub GetRefSet(refID as string)
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL("https://cd-static.bamgrid.com/dp-117731241344/sets/" + refID + ".json")
    response = xfer.GetToString()
    json = ParseJson(response)
end sub
