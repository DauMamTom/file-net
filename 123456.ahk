#Requires AutoHotkey v2.0
#SingleInstance Force

global ConfigFile := EnvGet("USERPROFILE") "\.private_server_joiner.json"

MainGui := Gui("-Resize", "123")
MainGui.SetFont("s10", "Segoe UI")

EditLink := MainGui.Add("Edit", "w660 h45 vLinkText")
SendMessage(0x1501, 1, StrPtr("paste link first"), EditLink)

BtnJoin := MainGui.Add("Button", "w320 h38 Default", "join")
BtnDiscord := MainGui.Add("Button", "x+20 w320 h38", "Join Discord")
StatusLabel := MainGui.Add("Text", "xm w660 Center +cRed", "")

BtnJoin.OnEvent("Click", JoinServer)
BtnDiscord.OnEvent("Click", (*) => Run("https://discord.gg/TMwS5BeRjJ"))
MainGui.OnEvent("Close", (*) => ExitApp())

LoadSavedLink()
MainGui.Show("w700 h180")


JoinServer(*) {
    link := Trim(EditLink.Value)

    if (link = "") {
        StatusLabel.Value := "invalid server link"
        return
    }

    SaveLink(link)

    try {
        if InStr(link, "/games/") && InStr(link, "privateServerLinkCode=") {
            if RegExMatch(link, "i)/games/(\d+)", &matchPlace) && RegExMatch(link, "i)[?&]privateServerLinkCode=([^&]+)", &matchCode) {
                place := matchPlace[1]
                code := matchCode[1]
                
                deepLink := "roblox://placeId=" . place . "&linkCode=" . code
                Run(deepLink)
                
                StatusLabel.Value := ""
                return
            }
        }

        if InStr(link, "/share?") {
            if RegExMatch(link, "i)[?&]code=([^&]+)", &matchCode) {
                code := matchCode[1]
                typ := "Server"
                
                if RegExMatch(link, "i)[?&]type=([^&]+)", &matchType) {
                    typ := matchType[1]
                }
                
                deepLink := "roblox://navigation/share_links?code=" . code . "&type=" . typ
                Run(deepLink)
                
                StatusLabel.Value := ""
                return
            }
        }

        StatusLabel.Value := "invalid server link"
    } catch {
        StatusLabel.Value := "invalid server link"
    }
}

LoadSavedLink() {
    if FileExist(ConfigFile) {
        try {
            content := FileRead(ConfigFile, "UTF-8")
            if RegExMatch(content, '"private_server_link"\s*:\s*"(.*?)"', &match) {
                EditLink.Value := UnescapeJson(match[1])
            }
        }
    }
}

SaveLink(link) {
    try {
        if FileExist(ConfigFile)
            FileDelete(ConfigFile)
        
        jsonContent := '{"private_server_link": "' . EscapeJson(link) . '"}'
        FileAppend(jsonContent, ConfigFile, "UTF-8")
    }
}

EscapeJson(str) {
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, '"', '\"')
    return str
}

UnescapeJson(str) {
    str := StrReplace(str, '\"', '"')
    str := StrReplace(str, "\\", "\")
    return str
}