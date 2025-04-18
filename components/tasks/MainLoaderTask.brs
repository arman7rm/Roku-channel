sub Init()
    m.top.functionName = "GetContent"
end sub

function GetContent() as void
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL("https://cd-static.bamgrid.com/dp-117731241344/home.json")
    rsp = xfer.GetToString()
    rootChildren = []
    rows = {}


    if rsp <> invalid and rsp <> ""
        json = ParseJson(rsp)
        if json <> invalid

            data = json.data
            if data <> invalid
                standardCollection = data.StandardCollection
                'contentDescription = standardCollection.Lookup("text", invalid).Lookup("title", invalid).Lookup("full", invalid).Lookup("collection", invalid).Lookup("default", invalid).Lookup("content", "Unknown")
                containers = standardCollection.containers
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
                ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
                m.top.content = contentNode
            end if
        end if
    else
        print "No response or invalid response from URL."
    end if

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

    ' url = video.image.tile["1.78"].series.default.url
    item.tile = GetImage(video)
    

    ' if url <> invalid
    '     item.tile = url
    ' end if

    ' url = video.Lookup("image", invalid).Lookup("title_treatment_layer", invalid).Lookup("1.78", invalid).Lookup("series", invalid).Lookup("default", invalid).Lookup("url", invalid)
    ' if url <> invalid
    '     item.title_treatment_layer = url
    ' end if

    ' url = video.Lookup("image", invalid).Lookup("title_treatment", invalid).Lookup("1.78", invalid).Lookup("series", invalid).Lookup("default", invalid).Lookup("url", invalid)
    ' if url <> invalid
    '     item.title_treatment = url
    ' end if


    ' url = video.Lookup("image", invalid).Lookup("background", invalid).Lookup("1.78", invalid).Lookup("series", invalid).Lookup("default", invalid).Lookup("url", invalid)
    ' if url <> invalid
    '     item.background = url
    ' end if

    ' url = video.Lookup("image", invalid).Lookup("hero_collection", invalid).Lookup("1.78", invalid).Lookup("series", invalid).Lookup("default", invalid).Lookup("url", invalid)
    ' if url <> invalid
    '     item.hero_collection = url
    ' end if


    ' url = video.Lookup("image", invalid).Lookup("hero_tile", invalid).Lookup("1.78", invalid).Lookup("series", invalid).Lookup("default", invalid).Lookup("url", invalid)
    ' if url <> invalid
    '     item.hero_tile = url
    ' end if

    item.contentId = video.contentId

    ' item.tags = []

    ' for each tag in video.tags
    '     item.tags.Push(tag.type)
    ' end for

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
    image = video.image' or json.image
    if image <> invalid
        tile = image["tile"] 
        if tile <> invalid
            aspectRatio1_78 = tile["1.78"] 
            if aspectRatio1_78 <> invalid
                series = aspectRatio1_78["series"]  
                if series <> invalid
                    default = series["default"]  
                    if default <> invalid
                        url = default["url"]
                        if url <> invalid
                            return url
                        end if
                    end if
                end if
            end if
        end if
    end if
    return ""
end function

sub GetRefSet(refID as string)
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL("https://cd-static.bamgrid.com/dp-117731241344/sets/" + refID + ".json")
    rsp = xfer.GetToString()
    json = ParseJson(rsp)


end sub

' Recursive function to find the value of a key in nested JSON
function FindKeyValue(obj as object, targetKey as string) as dynamic
    if obj = invalid return invalid

    ' Check if current object has the target key
    if obj.Lookup(targetKey) <> invalid
        return obj[targetKey]
    end if

    ' Recursively search nested objects
    for each key in obj
        if Type(obj[key]) = "roAssociativeArray"
            result = FindKeyValue(obj[key], targetKey)
            if result <> invalid return result
        else if Type(obj[key]) = "roArray"
            for each item in obj[key]
                if Type(item) = "roAssociativeArray"
                    result = FindKeyValue(item, targetKey)
                    if result <> invalid return result
                end if
            end for
        end if
    end for

    return invalid
end function