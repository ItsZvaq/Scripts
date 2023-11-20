-- Wait until client is loaded
repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") and game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.LoadingMessage.Visible == false

-- API CALLS
getgenv().api = loadstring(game:HttpGet("https://raw.githubusercontent.com/Narnia1337/hi/main/api.lua"))()
local bssapi=loadstring(game:HttpGet("https://raw.githubusercontent.com/Narnia1337/hi/main/bssapi.lua"))()
local library = loadstring(game:HttpGet("https://nameless-star-0651.on.fleek.co/library.lua"))()

-- Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActivatablesToys = require(ReplicatedStorage.Activatables.Toys)
local ScreenInfo = require(ReplicatedStorage.ScreenInfo)
local Events = require(ReplicatedStorage.Events)
local Quests = require(ReplicatedStorage.Quests)

local PlanterTypes = require(ReplicatedStorage.PlanterTypes)
local NectarTypes = require(ReplicatedStorage.NectarTypes)
local EggTypes = require(ReplicatedStorage.EggTypes)
local BeeTypes = require(ReplicatedStorage.BeeTypes)

local LocalPlanters = require(ReplicatedStorage.LocalPlanters)
local Accessories = require(ReplicatedStorage.Accessories)
local Collectors = require(ReplicatedStorage.Collectors)

local checkTool = require(ReplicatedStorage.ItemPackages.Collector).PlayerHas
local checkMask = require(ReplicatedStorage.ItemPackages.Accessory).PlayerHas
local ActivatablesNPC = require(ReplicatedStorage.Activatables.NPCs)
local ClientStatCache = require(ReplicatedStorage.ClientStatCache)
local timeToString = require(ReplicatedStorage.TimeString)
local StatTools = require(ReplicatedStorage.StatTools)
local StatReqs = require(ReplicatedStorage.StatReqs)
local ServerTime = require(ReplicatedStorage.OsTime)
-- Variables
local VirtualInputManager = game:GetService('VirtualInputManager')
local PathfindingService = game:GetService('PathfindingService')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local UserService = game:GetService("UserService")
local HttpService = game:GetService('HttpService')
local VirtualUser = game:GetService('VirtualUser')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local Lighting = game:GetService('Lighting')
local CoreGui = game:GetService('CoreGui')
local Players = game:GetService('Players')

-- Important Variables
local scriptType = "Paid"

getgenv().ExploitSpecific = "📜"
getgenv().Danger = "⚠️"
getgenv().Star = "⭐"

local httpreq = (syn and syn.request) or http_request or (http and http.request) or request
local setIdentity = (syn and syn.set_thread_identity) or setthreadcontodo or setidentity

local planterst = {plantername = {}, planterid = {}}
local moveTo = function(...) return end
local ScreenGui = ScreenInfo:GetScreenGui()
local player = Players.LocalPlayer
local NectarBlacklist = {}
local lastfieldpos = nil
local pathfinding = {}
local useBot = false

if not isfolder("macrov2") then makefolder("macrov2") end
if not isfolder("macrov2/plantercache") then makefolder("macrov2/plantercache") end
if not isfolder("macrov2/plantercache/"..player.Name) then makefolder("macrov2/plantercache/"..player.Name) end

-- Init local player
-- local successLP, LPresult = pcall(function()
-- 	return UserService:GetUserInfosByUserIdsAsync({ player.UserId })
-- end)

-- if successLP then
--     local userInfo = LPresult[1]
--     if player.Name ~= userInfo.Username then warn("Your username changed to default") end
--     player.Name = userInfo.Username
--     player.DisplayName = userInfo.DisplayName
-- end

local originalPlayerDisplayName = player.DisplayName
local originalPlayerName = player.Name


local currentMacroV2LoadedAt = tick()
getgenv().macroV2LoadedAt = currentMacroV2LoadedAt
local scriptTasks = {}

local --[[playerstatsevent]] RetrievePlayerStats = ReplicatedStorage.Events.RetrievePlayerStats
local --[[playeractivescommand]] PlayerActivesCommand = ReplicatedStorage.Events.PlayerActivesCommand
local monsterspawners = Workspace.MonsterSpawners

local statstable = RetrievePlayerStats:InvokeServer()
_G.autoload = player.Name or "USERNAME"

-- Player avatar
local playerAvatarUrl = "https://www.roblox.com/HeadShot-thumbnail/image?userId="..tostring(player.UserId).."&width=420&height=420&format=png" -- Old endpoint, used like placeholder.
pcall(function()
    playerAvatarUrl = HttpService:JSONDecode(
        httpreq(
            {
                Method="GET", 
                Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..player.UserId.."&size=420x420&format=Png&isCircular=false"
            }
        ).Body
    ).data[1].imageUrl
end)


-- Important Functions

local domapi = {
    ['Recursion'] = function(tables)	
        local returntable = {}	
        for i, v in next, tables do 	
            if type(v) == 'table' then	
                for g, f in next, v do	
                    table.insert(returntable, f)	
                end	
            else	
                table.insert(returntable, v)	
            end	
        end	
        return(returntable)	
    end,	
    ['Find'] = function(target, strings)	
        local returns = {}	
        for i, v in pairs(strings) do	
            h = tostring(v)	
            if string.find(target, h) then	
                table.insert(returns, h)	
            end	
        end	
        return(returns)	
    end,	
    ['SecToMin'] = function(sec)	
        return(sec/60)	
    end,	
    ['MinToSec'] = function(minutes)	
        return(minutes*60)	
    end,
    ['TweenSpeed'] = function(target)
        if typeof(target) == "CFrame" then 
            target = target.p
        end
        local tweenspeed = 0
        local distance = (target - api.humanoidrootpart().Position).magnitude
        if distance < 3 then
            tweenspeed = 3
        else
            tweenspeed = (distance/100)
        end
        return (tweenspeed)
    end,
    callEvent = function(event, ...)
        Events.ClientCall(event, ...)
    end
}

local debugStep = 0
local debugString = ""
local function debugNextStep(text)
    if text == true then debugString = debugString.." (Success)\n" return end
    debugStep = debugStep + 1
    debugString = debugString..debugStep..": "..text
end

getgenv().mv2debugSave = function()
    writefile("macrov2/debug.txt", debugString)
end

function updateClientStatCache()
    return RetrievePlayerStats:InvokeServer()
end

function returnvalue(tab, val)
    ok = false
    for i,v in pairs(tab) do
        if string.match(val, v) then
            ok = v
            break
        end
    end
    return ok
end

function maskString(str)
    if not str or type(str) ~= "string" or #str < 4 then
        return str
    end
    local len = #str
    local visibleChars = math.max(3, math.min(4, math.floor(len * 0.25)))
    local maskedChars = len - visibleChars
    local pattern = string.rep("*", maskedChars)
    local prefix = string.sub(str, 1, visibleChars)
    return prefix .. pattern
end

-- Quests
function checkQuestToggle(npc) 
    return (macrov2.toggles.blackbearquests and npc == "Black Bear") 
        or (macrov2.toggles.brownbearquests and npc == "Brown Bear")
        or (macrov2.toggles.pandabearquests and npc == "Panda Bear") 
        or (macrov2.toggles.sciencebearquests and npc == "Science Bear")
        or (macrov2.toggles.polarbearquests and npc == "Polar Bear") 
        or (macrov2.toggles.spiritbearquests and npc == "Spirit Bear")
        or (macrov2.toggles.buckobeequests and npc =="Bucko Bee") 
        or (macrov2.toggles.rileybeequests and npc =="Riley Bee") 
        or (macrov2.toggles.honeybeequests and npc == "Honey Bee")
        or (macrov2.toggles.onettquests and npc == "Onett")
end

function getQuestProgress(quest)
    setIdentity(2)
    local toReturn = Quests:Progress(quest, ClientStatCache:Get())
    setIdentity(7)
    return toReturn
end

function getQuestInfo(quest)
    setIdentity(2)
    local toReturn = Quests:Get(quest, ClientStatCache:Get())
    setIdentity(7)
    return toReturn
end

function getNPCQuest()
    local quests = {}
    for _, v in pairs(ClientStatCache:Get().Quests.Active) do
        local quest = getQuestInfo(v.Name)
        local npc = quest.NPC
        if quest and not quest.Hidden then
            if checkQuestToggle(npc)
            and not table.find(quests, v.Name) then
                -- print("added",v.Name)
                table.insert(quests, v.Name)
            end
        end
    end
    return quests
end

-- Nectars for webhook
local BuffTileModule = require(ReplicatedStorage.Gui.TileDisplay.BuffTile)

function getBuffTime1(buffName, convertToHMS)
    local buff = BuffTileModule.GetBuffTile(buffName)
    if not buff or not buff.TimerDur or not buff.TimerStart then 
        return 0 
    end

    local toReturn = buff.TimerDur - (math.floor(ServerTime()) - buff.TimerStart)
    if convertToHMS then 
        toReturn = timeToString(toReturn) 
    end
    
    return toReturn
end

local nectarTable = {
    "Comforting Nectar",
    "Satisfying Nectar",
    "Invigorating Nectar",
    "Refreshing Nectar",
    "Motivating Nectar"
}

function getAllNectar(bool)
    if bool then
        local tablereturn = {}
        for i, v in pairs(nectarTable) do
            table.insert(tablereturn, {name = v, time = getBuffTime1(v, true)})
        end
        return tablereturn
    end
end

debugNextStep("Main Config Init")

-- Config
getgenv().macrov2 = {
    configVersion = "1.0",
    rares = {},
    priority = {},
    autojelly = {Settings = {
        ["Roll For Specific Bees"] = false, 
        ["Roll For Rarity"] = false
    }, hiveslot = {
        ["Right"] = "0", 
        ["Up"] = "0"
    }, maxRoyalJellyUsage = {10}, AllowedRarities = {Legendary = false, Mythic = false, Epic = false}, specificbees = {}},
    bestfields = {
        red = "Strawberry Field",
        white = "Pumpkin Patch",
        blue = "Pine Tree Forest"
    },
    blacklistedfields = {},
    guidingblacklist = {},
    killermacrov2 = {},
    bltokens = {},
    webhookitems = {},
    toggles = {
        sproutplantnight = false,
        autosprout = false,
        sproutatnight = false,
        automemorymatch = false, 
        fireflies = false,
        faceFlame = false,
        faceBalloon = false,
        smileyonly = false,
        paperplanter = false,
        slowshower = false,
        no35bee = false,
        ignorehoneytokens = false,
        smartflame = false,
        pathfind = true,
		useBot = false,
        autofarm = false,
        farmclosestleaf = false,
        farmbubbles = false,
        smartbubbles = false,
        shutdownkick = false,
        smartscorch = false,
        autodig = false,
        farmrares = false,
        rgbui = false,
        farmflower = false,
        farmfuzzy = false,
        farmcoco = false,
        farmshower = false,
        farmflame = false,
        farmclouds = false,
        killmondo = false,
        killvicious = false,
        loopspeed = false,
        loopjump = false,
        -- autoquest = false,
        autoboosters = false,
        autodispense = false,
        clock = false,
        freeantpass = false,
        honeystorm = false,
        disableseperators = false,
        npctoggle = false,
        loopfarmspeed = false,
        mobquests = false,
        traincrab = false,
        traincommando = false,
        avoidmobs = false,
        farmsprouts = false,
        farmguiding = false, 
        enabletokenblacklisting = false,
        farmunderballoons = false,
        farmsnowflakes = false,
        antilag = false,
        collectgingerbreads = false,
        collectcrosshairs = false,
        farmpuffshrooms = false,
        tptonpc = false,
        donotfarmtokens = false,
        convertballoons = false,
        autostockings = false,
        autosamovar = false,
        autoonettart = false,
        autocandles = false,
        autofeast = false,
        autoplanters = false,
        autokillmobs = false,
        autoant = false,
        killwindy = false,
        godmode = false,
        disableconversion = false,
        autodonate = false,
        autouseconvertors = false,
        honeymaskconv = false,
        resetbeenergy = false,
        enablestatuspanel = false,
        autoequipmask = false,
        followplayer = false,
        allquests = false,
        blacklistinvigorating = false,
        blacklistcomforting = false,
        blacklistmotivating = false,
        blacklistrefreshing = false,
        blacklistsatisfying = false,
        plasticplanter = false,
        candyplanter = false,
        redclayplanter = false,
        blueclayplanter = false,
        tackyplanter = false,
        pesticideplanter = false,
        petalplanter = false,
        hydroponicplanter = false,
        heattreatedplanter = false,
        webhookupdates = false,
        webhookping = false,
        -- autoquesthoneybee = false,
        buyantpass = false,
        tweenteleport = false,
        docustomplanters = false,
        fastcrosshairs = false,
        unsafecrosshairs = false,
        smartmobkill = false,
        ["autouseBlue Extract"] = false,
        ["autouseRed Extract"] = false,
        ["autouseOil"] = false,
        ["autouseEnzymes"] = false,
        ["autouseGlue"] = false,
        ["autouseGlitter"] = false,
        ["autouseTropical Drink"] = false,
        ["autouseStinger"] = false,
        ["autouseJellyBeans"] = false,
        ["autouseSnowflake"] = false,
        usegumdropsforquest = false,
        autox4 = false,
        newtokencollection = false,
        farmduped = false,
        freerobopass = false,
        autosnowmachine = false,
        autohoneywreath = false,
        securemode = false,
        autokick = false,
        -- Auto Quests
        autodoquest = false,
        blackbearquests = false,
        -- motherbearquests = false,
        brownbearquests = false,
        pandabearquests = false,
        sciencebearquests = false,
        polarbearquests = false,
        spiritbearquests = false,
        buckobeequests = false,
        rileybeequests = false,
        honeybeequests = false,
        onettquests = false,
        -- Webhook
        webhookshowtotalhoney = false,
        webhookshowhoneyperhour = false,
        webhookonlytruncated = false,
        webhookcompletedquest = false,
        webhooknectars = false,
        webhookitems = false,
        weirdspeed = false,
        converttime = false,
        webhookshowplanters = false
    },
    vars = {
        mobblack = {},
        converttime = 60,
        weirdspeedmin = 40,
        weirdspeedmax = 60,
        webhookcolor = "0xfff802",
        viciousmax = 20,
        viciousmin = 0,
        windymax = 20,
        field = "Ant Field",
        convertat = 100,
        farmspeed = 60,
        prefer = "Tokens",
        ["autouseJellyBeansInterval"] = 35,
        walkspeed = 70,
        jumppower = 70,
        npcprefer = "All Quests",
        farmtype = "Walk",
        monstertimer = 15,
        autodigmode = "Normal",
        donoItem = "Coconut",
        donoAmount = 25,
        selectedTreat = "Treat",
        selectedTreatAmount = 0,
        autouseMode = "Just Tickets",
        autoconvertWaitTime = 10,
        defmask = "Gummy Mask",
        deftool = "Petal Wand",
        resettimer = 3,
        questcolorprefer = "Any NPC",
        playertofollow = "",
        convertballoonpercent = 50,
        planterharvestamount = 75,
        webhookurl = _G.webhookURL or "",
        discordid = 0,
        webhooktimer = 60,
        movingtype = "Tween",
        targetfps = 30,
        autokickinterval = 1,
        customplanter11 = "",
        customplanter12 = "",
        customplanter13 = "",
        customplanter14 = "",
        customplanter15 = "",
        customplanter21 = "",
        customplanter22 = "",
        customplanter23 = "",
        customplanter24 = "",
        customplanter25 = "",
        customplanter31 = "",
        customplanter32 = "",
        customplanter33 = "",
        customplanter34 = "",
        customplanter35 = "",
        customplanterfield11 = "",
        customplanterfield12 = "",
        customplanterfield13 = "",
        customplanterfield14 = "",
        customplanterfield15 = "",
        customplanterfield21 = "",
        customplanterfield22 = "",
        customplanterfield23 = "",
        customplanterfield24 = "",
        customplanterfield25 = "",
        customplanterfield31 = "",
        customplanterfield32 = "",
        customplanterfield33 = "",
        customplanterfield34 = "",
        customplanterfield35 = "",
        customplanterdelay11 = 75,
        customplanterdelay12 = 75,
        customplanterdelay13 = 75,
        customplanterdelay14 = 75,
        customplanterdelay21 = 75,
        customplanterdelay22 = 75,
        customplanterdelay23 = 75,
        customplanterdelay24 = 75,
        customplanterdelay25 = 75,
        customplanterdelay31 = 75,
        customplanterdelay32 = 75,
        customplanterdelay33 = 75,
        customplanterdelay34 = 75,
        customplanterdelay35 = 75,
    },
    dispensesettings = {
        blub = false,
        straw = false,
        treat = false,
        coconut = false,
        glue = false,
        rj = false,
        white = false,
        red = false,
        blue = false,
        freerobopass = false,
        freeantpass = false,
    },
    collectmethod = "New"
}

local defaultmacrov2 = macrov2

getgenv().temptable = {
    version = "2.6.1a",
    blackfield = "",
    tweening = false,
    guidingblack = "",
    redfields = {},
    bluefields = {},
    whitefields = {},
    shouldiconvertballoonnow = false,
    balloondetected = false,
    puffshroomdetected = false,
    magnitude = 60,
    blacklist = {""},
    running = false,
    nowalk = true,
    doingMemoryMatch = false,
    activeMemoryMatch = nil,
    tokenpath = Workspace.Collectibles,
    started = {
        vicious = false,
        mondo = false,
        windy = false,
        ant = false,
        monsters = false,
        crab = false,
        commando = false
    },
    detected = {vicious = false, windy = false},
    tokensfarm = false,
    converting = false,
    consideringautoconverting = false,
    activatingboosters = false,	
    activatingclock = false,
    activatingfreeantpassdispenser = false,	
    activatingfreerobopassdispenser = false,
    activatingonettart = false,
    activatingsnowmachine = false,
    activatingfeast = false,
    activatingsamovar = false,
    activatingstockings = false,
    activatingcandles = false,
    activatingwreath = false,
    donatingtoshrine = false,
    honeystart = statstable.Totals.Honey or 0,
    grib = nil,
    gribpos = CFrame.new(0, 0, 0),
    honeycurrent = player.CoreStats.Honey.Value,
    dead = false,
    float = false,
    pepsigodmode = false,
    alpha = false,
    beta = false,
    myhiveis = false,
    invis = false,
    windy = nil,
    sprouts = {detected = false, coords},
    guiding = {detected = false, coords},
    cache = {
        autofarm = false,
        killmondo = false,
        vicious = false,
        windy = false,
        traincommando = false
    },
    allplanters = {},
    planters = {
        planter = {},
        cframe = {},
        activeplanters = {type = {}, id = {}}
    },
    monstertypes = {
        "Ladybug", "Rhino", "Spider", "Scorpion", "Mantis", "Werewolf"
    },
    coconuts = {},
    crosshairs = {},
    triangle = {token = nil, bee = nil},
    bubbles = {},
    crosshair = false,
    coconut = false,
    act = 0,
    act2 = 0,
    ["touchedfunction"] = function(v)
        if lasttouched ~= v then
            if v.Parent.Name == "FlowerZones" then
                if v:FindFirstChild("ColorGroup") then
                    if tostring(v.ColorGroup.Value) == "Red" then
                        -- print("red field touched")
                        maskequip("Demon Mask")
                    elseif tostring(v.ColorGroup.Value) == "Blue" then
                        maskequip("Diamond Mask")
                    end
                else
                    maskequip("Gummy Mask")
                end
                lasttouched = v
            end
        end
    end,
    runningfor = 0,
    oldtool = updateClientStatCache()["EquippedCollector"],
    ["gacf"] = function(part, st)
        coordd = CFrame.new(part.Position + Vector3.new(0,st,0))
        return coordd
    end,
    lookat = nil,
    currtool = updateClientStatCache()["EquippedCollector"],
    starttime = tick(),
    planting = false,
    crosshaircounter = 0,
    doingbubbles = false,
    doingcrosshairs = false,
    pollenpercentage = 0,
    lastmobkill = 0,
    usegumdropsforquest = false,
    lastgumdropuse = tick(),
    farmingDuped = false,
    pathfinding = {status = false, activeID}
}
debugNextStep(true)

if isfile("Macro v2 discord.txt") == false then
    httpreq({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = HttpService:JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {code = "mv2"},
            nonce = HttpService:GenerateGUID(false)
        }),
        writefile("Macro v2 discord.txt", "discord.gg/mv2")
    })
end
function StringfindInTable(table, string)
    for __,___ in pairs(table) do
        if not ___:find(string) then continue end
        return ___
    end
end

function canToyBeUsed(toy)
    local toy = Workspace.Toys[toy] or nil
    local reqsPassed = false
    local noCooldown = false
    if not toy then return false end
    local requirements = toy:FindFirstChild("Requirements")
    if requirements == nil then
        reqsPassed = true
    end
    setIdentity(2)
    if not reqsPassed then
        reqsPassed = StatReqs.Check(ClientStatCache:Get(), require(requirements))
    end
    if reqsPassed then 
       local _,isRed,__ = ActivatablesToys.ButtonText(nil,toy)
       if not isRed then noCooldown = true end
    end
    setIdentity(7)
    if reqsPassed and noCooldown then return true else return false end
    -- return canbeUsed
end

-- Destroy other macro v2 guis
for i, v in pairs(CoreGui:GetDescendants()) do
    if v:IsA("TextLabel") and v.Text:find("Macro V2 v") then
        v.Parent.Parent:Destroy()
    end
end

debugNextStep("GUI init")

-- Init window
local Config = {
    WindowName = "Macro V2 v"..temptable.version.." Made By Narnia",
    Keybind = Enum.KeyCode.Semicolon
}

Window = library:Init(Config)

debugNextStep(true)

local guiElements = {
    toggles = {},
    vars = {},
    bestfields = {},
    dispensesettings = {}
}

debugNextStep("Loading Home Tab init")

-- Home Tab
local hometab = Window:Tab("Home")
local information = hometab:Section("Information")

local welcomeLabel = information:Label("Loading")
local stopLoadingCycle = false
task.spawn(function()
    local i = 1
    while not stopLoadingCycle do
        local dots = "."
        if i == 2 then dots = dots.."."
        elseif i == 3 then dots = dots..".."
        end
            
        welcomeLabel:Set("Loading"..dots)
        i = i + 1
        if i > 3 then i = 1 end
        wait(.5)
    end
end)
debugNextStep(true)
--[[
    Pathfinding
]]

debugNextStep("Pathfinding init")

local links = {
    startpoints = {
        Honey1Jump = { Coords = CFrame.new(-392.76458740234375, 68.12828826904297, -99.12889099121094), Name = "Honey1Jump"},
        RedHQJump = { Coords = CFrame.new(-250.05044555664062, 4.128303050994873, 202.9126739501953), Name = "RedHQJump"},
        RedCannonJump = { Coords = CFrame.new(-256.6207275390625, 4.777135848999023, 314.4209289550781), Name = "RedCannonJump"},
        Honey2Jump = { Coords = CFrame.new(-401.913818359375, 68.12828063964844, -101.50931549072266), Name = "Honey2Jump"},
        Honey3Jump = { Coords = CFrame.new(-426.5849914550781, 89.42639923095703, -174.0604705810547), Name = "Honey3Jump"},
        -- AntJump = { Coords = CFrame.new(-7.114750385284424, 14.48830795288086, 401.3905944824219), Name = "AntJump"},
        RedJumpBamboo = { Coords = CFrame.new(189.61605834960938, 20.128297805786133, 25.907989501953125), Name = "RedJumpBamboo"},
        RedJumpBamboo2 = { Coords = CFrame.new(201.83340454101562, 34.019710540771484, 24.70005226135254), Name = "RedJumpBamboo2"},
        JumpWedgeScienceBear = { Coords = CFrame.new(293.7715759277344, 68.12828063964844, -96.78761291503906), Name = "JumpWedgeScienceBear"},
        ScienceBearGliderSnow = { Coords = CFrame.new(268.6377868652344, 106.1092529296875, 32.022926330566406), Name = "ScienceBearGliderSnow"},
        DapperJump1 = { Coords = CFrame.new(390.9390563964844, 88.12828063964844, -268.93048095703125), Name = "DapperJump1"},
        DapperJump2 = { Coords = CFrame.new(396.50396728515625, 101.56547546386719, -303.1343994140625), Name = "DapperJump2"},
        DapperJump3 = { Coords = CFrame.new(403.5493469238281, 117.25138092041016, -317.306884765625), Name = "DapperJump3"},
        MushJump1 = { Coords = CFrame.new(-125.74980163574219, 4.12830114364624, 65.03797149658203), Name = "MushJump1"},
        PumpkinJump = { Coords = CFrame.new(-201.61119079589844, 68.12828063964844, -218.94935607910156), Name = "PumpkinJump"},
        PumpkinGlide = { Coords = CFrame.new(-113.4571762084961, 118.12825775146484, -176.8325958251953), Name = "PumpkinGlide"},
        BeeFeastJump = { Coords = CFrame.new(-85.3075180053711, 118.12825775146484, -112.59939575195312), Name = "BeeFeastJump"},
        TopSpawnGlide = { Coords = CFrame.new(2.970102071762085, 141.8545684814453, -66.13165283203125), Name = "TopSpawnGlide"},
        TopStarGlide = { Coords = CFrame.new(100.68426513671875, 176.9151153564453, -70.71910858154297), Name = "TopStarGlide"},
        a35Jump1 = { Coords = CFrame.new(-294.4212341308594, 18.077587127685547, 327.77587890625), Name = "a35Jump1"},
        a35Jump2 = { Coords = CFrame.new(-320.2309875488281, 32.36879348754883, 341.8817443847656), Name = "a35Jump2"},
        TopToPolarJump = { Coords = CFrame.new(-44.73221969604492, 176.1282501220703, -175.81422424316406), Name = "TopToPolarJump"},
        BlueCannonToRoseJump = { Coords = CFrame.new(-310.3309326171875, 68.07828521728516, 40.12779235839844), Name = "BlueCannonToRoseJump"},
        StockingJump = { Coords = CFrame.new(277.6906433105469, 93.4947509765625, 101.02001953125), Name = "StockingJump"},
        BlueFlowersGlide = { Coords = CFrame.new(170.4833526611328, 68.12828826904297, -71.56256103515625), Name = "BlueFlowersGlide"},
        TopToPineappleJump = { Coords = CFrame.new(115.9232406616211, 176.1282501220703, -158.48947143554688), Name = "TopToPineappleJump"},
        MeteorToPine = { Coords = CFrame.new(184.72584533691406, 125.52034759521484, -153.97593688964844), Name = "MeteorToPine"},
        SproutToDispenser = { Coords = CFrame.new(-282.076171875, 27.03758430480957, 276.4190673828125), Name = "SproutToDispenser"},
        CoconutJump1 = { Coords = CFrame.new(-413.0221862792969, 50.168338775634766, 408.8205871582031), Name = "CoconutJump1"},
        CoconutJump2 = { Coords = CFrame.new(-421.0817565917969, 59.679771423339844, 411.73480224609375), Name = "CoconutJump2"},
        CoconutJump3 = { Coords = CFrame.new(-380.97991943359375, 71.5997543334961, 451.66729736328125), Name = "CoconutJump3"},
        CoconutJump4 = { Coords = CFrame.new(-356.1214904785156, 81.55976867675781, 452.3200988769531), Name = "CoconutJump4"},
        CoconutJump5 = { Coords = CFrame.new(-336.0120849609375, 88.59371948242188, 411.4767150878906), Name = "CoconutJump5"},
        CoconutJump6 = { Coords = CFrame.new(-366.8395080566406, 81.55978393554688, 454.1266784667969), Name = "CoconutJump6"},
        CoconutJump7 = { Coords = CFrame.new(-387.9734802246094, 97.6497802734375, 502.697265625), Name = "CoconutJump7"},
        PepperJump1 = { Coords = CFrame.new(-421.1688537597656, 111.07975769042969, 519.884033203125), Name = "PepperJump1"},
        WindJump1 = { Coords = CFrame.new(-480.1778869628906, 123.32979583740234, 471.93603515625), Name = "WindJump1"},
        WindGlide1 = { Coords = CFrame.new(-443.4926452636719, 138.39964294433594, 371.84405517578125), Name = "WindGlide1"},
        SlingJump1 = { Coords = CFrame.new(48.80450439453125, 4.128303050994873, 196.98306274414062), Name = "SlingJump1"},
        SlingJump2 = { Coords = CFrame.new(56.86144256591797, 4.128302574157715, 233.30877685546875), Name = "SlingJump2"},
        SlingJump3 = { Coords = CFrame.new(95.36963653564453, 18.883298873901367, 227.37234497070312), Name = "SlingJump3"},
        SlingJump4 = { Coords = CFrame.new(93.3486328125, 18.883298873901367, 168.15460205078125), Name = "SlingJump4"},
        PandaJump = { Coords = CFrame.new(171.1122283935547, 20.128297805786133, 37.66733932495117), Name = "PandaJump"},
        FlowerDown = { Coords = CFrame.new(223.1501922607422, 33.628292083740234, 137.48019409179688), Name = "FlowerDown"},
        RedCannonJump1 = { Coords = CFrame.new(-209.19407653808594, 12.607428550720215, 340.72650146484375), Name = "RedCannonJump1"},
        RedHQLadder = { Coords = CFrame.new(-366.41717529296875, 20.338668823242188, 237.92361450195312), Name = "RedHQLadder"},
        RileyBeeLadder = { Coords = CFrame.new(-340.0308837890625, 46.117610931396484, 276.07891845703125), Name = "RileyBeeLadder"},
        SlingshotLadder = { Coords = CFrame.new(50.49577713012695, 4.128303050994873, 217.9420928955078), Name = "SlingshotLadder"},
        CloverLadder = { Coords = CFrame.new(90.69090270996094, 18.883298873901367, 180.4346466064453), Name = "CloverLadder"},
        Zone15Ladder = { Coords = CFrame.new(-314.2582092285156, 51.35832214355469, 58.49798583984375), Name = "Zone15Ladder"},
        AntsJump = { Coords = CFrame.new(4.070306777954102, 15.621834754943848, 403.3917236328125), Name = "AntsJump"}
    },
    endpoints = {
        Honey1Jump = { Coords = CFrame.new(-415.7094421386719, 79.4188003540039, -106.78644561767578), Name = "Honey1Jump"},
        RedHQJump = { Coords = CFrame.new(-268.0046081542969, 20.07830047607422, 202.31680297851562), Name = "RedHQJump"},
        RedCannonJump = { Coords = CFrame.new(-254.76805114746094, 17.187585830688477, 324.1759338378906), Name = "RedCannonJump"},
        Honey2Jump = { Coords = CFrame.new(-416.7687072753906, 89.42640686035156, -125.78326416015625), Name = "Honey2Jump"},
        Honey3Jump = { Coords = CFrame.new(-429.4402160644531, 103.29205322265625, -192.71041870117188), Name = "Honey3Jump"},
        -- AntJump = { Coords = CFrame.new(-5.480144500732422, 32.3983039855957, 423.0811462402344), Name = "AntJump"},
        RedJumpBamboo = { Coords = CFrame.new(201.83340454101562, 34.019710540771484, 24.70005226135254), Name = "RedJumpBamboo"},
        RedJumpBamboo2 = { Coords = CFrame.new(224.04989624023438, 48.225135803222656, 27.258071899414062), Name = "RedJumpBamboo2"},
        JumpWedgeScienceBear = { Coords = CFrame.new(317.1413269042969, 81.12190246582031, -97.8780517578125), Name = "JumpWedgeScienceBear"},
        ScienceBearGliderSnow = { Coords = CFrame.new(277.6906433105469, 93.4947509765625, 101.02001953125), Name = "ScienceBearGliderSnow"},
        DapperJump1 = { Coords = CFrame.new(396.50396728515625, 101.56547546386719, -303.1343994140625), Name = "DapperJump1"},
        DapperJump2 = { Coords = CFrame.new(403.5493469238281, 117.25138092041016, -317.306884765625), Name = "DapperJump2"},
        DapperJump3 = { Coords = CFrame.new(423.12664794921875, 131.45603942871094, -331.0450134277344), Name = "DapperJump3"},
        MushJump1 = { Coords = CFrame.new(-125.20164489746094, 20.128297805786133, 56.41190719604492), Name = "MushJump1"},
        PumpkinJump = { Coords = CFrame.new(-202.17745971679688, 83.51397705078125, -228.7169647216797), Name = "PumpkinJump"},
        PumpkinGlide = { Coords = CFrame.new(-202.11380004882812, 68.12828063964844, -181.45944213867188), Name = "PumpkinGlide"},
        BeeFeastJump = { Coords = CFrame.new(-108.22136688232422, 128.49754333496094, -111.26962280273438), Name = "BeeFeastJump"},
        TopSpawnGlide = { Coords = CFrame.new(-115.0983657836914, 4.6092705726623535, 274.37176513671875), Name = "TopSpawnGlide"},
        TopStarGlide = { Coords = CFrame.new(94.41138458251953, 65.25618743896484, 288.9031066894531), Name = "TopStarGlide"},
        a35Jump1 = { Coords = CFrame.new(-321.8291015625, 33.071466827392578, 350.0812683105469), Name = "a35Jump1"},
        a35Jump2 = { Coords = CFrame.new(-334.3596496582031, 45.82585525512695, 348.1188659667969), Name = "a35Jump2"},
        TopToPolarJump = { Coords = CFrame.new(-113.4571762084961, 118.12825775146484, -176.8325958251953), Name = "TopToPolarJump"},
        BlueCannonToRoseJump = { Coords = CFrame.new(-310.2383117675781, 20.078289031982422, 103.38355255126953), Name = "BlueCannonToRoseJump"},
        StockingJump = { Coords = CFrame.new(231.65621948242188, 35.25713348388672, 237.13072204589844), Name = "StockingJump"},
        BlueFlowersGlide = { Coords = CFrame.new(-2.040789842605591, 20.128297805786133, 50.11865234375), Name = "BlueFlowersGlide"},
        TopToPineappleJump = { Coords = CFrame.new(184.72584533691406, 125.52034759521484, -153.97593688964844), Name = "TopToPineappleJump"},
        MeteorToPine = { Coords = CFrame.new(257.364990234375, 68.12828063964844, -152.64593505859375), Name = "MeteorToPine"},
        SproutToDispenser = { Coords = CFrame.new(-299.19561767578125, 46.11760711669922, 297.0304870605469), Name = "SproutToDispenser"},
        CoconutJump1 = { Coords = CFrame.new(-421.0817565917969, 59.679771423339844, 411.73480224609375), Name = "CoconutJump1"},
        CoconutJump2 = { Coords = CFrame.new(-423.28302001953125, 71.5997543334961, 434.0774230957031), Name = "CoconutJump2"},
        CoconutJump3 = { Coords = CFrame.new(-356.1214904785156, 81.55976867675781, 452.3200988769531), Name = "CoconutJump3"},
        CoconutJump4 = { Coords = CFrame.new(-336.0120849609375, 88.5937271118164, 411.4767150878906), Name = "CoconutJump4"},
        CoconutJump5 = { Coords = CFrame.new(-321.2005615234375, 50.1683349609375, 373.90972900390625), Name = "CoconutJump5"},
        CoconutJump6 = { Coords = CFrame.new(-369.1633605957031, 98.03140258789062, 476.6775817871094), Name = "CoconutJump6"},
        CoconutJump7 = { Coords = CFrame.new(-391.943115234375, 111.07977294921875, 514.3994750976562), Name = "CoconutJump7"},
        PepperJump1 = { Coords = CFrame.new(-440.0786437988281, 123.32979583740234, 521.6873779296875),  Name = "PepperJump1"},
        WindJump1 = { Coords = CFrame.new(-478.69305419921875, 138.39964294433594, 446.51275634765625), Name = "WindJump1"},
        WindGlide1 = { Coords = CFrame.new(23.300024032592773, 4.128302097320557, 238.38751220703125), Name = "WindGlide1"},
        SlingJump1 = { Coords = CFrame.new(74.04813385009766, 19.091028213500977, 197.1480255126953), Name = "SlingJump1"},
        SlingJump2 = { Coords = CFrame.new(74.59917449951172, 19.83558464050293, 235.70098876953125), Name = "SlingJump2"},
        SlingJump3 = { Coords = CFrame.new(115.0332260131836, 33.628292083740234, 227.50086975097656), Name = "SlingJump3"},
        SlingJump4 = { Coords = CFrame.new(117.94770812988281, 33.628292083740234, 169.28123474121094), Name = "SlingJump4"},
        PandaJump = { Coords = CFrame.new(155.07400512695312, 35.128292083740234, 37.147090911865234), Name = "PandaJump"},
        FlowerDown = { Coords = CFrame.new(222.7679901123047, 4.128302097320557, 118.0878677368164), Name = "FlowerDown"},
        RedCannonJump1 = { Coords = CFrame.new(-238.68702697753906, 17.603551864624023, 344.2923278808594), Name = "RedCannonJump1"},
        RedHQLadder = { Coords = CFrame.new(-367.9334716796875, 46.117610931396484, 273.14813232421875), Name = "RedHQLadder"},
        RileyBeeLadder = { Coords = CFrame.new(-340.6359558105469, 68.14645385742188, 245.22561645507812), Name = "RileyBeeLadder"},
        SlingshotLadder = { Coords = CFrame.new(68.94750213623047, 18.883298873901367, 217.70068359375), Name = "SlingshotLadder"},
        CloverLadder = { Coords = CFrame.new(113.06523895263672, 33.628292083740234, 180.28797912597656), Name = "CloverLadder"},
        Zone15Ladder = { Coords = CFrame.new(-314.2582092285156, 68.07828521728516, 34.96257019042969), Name = "Zone15Ladder"},
        AntsJump = { Coords = CFrame.new(1.2342126369476318, 32.3962516784668, 430.9694519042969), Name = "AntsJump"}
    }
}

LPH_NO_VIRTUALIZE(function()
function humanoid() return player.Character:FindFirstChild("Humanoid") end
local regionModule = {}

function isInRegion3(region, point)
    local relative = (point - region.CFrame.p) / region.Size
    return -0.5 <= relative.X and relative.X <= 0.5
        and -0.5 <= relative.Y and relative.Y <= 0.5
        and -0.5 <= relative.Z and relative.Z <= 0.5
end

_G.visualize = true
local coststable = {}
local folder = Instance.new("Folder", workspace)
folder.Name = "PathfindLinks"

function CreateLink(p1, p2, name, b)
    if folder:FindFirstChild(name) then return end
    local at1 = Instance.new("Attachment",p1)
    local at2 = Instance.new("Attachment",p2)

    local link = Instance.new("PathfindingLink", folder)
    link.Attachment0 = at1 -- starting point of the link
    link.Attachment1 = at2 -- end point of the link
    link.IsBidirectional = b or false
    link.Label = name
    link.Name = name
end

function StringToCFrame(String)
    local Split = string.split(String, ",")
    return CFrame.new(Split[1],Split[2],Split[3])
end

local originalpart = Instance.new("Part")
originalpart.Parent = game
originalpart.CanCollide = true
originalpart.Transparency = 0
originalpart.Anchored = true
createlinks = function()
    local linksfolder = Instance.new("Folder", workspace)
    linksfolder.Name = "Links"
    local linksend = Instance.new("Folder", linksfolder)
    linksend.Name = "End"
    local linksstart = Instance.new("Folder", linksfolder)
    linksstart.Name = "Start"
    for i, v in pairs(links) do
        for e, r in pairs(v) do
            local clonething = originalpart:Clone() --print('Clone')
            if i == "endpoints" then
                clonething.Name = r["Name"].."End"
                clonething.Parent = linksend
                clonething.Transparency = 1
                local cframe = Instance.new("StringValue", clonething)
                cframe.Value = tostring(r["Coords"] + Vector3.new(0, -2.5, 0))

                clonething.CFrame = StringToCFrame(cframe.Value)
                clonething.Size = Vector3.new(0.3, 0.3, 0.3)
                -- task.spawn(function()
                --     while task.wait() do
                --         clonething.CFrame = StringToCFrame(cframe.Value)
                --         clonething.Size = Vector3.new(0.3, 0.3, 0.3)
                --     end
                -- end)
            elseif i == "startpoints" then
                clonething.Name = r["Name"].."Start"
                clonething.Parent = linksstart
                clonething.Transparency = 1
                local cframe = Instance.new("StringValue", clonething)
                cframe.Value = tostring(r["Coords"] + Vector3.new(0, -2.5, 0))

                clonething.CFrame = StringToCFrame(cframe.Value)
                clonething.Size = Vector3.new(0.3, 0.3, 0.3)
                -- task.spawn(function()
                --     while task.wait() do
                --         clonething.CFrame = StringToCFrame(cframe.Value)
                --         clonething.Size = Vector3.new(0.3, 0.3, 0.3)
                --     end
                -- end)
            end
        end
    end
end

createlinks()

for i, v in pairs(workspace.Links:GetDescendants()) do --print(i, v)
    local StartName = string.gsub(v.Name, "End", "Start")
    if workspace.Links.Start:FindFirstChild(StartName) and v.Parent.Name == "End" then
        CreateLink(workspace.Links.Start[StartName], workspace.Links.End[v.Name], v.Name, false)
        -- print(StartName, v.Name)
        if v.Name:find("Jump") then
            type2 = "Jump" --print('Jump')
            coststable[v.Name] = 0.1
        elseif v.Name:find("Glide") then
            type2 = "Glide" --print('Glide')
            coststable[v.Name] = 0.1
        elseif v.Name:find("Ladder") then
            type2 = "Glide" print('Ladder')
            coststable[v.Name] = 0.1
        elseif v.Name:find("Ban") then
            type2 = "Ban" --print('Ban')
            coststable[v.Name] = math.huge
        end
    end
end

function Noclip()
    api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
end



function Noclip2()
    if not getgenv().noclipnow then return end
    api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
    for i, v in pairs(player.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == true then
            v.CanCollide = false
            local wastrue = Instance.new("Folder", v)
            wastrue.Name = "wastrue"
            api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
        end
    end
end



CreateLink(Workspace.Toys["Gummy Bee Claimer"].GummyModel, Workspace.Toys["Glue Dispenser"].Platform, "GummyLink", false)
CreateLink(Workspace.Toys["Gummy Bee Claimer"].Platform, Workspace.Toys["Gummy Bee Claimer"].GummyModel.Wings, "UpWingGummy", false)
coststable["GummyLink"] = 0.1
coststable["UpWingGummy"] = 0.1

local Ban = Instance.new("Part", workspace)
Ban.Position = Vector3.new(-197.22, 83.67, 398.92)
Ban.Size = Vector3.new(2, 48, 56)
Ban.Anchored = true
Ban.Transparency = 0.9
Ban.Name = "CocoBan1"

local modifier = Instance.new("PathfindingModifier")
modifier.Label = "BanPoint1"
modifier.Parent = Ban

coststable["BanPoint1"] = math.huge

local CaveRegion = Region3.new(Vector3.new(69.03162384033203, 104.25777435302734, -233.6259002685547), Vector3.new(-20.200281143188477, 38.019710540771484, -85.00163269042969))
getgenv().avoidingcave = false
NoclipE2 = RunService.Stepped:Connect(Noclip2)
task.spawn(function()
    while task.wait() do
        if isInRegion3(CaveRegion, api.humanoidrootpart().Position) then
            getgenv().avoidingcave = true
            api.humanoidrootpart().CFrame = CFrame.new(api.humanoidrootpart().Position + Vector3.new(0, 10, 0))
            AntiFall = Instance.new("BodyVelocity", api.humanoidrootpart())
            AntiFall.Velocity = Vector3.new(0, 0, 0)
            AntiFall.Name = "BodyVelocity-Tween"
            getgenv().noclipnow = true
        else
            getgenv().avoidingcave = false
            getgenv().noclipnow = false
            for i, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") and v:FindFirstChild("wastrue") then
                    v.CanCollide = true
                end
            end
            if api.humanoidrootpart():FindFirstChild("BodyVelocity-Tween") then api.humanoidrootpart():FindFirstChild("BodyVelocity-Tween"):Destroy() end
        end
    end
end)

local regionModule = {}
function regionModule.getRegion(pos)
    local slingShotRegion = Region3.new(Vector3.new(134.365, 202.5, 23.5), Vector3.new(749.365, 65.5, -458.5))
    local redCannonRegion = Region3.new(Vector3.new(-406.5, 318.5, -64.735), Vector3.new(641.5, 61.5, -599.735))
    local bluePortalReggion = Region3.new(Vector3.new(-36.522, 150.559, 697.671), Vector3.new(-200.522, 13.559, 300.671))
    local redPortalRegion = Region3.new(Vector3.new(700.5, 204.5, -508.5), Vector3.new(128.5, -22.5, 336.5))
    
    local regions = {}
    
    if isInRegion3(slingShotRegion, pos) then table.insert(regions,{Position = Workspace.Toys["Slingshot"].Platform.Position, Toy = "Slingshot"}) end
    if isInRegion3(redCannonRegion, pos) then table.insert(regions,{Position = Workspace.Toys["Red Cannon"].Platform.Position, Toy = "Red Cannon"}) end
    if isInRegion3(bluePortalReggion, pos) then table.insert(regions,{Position = Workspace.Toys["Blue Portal"].Platform.Position, Toy = "Blue Portal"}) end
    if isInRegion3(redPortalRegion, pos) then table.insert(regions,{Position = Workspace.Toys["Red Portal"].Platform.Position, Toy = "Red Portal"}) end
    local nearest = nil
    if #regions > 0 then
        for _,v in pairs(regions) do
            if not nearest then
                nearest = v
            else
                local hrp = api.humanoidrootpart()
                if (hrp.Position - v.Position).magnitude < (hrp.Position - nearest.Position).magnitude then
                    nearest = v
                end
            end
        end
    end
    --print("Regions: ")
    --print(regions)
    --print("And nearest :")
    --print(nearest)
    return nearest or nil
end

for _,v in pairs(Workspace.MonsterBarriers:GetChildren()) do
    v.CanCollide = false
end

for _,v in pairs(Workspace.Paths:GetChildren()) do
    v.CanCollide = false
end

function pressButton(button)
    VirtualInputManager:SendKeyEvent(true, button, false, game)
    RunService.Heartbeat:Wait()
    VirtualInputManager:SendKeyEvent(false, button, false, game)
end

pathfinding = {regionModule = regionModule}

local currentTween

function pathfinding.Tween(Time, Object, canTeleport)
    if player.Character.Humanoid.Health == 0 then return nil end
    if currentTween then currentTween:Cancel() end
    temptable.tweening = true
    if Object then
        local Info = TweenInfo.new((api.humanoidrootpart().Position - Object).Magnitude / Time, Enum.EasingStyle.Linear)
        local Tween = TweenService:Create(api.humanoidrootpart(), Info, {CFrame = CFrame.new(Object)})
        currentTween = Tween
        if not api.humanoidrootpart():FindFirstChild("BodyVelocity-Tween") then
            AntiFall = Instance.new("BodyVelocity", api.humanoidrootpart())
            AntiFall.Velocity = Vector3.new(0, 0, 0)
            AntiFall.Name = "BodyVelocity-Tween"
            NoclipE = RunService.Stepped:Connect(Noclip)
        end
        paused = false
        task.spawn(function()
            while task.wait() do
                if getgenv().avoidingcave and not paused then
                    Tween:Pause()
                    paused = true
                elseif paused and not getgenv().avoidingcave and (Object - api.humanoidrootpart().Position).Magnitude > 10 then
                    Tween:Play()
                    pasued = false
                elseif (Object - api.humanoidrootpart().Position).Magnitude < 6 then
                    Tween:Cancel()
                    AntiFall:Destroy()
                    NoclipE:Disconnect()
                    break
                end
            end
        end)

        Tween:Play()
        local isCompleted = Tween.Completed:Wait(15)
        if not isCompleted then 
            if not canTeleport then
                pathfinding.Tween(Time, Object, true)
            else
                api.humanoidrootpart().CFrame = CFrame.new(Object)
            end
        end
        -- Tween.Completed:Connect(function()
        AntiFall:Destroy()
        NoclipE:Disconnect()
        -- end)
        task.wait()
        temptable.tweening = false
    end
end

function ComputePath(startGoal, endGoal)
    local Path
    local RetriesLeft = 1 -- 20 retries
    local RetryInterval = 0 -- delay 3 seconds each time it fails
    for i = RetriesLeft, 1, -1 do
        Path = PathfindingService:CreatePath({Costs = coststable, AgentCanJump = true, WaypointSpacing = 10, AgentRadius = 3})
        pcall(function()
            Path:ComputeAsync(startGoal, endGoal)
        end)
        if Path.Status == Enum.PathStatus.Success then
            return Path
        else
            return nil
            --warn("Path failed to compute, retrying...")
            --task.wait(RetryInterval)
        end
    end

    warn("Path failed to compute.") --  this will be ran when the for loop is finished, or when all the retries failed.
end

tries = 0

function pathfinding.followPath(endGoal, usedToy)
    if player.Character.Humanoid.Health == 0 then return "Humanoid.Health is 0" end
    if not macrov2.toggles.pathfind then return "toggles.pathfind is false" end
    print("pf-ok1")
    --print(endGoal)
    setIdentity(7)
    local startGoal = api.humanoidrootpart().Position
    -- print(typeof(startGoal), typeof(endGoal))
    -- print(endGoal)
    local canSkip = false
    local Path = ComputePath(startGoal, endGoal)
    print(1)

    local walkDistance = 0
    if Path then 
        player.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
        temptable.pathfinding.status = true
        local points = Path:GetWaypoints()
        for _,v in pairs(points) do
            if _ ~= #Path:GetWaypoints() then
                walkDistance = walkDistance + (v.Position - points[_+1].Position).magnitude
            end
        end
    end
    local cannonDistance = 0
    local secondCannonDisctance = 0
    local pointRegion = regionModule.getRegion(endGoal)
    --print(#pointRegions, endGoal)
    -- print(2)

    if pointRegion then
        local PathToCannon = ComputePath(startGoal, pointRegion.Position)
        if PathToCannon then
            -- warn("No path to cannon")
            for _,v in pairs(PathToCannon:GetWaypoints()) do
                if _ ~= #PathToCannon:GetWaypoints() then
                    cannonDistance = cannonDistance + (v.Position - PathToCannon:GetWaypoints()[_+1].Position).magnitude
                end
            end
        end
    end
    -- print(3)
    if cannonDistance ~= 0 and cannonDistance < walkDistance then
        -- print(pointRegion.Toy)
        -- print(pointRegion)
        if canToyBeUsed(pointRegion.Toy) then
            pathfinding.followPath(pointRegion.Position, true)
            task.wait()
            if pointRegion.Toy:find('Portal') and (pointRegion.Position - api.humanoidrootpart().Position).Magnitude <= 10 and ((pointRegion.Position * Vector3.new(0, 1, 0)) - (api.humanoidrootpart().Position * Vector3.new(0, 1, 0))).Magnitude <= 5 then
                domapi.callEvent("ToyEvent", pointRegion.Toy)
            elseif (pointRegion.Position - api.humanoidrootpart().Position).Magnitude <= 10 and ((pointRegion.Position * Vector3.new(0, 1, 0)) - (api.humanoidrootpart().Position * Vector3.new(0, 1, 0))).Magnitude <= 5 then
                domapi.callEvent("ToyEvent", pointRegion.Toy)
                require(Workspace.Toys[pointRegion.Toy].ClientEffect)()
            end
            local toWait = 2
            if pointRegion.Toy == "Red Cannon" then
                toWait = 2
            end
            task.wait(toWait)
            -- print(endGoal)
            pathfinding.followPath(endGoal, true)
            return
        else
            warn("You cannot use "..pointRegion.Toy)
            pathfinding.Tween(60, endGoal + Vector3.new(0,3,0))
        end
    end
    -- print(4)
    -- setting up path properties
    if not Path then
        warn("Path not found, using tween instead pathfinding.")
        pathfinding.Tween(60, endGoal + Vector3.new(0,3,0))
        temptable.pathfinding.status = false
        player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
        return task.wait()
    end
    local Waypoints = Path:GetWaypoints()
    -- print(5)
    if _G.visualize then
        if not Workspace:FindFirstChild("Points") then
            local a = Instance.new("Folder", Workspace)
            a.Name = "Points"
        end
        for _,v in pairs(workspace.Points:GetChildren()) do
            v:Destroy()
        end
        local oldPart
        for i, point in ipairs(Waypoints) do
            local visualWaypoint = Instance.new("Part")
            visualWaypoint.Size = Vector3.new(0.3, 0.3, 0.3)
            visualWaypoint.Anchored = true
            visualWaypoint.CanCollide = false
            visualWaypoint.Material = Enum.Material.Neon
            visualWaypoint.Shape = Enum.PartType.Ball
            visualWaypoint.Parent = workspace.Points
            visualWaypoint.Position = point.Position
            visualWaypoint.Color = Color3.fromRGB(255, 139, 0)
            Instance.new("Attachment", Part)
            visualWaypoint.Name = i
            oldPart = Part
        end
        local distance = 0
        local points = workspace.Points:GetChildren()
        for _,v in pairs(points) do
            if _ ~= #workspace.Points:GetChildren() then
                distance = distance + (v.Position - points[_+1].Position).magnitude
            end
        end
    end
    index = 0
    function deleteOldVisual()
        for i, v in pairs(workspace.Points:GetChildren()) do
            if tonumber(v.Name) < index then
                v:Destroy()
            end
        end
    end

    -- print(6)
    index = 0
    -- domapi.catchData(Waypoints, "json")
    for _, waypoint in ipairs(Waypoints) do
        local playerHumanoid = humanoid()
        deleteOldVisual()
        if not macrov2.toggles.pathfind then 
            temptable.pathfinding.status = false
            player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
            return pathfinding.Tween(waypoint.Position) 
        end
        index += 1

        if waypoint.Label:find("Jump") then
            task.wait(0.4)
            player.Character.Humanoid.Jump = true
            task.wait(0.05)
            if #Waypoints > index+1 then
                playerHumanoid:MoveTo(Waypoints[index+1].Position)
            else
                playerHumanoid:MoveTo(waypoint.Position)
            end
        end
        -- warn(waypoint.Label or "nothing")
        if waypoint.Label:find("Ladder") then
            print("Using ladder")
            task.wait(0.15)
            playerHumanoid.Jump = true
            task.wait(0.01)
            if #Waypoints > index+1 then
                playerHumanoid:MoveTo(Waypoints[index+1].Position)
            else 
                playerHumanoid:MoveTo(waypoint.Position)
            end
        end
        --[[if waypoint.Label:find("Jump") and waypoint.Label:find("Tripple") then
            player.Character.Humanoid.Jump = true
            task.spawn(function()
                if #Waypoints > index+1 then
                    humanoid():MoveTo(Waypoints[index+1].Position)
                else humanoid():MoveTo(waypoint.Position)
                end
            end)
            task.wait(0.2)
            player.Character.Humanoid.Jump = true
            task.wait(0.2)
            player.Character.Humanoid.Jump = true
        end]]
        if waypoint.Label:find("Glide") then
            player.Character.Humanoid.Jump = true
            task.wait(0.5)
            player.Character.Humanoid.Jump = true
            playerHumanoid:MoveTo(Waypoints[index+1].Position)
            if not playerHumanoid.MoveToFinished:Wait(2) then
                pathfinding.followPath(Waypoints[#Waypoints].Position)
                break
            end
        end
        --print(waypoint)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            playerHumanoid.Jump = true
        end
        playerHumanoid:MoveTo(waypoint.Position)
        local timeOut = playerHumanoid.MoveToFinished:Wait(1)
        if not timeOut then
            if temptable.dead then
                temptable.pathfinding.status = false
                player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
                return 
            end
            print("Timed out!")
            if tries < 3 then
                tries += 1
                playerHumanoid.Jump = true
                print(tostring(3 - tries), " left")
                pathfinding.followPath(endGoal)
                break
            else
                tries = 0
                pathfinding.Tween(endGoal)
                break
            end
        end
    end
    -- print(7)
    print("Path reached")
    temptable.pathfinding.status = false
    player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
    setIdentity(7)
end

moveTo = function(pos)
    print('MoveTo Called')
    if player.Character.Humanoid.Health == 0 then return nil end
    if typeof(pos) == "CFrame" then pos = pos.p end
    if macrov2.vars.movingtype == "Tween" then
        pathfinding.Tween(60, pos)
    elseif macrov2.vars.movingtype == "Pathfinding" then
        print("Trying to pathfind to ", pos)
        local pathfindResponse = pathfinding.followPath(pos)
        if pathfindResponse then warn("[Pathfinding]:", pathfindResponse) end
    end
end
end)()

debugNextStep(true)

rareidlist = {}

function updateRareIdList()
    table.clear(rareidlist)
    for i, v in pairs(macrov2.rares) do
        local rare, rareError = getItemByName(v)
        local rareTexture = rare and rare.Icon
        local tokenid = string.gsub(rareTexture, "%D+", "")
        if rareTexture and not table.find(rareidlist, rareTexture) then
            table.insert(rareidlist, tostring(tokenid))
        end
    end
end

-- Important Functions
function api:pressButton(button)
	VirtualInputManager:SendKeyEvent(true, button, false, game)
	RunService.Heartbeat:Wait()
	VirtualInputManager:SendKeyEvent(false, button, false, game)
end

-- Masks --
-- init masks table
maskstable = {}
for i,v in pairs(Accessories.GetTypes()) do
    if v.Slot == "Hat" then
       table.insert(maskstable, i) 
    end
 end

-- masks functions
getPartInModel = function(model)
    if not model then return "model is Nil" end
    for i, v in pairs(model:GetChildren()) do
        if v:IsA("Part") then
            return v
        end
    end
end

function maskequip(mask)
    if updateClientStatCache()["EquippedAccessories"]["Hat"] == mask then return end
    if not checkMask({Type = mask}, ClientStatCache:Get()) then return end
    for i, v in pairs(maskstable) do
        if mask == v then
            for r, e in pairs(workspace.Shops:GetDescendants()) do
                if e.Name == mask and e.Parent and e.Parent.Parent and e.Parent.Parent.Name == i then
                    moveTo(getPartInModel(e).Position)
                    ReplicatedStorage.Events.ItemPackageEvent:InvokeServer("Equip", {
                        Mute = false,
                        Type = mask,
                        Category = "Accessory"
                    })
                    break
                end
            end
        end
    end
end

-- Tools
-- tools table init
local toolstable = 
{
    ["BasicShop"] = {
        "Scooper",
        "Rake",
        "Clippers",
        "Magnet",
        "Vaccum"
    },
    ["ProShop"] = {
        "Super-Scooper",
        "Pulsar",
        "Electro-Magnet",
        "Scissors",
        "Honey Dipper"
    },
    ["Mountaintop"] = {
        "Golden Rake",
        "Spark Staff",
        "Porcelain Dipper"
    },
    ["BlueHQ"] = {
        "Bubble Wand",
        "Tide Popper"
    },
    ["RedHQ"] = {
        "Scythe",
        "Dark Scythe"
    },
    ["Petal Shop"] = {
        "Petal Wand"
    },
    ["GummyBearShop"] = {
        "Gummy Baller"
    }
}

-- tools functions
function equiptool(tool)
    if updateClientStatCache()["EquippedCollector"] == tool then return end
    if not checkTool({Type = tool}, ClientStatCache:Get()) then return end
    for i, v in pairs(toolstable) do
        if table.find(v, tool) then
            for r, e in pairs(Workspace.Shops:GetDescendants()) do
                if e.Name == tool and e.Parent and e.Parent.Parent and e.Parent.Parent.Name == i then
                    moveTo(e.Position)
                    ReplicatedStorage.Events.ItemPackageEvent:InvokeServer("Equip", {
                        Mute = true,
                        Type = tool,
                        Category = "Collector"
                    })
                    break
                end
            end
        end
    end
end

-- Get Player Items Function
function GetItemListWithValue()
    return ClientStatCache:Get("Eggs")
end

-- Sort items and tokens to make it easier to use
local Items = EggTypes.GetTypes()

local FormattedItems = {FullData = {}, NamesOnly = {}}

EggItems = {}

task.spawn(function()
    for i,v in pairs(Items) do
        if not v.Hidden then
            if v.DisplayName then
                local succ,err = pcall(function()
                    HttpService:JSONEncode(v)
                end)
                if succ then
                    v["SystemName"] = i
                    FormattedItems["FullData"][v.DisplayName] = v
                    table.insert(FormattedItems["NamesOnly"], v.DisplayName)
                    table.insert(EggItems, v.DisplayName)
                end
            end
        end
    end
    for i,v in pairs(ReplicatedStorage.Collectibles:GetChildren()) do
        if v:IsA("ModuleScript") then
            if v:FindFirstChild("Icon") then
                FormattedItems["FullData"][v.Name] = {Icon = tostring(v.Icon.Texture)}
                table.insert(FormattedItems["NamesOnly"], v.Name)
                if v:FindFirstChild("IconPlus") then
                    FormattedItems["FullData"][v.Name.."Plus"] = {DisplayName = v.Name, Icon = tostring(v.IconPlus.Texture)}
                    table.insert(FormattedItems["NamesOnly"], v.Name.."Plus")
                end
            end
        end
    end
    for i,v in pairs(ReplicatedStorage.Buffs:GetChildren()) do
        if v.Name:find("Icon") then
            local tokenName = v.Name:gsub(" Icon", "")
            -- print(tokenName, v.Texture)
            FormattedItems["FullData"][tokenName] = {DisplayName = tokenName, Icon = tostring(v.Texture)}
            table.insert(FormattedItems["NamesOnly"], tokenName)
        end
    end
end)

function getItemByName(name)
    if not table.find(FormattedItems["NamesOnly"],name) then return nil, name.." not found in the NamesOnly list" end
    for i,v in pairs(FormattedItems["FullData"]) do
        if v.DisplayName == name then
            return v
        end
    end
    return nil, "Not found full data of "..name
end
local hiveClaimed = false
if not player:FindFirstChild("Honeycomb") then
    hiveClaimed = false
    debugNextStep("Claim hive")
end

-- Claim Hive
while not player:FindFirstChild("Honeycomb") do task.wait(1)
    for i = -8, -1 do
        for i2,v in pairs(Workspace.Honeycombs:GetChildren()) do
            if v and string.find(v.Name, tostring(string.gsub(i, "-", ""))) then
                if v:FindFirstChild("Owner").Value then continue end
                if not player:FindFirstChild("Honeycomb") then
                    repeat
                        moveTo(v:FindFirstChild("SpawnPos").Value.p)
                        if (v:FindFirstChild("SpawnPos").Value.p - api.humanoidrootpart().Position).Magnitude < 10 then
                            api:pressButton("E")
                        end
                        task.wait()
                    until v:FindFirstChild("Owner").Value or player:FindFirstChild("Honeycomb")
                end
            end
        end
    end
end

local plrHive = player:FindFirstChild("Honeycomb").Value
if not hiveClaimed and plrHive then
    hiveClaimed = true
    debugNextStep(true)
end

debugNextStep("Important values init, part 1")

function hideUserName(bool)
    if bool then
        local hiddenName = maskString(player.Name)
        if plrHive then
            plrHive.Display.Gui.Frame.OwnerName.Text = hiddenName
            for i,v in pairs(Workspace.HivePlatforms:GetChildren()) do
                if v.Hive.Value == plrHive then
                    v.Circle.SurfaceGui.TextLabel.Text = hiddenName
                end
            end
        end
        player.Name = hiddenName
        player.DisplayName = maskString(player.DisplayName)
    else
        if plrHive then
            plrHive.Display.Gui.Frame.OwnerName.Text = originalPlayerName
            for i,v in pairs(Workspace.HivePlatforms:GetChildren()) do
                if v.Hive.Value == plrHive then
                    v.Circle.SurfaceGui.TextLabel.Text = originalPlayerName
                end
            end
        end
        player.Name = originalPlayerName
        player.DisplayName = originalPlayerDisplayName
    end
end
task.spawn(function()
    hideUserName(false)
end)

function getNearestRareInField(field)
    local smallest;
    for i, v in pairs(tokenpath:GetChildren()) do
        local tokenid = string.gsub(v:FindFirstChildOfClass("Decal").Texture, "%D+", "")
        if table.find(rareidlist, tostring(tokenid)) and findField(v.Position) and findField(api.humanoidrootpart().Position) and findField(v.Position).Name == findField(api.humanoidrootpart().Position).Name then
            dist = (v.Position - api.humanoidrootpart().Position).Magnitude
            if not smallest then smallest = dist continue end
            if smallest > dist then
                smallest = dist
                toreturn = v
                continue
            end
        end
    end
    return toreturn
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- init Monster Spawners
for i, v in pairs(monsterspawners:GetDescendants()) do
    if v.Name == "TimerAttachment" then v.Name = "Attachment" end
end
for i, v in pairs(monsterspawners:GetChildren()) do
    if v.Name == "RoseBush" then
        v.Name = "ScorpionBush"
    elseif v.Name == "RoseBush2" then
        v.Name = "ScorpionBush2"
    end
end

-- init important tables below
for i, v in pairs(Workspace.FlowerZones:GetChildren()) do
    if v:FindFirstChild("ColorGroup") then
        if v:FindFirstChild("ColorGroup").Value == "Red" then
            table.insert(temptable.redfields, v.Name)
        elseif v:FindFirstChild("ColorGroup").Value == "Blue" then
            table.insert(temptable.bluefields, v.Name)
        end
    else
        table.insert(temptable.whitefields, v.Name)
    end
end

-- init bees table
-- local BeeTable = BeeTypes.GetTypes()

local flowertable = {}
local collectorstable = {}
local fieldstable = {}
local toysTable = {}
local spawnerstable = {}
local accesoriestable = {}
local donatableItemsTable = {}
local treatsTable = {}


for i, v in pairs(Workspace.Flowers:GetChildren()) do
    table.insert(flowertable, v.Position)
end

for i, v in pairs(getupvalues(Collectors.Exists)) do
    for k, e in pairs(v) do table.insert(collectorstable, k) end
end

for i, v in pairs(Workspace.FlowerZones:GetChildren()) do
    table.insert(fieldstable, v.Name)
end

for i, v in pairs(Workspace.Toys:GetChildren()) do
    table.insert(toysTable, v.Name)
end

for i, v in pairs(monsterspawners:GetChildren()) do
    table.insert(spawnerstable, v.Name)
end

for i, v in pairs(Accessories.GetTypes()) do
    if not v.Restricted then
        table.insert(accesoriestable,i)
    end
end

for i, v in pairs(PlanterTypes.GetTypes()) do
    if v.Description ~= "Test planter." then
       table.insert(temptable.allplanters, i) 
    end
end

for i, v in pairs(Items) do
    if v.DonatableToWindShrine == true then
        table.insert(donatableItemsTable, i)
    end
end

for i, v in pairs(Items) do 
    if v.TreatValue then 
        table.insert(treatsTable, i) 
    end 
end
local buffTable = {
    ["Blue Extract"] = {b = false, DecalID = "2495936060"},
    ["Red Extract"] = {b = false, DecalID = "2495935291"},
    ["Oil"] = {b = false, DecalID = "2545746569"}, -- ?
    ["Enzymes"] = {b = false, DecalID = "2584584968"},
    ["Glue"] = {b = false, DecalID = "2504978518"},
    ["Glitter"] = {b = false, DecalID = "2542899798"},
    ["Tropical Drink"] = {b = false, DecalID = "3835877932"}
}

local DropdownPlanterTable = {
    "Plastic Planter",
    "Candy Planter",
    "Red Clay Planter",
    "Blue Clay Planter",
    "Paper Planter",
    "Tacky Planter",
    "Pesticide Planter",
    "Heat-Treated Planter",
    "Hydroponic Planter",
    "Petal Planter",
    "The Planter Of Plenty",
    "None"
}

-- Sort tables
table.sort(fieldstable)
table.sort(accesoriestable)
table.sort(toysTable)
table.sort(spawnerstable)
table.sort(maskstable)
table.sort(temptable.allplanters)
table.sort(collectorstable)
table.sort(donatableItemsTable)
table.sort(buffTable)

local DropdownFieldsTable = deepcopy(fieldstable)
for i,v in pairs(DropdownFieldsTable) do
    if v == "Ant Field" then
        table.remove(DropdownFieldsTable, i)
    end
end
table.insert(DropdownFieldsTable, "None")

-- float pad
local floatpad = Instance.new("Part", Workspace)
floatpad.CanCollide = false
floatpad.Anchored = true
floatpad.Transparency = 1
floatpad.Name = "FloatPad"

-- cococrab
local cocopad = Instance.new("Part", Workspace)
cocopad.Name = "Coconut Part"
cocopad.Anchored = true
cocopad.Transparency = 1
cocopad.Size = Vector3.new(135, 1, 100)
cocopad.CanCollide = false
cocopad.Position = Vector3.new(-266.52117919922, 105.11863250732, 480.46791992188)

-- mondopad
local mondopad = Instance.new("Part", Workspace)
mondopad.Name = "Mondo Part"
mondopad.Anchored = true
mondopad.Transparency = 1
mondopad.Size = Vector3.new(10, 1, 10)
mondopad.Position = Vector3.new(76.8657761,215.084152,-163.525879)

-- antfarm
local antpart = Instance.new("Part", workspace)
antpart.Name = "Ant Autofarm Part"
antpart.Position = Vector3.new(96, 47, 553)
antpart.Anchored = true
antpart.Size = Vector3.new(128, 1, 50)
antpart.Transparency = 1
antpart.CanCollide = false

debugNextStep(true)

debugNextStep("Important values init, part 2")

-- More important functions
function addcommas(num)
    local str = tostring(num):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if str:sub(1,1) == "," then
        str = str:sub(2)
    end
    return str
end

function parseInt(name)
    return tonumber(string.match(name, '%d[%d.,]*'))
end

function formatModule(name)
    return "["..name.."]:"
end

function truncatetime(sec)
    local second = tostring(sec%60)
    local minute = tostring(math.floor(sec / 60 - math.floor(sec / 3600) * 60))
    local hour = tostring(math.floor(sec / 3600))
    
    return (#hour == 1 and "0"..hour or hour)..":"..(#minute == 1 and "0"..minute or minute)..":"..(#second == 1 and "0"..second or second)
end

function truncate(num)
    num = tonumber(math.round(num))
    if num <= 0 then
        return 0
    end
    local savenum = ""
    local i = 0
    local suff = ""
    local suffixes = {"k","M","B","T","qd","Qn","sx","Sp","O","N"}
    local length = math.floor(math.log10(num)+1)
    while num > 999 do
        i = i + 1
        suff = suffixes[i] or "???"
        num = num/1000
        savenum = (math.floor(num*100)/100)..suff
    end
    if i == 0 then
        return num
    end
    return savenum
end

-- webhook functions and vars
local npcIconsEndpoint = "https://static.wikia.nocookie.net/bee-swarm-simulator/images/"
local npcsIcons = {
    ["Polar Bear"]   = npcIconsEndpoint.."d/d4/Polarcloseup.png",
    ["Bucko Bee"]    = npcIconsEndpoint.."3/3d/GiftedBuckoBeeNPCTransparent.png",
    ["Black Bear"]   = npcIconsEndpoint.."c/c2/Blackcloseup.png",
    ["Mother Bear"]  = npcIconsEndpoint.."1/15/Mothercloseup.png",
    ["Brown Bear"]   = npcIconsEndpoint.."3/33/Browncloseup.png",
    ["Panda Bear"]   = npcIconsEndpoint.."a/a0/Pandacloseup.png",
    ["Science Bear"] = npcIconsEndpoint.."d/d5/Sciencecloseup.png",
    ["Dapper Bear"]  = npcIconsEndpoint.."8/89/Dapperbearface.png",
    ["Spirit Bear"]  = npcIconsEndpoint.."2/24/Spiritcloseup.png",
    ["Riley Bee"]    = npcIconsEndpoint.."b/b0/GiftedRileyBeeNPCTransparent.png"
}

local nectarEmojis = {
    ["Refreshing Nectar"]   = "<:Refreshing:1080956994070007818>",
    ["Invigorating Nectar"] = "<:Invigorating:1080967902800392354>",
    ["Comforting Nectar"]   = "<:Comforting:1080968750888652960>",
    ["Motivating Nectar"]   = "<:Motivating:1080969173536096357>",
    ["Satisfying Nectar"]   = "<:Satisfying:1080969460288073748>"
}

local plantersEmojis = {
    ["Paper Planter"]         = "<:PaperPlanter:1084965375965405265>",
    ["Ticket Planter"]        = "<:TicketPlanter:1084965386757345361>",
    ["Festive Planter"]       = "<:FestivePlanter:1084965370579914854>",
    ["Plastic Planter"]       = "<:PlasticPlanter:1084965381711597598>",
    ["Candy Planter"]         = "<:CandyPlanter:1084965368147226716>",
    ["Red Clay Planter"]      = "<:RedClayPlanter:1084965382911168583>",
    ["Blue Clay Planter"]     = "<:BlueClayPlanter:1084950550946250833>",
    ["Tacky Planter"]         = "<:TackyPlanter:1084965385222246470>",
    ["Pesticide Planter"]     = "<:PesticidePlanter:1084965377727025372>",
    ["Petal Planter"]         = "<:PetalPlanter:1084965380394598500>",
    ["Heat-Treated Planter"]  = "<:HeatTreatedPlanter:1084950774989213797>",
    ["Hydroponic Planter"]    = "<:HydroponicPlanter:1084965372442198177>",
    ["The Planter Of Plenty"] = "<:ThePlanterOfPlenty:1084950301393567854>",
}

function webhookFieldsList()
    local timepassed = math.round(tick() - temptable.starttime)
    local honeygained = temptable.honeycurrent - temptable.honeystart

    local totalhoneystring = truncate(temptable.honeycurrent)
    local honeygainedstring = truncate(honeygained)
    local honeyperhourstring = truncate(math.floor(honeygained / timepassed) * 3600)

    if not macrov2.toggles.webhookonlytruncated then
        totalhoneystring = addcommas(temptable.honeycurrent).." ("..totalhoneystring..")"
        honeygainedstring = addcommas(honeygained).." ("..honeygainedstring..")"
        honeyperhourstring = addcommas(math.floor(honeygained / timepassed) * 3600).." ("..honeyperhourstring..")"
    end

    local uptimestring = truncatetime(timepassed)
    -- local ListAll = GetItemListWithValue()
    local fields = {}

    if macrov2.toggles.webhookshowtotalhoney then
        table.insert(fields, {
            ["name"] = "Total Honey:",
            ["value"] = totalhoneystring,
            ["inline"] =  false
        })
    end
    table.insert(fields, {
        ["name"] = "Session Honey:     ",
        ["value"] = honeygainedstring,
        ["inline"] =  true
    })
    table.insert(fields, {
        ["name"] = "Session Uptime:",
        ["value"] = uptimestring,
        ["inline"] =  true
    })
    if macrov2.toggles.webhookshowhoneyperhour then
        table.insert(fields, {
            ["name"] = "Honey per hour:",
            ["value"] = honeyperhourstring,
            ["inline"] =  false
        })
    end
    if macrov2.toggles.webhooknectars then
        local nectars = getAllNectar(true)
        local nectarsString = ""
        for index, nectar in pairs(nectars) do
            if nectar.time == 0 then continue end
            nectarsString = nectarsString..""..(nectarEmojis[nectar.name] or nectar.name..":").." "..nectar.time
            nectarsString = nectarsString.."\n"
        end
        if #nectarsString > 1 then
            table.insert(fields, {
                ["name"] = "Nectars:",
                ["value"] = nectarsString,
                ["inline"] =  false
            })
        end
    end
    if macrov2.toggles.webhookshowplanters then
        local plantersString = ""
        local minePlanters = getMinePlanters()
        for i,v in pairs(minePlanters) do
            plantersString = plantersString..""..plantersEmojis[v.PotModel.Name].." "..math.floor(v.GrowthPercent*1000)/10 .. "%\n"
        end
        if plantersString ~= "" then
            table.insert(fields, {
                name = "Active Planters",
                value = plantersString,
                inline = false
            })
        end
    end
    if macrov2.toggles.webhookitems then
        local itemsString = ""
        for index, item in pairs(macrov2.webhookitems) do
            local systemItem = getItemByName(item)
            if systemItem and systemItem.SystemName then 
                local systemName = systemItem.SystemName
                local count = GetItemListWithValue()[systemName] or 0
                itemsString = itemsString .. item .. ": **" .. tostring(count) .. "**\n"
            end
        end
        if itemsString ~= "" then
            table.insert(fields, {
                name = "Items",
                value = itemsString,
                inline = false
            })
        end
    end
    return fields
end

function generateWebhookBody(settings)
    local body = {
        ["username"] = player.Name,
        ["avatar_url"] = playerAvatarUrl,
        ["content"] = settings.content or "",
        ["embeds"] = {{
            ["title"] = "**"..settings.embedTitle.."**",
            ["description"] = settings.embedDescription or "",
            ["type"] = "rich",
            ["color"] = tonumber(settings.color) or tonumber(macrov2.vars.webhookcolor),
            ["thumbnail"] = {url = settings.thumbnail or "https://cdn.discordapp.com/icons/1024873171867942933/a_6704e7f2ca7cee2f8b9ea7a90891cf57.gif?size=96"},
            ["fields"] = settings.fields or {},
            ["footer"] = {
                ["text"] = os.date("%x").." • "..os.date("%I")..":"..os.date("%M")..":"..os.date("%S").." "..os.date("%p")
            }
        }}
    }
    return body
end

function sendWebhook(body)
    local headers = {
        ["content-Type"] = "application/json"
    }
    httpreq({
        Url = macrov2.vars.webhookurl, 
        Body = HttpService:JSONEncode(body), 
        Method = "POST", 
        Headers = headers
    })
end

function questWebhook(quest,fields)
    local thumbnail = npcsIcons[quest]
    local data = generateWebhookBody({
        embedTitle = "Macro v2 | Quests",
        thumbnail = thumbnail,
        fields = fields
    })
    sendWebhook(data)
end

function disconnected(hook, discordid, reason)
    local discordMention = ""
    if discordid then discordMention = "<@"..tostring(discordid)..">" end

    local whookfields = {}
    table.insert(whookfields, {
        ["name"] = "Reason:",
        ["value"] = reason,
        ["inline"] =  false
    })
    table.insert(whookfields, webhookFieldsList())

    local data = generateWebhookBody({
        content = discordMention..(reason == "Server Timeout (Game Freeze)" and "Freeze" or "Kick"),
        embedTitle = "Disconnect Detected",
        color = 0xff0202,
        fields = whookfields
    })

    sendWebhook(data)
end

function hourly(ping, hook, discordid)
    local discordMention = ""
    if discordid then discordMention = "<@"..tostring(discordid)..">" end

    local data = generateWebhookBody({
        content = ping and discordMention.."Honey Update" or "Honey Update",
        embedTitle = "Honey Update",
        fields = webhookFieldsList()
    })

    print("sending webhook")
    sendWebhook(data)
end

getgenv().sendHourlyWebhook = function()
    local data = generateWebhookBody({
        embedTitle = "Honey Update",
        fields = webhookFieldsList()
    })

    print("sending webhook")
    sendWebhook(data)
end

function questWebhookListener(name,quest)
    if macrov2.toggles.webhookcompletedquest then
        if name == "CompleteQuest" or name == "CompleteQuestFromPool" then 
            spawn(function() 
                local ppower
                pcall(function() 
                    local quest = tostring(quest)
                    local data = ClientStatCache.Get()
                    ppower = data.Modifiers.MaxBeeEnergy._.Mods[1].Combo
                end)
                ppower=tostring(ppower)
                if quest=="Polar Bear" then 
                    questWebhook(quest,{
                        {
                            name = "Completed Quest",
                            value = quest.."\n\n<:PolarPower:1080979354030444594> x"..ppower
                        }
                    })
                else
                    questWebhook(quest,{
                        {
                            name = "Completed Quest",
                            value = quest
                        }
                    })
                end
                
            end)
        end
    end
end

LPH_NO_VIRTUALIZE(function()
    local oldCCall
    oldCCall = hookfunction(Events.ClientCall,function(...)
        local name,quest = ...
        spawn(function() questWebhookListener(name,quest) end)
        return oldCCall(...)
    end)
end)()

debugNextStep(true)

function findField(position)
    if not position then return nil end
    
    for _,v in pairs(Workspace.FlowerZones:GetChildren()) do
        local fieldPos = v.CFrame.p
        local fieldSize = v.Size + Vector3.new(0, 30, 0)
        if position.X > fieldPos.X - fieldSize.X/2 and position.X < fieldPos.X + fieldSize.X/2 then
            if position.Z > fieldPos.Z - fieldSize.Z/2 and position.Z < fieldPos.Z + fieldSize.Z/2 then
                if position.Y > fieldPos.Y - fieldSize.Y/2 and position.Y < fieldPos.Y + fieldSize.Y/2 then
                    return v
                end
                -- return v
            end
        end
    end

    return nil
end

function statsget(name)
    return ClientStatCache:Get(name)
end

task.spawn(function()
    while task.wait(0.1) do
        for i, v in pairs(temptable.tokenpath:GetChildren()) do
            if v:IsA("Part") and v.CFrame.YVector.Y ~= 1 then
                local collected = Instance.new("Folder")
                collected.Name = "Collected"
                collected.Parent = v
            end
        end
    end
end)

function getCurrentTime()
    local TimeToReturn;
    local CurrentTime = Lighting.ClockTime
    if CurrentTime > 10 then
        TimeToReturn = "Day"
    elseif CurrentTime < 10 then
        TimeToReturn = "Night"
    end
    return TimeToReturn
end

function farm(trying)
    if macrov2.toggles.loopfarmspeed then
        api.humanoid().WalkSpeed = macrov2.vars.farmspeed
    end
    if trying:FindFirstChild("Collected") then return nil end
    local newname = math.random(30000)
    trying.Name = newname
    repeat task.wait()
        api.humanoid():MoveTo(trying.Position)
    until temptable.dead or api.humanoid().MoveToFinished or not macrov2.toggles.autofarm or trying.CFrame.YVector.Y ~= 1 or trying.Parent and not trying:FindFirstChild(newname)
    local collectionStartedTime = tick()
    repeat 
        task.wait()
    until 
      tick() - collectionStartedTime < 5
      and macrov2.collectmethod == "Old"
      and (trying.Position - api.humanoidrootpart().Position).magnitude <= 2
     or macrov2.collectmethod == "New" 
      and (api.humanoid().MoveToFinished and (trying.Position - api.humanoidrootpart().Position).Magnitude <= 4)
     or not IsToken(trying) 
     or not temptable.running or trying.CFrame.YVector.Y ~= 1
    --  --print("After token collect")
end

function disableall()
    if macrov2.toggles.autofarm and not temptable.converting then
        temptable.cache.autofarm = true
        macrov2.toggles.autofarm = false
    end
    if macrov2.toggles.killmondo and not temptable.started.mondo then
        macrov2.toggles.killmondo = false
        temptable.cache.killmondo = true
    end
    if macrov2.toggles.killvicious and not temptable.started.vicious then
        macrov2.toggles.killvicious = false
        temptable.cache.vicious = true
    end
    if macrov2.toggles.killwindy and not temptable.started.windy then
        macrov2.toggles.killwindy = false
        temptable.cache.windy = true
    end
end

function enableall()
    if temptable.cache.autofarm then
        macrov2.toggles.autofarm = true
        temptable.cache.autofarm = false
    end
    if temptable.cache.killmondo then
        macrov2.toggles.killmondo = true
        temptable.cache.killmondo = false
    end
    if temptable.cache.vicious then
        macrov2.toggles.killvicious = true
        temptable.cache.vicious = false
    end
    if temptable.cache.windy then
        macrov2.toggles.killwindy = true
        temptable.cache.windy = false
    end
end
debugNextStep("Important values init, part 3")
task.spawn(function()
    while task.wait(0.1) do	
        valuetesting = 0	
        for i, v in next, domapi.Recursion({temptable.started, temptable.converting, temptable.planting, temptable.activatingboosters, temptable.activatingclock,temptable.activatingsamovar, temptable.activatingfeast, temptable.activatingcandles, temptable.activatingfreerobopassdispenser, temptable.activatingfreeantpassdispenser, temptable.activatingonettart, temptable.activatingsnowmachine, temptable.activatingwreath, temptable.activatingstockings, temptable.donatingtoshrine}) do	
            if v == true then	
                valuetesting = valuetesting + 1	
            end	
        end	
    end	
end)

function getlinktoken()
    local smallest;
    for i,v in pairs(temptable.tokenpath:GetChildren()) do
        tokenId = string.gsub(v:FindFirstChildOfClass("Decal").Texture, "%D+", "")
        if tokenId ~= "1629547638" then
            toreturn = false
            continue
        else
            dist = (v.Position - api.humanoidrootpart.Position).Magnitude
            if not smallest then smallest = dist end
            if smallest > dist then
                toreturn = v
                smallest = dist
                continue
            end
        end
    end
    return toreturn
end

function gettoken(v3, farmclosest)
    if not v3 then v3 = fieldposition end
    task.wait()
    if farmclosest then
        for i=0,10 do
            local closesttoken = {}
            for e, r in next, temptable.tokenpath:GetChildren() do
                if r:FindFirstChild("farmed") then continue end
                if r:FindFirstChild("Collected") then continue end
                itb = false
                local tokenId
                if r:FindFirstChildOfClass("Decal") then
                    for i,v in pairs(macrov2.bltokens) do
                        local rare = getItemByName(v)
                        local rareTexture = rare and rare.Icon
                        -- print(rareTexture, r:FindFirstChildOfClass("Decal").Texture, r:FindFirstChildOfClass("Decal").Texture == rareTexture)
                        if rareTexture and rareTexture == tostring(r:FindFirstChildOfClass("Decal").Texture) and macrov2.toggles.enabletokenblacklisting then
                            itb = true
                        end
                    end
                    tokenId = string.gsub(r:FindFirstChildOfClass("Decal").Texture, "%D+", "")
                end
                if macrov2.toggles.ignorehoneytokens and tokenId == "1472135114" then continue end
                if not itb and findField(r.Position) == findField(api.humanoidrootpart().Position) then
                    if closesttoken.Distance then
                        if (r.Position - api.humanoidrootpart().Position).magnitude < closesttoken.Distance then
                            closesttoken = {Token = r, Distance = (r.Position - api.humanoidrootpart().Position).magnitude}
                        end
                    else
                        closesttoken = {Token = r, Distance = (r.Position - api.humanoidrootpart().Position).magnitude}
                    end
                end
            end
            if closesttoken.Token and not getlinktoken() then
                -- rconsoleprint(tokenId)
                if getNearestRareInField(findField(api.humanoidrootpart.Position).Name) then rare = true end
                if not rare then
                    farm(closesttoken.Token)
                else
                    farm(getNearestRareInField(findField(api.humanoidrootpart.Position).Name))
                end
                local farmed = Instance.new("BoolValue", closesttoken.Token)
                farmed.Name = "farmed"
                task.spawn(function()
                    task.wait(1)
                    if closesttoken.Token and closesttoken.Token.Parent then
                        farmed.Parent = nil
                    end
                end)
                break
            elseif closesttoken.Token and getlinktoken() then
                if getNearestRareInField(findField(api.humanoidrootpart.Position).Name) then rare = true end
                if not rare then
                    farm(closesttoken.Token)
                else
                    farm(getNearestRareInField(findField(api.humanoidrootpart.Position).Name))
                end
                farm(getlinktoken())
                local farmed = Instance.new("BoolValue", closesttoken.Token)
                farmed.Name = "farmed"
                task.spawn(function()
                    task.wait(1)
                    if closesttoken.Token and closesttoken.Token.Parent then
                        farmed.Parent = nil
                    end
                end)
                break
            end
        end
    else
        local tokensFarmed = 0
        for e, r in next, temptable.tokenpath:GetChildren() do
            itb = false
            local tokenId
            if r:FindFirstChildOfClass("Decal") then
                for i,v in pairs(macrov2.bltokens) do
                    local rare = getItemByName(v)
                    local rareTexture = rare and rare.Icon
                    -- print(rareTexture, r:FindFirstChildOfClass("Decal").Texture, r:FindFirstChildOfClass("Decal").Texture == rareTexture)
                    if rareTexture and rareTexture == tostring(r:FindFirstChildOfClass("Decal").Texture) and macrov2.toggles.enabletokenblacklisting then
                        -- warn("BLACKLISTED")
                        itb = true
                    end
                end
                tokenId = string.gsub(r:FindFirstChildOfClass("Decal").Texture, "%D+", "")
            end
            if macrov2.toggles.ignorehoneytokens and tokenId == "1472135114" then --[[rconsoleprint("ignored honey token")]] continue end
            if tonumber((r.Position - api.humanoidrootpart().Position).Magnitude) <= temptable.magnitude / 1.4 and not itb and (v3 - r.Position).magnitude <= temptable.magnitude then
                tokensFarmed = tokensFarmed + 1
                farm(r)
            end
        end
    end
    if tokensFarmed == 0 then
        getflower()
    end
end

function makesprinklers()
    print("sprinklers")
    sprinkler = updateClientStatCache().EquippedSprinkler
    e = 1
    if sprinkler == "Basic Sprinkler" or sprinkler == "The Supreme Saturator" then
        e = 1
    elseif sprinkler == "Silver Soakers" then
        e = 2
    elseif sprinkler == "Golden Gushers" then
        e = 3
    elseif sprinkler == "Diamond Drenchers" then
        e = 4
    end
    for i = 1, e do
        k = api.humanoid().JumpPower
        if e ~= 1 then api.humanoid().JumpPower = 70 api.humanoid().Jump = true task.wait(.2) end
        PlayerActivesCommand:FireServer({["Name"] = "Sprinkler Builder"})
        if e ~= 1 then api.humanoid().JumpPower = k task.wait(1) end
    end
end

function isMobBlack(name)
    for i, v in pairs(macrov2.vars.mobblack) do
        if string.find(name, v) then
            return true
        end
    end
end

function domob(place)
    if not place or not place.Name then return nil end
    if place and place.Name and isMobBlack(place.Name) then return nil end
    if place:FindFirstChild("Territory") then
        local timestamp = tick()
        local secondstamp = tick()
        local monsterpart = place.Territory.Value

        if place.Name:match("Werewolf") then
            monsterpart = Workspace.Territories.WerewolfPlateau.w
        elseif place.Name:match("Mushroom") then
            monsterpart = Workspace.Territories.MushroomZone.Part
        end

        local point = Vector3.new((place.CFrame.p.X + monsterpart.CFrame.p.X) / 2, monsterpart.CFrame.p.Y, (place.CFrame.p.Z + monsterpart.CFrame.p.Z) / 2)

        if place:FindFirstChild("TimerLabel", true).Visible then
            return false
        end

        while not place:FindFirstChild("TimerLabel", true).Visible and tick() - timestamp < 25 do
            if temptable.dead then task.wait(30) end
            if tick() - secondstamp > 2 then
                api.tween(domapi.TweenSpeed(CFrame.new(point + Vector3.new(0, 30, 0))), CFrame.new(point + Vector3.new(0, 30, 0)))
                api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
                task.wait(1)
                secondstamp = tick()
            end
            task.wait()
            moveTo(point)
            api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
        end

        if tick() - timestamp > 25 then
            return false
        end

        task.wait(1)
        for i = 1, 20 do
            gettoken(api.humanoidrootpart().Position)
        end

        return true
    end
end

local monsternames = {
    "Mantis",
    "Scorpion",
    "Spider",
    "Werewol",
    "Rhino",
    "Ladybug"
}

function killmobs()
    if macrov2.toggles.smartmobkill and scriptType == "Paid" then
        
        local totalmonsters = {}
        
        local quests = getNPCQuest()
        for i, v in pairs(quests) do
            for k, x in pairs(getQuestProgress(v)) do
                local iscompleted = x[1]
                local progress = x[2]
                local need = x[3]
                --print(v,i)
                local todo = tostring(getQuestInfo(v).Tasks[k].Description) .. '\n' .. progress .. '/' .. need
                if type(todo) ~= "string" then
                    todo = todo(ClientStatCache:Get())
                end
                --print(todo)
                for _,monstername in pairs(monsternames) do
                    local monsterindex = todo:find(monstername)
                    if monsterindex and not todo:find("Field") and todo:find("/") then
                        --print(monstername)
                        local totalmonstercount = todo:sub(todo:find("/") + 1, #todo)
                        local defeatedmonstercount = todo:sub(todo:find("\n"), todo:find("/") - 1)
                        totalmonsters[monstername] = totalmonsters[monstername] and totalmonsters[monstername] + totalmonstercount - defeatedmonstercount or totalmonstercount - defeatedmonstercount
                    end
                end
            end
        end

        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("Rhino Bush")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Ladybug"] and totalmonsters["Ladybug"] > 0 then
            if domob(monsterspawners:FindFirstChild("Ladybug Bush")) then
                totalmonsters["Ladybug"] = totalmonsters["Ladybug"] - 1
            end
        end
        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("Rhino Cave 1")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("Rhino Cave 2")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("Rhino Cave 3")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("PineappleBeetle")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Mantis"] and totalmonsters["Mantis"] > 0 then
            if domob(monsterspawners:FindFirstChild("PineappleMantis1")) then
                totalmonsters["Mantis"] = totalmonsters["Mantis"] - 1
            end
        end
        if totalmonsters["Spider"] and totalmonsters["Spider"] > 0 then
            domob(monsterspawners:FindFirstChild("Spider Cave"))
        end
        if totalmonsters["Ladybug"] and totalmonsters["Ladybug"] > 0 then
            if domob(monsterspawners:FindFirstChild("MushroomBush")) then
                totalmonsters["Ladybug"] = totalmonsters["Ladybug"] - 1
            end
        end
        if totalmonsters["Ladybug"] and totalmonsters["Ladybug"] > 0 then
            domob(monsterspawners:FindFirstChild("Ladybug Bush 2"))
            domob(monsterspawners:FindFirstChild("Ladybug Bush 3"))
        end
        if totalmonsters["Scorpion"] and totalmonsters["Scorpion"] > 0 then
            domob(monsterspawners:FindFirstChild("ScorpionBush")) 
            domob(monsterspawners:FindFirstChild("ScorpionBush2"))
        end
        if totalmonsters["Werewol"] and totalmonsters["Werewol"] > 0 then
            domob(monsterspawners:FindFirstChild("WerewolfCave"))
        end
        if totalmonsters["Mantis"] and totalmonsters["Mantis"] > 0 then
            domob(monsterspawners:FindFirstChild("ForestMantis1"))
            domob(monsterspawners:FindFirstChild("ForestMantis2"))
        end
    else
        domob(monsterspawners:FindFirstChild("Rhino Bush")) -- Clover Field
        domob(monsterspawners:FindFirstChild("Ladybug Bush")) -- Clover Field
        domob(monsterspawners:FindFirstChild("Rhino Cave 1")) -- Blue Flower Field
        domob(monsterspawners:FindFirstChild("Rhino Cave 2")) -- Bamboo Field
        domob(monsterspawners:FindFirstChild("Rhino Cave 3")) -- Bamboo Field
        domob(monsterspawners:FindFirstChild("PineappleMantis1")) -- Pineapple Field
        domob(monsterspawners:FindFirstChild("PineappleBeetle")) -- Pineapple Field
        domob(monsterspawners:FindFirstChild("Spider Cave")) -- Spider Field
        domob(monsterspawners:FindFirstChild("MushroomBush")) -- Mushroom Field
        domob(monsterspawners:FindFirstChild("Ladybug Bush 2")) -- Strawberry Field
        domob(monsterspawners:FindFirstChild("Ladybug Bush 3")) -- Strawberry Field
        domob(monsterspawners:FindFirstChild("ScorpionBush")) -- Rose Field
        domob(monsterspawners:FindFirstChild("ScorpionBush2")) -- Rose Field
        domob(monsterspawners:FindFirstChild("WerewolfCave")) -- Werewolf
        domob(monsterspawners:FindFirstChild("ForestMantis1")) -- Pine Tree Field
        domob(monsterspawners:FindFirstChild("ForestMantis2")) -- Pine Tree Field
    end
end

function IsToken(token)
    if not token then return false end
    if not token.Parent then return false end
    if token then
        if token.Orientation.Z ~= 0 then return false end
        if token:FindFirstChild("FrontDecal") then
        else
            return false
        end
        if not token.Name == "C" then return false end
        if not token:IsA("Part") then return false end
        return true
    else
        return false
    end
end

function getplanters()
    table.clear(planterst.plantername)
    table.clear(planterst.planterid)
    for i, v in pairs(debug.getupvalues(LocalPlanters.LoadPlanter)[4]) do
        if v.GrowthPercent == 1 and v.IsMine then
            table.insert(planterst.plantername, v.Type)
            table.insert(planterst.planterid, v.ActorID)
        end
    end
    return planterst
end

function getMinePlanters()
    local minePlantersTable = {}
    for i, v in pairs(debug.getupvalues(LocalPlanters.LoadPlanter)[4]) do
        if v.IsMine and v.PotModel then
            table.insert(minePlantersTable,v)
        end
    end
    return minePlantersTable
end

function getBuffTime(decalID)
    if not decalID then return 0 end
    
    for i,v in pairs(ScreenGui:GetChildren()) do
        if v.Name == "TileGrid" then
            for j,k in pairs(v:GetChildren()) do
                if k:FindFirstChild("BG") and k.BG:FindFirstChild("Icon") then
                    if string.find(tostring(k.BG.Icon.Image), decalID) then
                        return k.BG.Bar.Size.Y.Scale
                    end
                end
            end
        end
    end

    return 0
end
debugNextStep(true)
local fieldIcons = ReplicatedStorage.SmallFieldIcons:GetChildren()

function boostedFieldByName(field)
    for _,v in pairs(fieldIcons) do
        if v.Name == field then
            return true
        end
    end
    return false
end

function boostedFieldByMostTime()
    local tbl = {}
    for _,v in pairs(fieldIcons) do
        local time = getBuffTime(tostring(v.Texture):match("%d+"))
        if time and time > 0 then
            if not tbl.Time or tbl.Time < time then
                tbl.Time = time
                tbl.Field = Workspace:WaitForChild("FlowerZones")[v.Name]
            end
        end
    end
    return tbl.Field
end

function getBuffStack(decalID)
    if not decalID then return 0 end
    
    for i,v in pairs(ScreenGui:GetChildren()) do
        if v.Name == "TileGrid" then
            for j,k in pairs(v:GetChildren()) do
                if k:FindFirstChild("BG") and k.BG:FindFirstChild("Icon") then
                    if string.find(tostring(k.BG.Icon.Image), decalID) then
                        local placeholder = k.BG.Text.Text:gsub("x", "")
                        return tonumber(placeholder) or 1
                    end
                end
            end
        end
    end

    return 0
end

function farmant()
    debugNextStep("Farm ants started")
    antpart.CanCollide = true
    disableall()
    temptable.started.ant = true
    local anttable = {left = true, right = false}
    temptable.oldtool = updateClientStatCache()["EquippedCollector"]
    if temptable.oldtool ~= "Tide Popper" or temptable.oldtool ~= "Spark Staff" then
        equiptool("Spark Staff")
    end
    moveTo(CFrame.new(92.2364731, 32.4959831, 508.285187))
    local oldmask = updateClientStatCache()["EquippedAccessories"]["Hat"]
    maskequip("Demon Mask")
    task.wait(5)
    domapi.callEvent("ToyEvent", "Ant Challenge")
    macrov2.toggles.autodig = true
    local acl = CFrame.new(Vector3.new(127, 48, 547), Vector3.new(94, 51.8, 550))
    local acr = CFrame.new(Vector3.new(65, 48, 534), Vector3.new(94, 51.8, 550))
    task.wait(1)
    PlayerActivesCommand:FireServer({
        ["Name"] = "Sprinkler Builder"
    })
    api.tween(domapi.TweenSpeed(CFrame.new(api.humanoidrootpart().Position + Vector3.new(0,15,0))),CFrame.new(api.humanoidrootpart().Position + Vector3.new(0,15,0)))
    local anttokendb = false
    task.wait(3)
    repeat
        task.wait()
        task.spawn(function()
            if not anttokendb then
                anttokendb = true
                local smallest = math.huge
                for _,token in pairs(temptable.tokenpath:GetChildren()) do
                    local decal = token:FindFirstChildOfClass("Decal")
                    if decal and decal.Texture then
                        if decal.Texture == "rbxassetid://1629547638" then
                            for _,monster in pairs(Workspace.Monsters:GetChildren()) do
                                if monster.Name:find("Ant") and monster:FindFirstChild("Head") then
                                    local dist = (monster.Head.CFrame.p - token.CFrame.p).magnitude
                                    if dist < smallest then
                                        smallest = dist
                                    end
                                end
                            end
                            
                            if player.Character:FindFirstChild("Humanoid") and smallest > 2 and smallest < 100 then
                                local save = api.humanoidrootpart().CFrame
                                if token:FindFirstChild("Collected") then return end
                                api.tween(domapi.TweenSpeed(CFrame.new(token.CFrame.p)),CFrame.new(token.CFrame.p))
                                task.wait(0.2)
                                api.humanoidrootpart().CFrame = save
                                local checked = Instance.new("Folder", token)
                                checked.Name = "Collected"
                                break
                            end
                        end
                    end
                end
                task.wait(0.3)
                anttokendb = false
            end
        end)
        for i, v in next, Workspace.Toys["Ant Challenge"].Obstacles:GetChildren() do
            if v:FindFirstChild("Root") then
                if (v.Root.Position - api.humanoidrootpart().Position).magnitude <= 40 and anttable.left then
                    api.humanoidrootpart().CFrame = acr
                    anttable.left = false
                    anttable.right = true
                    task.wait(0.2)
                elseif (v.Root.Position - api.humanoidrootpart().Position).magnitude <= 40 and anttable.right then
                    api.humanoidrootpart().CFrame = acl
                    anttable.left = true
                    anttable.right = false
                    task.wait(0.2)
                end
            end
        end
    until Workspace.Toys["Ant Challenge"].Busy.Value == false
    task.wait(1)
    if temptable.oldtool ~= "Tide Popper" then
        equiptool(temptable.oldtool)
    end
    maskequip(oldmask)
    temptable.started.ant = false
    antpart.CanCollide = false
    enableall()
    debugNextStep(true)
end

function collectplanters()
    getplanters()
    for i, v in pairs(planterst.plantername) do
        if api.partwithnamepart(v, Workspace.Planters) and api.partwithnamepart(v, Workspace.Planters):FindFirstChild("Soil") then
            local soil = api.partwithnamepart(v, Workspace.Planters).Soil
            moveTo(soil.Position + Vector3.new(0, 3, 0))
            ReplicatedStorage.Events.PlanterModelCollect:FireServer(planterst.planterid[i])
            task.wait(.5)
            PlayerActivesCommand:FireServer({["Name"] = v .. " Planter"})
            for i = 1, 5 do gettoken(soil.Position) end
            task.wait(2)
        end
    end
end

function getprioritytokens()
    task.wait()
    if temptable.running == false then
        for e, r in next, temptable.tokenpath:GetChildren() do
            if r:FindFirstChildOfClass("Decal") then
                for i,v in pairs(macrov2.priority) do
                    local rare = getItemByName(v)
                    local rareTexture = rare and rare.Icon
                    local tokenDecal = r:FindFirstChildOfClass("Decal")
                    if rareTexture ~= nil and tokenDecal ~= nil and tostring(tokenDecal.Texture) == rareTexture then
                        if true and
                          not r:FindFirstChild("got it") or tonumber((r.Position - api.humanoidrootpart().Position).magnitude) <= temptable.magnitude / 1.4 and
                          not r:FindFirstChild("got it") then
                            farm(r)
                            break
                        end
                    end
                end
            end
        end
    end
end

function gethiveballoon()
    for _,balloon in pairs(Workspace.Balloons.HiveBalloons:GetChildren()) do
        if balloon:FindFirstChild("BalloonRoot") then
            if balloon.BalloonRoot.CFrame.p.X == player.SpawnPos.Value.p.X then
                return true
            end
        end
    end
    return false
end

function getfurthestballoon()
    local biggest = 0
    local saveloon = nil
    local balloons = Workspace:FindFirstChild("Balloons")
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if balloons and root then
        for _,balloon in pairs(balloons.FieldBalloons:GetChildren()) do
            local owner = balloon:FindFirstChild("PlayerName")
            if owner then
                if owner.Value == player.Name then
                    local text = balloon.BalloonBody.GuiAttach.Gui.Bar.TextLabel.Text
                    local bar = balloon.BalloonBody.GuiAttach.Gui.Bar.FillBar
                    if bar.Parent.BackgroundTransparency == 0 and fieldposition then
                        local dist = (root.CFrame.p - balloon.BalloonBody.Position).magnitude
                        if dist > biggest and dist < 100 then
                            biggest = dist
                            saveloon = balloon
                        end
                    end
                end
            end
        end
    end
    if saveloon and fieldposition then
        return Vector3.new(saveloon.BalloonBody.Position.X, fieldposition.Y, saveloon.BalloonBody.Position.Z)
    end
    return nil
end

function converthoney()
    task.wait()
    if temptable.converting then
        if ScreenGui.ActivateButton.TextBox.Text ~= "Stop Making Honey" and ScreenGui.ActivateButton.BackgroundColor3 ~= Color3.new(201, 39, 28) or (player.SpawnPos.Value.Position - api.humanoidrootpart().Position).magnitude > 13 then
            local pos = (player.SpawnPos.Value * CFrame.fromEulerAnglesXYZ(0, 110, 0) + Vector3.new(0, 0, 9)).p
            moveTo(pos)
            task.wait(.9)
            if ScreenGui.ActivateButton.TextBox.Text ~= "Stop Making Honey" and ScreenGui.ActivateButton.BackgroundColor3 ~= Color3.new(201, 39, 28) or (player.SpawnPos.Value.Position - api.humanoidrootpart().Position).magnitude > 13 then
                ReplicatedStorage.Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
            end
            task.wait(.1)
        end
    end
end

task.spawn(function()
    while task.wait(macrov2.vars.converttime) do
        if macrov2.toggles.converttime then
            converthoney()
        end
    end
end)

function closestleaf()
    for i, v in next, Workspace.Flowers:GetChildren() do
        if temptable.running == false and tonumber((v.Position - player.Character.HumanoidRootPart.Position).magnitude) < temptable.magnitude / 1.4 then
            farm(v)
            break
        end
    end
end

function getballoons()
    if (macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model"))
      or temptable.started.ant 
      or temptable.started.vicious 
      or temptable.started.commando 
      or temptable.converting 
      or temptable.planting 
      or temptable.started.monsters 
      or temptable.doingcrosshairs
      or temptable.doingbubbles
      or not macrov2.toggles.autofarm
    then return end
    for i, v in next, Workspace.Balloons.FieldBalloons:GetChildren() do
        if v:FindFirstChild("BalloonRoot") and v:FindFirstChild("PlayerName") then
            if v:FindFirstChild("PlayerName").Value == player.Name then
                if tonumber((v.BalloonRoot.Position - api.humanoidrootpart().Position).magnitude) < temptable.magnitude / 1.4 then
                    api.walkTo(v.BalloonRoot.Position)
                end
            end
        end
    end
end

local getDuped = function() return end
LPH_NO_VIRTUALIZE(function()
    local prioritized = {}
    
    local function farmDuped(dupedToken, prio)
        temptable.farmingDuped = true
        local s,e = pcall(function()
            local needed = dupedToken.Parent and dupedToken.Attachment.BillboardGuiBack.BackCircle
            repeat
                api.walkTo(dupedToken.Position)
                wait()
            until not needed.Parent or not dupedToken.Parent or needed.ImageColor3 == Color3.new(1, 0, 1) or (not prio and #prioritized>0) or not findField((dupedToken.Position - Vector3.new(0,5,0))) == findField(api.humanoidrootpart().Position) or not macrov2.toggles.farmduped
        end)
        if e then warn(e) end
        if prio then table.remove(prioritized, table.find(prioritized, dupedToken)) end
        temptable.farmingDuped = false
    end
    
    getDuped = function()
        if macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model") then return end
        if temptable.doingcrosshairs or temptable.started.vicious or temptable.started.commando or temptable.converting or temptable.planting then return end
        if #prioritized > 0 then
            for i,dupedToken in pairs(prioritized) do
                return farmDuped(dupedToken, true)
            end
        end
        for i,v in pairs(Workspace.Camera:GetChildren()) do
            if v.Name == "DupedTokens" then
                for i2,dupedToken in pairs(v:GetChildren()) do
                    if macrov2.toggles.smileyonly and string.gsub(dupedToken:FindFirstChildOfClass("Decal").Texture, "%D+", "") ~= "5877939956" then continue end
                    if not (#prioritized > 0) then
                        --print(findField((dupedToken.Position - Vector3.new(0,5,0))), findField(api.humanoidrootpart().Position))
                        if findField((dupedToken.Position - Vector3.new(0,5,0))) == findField(api.humanoidrootpart().Position) then
                            return farmDuped(dupedToken, false)
                        end
                    end
                end
            end
        end
    end
    
    Workspace.Camera.DupedTokens.ChildAdded:Connect(function(dupedToken)
        if macrov2.toggles.farmduped then
            if findField((dupedToken.Position - Vector3.new(0,5,0))) == findField(api.humanoidrootpart().Position) then
                if not macrov2.toggles.smileyonly then
                    if tostring(dupedToken.FrontDecal.Texture):match("%d+") == "5877939956" or tostring(dupedToken.FrontDecal.Texture):match("%d+") == "1629547638" then
                        table.insert(prioritized,dupedToken)
                    end
                elseif tostring(dupedToken.FrontDecal.Texture):match("%d+") == "5877939956" and macrov2.toggles.smileyonly then
                    table.insert(prioritized,dupedToken)
                end
            end
        end
    end)
end)()

function checkSight(target)
    local ray = Ray.new(api.humanoidrootpart().Position, (target.Position - api.humanoidrootpart().Position).Unit * 40)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
    if hit then
        if hit:IsDescendantOf(target.Parent) and math.abs(hit.Position.Y - api.humanoidrootpart().Position.Y) < 3 then
            return true
        end
    end
    return false
end

function fireflies()
    for i, v in pairs(Workspace.NPCBees:GetChildren()) do
        if Workspace.NPCBees:FindFirstChild('Firefly') then
            if string.find(v.Name, "Firefly") then
                if findField(api.humanoidrootpart().Position) and findField(v.Position) and findField(api.humanoidrootpart().Position).Name ~= findField(v.Position).Name then
                    disableall()
                    fieldposition = v.Position
                    moveTo(v.Position)
                    break
                elseif findField(api.humanoidrootpart().Position) and findField(v.Position) and findField(api.humanoidrootpart().Position).Name ~= findField(v.Position).Name and ((v.Position * Vector3.new(0, 1, 0)) - (api.humanoidrootpart().Position * Vector3.new(0, 1, 0))).Magnitude < 5 and checkSight(v) then
                    disableall()
                    repeat
                        farm(v)
                    until ((v.Position * Vector3.new(0, 1, 0)) - (api.humanoidrootpart().Position * Vector3.new(0, 1, 0))).Magnitude > 5 or temptable.dead or not checkSight(v)
                    task.wait(0.01)
                    for i = 1, 5 do
                        gettoken(api.humanoidrootpart().Position)
                    end
                end
            end
        elseif not Workspace.NPCBees:FindFirstChild('Firefly') then
            enableall()
            break
        end
    end
end

task.spawn(function()
    while task.wait() do
        if macrov2.toggles.fireflies then
            fireflies()
        end
    end
end)

function useToy(toyName, tweenTime, isBeesmasToy, temp)
    --print(macrov2.toggles[temp], macrov2.dispensesettings[temp])
    if macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model") then return end
    if canToyBeUsed(toyName) and not temptable.converting then disableall() else return end
    local used = false
    task.wait()
    local patformPos = Workspace.Toys[toyName].Platform.Position
    while not temptable.converting and canToyBeUsed(toyName) and (macrov2.toggles[temp] or macrov2.dispensesettings[temp]) and not (macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model")) do
        moveTo(patformPos + Vector3.new(0,3,0))
        task.wait(0.5)
        if (patformPos - api.humanoidrootpart().Position).Magnitude < 10 then
            setIdentity(2)
            ActivatablesToys.ButtonEffect(player, workspace.Toys[toyName])
            setIdentity(7)
        end
        task.wait(2)
        used = true
    end
    if temptable.converting then return end 
    if isBeesmasToy and used then 
        task.wait(1.5) 
        tokensNear = {} 
        for i, v in pairs(temptable.tokenpath:GetChildren()) do
            if (v.Position - patformPos).magnitude < 25
            and v.CFrame.YVector.Y == 1
            and tostring(v.FrontDecal.texture):match("%d+") ~= "65867881" then
                table.insert(tokensNear, v)
            end
        end 
        --print(#tokensNear)
        while #tokensNear > 0 do
            for i,v in pairs(tokensNear) do
                if (patformPos - api.humanoidrootpart().Position).magnitude > 25 then 
                    api.tween((tweenTime or 2), CFrame.new(patformPos + Vector3.new(0,3,0)))
                end
                if not v.Parent then table.remove(tokensNear, i) continue end
                gettoken(v.Position)
            end
            task.wait()
        end 
    end
    task.wait() 
    enableall()
end

function useMemoryMatch(memoryMatch)
    if canToyBeUsed(memoryMatch) and not temptable.converting then disableall() else return "first" end
    local patformPos = Workspace.Toys[memoryMatch].Platform.Position
    while not temptable.converting 
          and canToyBeUsed(memoryMatch) 
          and macrov2.toggles.automemorymatch 
          and not (macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model"))
          and not temptable.activeMemoryMatch
    do
        moveTo(patformPos + Vector3.new(0,3,0))
        task.wait(0.5)
        if (patformPos - api.humanoidrootpart().Position).Magnitude < 15 then
            api:pressButton("E")
        end
        task.wait(1)
    end
    repeat wait() until temptable.activeMemoryMatch and temptable.doingMemoryMatch
    repeat wait() until not temptable.activeMemoryMatch and not temptable.doingMemoryMatch
    enableall()
end

--BlackScreen
if type(gethui) == 'function' then
	CoreGui = gethui()
end
local GPUGUI = Instance.new("ScreenGui")
GPUGUI.Name = 'GPUSaver'
GPUGUI.Enabled = false
GPUGUI.Parent = CoreGui
local TextLabel = Instance.new("TextLabel")
TextLabel.BackgroundColor3 = Color3.new(0, 0, 0)
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextStrokeTransparency = 1
TextLabel.AnchorPoint = Vector2.new(.5, .5)
TextLabel.Position = UDim2.fromScale(.5, .5)
TextLabel.Size = UDim2.fromScale(1.5, 1.5)
TextLabel.Font = Enum.Font.RobotoMono
TextLabel.TextSize = 24
TextLabel.Text = "GPUSaver is currently running click to disable."
TextLabel.Parent = GPUGUI

local OldLevel = settings().Rendering.QualityLevel

local resume = function()
    if macrov2.toggles.antilag then
    RunService:Set3dRenderingEnabled(true)
    settings().Rendering.QualityLevel = OldLevel
    GPUGUI.Enabled = false
    setfpscap(60)
    end
end
local pause = function()
    if macrov2.toggles.antilag then
        OldLevel = settings().Rendering.QualityLevel
        GPUGUI.Enabled = true
        RunService:Set3dRenderingEnabled(false)
        settings().Rendering.QualityLevel = 1
        setfpscap(macrov2.vars.targetfps or 60)
    end
end

task.spawn(function()
    local con0 = UserInputService.WindowFocusReleased:Connect(pause)
    local con1 = UserInputService.WindowFocused:Connect(resume)
    local con2 = UserInputService.InputBegan:Connect(function(input) if paused and input.UserInputState == Enum.UserInputState.Begin and input.UserInputType == Enum.UserInputType.Keyboard then resume(); end; end)
end)
local AllToysTable = {
    ["toysTable"] = {
        ['collectgingerbreads'] = "Gingerbread House",
        ['clock'] = "Wealth Clock",
        ['honeystorm'] = "Honeystorm",
        ['freeantpass'] = "Free Ant Pass Dispenser",
        ['freerobopass'] = "Free Robo Pass Dispenser"
    },
    ["boostersTable"] = {
        ['white'] = 'Field Booster',
        ['red'] = 'Red Field Booster',
        ['blue'] = 'Blue Field Booster'
    },
    ["dispensersTable"] = {
        ['rj'] = "Free Royal Jelly Dispenser",
        ['blub'] = "Blueberry Dispenser",
        ['straw'] = "Strawberry Dispenser",
        ['treat'] = "Treat Dispenser",
        ['coconut'] = "Coconut Dispenser"
    },
    ["beesmasToysTable"] = {
        ['autosamovar'] = "Samovar",
        ['autostockings'] = "Stockings",
        ['autoonettart'] = "Onett's Lid Art",
        ['autocandles'] = "Honeyday Candles",
        ['autofeast'] = "Beesmas Feast",
        ['autosnowmachine'] = "Snow Machine",
        ['autohoneywreath'] = "Honey Wreath"
    },
    ["memoryMatchTable"] = {}
}

for i,v in pairs(Workspace.Toys:GetChildren()) do
    if v.Name:find("Memory Match") then table.insert(AllToysTable["memoryMatchTable"], v.Name) end
end

function getToysFlag(name, name2)
    if name == "dispensersTable" then
        return (macrov2.toggles.autodispense and macrov2.dispensesettings[name2])
    elseif name == "boostersTable" then
        return (macrov2.toggles.autoboosters and macrov2.dispensesettings[name2])
    elseif name == "memoryMatchTable" then
        return macrov2.toggles.automemorymatch
    else
        return macrov2.toggles[name2]
    end
end

function getNearestUsableToy()
    local smallest;
    for e,r in pairs(AllToysTable) do
        for i,v in pairs(r) do
            local patformPos = workspace.Toys[v].Platform.Position
            if not canToyBeUsed(v) or temptable.converting or not getToysFlag(e, i) then continue end
            local dist = (patformPos - api.humanoidrootpart().Position).Magnitude
            if e:find("memory") or e:find("bees") then ispaid = true end
            if not smallest then smallest = dist end
            if smallest >= dist then
                isbeemas = false
                ismemory = false
                ispaid = false
                tweentime = 2
                toyremote = "hi"
                if e == "beesmasToysTable" then isbeemas = true tweentime = 2 end
                if e == "memoryMatchTable" then ismemory = true tweentime = nil end
                if e:find("memory") or e:find("bees") then ispaid = true end
                if e:find("dispenser") then
                    tweentime = 1
                end
                smallest = dist
                toreturn = v
                if not e:find("memory") then toyremote = i end
            end
        end
    end
    return {toreturn, isbeemas, ismemory, ispaid, toyremote, tweentime}
end

function getToys()
    local NearestToy = getNearestUsableToy()
    local Toy = NearestToy[1]
    local isbeemas = NearestToy[2]
    local ismemory = NearestToy[3]
    local ispaid = NearestToy[4]
    local toyremote = NearestToy[5]
    local tweentime = NearestToy[6]
    if not NearestToy then return end
    if not Toy then return "Error" end
    if not isbeemas and not ismemory and not ispaid then
        useToy(Toy, tweentime, false, toyremote)
    elseif isbeemas and not ismemory and scriptType == "Paid" then
        useToy(Toy, tweentime, true, toyremote)
    elseif ismemory and not isbeemas and scriptType == "Paid" then
        local aaa = useMemoryMatch(Toy)
        warn(aaa)
    end
end

LPH_NO_VIRTUALIZE(function()
    local MemoryMatchStartGame = require(ReplicatedStorage.Gui.MinigameGui).StartGame
    local MemoryMatchModule = require(ReplicatedStorage.Gui.MemoryMatch)
    
    local function UpdateGameTable(a)
        local dupes = {}
        local exclude = a.Game.MatchedTiles
    
        for index, value in pairs(a.Game.RevealedTiles) do
            if exclude[index] == nil then  -- skip excluded indexes
                if dupes[value] == nil then
                    dupes[value] = {Indexes = {index}}
                else
                    table.insert(dupes[value]["Indexes"], index)
                end
            end
        end
    
        for i,v in pairs(dupes) do
          if #v.Indexes < 2 then dupes[i] = nil end
        end
    
        return dupes
    end
    
    function newMemoryMatchStartGame(a)
        if not macrov2.toggles.automemorymatch then return end
        repeat wait() until a and a.Game and a.Game.Grid and a.Game.Grid.InputActive
        temptable.activeMemoryMatch = a
        print("You have",a.Game.Chances,"Chances")
        temptable.doingMemoryMatch = true
        for Index = 1, a.Game.NumTiles do
            wait()
            if a.Game.Chances == 0 then break end
    
            local tile = a.Game.Grid:GetTileAtIndex(Index)
    
            if a.Game.LastSelectedIndex ~= nil then
                local searchFor = a.Game.RevealedTiles[a.Game.LastSelectedIndex]
                local dupes = UpdateGameTable(a)
                -- print(searchFor)
                for i2,v2 in pairs(dupes) do
                    if i2 == searchFor and v2.Indexes[1] ~= Index then tile = a.Game.Grid:GetTileAtIndex(v2.Indexes[1]) print("found matched tile") break end
                end
            else
                local dupes = UpdateGameTable(a)
                for i,v in pairs(dupes) do
                    if #v.Indexes > 1 then
                        setIdentity(2)
                        MemoryMatchModule.RegisterTileSelected(a.Game, a.Game.Grid:GetTileAtIndex(v.Indexes[1]))
                        setIdentity(7)
                        repeat wait() until a.Game.Grid.InputActive or a.Game.Chances == 0
                        tile = a.Game.Grid:GetTileAtIndex(v.Indexes[2])
                        wait()
                        break
                    end
                end
            end
            setIdentity(2)
            MemoryMatchModule.RegisterTileSelected(a.Game, tile)
            setIdentity(7)
            repeat wait() until a.Game.Grid.InputActive or a.Game.Chances == 0
            wait()
        end
        temptable.doingMemoryMatch = false
        temptable.activeMemoryMatch = nil
    end
    
    local hookedMemoryMatchStartGame; hookedMemoryMatchStartGame = hookfunction(MemoryMatchStartGame, function(...)
        local a = hookedMemoryMatchStartGame(...)
        task.spawn(function() newMemoryMatchStartGame(a) end)
        return a
    end)
    end)()
    
    --[[
        Auto Memory Match End
    ]]

function isPuffInField(stem)
    if stem and player.Character:FindFirstChild("HumanoidRootPart") then
        return findField(stem.CFrame.p) == findField(api.humanoidrootpart().CFrame.p)
    end
    return false
end

function getpuff()
    local smallest = math.huge
    local closestPuffStem
    local mythics = {}
    local legendaries = {}
    local epics = {}
    local rares = {}
    local commons = {}
    for _,puffshroom in pairs(Workspace.Happenings.Puffshrooms:GetChildren()) do
        local stem = puffshroom:FindFirstChild("Puffball Stem")
        if stem and findField(stem.Position) then
            local field = findField(stem.Position)
            if not table.find(macrov2.blacklistedfields, field.Name) then
                if stem and player.Character:FindFirstChild("HumanoidRootPart") then
                    if stem then
                        if string.find(puffshroom.Name, "Mythic") then
                            table.insert(mythics, {stem, isPuffInField(stem)})
                        elseif string.find(puffshroom.Name, "Legendary") then
                            table.insert(legendaries, {stem, isPuffInField(stem)})
                        elseif string.find(puffshroom.Name, "Epic") then
                            table.insert(epics, {stem, isPuffInField(stem)})
                        elseif string.find(puffshroom.Name, "Rare") then
                            table.insert(rares, {stem, isPuffInField(stem)})
                        else
                            table.insert(commons, {stem, isPuffInField(stem)})
                        end
                    end
			        local smallest
                    if #mythics ~= 0 then
                        for _,v in pairs(mythics) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                            task.wait()
                            task.wait()
                        end
                        for _,v in pairs(mythics) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                                task.wait()
                                task.wait()
                            end
                        end
                    elseif #legendaries ~= 0 then
                        for _,v in pairs(legendaries) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                            task.wait()
                            task.wait()
                        end
                        for _,v in pairs(legendaries) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                                task.wait()
                                task.wait()
                            end
                        end
                    elseif #epics ~= 0 then
                        for _,v in pairs(epics) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                            task.wait()
                            task.wait()
                        end
                        for _,v in pairs(epics) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                                task.wait()
                                task.wait()
                            end
                        end
                    elseif #rares ~= 0 then
                        for _,v in pairs(rares) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                            task.wait()
                            task.wait()
                        end
                        for _,v in pairs(rares) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                                task.wait()
                                task.wait()
                            end
                        end
                    elseif #commons ~= 0 then
                        fieldpos = api.getbiggestmodel(Workspace.Happenings.Puffshrooms):FindFirstChild("Puffball Stem").CFrame
                        for _,v in pairs(commons) do
                            local stem, infield = unpack(v)
                            if infield and api.humanoidrootpart() then
					            dist = (api.humanoidrootpart().Position - stem.Position).Magnitude
					            if smallest == nil then smallest = dist continue end
					            if dist < smallest then
					                dist = smallest
                                    fieldpos = stem.CFrame
                                    task.wait()
                                    task.wait()
					            end
                            end
                        end
                    end
                    for i = 1, 10 do
                        gettoken(api.humanoidrootpart().Position)
                    end
                end
            else
                if fieldselected and fieldselected.Position then
                fieldpos = fieldselected.Position
                end
            end
        end
    end
    fieldposition = fieldpos
    moveTo(fieldpos)
    temptable.magnitude = 35
    onlyonesprinkler = true
end

function getflower()
    flowerrrr = flowertable[math.random(#flowertable)]
    if tonumber((flowerrrr - api.humanoidrootpart().Position).magnitude) <= temptable.magnitude / 1.4 and
        tonumber((flowerrrr - fieldposition).magnitude) <= temptable.magnitude / 1.4 then
        if temptable.running == false then
            if macrov2.toggles.loopfarmspeed then
                api.humanoid().WalkSpeed = macrov2.vars.farmspeed
            end
            api.walkTo(flowerrrr)
        end
    end
end

function getcloud()
    if (macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model"))
      or temptable.started.ant 
      or temptable.started.vicious 
      or temptable.started.commando 
      or temptable.converting 
      or temptable.planting 
      or temptable.started.monsters 
      or temptable.doingcrosshairs
      or temptable.doingbubbles
      or not macrov2.toggles.autofarm 
    then return end
    for i, v in next, Workspace.Clouds:GetChildren() do
        e = v:FindFirstChild("Plane")
        if e and tonumber((e.Position - api.humanoidrootpart().Position).magnitude) < temptable.magnitude / 1.4 then
            api.walkTo(e.Position)
        end
    end
end

function getfuzzy()
    if (macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model"))
      or temptable.started.ant 
      or temptable.started.vicious 
      or temptable.started.commando 
      or temptable.converting 
      or temptable.planting 
      or temptable.started.monsters 
      or temptable.doingcrosshairs
      or temptable.doingbubbles
      or not macrov2.toggles.autofarm 
    then return end
    pcall(function()
        for i, v in next, workspace.Particles:GetChildren() do
            if v.Name == "DustBunnyInstance" and temptable.running == false and
                tonumber((v.Plane.Position - api.humanoidrootpart().Position).magnitude) < temptable.magnitude /
                1.4 then
                if v:FindFirstChild("Plane") then
                    farm(v:FindFirstChild("Plane"))
                    break
                end
            end
        end
    end)
end

function getflame()
    if (macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model"))
      or temptable.started.ant 
      or temptable.started.vicious 
      or temptable.started.commando 
      or temptable.converting 
      or temptable.planting 
      or temptable.started.monsters 
      or temptable.doingcrosshairs
      or temptable.doingbubbles
      or not macrov2.toggles.autofarm 
    then return end
    for _,v in pairs(Workspace.PlayerFlames:GetChildren()) do
        if player.Character and api.humanoidrootpart() and v:FindFirstChild("PF") and v.PF.Color.Keypoints[1].Value.G == 0 and findField(v.Position) == findField(api.humanoidrootpart().Position) then
            api.humanoid():MoveTo(v.Position)
            repeat
                task.wait()
            until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or not temptable.running
            return
        end
    end
end

function avoidmob()
    for i, v in next, Workspace.Monsters:GetChildren() do
        if v:FindFirstChild("Head") then
            if (v.Head.Position - api.humanoidrootpart().Position).magnitude < 30 and api.humanoid():GetState() ~= Enum.HumanoidStateType.Freefall then
                player.Character.Humanoid.Jump = true
            end
        end
    end
end

function dobubbles()
    if (macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model"))
      or temptable.started.ant 
      or temptable.started.vicious 
      or temptable.started.commando 
      or temptable.converting 
      or temptable.planting 
      or temptable.started.monsters 
      or not macrov2.toggles.autofarm 
    then return end

    temptable.doingbubbles = true
    local savespeed = macrov2.vars.walkspeed
    macrov2.vars.walkspeed = macrov2.vars.walkspeed * 1.3

    for _,v in pairs(Workspace.Particles:GetChildren()) do
        if string.find(v.Name, "Bubble") and v.Parent and player.Character and api.humanoidrootpart() and --[[getBuffTime("5101328809") > 0.2]] true and (v.Position - api.humanoidrootpart().Position).magnitude < temptable.magnitude * 0.9 then
            api.humanoid():MoveTo(v.Position)
            repeat
                task.wait()
            until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or not temptable.running
        end
    end

    temptable.doingbubbles = false
    macrov2.vars.walkspeed = savespeed
end

function docrosshairs()
    if (macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model"))
      or temptable.started.ant 
      or temptable.started.vicious 
      or temptable.started.commando 
      or temptable.converting 
      or temptable.planting 
      or temptable.started.monsters 
      or not macrov2.toggles.autofarm 
    then return end

    local savespeed = macrov2.vars.walkspeed

    for _,v in pairs(Workspace.Particles:GetChildren()) do
        if string.find(v.Name, "Crosshair") and v.Parent and player.Character and api.humanoidrootpart() and v.BrickColor ~= BrickColor.new("Flint") then
            if macrov2.toggles.fastcrosshairs and scriptType == "Paid" then
                if (v.Position - api.humanoidrootpart().Position).magnitude > 200 then continue end
                if getBuffTime("8172818074") > 0.66 and getBuffStack("8172818074") > 9 then
                    if v.BrickColor == BrickColor.new("Alder") then
                        task.wait(0.5)
                        local save_height = v.Position.y
                        repeat
                            task.wait()
                            api.humanoid():MoveTo(v.Position)
                        until not v or not v.Parent or v.Position.y ~= save_height
                    end
                else
                    if v.BrickColor == BrickColor.new("Red flip/flop") or v.BrickColor == BrickColor.new("Alder") then
                        repeat
                            api.humanoid():MoveTo(v.Position)
                            task.wait()
                        until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or v.BrickColor == BrickColor.new("Forest green") or v.BrickColor == BrickColor.new("Royal purple")
                    end
                end
            elseif macrov2.toggles.unsafecrosshairs and scriptType == "Paid" then
                if (v.Position - api.humanoidrootpart().Position).magnitude > 200 then continue end
                if getBuffTime("8172818074") > 0.66 and getBuffStack("8172818074") > 9 then
                    if v.BrickColor == BrickColor.new("Alder") then
                        task.wait(0.5)
                        local save_height = v.Position.y
                        repeat
                            task.wait()
                            api.humanoidrootpart().CFrame = CFrame.new(v.Position)
                        until not v or not v.Parent or v.Position.y ~= save_height
                    end
                else
                    if v.BrickColor == BrickColor.new("Red flip/flop") or v.BrickColor == BrickColor.new("Alder") then
                        repeat
                            api.humanoid():MoveTo(v.Position)
                            task.wait()
                        until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or v.BrickColor == BrickColor.new("Forest green") or v.BrickColor == BrickColor.new("Royal purple")
                    end
                end
            elseif macrov2.toggles.collectcrosshairs then
                if (v.Position - api.humanoidrootpart().Position).magnitude < 200 then
                    temptable.doingcrosshairs = true
                    macrov2.vars.walkspeed = savespeed * 1.75
                    api.humanoid():MoveTo(v.Position)
                    repeat
                        task.wait()
                    until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or v.BrickColor == BrickColor.new("Forest green") or v.BrickColor == BrickColor.new("Royal purple") or not temptable.running
                    macrov2.vars.walkspeed = savespeed
                    temptable.doingcrosshairs = false
                end
            end
        end
    end
end

function makequests()
    -- print("makequests called") 
    for i, v in next, Workspace.NPCs:GetChildren() do
        -- print(v.Name)
        if checkQuestToggle(v.Name)
         and macrov2.toggles.autofarm 
         and macrov2.toggles.autodoquest
        then
            -- print(v.Name)
            if v:FindFirstChild("Platform") then
                -- print(1)
                if v.Platform:FindFirstChild("AlertPos") then
                    -- print(2)
                    if v.Platform.AlertPos:FindFirstChild("AlertGui") then
                        -- print(3)
                        if v.Platform.AlertPos.AlertGui:FindFirstChild("ImageLabel") then
                            -- print(4)
                            local image = v.Platform.AlertPos.AlertGui.ImageLabel
                            if image.ImageTransparency == 0 then
                                -- print(5)
                                doingquests = true
                                if macrov2.toggles.tptonpc then
                                    api.humanoidrootpart().CFrame = CFrame.new(v.Platform.Position + Vector3.new(0,3,0))
                                else
                                    moveTo(v.Platform.Position + Vector3.new(0,3,0))
                                end
                                
                                local attempts = 0
                                setIdentity(2)
                                while image.ImageTransparency == 0 and (v.Platform.Position - api.humanoidrootpart().Position).magnitude < 25 and attempts < 5 do
                                    if (api.humanoidrootpart().Position - v.Platform.Position).Magnitude <= 25 and not ScreenGui.NPC.Visible then
                                        while not ScreenGui.NPC.Visible and not ((api.humanoidrootpart().Position - v.Platform.Position).Magnitude > 25) do
                                            -- api:pressButton("E")
                                            ActivatablesNPC.ButtonEffect(player, Workspace.NPCs[v.Name])
                                            task.wait(.5)
                                        end
                                    end
                                    
                                    local tempTimestamp = tick()

                                    repeat wait()
                                    until ScreenGui.NPC.Visible or tick() - tempTimestamp > 5

                                    while ScreenGui.NPC.Visible do
                                        if ScreenGui.NPC.OptionFrame.Visible and ScreenGui.NPC.OptionFrame.Option2.Visible and ScreenGui.NPC.OptionFrame.Option2.Text:find("Talk to") then
                                            firesignal(ScreenGui.NPC.OptionFrame.Option2.MouseButton1Click)
                                        else
                                            firesignal(ScreenGui.NPC.ButtonOverlay.MouseButton1Click)
                                        end
                                        wait()
                                    end

                                    task.wait(2.5)
                                    attempts = attempts + 1
                                end
                                setIdentity(7)
                                task.wait(.5)
                            end
                        end
                    end
                end
            end
        end
    end
end
debugNextStep("Planters data init")
fullPlanterData = {
    ["Red Clay"] = {
        NectarTypes = {Invigorating = 1.2, Satisfying = 1.2},
        GrowthFields = {
            ["Pepper Patch"] = 1.25,
            ["Rose Field"] = 1.25,
            ["Strawberry Field"] = 1.25,
            ["Mushroom Field"] = 1.25
        }
    },
    Plenty = {
        NectarTypes = {
            Satisfying = 1.5,
            Comforting = 1.5,
            Invigorating = 1.5,
            Refreshing = 1.5,
            Motivating = 1.5
        },
        GrowthFields = {
            ["Mountain Top Field"] = 1.5,
            ["Coconut Field"] = 1.5,
            ["Pepper Patch"] = 1.5,
            ["Stump Field"] = 1.5
        }
    },
    --[[
    Festive = {
        NectarTypes = {
            Satisfying = 3,
            Comforting = 3,
            Invigorating = 3,
            Refreshing = 3,
            Motivating = 3
        },
        GrowthFields = { }
    },
    ]]
    Paper = {
        NectarTypes = {
            Satisfying = 0.75,
            Comforting = 0.75,
            Invigorating = 0.75,
            Refreshing = 0.75,
            Motivating = 0.75
        },
        GrowthFields = {}
    },
    Tacky = {
        NectarTypes = {Satisfying = 1.25, Comforting = 1.25},
        GrowthFields = {
            ["Sunflower Field"] = 1.25,
            ["Mushroom Field"] = 1.25,
            ["Dandelion Field"] = 1.25,
            ["Clover Field"] = 1.25,
            ["Blue Flower Field"] = 1.25
        }
    },
    Candy = {
        NectarTypes = {Motivating = 1.2},
        GrowthFields = {
            ["Coconut Field"] = 1.25,
            ["Strawberry Field"] = 1.25,
            ["Pineapple Patch"] = 1.25
        }
    },
    Hydroponic = {
        NectarTypes = {Refreshing = 1.4, Comforting = 1.4},
        GrowthFields = {
            ["Blue Flower Field"] = 1.5,
            ["Pine Tree Forest"] = 1.5,
            ["Stump Field"] = 1.5,
            ["Bamboo Field"] = 1.5
        }
    },
    Plastic = {
        NectarTypes = {
            Refreshing = 1,
            Invigorating = 1,
            Comforting = 1,
            Satisfying = 1,
            Motivating = 1
        },
        GrowthFields = {}
    },
    Petal = {
        NectarTypes = {Satisfying = 1.5, Comforting = 1.5},
        GrowthFields = {
            ["Sunflower Field"] = 1.5,
            ["Dandelion Field"] = 1.5,
            ["Spider Field"] = 1.5,
            ["Pineapple Patch"] = 1.5,
            ["Coconut Field"] = 1.5
        }
    },
    ["Heat-Treated"] = {
        NectarTypes = {Invigorating = 1.4, Motivating = 1.4},
        GrowthFields = {
            ["Pepper Patch"] = 1.5,
            ["Rose Field"] = 1.5,
            ["Strawberry Field"] = 1.5,
            ["Mushroom Field"] = 1.5
        }
    },
    ["Blue Clay"] = {
        NectarTypes = {Refreshing = 1.2, Comforting = 1.2},
        GrowthFields = {
            ["Blue Flower Field"] = 1.25,
            ["Pine Tree Forest"] = 1.25,
            ["Stump Field"] = 1.25,
            ["Bamboo Field"] = 1.25
        }
    },
    Pesticide = {
        NectarTypes = {Motivating = 1.3, Satisfying = 1.3},
        GrowthFields = {
            ["Strawberry Field"] = 1.3,
            ["Spider Field"] = 1.3,
            ["Bamboo Field"] = 1.3
        }
    }
}

local planterData = deepcopy(fullPlanterData)

local nectarData = {
    Refreshing =  {"Blue Flower Field", "Strawberry Field", "Coconut Field"},
    Invigorating= {"Clover Field", "Cactus Field", "Mountain Top Field", "Pepper Patch"},
    Comforting =  {"Dandelion Field", "Bamboo Field", "Pine Tree Forest"},
    Motivating =  {"Mushroom Field", "Spider Field", "Stump Field", "Rose Field"},
    Satisfying =  {"Sunflower Field", "Pineapple Patch", "Pumpkin Patch"}
}

function GetPlanterData(name)
    local concacbo = LocalPlanters.LoadPlanter
    local PlanterTable = debug.getupvalues(concacbo)[4]
    local tttttt = nil
    for k, v in pairs(PlanterTable) do
        -- if v.IsMine then print(v.Type, name) end
        if v.PotModel and v.IsMine and v.Type == name then
            tttttt = v
        end
    end
    return tttttt
end

local fullnectardata = NectarTypes.GetTypes()

function fetchNectarsData()

    local ndata = {
        Refreshing  = "none",
        Invigorating= "none",
        Comforting  = "none",
        Motivating  = "none",
        Satisfying  = "none"
    }

    if player and ScreenGui then
        if player.PlayerGui and ScreenGui then
            if ScreenGui then
                for i, v in pairs(ScreenGui:GetChildren()) do
                    if v.Name == "TileGrid" then
                        for p, l in pairs(v:GetChildren()) do
                            for k, e in pairs(fullnectardata) do
                                if l:FindFirstChild("BG") then
                                    if l:FindFirstChild("BG"):FindFirstChild("Icon") then
                                        if l:FindFirstChild("BG"):FindFirstChild("Icon").ImageColor3 == e.Color then
                                            local Xsize = l:FindFirstChild("BG").Bar.AbsoluteSize.X
                                            local Ysize = l:FindFirstChild("BG").Bar.AbsoluteSize.Y
                                            local percentage = (Ysize / Xsize) * 100
                                            ndata[k] = percentage
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return ndata
end

function isBlacklisted(nectartype, blacklist)
    local bl = false
    for i, v in pairs(blacklist) do
        if v == nectartype then
            bl = true
        end
    end
    for i, v in pairs(NectarBlacklist) do
        if v == nectartype then
            bl = true
        end
    end
    return bl
end

function calculateLeastNectar(blacklist)
    local leastNectar = nil
    local tempLeastValue = 999

    local nectarData = fetchNectarsData()
    for i, v in pairs(nectarData) do
        if not isBlacklisted(i, blacklist) then
            if v == "none" or v == nil then
                leastNectar = i
                tempLeastValue = 0
            else
                if v <= tempLeastValue then
                    tempLeastValue = v
                    leastNectar = i
                end
            end
        end
    end
    return leastNectar
end
degradedfields = {}
function CheckDegraded()
    for i,v in pairs(Workspace.Planters:GetChildren()) do
        if v.Name == "PlanterBulb" and v.BrickColor == "Burlap" then
            local PlanterBulb = {Object = v, Location = findField(v.Position)}
            if PlanterBulb.Location then
                for _, planter in pairs(fetchAllPlanters()) do
                    if planter.PotModel:GetChildren()[1] and planter.PotModel:GetChildren()[1].Position and findField(planter.PotModel:GetChildren()[1].Position) and findField(planter.PotModel:GetChildren()[1].Position).Name == PlanterBulb.Location.Name then
                        RequestCollectPlanter(planter)
                        table.insert(degradedfields, findField(planter.PotModel:GetChildren()[1].Position).Name)
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait() do
        if macrov2.toggles.autoplanters then
            CheckDegraded()
        end
    end
end)

function farmPlanters()
    --print(formatModule("Planters"), "started cycle")
    local s,err = pcall(function()
        if macrov2.toggles.docustomplanters then
            local plantercycles = {
                {
                    {Planter = macrov2.vars.customplanter11, Field = macrov2.vars.customplanterfield11, Percent = macrov2.vars.customplanterdelay11},
                    {Planter = macrov2.vars.customplanter12, Field = macrov2.vars.customplanterfield12, Percent = macrov2.vars.customplanterdelay12},
                    {Planter = macrov2.vars.customplanter13, Field = macrov2.vars.customplanterfield13, Percent = macrov2.vars.customplanterdelay13},
                    {Planter = macrov2.vars.customplanter14, Field = macrov2.vars.customplanterfield14, Percent = macrov2.vars.customplanterdelay14},
                    {Planter = macrov2.vars.customplanter15, Field = macrov2.vars.customplanterfield15, Percent = macrov2.vars.customplanterdelay15}
                },
                {
                    {Planter = macrov2.vars.customplanter21, Field = macrov2.vars.customplanterfield21, Percent = macrov2.vars.customplanterdelay21},
                    {Planter = macrov2.vars.customplanter22, Field = macrov2.vars.customplanterfield22, Percent = macrov2.vars.customplanterdelay22},
                    {Planter = macrov2.vars.customplanter23, Field = macrov2.vars.customplanterfield23, Percent = macrov2.vars.customplanterdelay23},
                    {Planter = macrov2.vars.customplanter24, Field = macrov2.vars.customplanterfield24, Percent = macrov2.vars.customplanterdelay24},
                    {Planter = macrov2.vars.customplanter25, Field = macrov2.vars.customplanterfield25, Percent = macrov2.vars.customplanterdelay25}
                },
                {
                    {Planter = macrov2.vars.customplanter31, Field = macrov2.vars.customplanterfield31, Percent = macrov2.vars.customplanterdelay31},
                    {Planter = macrov2.vars.customplanter32, Field = macrov2.vars.customplanterfield32, Percent = macrov2.vars.customplanterdelay32},
                    {Planter = macrov2.vars.customplanter33, Field = macrov2.vars.customplanterfield33, Percent = macrov2.vars.customplanterdelay33},
                    {Planter = macrov2.vars.customplanter34, Field = macrov2.vars.customplanterfield34, Percent = macrov2.vars.customplanterdelay34},
                    {Planter = macrov2.vars.customplanter35, Field = macrov2.vars.customplanterfield35, Percent = macrov2.vars.customplanterdelay35}
                }
            }

            local steps = {
                5, 5, 5
            }

            for i,cycle in pairs(plantercycles) do
                for j,step in pairs(cycle) do
                    if not step.Planter or not step.Planter:find("Planter") then
                        steps[i] = steps[i] - 1
                    elseif not step.Field or (not step.Field:find("Field") and not step.Field:find("Patch") and not step.Field:find("Forest")) then
                        steps[i] = steps[i] - 1
                    end
                end
            end

            for i=1,3 do
                if not isfile("macrov2/plantercache/"..player.Name.."/cycle"..i.."cache.file") then
                    for _,planter in pairs(fetchAllPlanters()) do
                        RequestCollectPlanter(planter)
                    end
                    writefile("macrov2/plantercache/"..player.Name.."/cycle"..i.."cache.file", "1")
                end
            end

            if not temptable.started.ant and macrov2.toggles.autofarm and not temptable.converting and not temptable.started.monsters then
                for i,cycle in pairs(plantercycles) do
                    if steps[i] == 0 then continue end
                    local planted = false
                    local currentstep = isfile("macrov2/plantercache/"..player.Name.."/cycle"..i.."cache.file") and tonumber(readfile("macrov2/plantercache/"..player.Name.."/cycle"..i.."cache.file")) or 1
                    currentstep = (currentstep - 1) % steps[i] + 1
                    for j,step in pairs(cycle) do
                        if step.Percent and step.Planter and step.Planter:find("Planter") and step.Field and (step.Field:find("Field") or step.Field:find("Patch") or step.Field:find("Forest")) then
                            for _,planter in pairs(fetchAllPlanters()) do
                                if planter.PotModel and planter.PotModel.Parent and planter.PotModel.PrimaryPart then
                                    if planter.GrowthPercent >= step.Percent / 100 then
                                        if planter.PotModel.Name == step.Planter and findField(planter.PotModel.PrimaryPart.Position).Name == step.Field then
                                            RequestCollectPlanter(planter)
                                        end
                                    else
                                        if planter.PotModel.Name == step.Planter and findField(planter.PotModel.PrimaryPart.Position).Name == step.Field then
                                            planted = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if not planted and cycle[currentstep].Planter and #fetchAllPlanters() < 3 then
                        local planter = cycle[currentstep].Planter
                        if planter == "The Planter Of Plenty" and GetItemListWithValue()["PlentyPlanter"] and GetItemListWithValue()["PlentyPlanter"] > 0 then
                            PlantPlanter(planter, cycle[currentstep].Field)
                            writefile("macrov2/plantercache/"..player.Name.."/cycle"..i.."cache.file", tostring((currentstep - 1) % steps[i] + 2))
                        else
                            if GetItemListWithValue()[planter:gsub(" Planter", "") .. "Planter"] and GetItemListWithValue()[planter:gsub(" Planter", "") .. "Planter"] > 0 then
                                PlantPlanter(planter:gsub(" Planter", ""), cycle[currentstep].Field)
                                writefile("macrov2/plantercache/"..player.Name.."/cycle"..i.."cache.file", tostring((currentstep - 1) % steps[i] + 2))
                            end
                        end
                    end
                end
            end
        elseif macrov2.toggles.autoplanters then
            NectarBlacklist["Invigorating"] = macrov2.toggles.blacklistinvigorating and "Invigorating" or nil
            NectarBlacklist["Comforting"] = macrov2.toggles.blacklistcomforting and "Comforting" or nil
            NectarBlacklist["Motivating"] = macrov2.toggles.blacklistmotivating and "Motivating" or nil
            NectarBlacklist["Refreshing"] = macrov2.toggles.blacklistrefreshing and "Refreshing" or nil
            NectarBlacklist["Satisfying"] = macrov2.toggles.blacklistsatisfying and "Satisfying" or nil

            planterData["Paper"] = not macrov2.toggles.paperplanter and fullPlanterData["Paper"] or nil
            planterData["Plastic"] = not macrov2.toggles.plasticplanter and fullPlanterData["Plastic"] or nil
            planterData["Candy"] = not macrov2.toggles.candyplanter and fullPlanterData["Candy"] or nil
            planterData["Red Clay"] = not macrov2.toggles.redclayplanter and fullPlanterData["Red Clay"] or nil
            planterData["Blue Clay"] = not macrov2.toggles.blueclayplanter and fullPlanterData["Blue Clay"] or nil
            planterData["Tacky"] = not macrov2.toggles.tackyplanter and fullPlanterData["Tacky"] or nil
            planterData["Pesticide"] = not macrov2.toggles.pesticideplanter and fullPlanterData["Pesticide"] or nil
            planterData["Petal"] = not macrov2.toggles.petalplanter and fullPlanterData["Petal"] or nil
            planterData["Hydroponic"] = not macrov2.toggles.hydroponicplanter and fullPlanterData["Hydroponic"] or nil
            planterData["Heat-Treated"] = not macrov2.toggles.heattreatedplanter and fullPlanterData["Heat-Treated"] or nil
            planterData["Plenty"] = not macrov2.toggles.planterofplenty and fullPlanterData["Plenty"] or nil

            if macrov2.toggles.autoplanters and not temptable.started.ant and macrov2.toggles.autofarm and not temptable.converting then
                RequestCollectPlanters(fetchAllPlanters())
                -- print("after collect")
                if #fetchAllPlanters() < 3 then
                    local LeastNectar = calculateLeastNectar(fetchNectarBlacklist())
                    local Field = fetchBestFieldWithNectar(LeastNectar)
                    local Planter = fetchBestMatch(LeastNectar, Field)
                    if LeastNectar and Field and Planter then
                        -- print(formatString(Planter, Field, LeastNectar))
                        PlantPlanter(Planter, Field)
                    end
                end
            end
        end
    end)
    if err then warn(formatModule("Planters"), err) end
end
debugNextStep(true)
function donateToShrine(item, qnt)
    local s, e = pcall(function()
        temptable.donatingtoshrine = true
        disableall()
        ReplicatedStorage.Events.WindShrineDonation:InvokeServer(item, qnt)
        task.wait(0.5)
        ReplicatedStorage.Events.WindShrineTrigger:FireServer()

        local UsePlatform = Workspace.NPCs["Wind Shrine"].Stage
        moveTo(UsePlatform.Position + Vector3.new(0, 3, 0))

        for i = 1, 20 do
            task.wait(0.05)
            for i, v in pairs(temptable.tokenpath:GetChildren()) do
                if (v.Position - UsePlatform.Position).magnitude < 60 and
                    v.CFrame.YVector.Y == 1 then
                    moveTo(v.Position)
                end
            end
        end
        temptable.donatingtoshrine = false
        enableall()
    end)
    if not s then --[[print(e)]] end
end

local function isWindshrineOnCooldown()
    local isOnCooldown = false
    local cooldown = (StatTools.GetLastCooldownTime(ClientStatCache:Get(), "WindShrine"))
    if cooldown > 0 then isOnCooldown = true end
    return isOnCooldown
end

local function getTimeSinceToyActivation(name)
    return ServerTime() - (ClientStatCache:Get("ToyTimes")[name] or math.huge)
end

local function getTimeUntilToyAvailable(n)
    return (Workspace.Toys[n]:FindFirstChild("Cooldown") or Workspace.Toys[n]:FindFirstChild("PlaytimeCooldown")).Value - getTimeSinceToyActivation(n)
end

function useConvertors()
    local conv = {
        "Instant Converter", "Instant Converter B", "Instant Converter C"
    }

    local lastWithoutCooldown = nil

    for i, v in pairs(conv) do
        if canToyBeUsed(v) == true then lastWithoutCooldown = v end
    end
    local converted = false
    if lastWithoutCooldown ~= nil and
        string.find(macrov2.vars.autouseMode, "Ticket") or
        string.find(macrov2.vars.autouseMode, "All") then
        if converted == false then
            ReplicatedStorage.Events.ToyEvent:FireServer(lastWithoutCooldown)
            converted = true
        end
    end
    if GetItemListWithValue()["Snowflake"] > 0 and
        string.find(macrov2.vars.autouseMode, "Snowflak") or
        string.find(macrov2.vars.autouseMode, "All") then
        PlayerActivesCommand:FireServer({["Name"] = "Snowflake"})
    end
    if GetItemListWithValue()["Coconut"] > 0 and
        string.find(macrov2.vars.autouseMode, "Coconut") or
        string.find(macrov2.vars.autouseMode, "All") then
        PlayerActivesCommand:FireServer({["Name"] = "Coconut"})
    end
end

function fetchBuffTable(stats)
    local stTab = {}
    if player and ScreenGui then
        if player.PlayerGui and ScreenGui then
            if ScreenGui then
                for i, v in pairs(ScreenGui:GetChildren()) do
                    if v.Name == "TileGrid" then
                        for p, l in pairs(v:GetChildren()) do
                            if l:FindFirstChild("BG") then
                                if l:FindFirstChild("BG"):FindFirstChild("Icon") then
                                    local ic = l:FindFirstChild("BG"):FindFirstChild("Icon")
                                    for field, fdata in pairs(stats) do
                                        if fdata["DecalID"] ~= nil then
                                            if string.find(ic.Image, fdata["DecalID"]) then
                                                if ic.Parent:FindFirstChild("Text") then
                                                    if ic.Parent:FindFirstChild("Text").Text == "" then
                                                        stTab[field] = 1
                                                    else
                                                        local thing = ""
                                                        thing = string.gsub(ic.Parent:FindFirstChild("Text").Text, "x", "")
                                                        stTab[field] = tonumber(thing + 1)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return stTab
end

function fetchBestMatch(nectartype, field)
    local bestPlanter = nil
    local bestNectarMult = 0
    local bestFieldGrowthRate = 0

    local myPlanters = debug.getupvalues(LocalPlanters.LoadPlanter)[4]

    for i, v in pairs(planterData) do
        if not GetPlanterData(i) and GetItemListWithValue()[i .. "Planter"] then
            if GetItemListWithValue()[i .. "Planter"] >= 1 then
                if v.GrowthFields[field] ~= nil then
                    if v.GrowthFields[field] > bestFieldGrowthRate then
                        bestFieldGrowthRate = v.GrowthFields[field]
                        bestPlanter = i
                    end
                end
            end
        end
    end
    for i, v in pairs(planterData) do
        if not GetPlanterData(i) and GetItemListWithValue()[i .. "Planter"] then
            if GetItemListWithValue()[i .. "Planter"] >= 1 then
                if v.NectarTypes[nectartype] ~= nil then
                    if v.NectarTypes[nectartype] > bestNectarMult then
                        local totalNectarFieldGrowthMult = 0
                        if v["GrowthFields"][field] ~= nil then
                            totalNectarFieldGrowthMult = totalNectarFieldGrowthMult + (v["GrowthFields"][field])
                        end
                        bestNectarMult = (v.NectarTypes[nectartype] + totalNectarFieldGrowthMult)
                        bestPlanter = i
                    end
                end
            end
        end
    end
    return bestPlanter
end

function getPlanterLocation(plnt)
    local resultingField = "None"
    local lowestMag = math.huge
    for i, v in pairs(Workspace.FlowerZones:GetChildren()) do
        if (v.Position - plnt.Position).magnitude < lowestMag then
            lowestMag = (v.Position - plnt.Position).magnitude
            resultingField = v.Name
        end
    end
    return resultingField
end

function isFieldOccupied(field)
    local isOccupied = false
    local concacbo = LocalPlanters.LoadPlanter
    local PlanterTable = debug.getupvalues(concacbo)[4]

    for k, v in pairs(PlanterTable) do
        if v.PotModel and v.PotModel.Parent and v.PotModel.PrimaryPart then
            if getPlanterLocation(v.PotModel.PrimaryPart) == field then
                isOccupied = true
            end
        end
    end
    return isOccupied
end

function fetchAllPlanters()
    local p = {}
    local concacbo = LocalPlanters.LoadPlanter
    local PlanterTable = debug.getupvalues(concacbo)[4]
    -- warn(#PlanterTable)

    for k, v in pairs(PlanterTable) do
        if v.PotModel and v.PotModel.Parent and v.IsMine == true then
            p[k] = v
        end
    end
    return p
end

function isNectarPending(nectartype)
    local planterz = fetchAllPlanters()
    local isPending = false
    for i, v in pairs(planterz) do
        local location = getPlanterLocation(v.PotModel.PrimaryPart)
        if location then
            local conftype = getNectarFromField(location)
            if conftype then
                if conftype == nectartype then
                    isPending = true
                end
            end
        end
    end
    return isPending
end

function fetchBestFieldWithNectar(nectar)
    local bestField = "None"
    local nectarFields = nectarData[nectar]
    local fieldPlaceholderValue = ""

    repeat
        task.wait(0.01)
        local randomField = nectarFields[math.random(1, #nectarFields)]
        if randomField then
            fieldPlaceholderValue = randomField
        end
    until not isFieldOccupied(fieldPlaceholderValue) and not table.find(degradedfields, randomField)

    bestField = fieldPlaceholderValue

    return bestField
end

function checkIfPlanterExists(pNum)
    local exists = false
    local stuffs = fetchAllPlanters()
    if stuffs ~= {} then
        for i, v in pairs(stuffs) do
            if v["ActorID"] == pNum then
                exists = true
            end
        end
    end
    return exists
end

function collectSpecificPlanter(prt, id)
    if prt then
        if player.Character then
            if api.humanoidrootpart() then
                -- print("Tried to collect")
                moveTo(prt.Position)
                -- pathfinding.Tween(80, prt.Position + Vector3.new(0,2,0))
                -- print("here!")
                task.wait(1) -- just removed 5s delay
                ReplicatedStorage.Events.PlanterModelCollect:FireServer(id)
                task.wait(2)
                for i = 1, 5 do
                    gettoken(api.humanoidrootpart().Position)
                end
                --sakata
            end
        end
    end
end

function RequestCollectPlanter(planter)
    if planter.PotModel and planter.PotModel.Parent and planter.ActorID then
        repeat
            task.wait(.5)
            collectSpecificPlanter(planter.PotModel.PrimaryPart, planter.ActorID)
        until not checkIfPlanterExists(planter.ActorID) 
    end
end

function RequestCollectPlanters(planterTable) 
    -- task.spawn(function() 
    -- print("request collect planters called")
        local plantersToCollect = {} 
        if planterTable then 
            for i, v in pairs(planterTable) do 
                if v["GrowthPercent"] ~= nil then 
                    if macrov2.vars.planterharvestamount then 
                        if v["GrowthPercent"] >= (macrov2.vars.planterharvestamount / 100) then 
                            table.insert(plantersToCollect, { 
                                ["PM"] = v["PotModel"].PrimaryPart,
                                ["AID"] = v["ActorID"]
                            }) 
                        end 
                    else 
                        if v["GrowthPercent"] >= (75 / 100) then 
                            table.insert(plantersToCollect, {
                                ["PM"] = v["PotModel"].PrimaryPart,
                                ["AID"] = v["ActorID"]
                            })
                        end 
                    end 
                end 
            end 
        end 
        if plantersToCollect ~= {} then 
            for i, v in pairs(plantersToCollect) do 
                repeat
                    task.wait(0.5)
                    -- print("collecting")
                    collectSpecificPlanter(v["PM"], v["AID"])
                until checkIfPlanterExists(v["AID"]) == false
            end 
        end 
    -- end) 
end 

function PlantPlanter(name, field)
    -- task.wait(1)
    -- print("Plant planter called with", name, field)
    if field and name then
        local specField = Workspace.FlowerZones:FindFirstChild(field)
        -- print(specField)
        if specField ~= nil then
            temptable.planting = true
            local attempts = 0
            repeat
                if player.Character then
                    if api.humanoidrootpart() then
                        repeat
                            moveTo(specField.Position)
                            wait()
                        until (api.humanoidrootpart().Position - specField.Position).magnitude < 25
                        wait(1)
                        if name == "Plenty" then
                            PlayerActivesCommand:FireServer({["Name"] = "The Planter Of Plenty"})
                        else
                            PlayerActivesCommand:FireServer({["Name"] = name .. " Planter"})
                        end
                    end
                    attempts = attempts + 1
                    task.wait(1)
                end
            until GetPlanterData(name) ~= nil or attempts == 15
            temptable.planting = false
        end
    end
end

function getNectarFromField(field)
    local foundnectar = nil
    for i, v in pairs(nectarData) do
        for k, p in pairs(v) do
            if p == field then
                foundnectar = i
            end
        end
    end
    return foundnectar
end

function fetchNectarBlacklist()
    local nblacklist = {}
    for i, v in pairs(nectarData) do
        if isNectarPending(i) == true then
            table.insert(nblacklist, i)
        end
    end
    return nblacklist
end

-- function formatString(Planter, Field, Nectar)
--     return "You should plant a " .. Planter .. " Planter in the " .. Field .. " to get " .. Nectar .. " Nectar."
-- end

stopLoadingCycle = true

debugNextStep("Loadding the GUI")

welcomeLabel:Set("Welcome, " .. api.nickname .. "!")
information:Label("Script version: " .. temptable.version)
information:Label(Danger.." - Not Safe Function")
information:Label("⚙ - Configurable Function")
information:Label("📜 - May be exploit specific")
information:Label("Head: Narnia#1337")
information:Label("UI: complex#8999")
information:Label("Script by Boxking776 and RoseGold#5441")
information:Label("Originally by weuz_ and mrdevl")
local gainedhoneylabel = information:Label("Gained Honey: 0")
local honeyperhourlabel = information:Label("Honey per hour: 0")
local uptimelabel = information:Label("Uptime: 0")
information:Button("Discord Invite", function()
    setclipboard("https://discord.gg/mv2")
end)
local extraInformation = hometab:Section("Extras")
extraInformation:Label("UI Toggle: Semicolon")
--extraInformation:Label("To use Auto Quest, you MUST have your quest menu open")
extraInformation:Label("Setting 0 as your Discord ID will ping nobody")
extraInformation:Label("When typing anything into a textbox, you must press enter.")
extraInformation:Button("Stop Pathfind", function()
    macrov2.toggles.pathfind = false
    task.wait(10)
    macrov2.toggles.pathfind = true
end)
extraInformation:Button("Save Settings", function()
    writefile("macrov2/BSS_" .. player.Name .. ".json", HttpService:JSONEncode(macrov2))
    api.notify("Macro v2 "..temptable.version,"Config successfully saved!", 3)
end)
guiElements["toggles"]["useBot"] = extraInformation:Toggle("Enable Discord Bot Usage", function(State)
    macrov2.toggles.useBot = State
end)
guiElements["vars"]["discordid"] = extraInformation:Box("Discord ID", "", function(Value)
    if tonumber(Value) then
        macrov2.vars.discordid = Value
    else
        api.notify("Macro v2 " .. temptable.version, "Invalid ID!", 2)
    end
end)

local farmtab = Window:Tab("Farming")
-- Farm Tab Stuff
local farmo = farmtab:Section("Farming")
local fielddropdown = farmo:Dropdown("Field", fieldstable, function(String)
    macrov2.vars.field = String
end)
fielddropdown:Set(fieldstable[1])
guiElements["vars"]["field"] = fielddropdown
local convertatslider = farmo:Slider("Convert At", function(Value) macrov2.vars.convertat = Value end, {Min = 0, Max = 100, Default = 100})
guiElements["vars"]["convertat"] = convertatslider
local autofarmtoggle = farmo:Toggle("Autofarm [⚙]", function(State)
    macrov2.toggles.autofarm = State
end)
guiElements["toggles"]["autofarm"] = autofarmtoggle
-- autofarmtoggle:CreateKeybind("U", function(Key) end)
guiElements["toggles"]["autodig"] = farmo:Toggle("Autodig", function(State)
    macrov2.toggles.autodig = State
end)

guiElements["toggles"]["ignorehoneytokens"] = farmo:Toggle("Ignore Honey Tokens", function(State)
    macrov2.toggles.ignorehoneytokens = State
end)

local contt = farmtab:Section("Container Tools")
guiElements["toggles"]["disableconversion"] = contt:Toggle("Don't Convert Pollen", function(State)
    macrov2.toggles.disableconversion = State
end)
guiElements["toggles"]["autouseconvertors"] = contt:Toggle("Auto Bag Reduction", function(Boole)
    macrov2.toggles.autouseconvertors = Boole
end)
guiElements["vars"]["autouseMode"] = contt:Dropdown("Bag Reduction Mode", {
    "Ticket Converters", "Just Snowflakes", "Just Coconuts",
    "Snowflakes and Coconuts", "Tickets and Snowflakes", "Tickets and Coconuts",
    "All"
}, function(Select) macrov2.vars.autouseMode = Select end)
guiElements["vars"]["autoconvertWaitTime"] = contt:Slider("Reduction Time", function(state)
    macrov2.vars.autoconvertWaitTime = tonumber(state)
end, {Min = 3, Max = 20, Default = 10})
do
guiElements["toggles"]["autosprinkler"] = farmo:Toggle("Auto Sprinkler", function(State) macrov2.toggles.autosprinkler = State end)
guiElements["toggles"]["farmbubbles"] = farmo:Toggle("Farm Bubbles", function(State) macrov2.toggles.farmbubbles = State end)
guiElements["toggles"]["farmflame"] = farmo:Toggle("Farm Flames", function(State) macrov2.toggles.farmflame = State end)
guiElements["toggles"]["farmcoco"] = farmo:Toggle("Farm Coconuts", function(State) macrov2.toggles.farmcoco = State end)
guiElements["toggles"]["farmshower"] = farmo:Toggle("Farm Shower", function(State) macrov2.toggles.farmshower = State end)
guiElements["toggles"]["collectcrosshairs"] = farmo:Toggle("Farm Precise Crosshairs", function(State) macrov2.toggles.collectcrosshairs = State end)
guiElements["toggles"]["farmfuzzy"] = farmo:Toggle("Farm Fuzzy Bombs", function(State) macrov2.toggles.farmfuzzy = State end)
guiElements["toggles"]["farmunderballoons"] = farmo:Toggle("Farm Under Balloons", function(State) macrov2.toggles.farmunderballoons = State end)
guiElements["toggles"]["farmclouds"] = farmo:Toggle("Farm Under Clouds", function(State) macrov2.toggles.farmclouds = State end)
guiElements["toggles"]["fireflies"] = farmo:Toggle("Farm Fireflies", function(State) macrov2.toggles.fireflies = State end)
guiElements["toggles"]["honeymaskconv"] = farmo:Toggle("Auto Honey Mask", function(bool) macrov2.toggles.honeymaskconv = bool end)
guiElements["vars"]["defmask"] = farmo:Dropdown("Default Mask", maskstable, function(Option) macrov2.vars.defmask = Option end)
guiElements["vars"]["deftool"] = farmo:Dropdown("Default Tool", collectorstable, function(val) macrov2.vars.deftool = val end)
guiElements["toggles"]["followplayer"] = farmo:Toggle("Follow Player", function(bool)
    macrov2.toggles.followplayer = bool
end)
guiElements["vars"]["playertofollow"] = farmo:Box("Player to Follow", "player name", function(Value)
    macrov2.vars.playertofollow = Value
end)
guiElements["toggles"]["farmclosestleaf"] = farmo:Toggle("Farm Closest Leaves", function(State) macrov2.toggles.farmclosestleaf = State end)

local farmt = farmtab:Section("Farming")
guiElements["toggles"]["autodispense"] = farmt:Toggle("Auto Dispenser [⚙]", function(State) macrov2.toggles.autodispense = State end)
guiElements["toggles"]["autoboosters"] = farmt:Toggle("Auto Field Boosters [⚙]", function(State) macrov2.toggles.autoboosters = State end)
guiElements["toggles"]["clock"] = farmt:Toggle("Auto Wealth Clock", function(State) macrov2.toggles.clock = State end)
guiElements["toggles"]["freeantpass"] = farmt:Toggle("Auto Free Ant Pass", function(State) macrov2.toggles.freeantpass = State end)
guiElements["toggles"]["freerobopass"] = farmt:Toggle("Auto Free Robo Pass", function(State) macrov2.toggles.freerobopass = State end)
guiElements["toggles"]["farmsprouts"] = farmt:Toggle("Farm Sprouts", function(State) macrov2.toggles.farmsprouts = State end)
guiElements["toggles"]["sproutatnight"] = farmt:Toggle("Only Farm Sprouts At Night", function(State) macrov2.toggles.sproutatnight = State end)
guiElements["toggles"]["farmrares"] = farmt:Toggle("Teleport To Rares ["..Danger.."]", function(State) macrov2.toggles.farmrares = State end)
-- guiElements["toggles"]["autoquest"] = farmt:Toggle("Auto Accept/Confirm Quests [⚙]", function(State) macrov2.toggles.autoquest = State end)
-- guiElements["toggles"]["autodoquest"] = farmt:Toggle("Auto Do Quests [⚙]", function(State) macrov2.toggles.autodoquest = State end)
guiElements["toggles"]["honeystorm"] = farmt:Toggle("Auto Honeystorm", function(State) macrov2.toggles.honeystorm = State end)
guiElements["toggles"]["resetbeenergy"] = farmt:Toggle("Reset Bee Energy after X Conversions", function(bool)
    macrov2.toggles.resetbeenergy = bool
end)
guiElements["vars"]["resettimer"] = farmt:Box("Conversion Amount", "default = 3", function(Value)
    macrov2.vars.resettimer = tonumber(Value)
end)

combtab = Window:Tab("Combat")
-- Combat Tab Stuff
mobkill = combtab:Section("Combat")
mobkill:Toggle("Train Crab", function(State)
    macrov2.toggles.traincrab = State
    if State then
        moveTo(CFrame.new(-375, 110, 535))
        task.wait(5)
        api.tween(1, CFrame.new(-256, 130, 475))
    end
    cocopad.CanCollide = State
end)

mobkill:Toggle("Train Snail", function(State)
    macrov2.toggles.trainsnail = State
    local stumpField = Workspace.FlowerZones["Stump Field"]
    if State then
        local stumpFieldCFrame = CFrame.new(stumpField.Position - Vector3.new(0,20,0))
        api.tween(domapi.TweenSpeed(stumpFieldCFrame),stumpFieldCFrame)
    else
        local stumpFieldCFrame = CFrame.new(stumpField.Position + Vector3.new(0,3,0))
        api.tween(domapi.TweenSpeed(stumpFieldCFrame),stumpFieldCFrame)
    end
end)
guiElements["toggles"]["killmondo"] = mobkill:Toggle("Kill Mondo", function(State) macrov2.toggles.killmondo = State end)
--guiElements["toggles"]["traincommando"] = mobkill:Toggle("Train Commando", function(State) macrov2.toggles.traincommando = State end)
guiElements["toggles"]["killvicious"] = mobkill:Toggle("Kill Vicious", function(State) macrov2.toggles.killvicious = State end)
guiElements["toggles"]["killwindy"] = mobkill:Toggle("Kill Windy", function(State) macrov2.toggles.killwindy = State end)
local autokillmobstoggle = mobkill:Toggle("Auto Kill Mobs", function(State) macrov2.toggles.autokillmobs = State end)
autokillmobstoggle:Tooltip("Kills mobs after x pollen converting")
guiElements["toggles"]["autokillmobs"] = autokillmobstoggle
guiElements["toggles"]["avoidmobs"] = mobkill:Toggle("Avoid Mobs", function(State) macrov2.toggles.avoidmobs = State end)
local autoanttoggle = mobkill:Toggle("Auto Ant", function(State) macrov2.toggles.autoant = State end)
autoanttoggle:Tooltip("You Need Spark Staff; Goes to Ant Challenge after pollen converting")
guiElements["toggles"]["autoant"] = autoanttoggle
end
local amks = combtab:Section("Auto Kill Mobs Settings")
guiElements["vars"]["monstertimer"] = amks:Box("Reset Mob Timer Minutes", "default = 15", function(Value)
    if tonumber(Value) then
        macrov2.vars.monstertimer = tonumber(Value)
    end
end)
amks:Button("Kill Mobs", function()
    temptable.started.monsters = true
    killmobs()
    temptable.started.monsters = false
end)

amks:Button("Start Ant", function()
    moveTo(CFrame.new(92.2364731, 32.4959831, 508.285187))

    farmant()
    temptable.started.ant = false
end)

guiElements["vars"]["viciousmax"] = mobkill:Slider("Max Vicious Level", function(Slide) macrov2.vars.viciousmax = Slide end, {Min = 1, Max = 20, Default = 20}) --sakata
guiElements["vars"]["viciousmin"] = mobkill:Slider("Min Vicious Level", function(Slide) macrov2.vars.viciousmin = Slide end, {Min = 1, Max = 20, Default = 20}) --sakata
guiElements["vars"]["windymax"] = mobkill:Slider("Max Windy Level", function(Slide) macrov2.vars.windymax = Slide end, {Min = 1, Max = 20, Default = 20}) --sakata

local itemstab = Window:Tab("Items")
-- Items Tab Stuff

useitems = itemstab:Section("Use Items")

guiElements["vars"]["autosprout"] = useitems:Toggle("Auto Plant Sprout", function(State)
    macrov2.toggles.autosprout = State --PlayerActivesCommand:FireServer({["Name"] = "Sprout"})
end)
guiElements["toggles"]["sproutplantnight"] = useitems:Toggle("Auto Plant Sprout At Night", function(State)
    macrov2.toggles.sproutplantnight = State --PlayerActivesCommand:FireServer({["Name"] = "Sprout"})
end)

task.spawn(function()
    while task.wait(2) do
        if macrov2.toggles.autosprout then
            if macrov2.toggles.sproutplantnight and getCurrentTime() == "Night" then
                PlayerActivesCommand:FireServer({["Name"] = "Magic Bean"})
            elseif not macrov2.toggles.sproutplantnight then
                PlayerActivesCommand:FireServer({["Name"] = "Magic Bean"})
            end
        end
    end
end)

useitems:Button("Use All Buffs ["..Danger.."]", function()
    for i, v in pairs(buffTable) do
        PlayerActivesCommand:FireServer({["Name"] = i})
    end
end)

for i, v in pairs(buffTable) do
    useitems:Button("Use " .. i, function()
        PlayerActivesCommand:FireServer({["Name"] = i})
    end)
    guiElements["vars"]["autouse"..i] = useitems:Toggle("Auto Use " .. i, function(bool)
        buffTable[i].b = bool
        macrov2.vars["autouse"..i] = bool
    end)
end

guiElements["vars"]["autouseStinger"] = useitems:Toggle("Auto Use Stinger", function(bool)
    macrov2.toggles["autouseStinger"] = bool
end)

guiElements["vars"]["autouseSnowflake"] = useitems:Toggle("Auto Use Snowflake", function(bool)
    macrov2.toggles["autouseSnowflake"] = bool
end)

guiElements["vars"]["autouseJellyBeans"] = useitems:Toggle("Auto Use Jelly Beans", function(bool)
    macrov2.toggles["autouseJellyBeans"] = bool
end)

local maxJellyUsageInput = useitems:Box("Auto Jelly Beans interval (seconds)", "ex: 35",function(Text)
    if not tonumber(Text) then
        api.notify("Only numbers allowed")
        return 
    end
    macrov2.vars["autouseJellyBeansInterval"] = tonumber(Text)
end
)

autofeed = itemstab:Section("Auto Feed")

local function feedAllBees(treat, amt)
    for L = 1, 5 do
        for U = 1, 10 do
            ReplicatedStorage.Events.ConstructHiveCellFromEgg:InvokeServer(L, U, treat, amt)
        end
    end
end

guiElements["vars"]["selectedTreat"] = autofeed:Dropdown("Select Treat", treatsTable, function(option)
    macrov2.vars.selectedTreat = option
end)
guiElements["vars"]["selectedTreatAmount"] = autofeed:Box("Treat Amount", "10", function(Value)
    macrov2.vars.selectedTreatAmount = tonumber(Value)
end)
autofeed:Button("Feed All Bees", function()
    feedAllBees(macrov2.vars.selectedTreat, macrov2.vars.selectedTreatAmount)
end)

local windShrine = itemstab:Section("Wind Shrine")
guiElements["vars"]["donoItem"] = windShrine:Dropdown("Select Item", donatableItemsTable, function(Option)
    macrov2.vars.donoItem = Option
end)
guiElements["vars"]["donoAmount"] = windShrine:Box("Item Quantity", "10", function(Value)
    macrov2.vars.donoAmount = tonumber(Value)
end)
windShrine:Button("Donate", function()
    donateToShrine(macrov2.vars.donoItem, macrov2.vars.donoAmount)
end)
guiElements["toggles"]["autodonate"] = windShrine:Toggle("Auto Donate", function(selection)
    macrov2.toggles.autodonate = selection
end)

local plantertab = Window:Tab("Planters")
-- Planters Tab Stuff
local plantersection = plantertab:Section("Automatic Planters & Nectars")
guiElements["toggles"]["autoplanters"] = plantersection:Toggle("Auto Planters", function(State) macrov2.toggles.autoplanters = State end)
guiElements["toggles"]["blacklistinvigorating"] = plantersection:Toggle("Blacklist Invigorating", function(State) macrov2.toggles.blacklistinvigorating = State end)
guiElements["toggles"]["blacklistcomforting"] = plantersection:Toggle("Blacklist Comforting", function(State) macrov2.toggles.blacklistcomforting = State end)
guiElements["toggles"]["blacklistmotivating"] = plantersection:Toggle("Blacklist Motivating", function(State) macrov2.toggles.blacklistmotivating = State end)
guiElements["toggles"]["blacklistrefreshing"] = plantersection:Toggle("Blacklist Refreshing", function(State) macrov2.toggles.blacklistrefreshing = State end)
guiElements["toggles"]["blacklistsatisfying"] = plantersection:Toggle("Blacklist Satisfying", function(State) macrov2.toggles.blacklistsatisfying = State end)
guiElements["vars"]["planterharvestamount"] = plantersection:Slider("Planter Harvest Percentage", function(Value)
    macrov2.vars.planterharvestamount = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["toggles"]["plasticplanter"] = plantersection:Toggle("Blacklist Plastic Planter", function(State) macrov2.toggles.plasticplanter = State end)
guiElements["toggles"]["candyplanter"] = plantersection:Toggle("Blacklist Candy Planter", function(State) macrov2.toggles.candyplanter = State end)
guiElements["toggles"]["redclayplanter"] = plantersection:Toggle("Blacklist Red Clay Planter", function(State) macrov2.toggles.redclayplanter = State end)
guiElements["toggles"]["blueclayplanter"] = plantersection:Toggle("Blacklist Blue Clay Planter", function(State) macrov2.toggles.blueclayplanter = State end)
guiElements["toggles"]["tackyplanter"] = plantersection:Toggle("Blacklist Tacky Planter", function(State) macrov2.toggles.tackyplanter = State end)
guiElements["toggles"]["paperplanter"] = plantersection:Toggle("Blacklist Paper Planter", function(State) macrov2.toggles.paperplanter = State end)
guiElements["toggles"]["pesticideplanter"] = plantersection:Toggle("Blacklist Pesticide Planter", function(State) macrov2.toggles.pesticideplanter = State end)
guiElements["toggles"]["petalplanter"] = plantersection:Toggle("Blacklist Petal Planter", function(State) macrov2.toggles.petalplanter = State end)
guiElements["toggles"]["hydroponicplanter"] = plantersection:Toggle("Blacklist Hydroponic Planter", function(State) macrov2.toggles.hydroponicplanter = State end)
guiElements["toggles"]["heattreatedplanter"] = plantersection:Toggle("Blacklist Heat-Treated Planter", function(State) macrov2.toggles.heattreatedplanter = State end)
guiElements["toggles"]["planterofplenty"] = plantersection:Toggle("Blacklist Planter Of Planty", function(State) macrov2.toggles.planterofplenty = State end)

local customplanterssection = plantertab:Section("Custom Planters")
customplanterssection:Label("Turning this on will disable auto planters!\n["..Danger.."] You should know what you are doing before turning this on! ["..Danger.."]")
guiElements["toggles"]["docustomplanters"] = customplanterssection:Toggle("Custom Planters", function(State) macrov2.toggles.docustomplanters = State end)

local customplanter1section = plantertab:Section("Custom Planter 1")
guiElements["vars"]["customplanterfield11"] = customplanter1section:Dropdown("Field 1", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield11 = Option
end)
guiElements["vars"]["customplanter11"] = customplanter1section:Dropdown("Field 1 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter11 = Option
end)
guiElements["vars"]["customplanterdelay11"] = customplanter1section:Slider("Field 1 Harvest %", function(Value)
    macrov2.vars.customplanterdelay11 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield12"] = customplanter1section:Dropdown("Field 2", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield12 = Option
end)
guiElements["vars"]["customplanter12"] = customplanter1section:Dropdown("Field 2 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter12 = Option
end)
guiElements["vars"]["customplanterdelay12"] = customplanter1section:Slider("Field 2 Harvest %", function(Value)
    macrov2.vars.customplanterdelay12 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield13"] = customplanter1section:Dropdown("Field 3", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield13 = Option
end)
guiElements["vars"]["customplanter13"] = customplanter1section:Dropdown("Field 3 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter13 = Option
end)
guiElements["vars"]["customplanterdelay13"] = customplanter1section:Slider("Field 3 Harvest %", function(Value)
    macrov2.vars.customplanterdelay13 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield14"] = customplanter1section:Dropdown("Field 4", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield14 = Option
end)
guiElements["vars"]["customplanter14"] = customplanter1section:Dropdown("Field 4 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter14 = Option
end)
guiElements["vars"]["customplanterdelay14"] = customplanter1section:Slider("Field 4 Harvest %", function(Value)
    macrov2.vars.customplanterdelay14 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield15"] = customplanter1section:Dropdown("Field 5", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield15 = Option
end)
guiElements["vars"]["customplanter15"] = customplanter1section:Dropdown("Field 5 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter15 = Option
end)
guiElements["vars"]["customplanterdelay15"] = customplanter1section:Slider("Field 5 Harvest %", function(Value)
    macrov2.vars.customplanterdelay15 = Value
end, {Min = 0, Max = 100, Default = 75})

local customplanter2section = plantertab:Section("Custom Planter 2")
guiElements["vars"]["customplanterfield21"] = customplanter2section:Dropdown("Field 1", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield21 = Option
end)
guiElements["vars"]["customplanter21"] = customplanter2section:Dropdown("Field 1 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter21 = Option
end)
guiElements["vars"]["customplanterdelay21"] = customplanter2section:Slider("Field 1 Harvest %", function(Value)
    macrov2.vars.customplanterdelay21 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield22"] = customplanter2section:Dropdown("Field 2", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield22 = Option
end)
guiElements["vars"]["customplanter22"] = customplanter2section:Dropdown("Field 2 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter22 = Option
end)
guiElements["vars"]["customplanterdelay22"] = customplanter2section:Slider("Field 2 Harvest %", function(Value)
    macrov2.vars.customplanterdelay22 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield23"] = customplanter2section:Dropdown("Field 3", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield23 = Option
end)
guiElements["vars"]["customplanter23"] = customplanter2section:Dropdown("Field 3 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter23 = Option
end)
guiElements["vars"]["customplanterdelay23"] = customplanter2section:Slider("Field 3 Harvest %", function(Value)
    macrov2.vars.customplanterdelay23 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield24"] = customplanter2section:Dropdown("Field 4", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield24 = Option
end)
guiElements["vars"]["customplanter24"] = customplanter2section:Dropdown("Field 4 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter24 = Option
end)
guiElements["vars"]["customplanterdelay24"] = customplanter2section:Slider("Field 4 Harvest %", function(Value)
    macrov2.vars.customplanterdelay24 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield25"] = customplanter2section:Dropdown("Field 5", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield25 = Option
end)
guiElements["vars"]["customplanter25"] = customplanter2section:Dropdown("Field 5 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter25 = Option
end)
guiElements["vars"]["customplanterdelay25"] = customplanter2section:Slider("Field 5 Harvest %", function(Value)
    macrov2.vars.customplanterdelay25 = Value
end, {Min = 0, Max = 100, Default = 75})

local customplanter3section = plantertab:Section("Custom Planter 3")
guiElements["vars"]["customplanterfield31"] = customplanter3section:Dropdown("Field 1 Field", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield31 = Option
end)
guiElements["vars"]["customplanter31"] = customplanter3section:Dropdown("Field 1 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter31 = Option
end)
guiElements["vars"]["customplanterdelay31"] = customplanter3section:Slider("Field 1 Harvest %", function(Value)
    macrov2.vars.customplanterdelay31 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield32"] = customplanter3section:Dropdown("Field 2 Field", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield32 = Option
end)
guiElements["vars"]["customplanter32"] = customplanter3section:Dropdown("Field 2 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter32 = Option
end)
guiElements["vars"]["customplanterdelay32"] = customplanter3section:Slider("Field 2 Harvest %", function(Value)
    macrov2.vars.customplanterdelay32 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield33"] = customplanter3section:Dropdown("Field 3 Field", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield33 = Option
end)
guiElements["vars"]["customplanter33"] = customplanter3section:Dropdown("Field 3 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter33 = Option
end)
guiElements["vars"]["customplanterdelay33"] = customplanter3section:Slider("Field 3 Harvest %", function(Value)
    macrov2.vars.customplanterdelay33 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield34"] = customplanter3section:Dropdown("Field 4 Field", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield34 = Option
end)
guiElements["vars"]["customplanter34"] = customplanter3section:Dropdown("Field 4 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter34 = Option
end)
guiElements["vars"]["customplanterdelay34"] = customplanter3section:Slider("Field 4 Harvest %", function(Value)
    macrov2.vars.customplanterdelay34 = Value
end, {Min = 0, Max = 100, Default = 75})
guiElements["vars"]["customplanterfield35"] = customplanter3section:Dropdown("Field 5 Field", DropdownFieldsTable, function(Option)
    macrov2.vars.customplanterfield35 = Option
end)
guiElements["vars"]["customplanter35"] = customplanter3section:Dropdown("Field 5 Planter Type", DropdownPlanterTable, function(Option)
    macrov2.vars.customplanter35 = Option
end)
guiElements["vars"]["customplanterdelay35"] = customplanter3section:Slider("Field 5 Harvest %", function(Value)
    macrov2.vars.customplanterdelay35 = Value
end, {Min = 0, Max = 100, Default = 75})

local misctab = Window:Tab("Misc")

-- Misc Tab Stuff
local wayp = misctab:Section("Waypoints")

wayp:Dropdown("Field Teleports", fieldstable, function(Option)
    api.humanoidrootpart().CFrame = Workspace.FlowerZones:FindFirstChild(Option).CFrame
end)
wayp:Dropdown("Monster Teleports", spawnerstable, function(Option)
    local monsterSpawner = monsterspawners:FindFirstChild(Option)
    local monsterSpawnerCFrame = CFrame.new(monsterSpawner.Position + Vector3.new(0,3,0))
    api.tween(domapi.TweenSpeed(monsterSpawnerCFrame),monsterSpawnerCFrame)
end)
wayp:Dropdown("Toys Teleports", toysTable, function(Option)
    toy = Workspace.Toys:FindFirstChild(Option).Platform
    local toyCFrame = CFrame.new(toy.Position + Vector3.new(0,3,0))
    api.tween(domapi.TweenSpeed(toyCFrame),toyCFrame)
end)
wayp:Button("Teleport to hive", function()
    api.humanoidrootpart().CFrame = player.SpawnPos.Value
end)

local miscc = misctab:Section("Misc")

local antilag = miscc:Toggle("GPU Saver", function(State)
    macrov2.toggles.antilag = State
end)
local targetfps = miscc:Box("TargetFps", 25, function(Value)
    macrov2.vars.targetfps = Value
end)
guiElements["toggles"]["antilag"] = antilag
guiElements["vars"]["targetfps"] = targetfps

miscc:Toggle("Hide Username", function(State)
    hideUserName(State)
end)

miscc:Button("Ant Challenge Semi-Godmode", function()
    api.tween(domapi.TweenSpeed(CFrame.new(93.4228, 32.3983, 553.128)),CFrame.new(93.4228, 32.3983, 553.128))
    task.wait(1)
    ReplicatedStorage.Events.ToyEvent:FireServer("Ant Challenge")
    api.humanoidrootpart().Position = Vector3.new(93.4228, 42.3983, 553.128)
    task.wait(2)
    player.Character.Humanoid.Name = 1
    local l = player.Character["1"]:Clone()
    l.Parent = player.Character
    l.Name = "Humanoid"
    task.wait()
    player.Character["1"]:Destroy()
    api.tween(domapi.TweenSpeed(CFrame.new(93.4228, 32.3983, 553.128)),CFrame.new(93.4228, 32.3983, 553.128))
    task.wait(8)
    api.tween(domapi.TweenSpeed(CFrame.new(93.4228, 32.3983, 553.128)),CFrame.new(93.4228, 32.3983, 553.128))
end)
local wstoggle = miscc:Toggle("Walk Speed", function(State)
    macrov2.toggles.loopspeed = State
end)
local weirdwstoggle = miscc:Toggle("Weird Speed Pops told me to add :trole~1:", function(State)
    macrov2.toggles.weirdspeed = State
end)
guiElements["toggles"]["weirdspeedmin"] = weirdwstoggle
guiElements["vars"]["weirdspeedmin"] = miscc:Slider("Weird Speed Min", function(Value)
    macrov2.vars.weirdspeedmin = Value
end, {Min = 1, Max = 150, Default = 40})
guiElements["vars"]["weirdspeedmax"] = miscc:Slider("Weird Speed max", function(Value)
    macrov2.vars.weirdspeedmax = Value
end, {Min = 1, Max = 150, Default = 60})
-- wstoggle:CreateKeybind("K", function(Key) end)
guiElements["toggles"]["loopspeed"] = wstoggle
local jptoggle = miscc:Toggle("Jump Power", function(State)
    macrov2.toggles.loopjump = State
end)
-- jptoggle:CreateKeybind("L", function(Key) end)
guiElements["toggles"]["loopjump"] = jptoggle
guiElements["toggles"]["godmode"] = miscc:Toggle("Godmode", function(State)
    macrov2.toggles.godmode = State
    bssapi:Godmode(State)
end)
local misco = misctab:Section("Other")
misco:Dropdown("Equip Accesories", accesoriestable, function(Option)
    local ohString1 = "Equip"
    local ohTable2 = {
        ["Mute"] = false,
        ["Type"] = Option,
        ["Category"] = "Accessory"
    }
    ReplicatedStorage.Events.ItemPackageEvent:InvokeServer(ohString1, ohTable2)
end)
misco:Dropdown("Equip Masks", maskstable, function(Option)
    maskequip(Option)
end)
misco:Dropdown("Equip Collectors", collectorstable, function(Option)
    equiptool(Option)
end)
misco:Dropdown("Generate Amulet", {
    "Supreme Star Amulet", "Diamond Star Amulet", "Gold Star Amulet",
    "Silver Star Amulet", "Bronze Star Amulet", "Moon Amulet"
}, function(Option)
    ReplicatedStorage.Events.ToyEvent:FireServer(Option .. " Generator")
end)
misco:Button("Export Stats Table ["..ExploitSpecific.."]", function()
    writefile("Stats_" .. api.nickname .. ".json", ClientStatCache:Encode())
end)
local visu = misctab:Section("Visual")
visu:Button("Set full hive to level 25 ["..ExploitSpecific.."]", function()
    task.spawn(function()
        local HiveLevel = 25

        local a = Workspace.Honeycombs:GetChildren()
        for i,v in pairs(a) do if v.Owner.Value==player then hive=v;break;end;end
        local b = hive.Cells:GetChildren()

        for i,v in pairs(b) do
            if v:IsA("Model") and v:FindFirstChild("LevelPart") then
                v.LevelPart.SurfaceGui.TextLabel.Text = HiveLevel
            end
        end
        local a = Workspace.Bees:GetChildren()
        for i,v in pairs(a) do
            if v.OwnerId.Value == player.UserId then
                v.Wings.Decal.Texture = "rbxassetid://9122780034"
            end
        end
    end)
end)

local webhooksection = misctab:Section("Webhook")
guiElements["toggles"]["webhookupdates"] = webhooksection:Toggle("Send Webhook Updates", function(State)
    macrov2.toggles.webhookupdates = State
end)
guiElements["vars"]["webhookurl"] = webhooksection:Box("Webhook URL", "Discord webhook URL", function(Value)
    if Value and string.find(Value, "https://") then
        macrov2.vars.webhookurl = Value
    else
        api.notify("Macro v2 " .. temptable.version, "Invalid URL!", 2)
    end
end)

guiElements["toggles"]["shutdownkick"] = webhooksection:Toggle("Shutdown on Kick", function(State)
    macrov2.toggles.shutdownkick = State
end)

guiElements["toggles"]["webhookshowtotalhoney"] = webhooksection:Toggle("Show total honey", function(State)
    macrov2.toggles.webhookshowtotalhoney = State
end)

guiElements["toggles"]["webhookshowhoneyperhour"] = webhooksection:Toggle("Show honey per hour", function(State)
    macrov2.toggles.webhookshowhoneyperhour = State
end)

guiElements["toggles"]["webhookonlytruncated"] = webhooksection:Toggle("Show only truncated", function(State)
    macrov2.toggles.webhookonlytruncated = State
end)

guiElements["toggles"]["webhooknectars"] = webhooksection:Toggle("Show nectars", function(State)
    macrov2.toggles.webhooknectars = State
end)

guiElements["toggles"]["webhookcompletedquest"] = webhooksection:Toggle("Send when quest completed", function(State)
    macrov2.toggles.webhookcompletedquest = State
end)

guiElements["toggles"]["webhookshowplanters"] = webhooksection:Toggle("Show Planters", function(State)
    macrov2.toggles.webhookshowplanters = State
end)

local webhookItemsDropdown
webhookItemsDropdown = webhooksection:Dropdown("Webhook Items (select to remove)", macrov2.webhookitems, function(option)
    if option == nil or option == "" then return end
    table.remove(macrov2.webhookitems, table.find(macrov2.webhookitems, option))
    task.spawn(function()
        webhookItemsDropdown:Update(macrov2.webhookitems)
        wait()
        webhookItemsDropdown:Set("")
    end)
end)

-- for i,v in pairs(FormattedItems) do 
--     print(v)
-- end

webhooksection:Box("Item Name", "ex: Star Jelly",function(Text)
    if not table.find(FormattedItems["NamesOnly"], Text) then
        api.notify("Macro v2 | Error", "Item not found!",2)
        return
    elseif table.find(macrov2.webhookitems, Text) then
        api.notify("Macro v2 | Error", "Item already added!",2)
        return
    elseif not table.find(EggItems, Text) then
        api.notify("Macro v2 | Error", "Is it an item??",1)
        return
    end
    table.insert(macrov2.webhookitems,Text)
    webhookItemsDropdown:Update(macrov2.webhookitems)
    api.notify("Macro v2 | Success", "Added "..Text.."\nto rares list", 1)
end)

guiElements["toggles"]["webhookitems"] = webhooksection:Toggle("Show items", function(State)
    macrov2.toggles.webhookitems = State
end)

webhooksection:Button('Test Web Hook', function()
    local data = {
        ["username"] = player.Name,
        ["avatar_url"] = playerAvatarUrl,
        ["content"] = ping and "<@"..tostring(discordid),
        ["embeds"] = {{
            ["title"] = "**Test**",
            ["type"] = "rich",
            ["color"] = tonumber(0x1B2A35),
            ["thumbnail"] = {url = "https://cdn.discordapp.com/icons/1024873171867942933/a_6704e7f2ca7cee2f8b9ea7a90891cf57.gif?size=96"},
            ["fields"] = {
                {
                    ["name"] = "Webhook Test",
                    ["value"] = "Hey lol - Narnia",
                    ["inline"] =  false
                },
            },
            ["footer"] = {
                ["text"] = os.date("%x").." • "..os.date("%I")..":"..os.date("%M")..":"..os.date("%S").." "..os.date("%p")
            }
        }}
    }
    httpreq({
        Url = macrov2.vars.webhookurl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(data)
    })
end)

guiElements["vars"]["webhooktimer"] = webhooksection:Slider("Minutes Between Updates", function(Value)
    macrov2.vars.webhooktimer = Value
end, {Min = 1, Max = 60, Default = 60}) --sakata
guiElements["vars"]["webhookcolor"] = webhooksection:Box("Webhook Color", "", function(Value)
    local done = false
    if string.match(Value, "^".."0x") then 
        done = true
        macrov2.vars.webhookcolor = Value
    end
    if not done then
        local newValue,_ = string.gsub(Value, "#", "0x") 
        if _ == 1 then
            -- print(newValue)
            macrov2.vars.webhookcolor = newValue
        else
            api.notify("Macro v2 " .. temptable.version, "Invalid Color!", 2)
            api.notify("Macro v2 " .. temptable.version, "Make sure you're using Hex color.", 5)
        end
    end
end)
guiElements["toggles"]["webhookping"] = webhooksection:Toggle("Ping on Honey Update", function(State)
    macrov2.toggles.webhookping = State
end)
guiElements["vars"]["discordid"] = webhooksection:Box("Discord ID", "", function(Value)
    if tonumber(Value) then
        macrov2.vars.discordid = Value
    else
        api.notify("Macro v2 " .. temptable.version, "Invalid ID!", 2)
    end
end)

local cordX, cordY, autoBuy = 1,1,false

autobasicsection = misctab:Section("Auto basic bee")
autobasicsection:Label("Use only if you know")
autobasicsection:Label("what are you doing")
local basicBeeMessage = autobasicsection:Label("")

autobasicsection:Box("Slot (left -> right)", "", function(Value)
    if not tonumber(Value) or tonumber(Value) < 1 or tonumber(Value) > 5 then
        basicBeeMessage:Set("invalid value")
        task.wait(1)
        basicBeeMessage:Set("")
    end
    cordX = tonumber(Value)
end)
autobasicsection:Box("Slot (down -> up)", "", function(Value)
    if not tonumber(Value) or tonumber(Value) < 1 or tonumber(Value) > 10 then
        basicBeeMessage:Set("invalid value")
        task.wait(1)
        basicBeeMessage:Set("")
    end
    cordY = tonumber(Value)
end)
autobasicsection:Toggle("Auto buy (rj and eggs)", function(State)
    autoBuy = State
end)

local function place(item) game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(cordX, cordY, item) end
local function buy(item) game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer("Purchase", {["Type"] = item,["Amount"] = 1,["Category"] = "Eggs"}) end

autobasicsection:Button("Start", function()
    task.spawn(function() 
        local success = false
        local cell = nil
        if plrHive then cell = plrHive.Cells:FindFirstChild("C" .. cordX .. "," .. cordY) end
        function ReRoll()
            if _G.emergencyStop then return end
            local eggsCount = GetItemListWithValue()["Basic"]
            local jellyCount = GetItemListWithValue()["RoyalJelly"]
            if not autoBuy and eggsCount < 1 or jellyCount < 1 then return end
            if autoBuy and eggsCount < 1 then buy("Basic") end
            if cell:FindFirstChild("Backplate").Color == Color3.fromRGB(174, 121, 47) then
                if jellyCount < 1 and autoBuy then buy("RoyalJelly") end
                place("RoyalJelly")
                task.wait()
            end
            place("Basic")
            task.wait()
            if not cell:FindFirstChild("GiftedCell") then ReRoll() end
            success = true
        end
        ReRoll()
        api.notify("Macro V2 | Auto basic Bee", success and "Successfully got gifted basic Bee" or "No basic bee..",5)
    end)
end)

autobasicsection:Button("Emergency stop", function()

end)

local setttab = Window:Tab("Settings")
-- Settings Tab Stuff

local securesettings = setttab:Section("Security")
guiElements["toggles"]["autokick"] = securesettings:Toggle("Auto kick", function(State)
    macrov2.toggles.autokick = State
end)
guiElements["vars"]["autokickinterval"] = securesettings:Box("Auto kick every (minutes)", "", function(Value)
    macrov2.vars.autokickinterval = Value
end)

local movingtype = securesettings:Dropdown("Movement method", {"Tween","Pathfinding"}, function(Option)
    macrov2.vars.movingtype = Option
end)
movingtype:Set("Tween")
guiElements["vars"]["movingtype"] = movingtype



local farmsettings = setttab:Section("Autofarm Settings")
guiElements["vars"]["farmspeed"] = farmsettings:Box("Autofarming Walkspeed", "Default Value = 60", function(Value)
    macrov2.vars.farmspeed = Value
end)
guiElements["toggles"]["loopfarmspeed"] = farmsettings:Toggle("^ Loop Speed On Autofarming", function(State)
    macrov2.toggles.loopfarmspeed = State
end)
guiElements["toggles"]["farmflower"] = farmsettings:Toggle("Don't Walk In Field", function(State)
    macrov2.toggles.farmflower = State
end)
guiElements["toggles"]["convertballoons"] = farmsettings:Toggle("Convert Hive Balloon", function(State)
    macrov2.toggles.convertballoons = State
end)
guiElements["toggles"]["converttime"] = farmsettings:Toggle("Convert after X amount of Time", function(State)
    macrov2.toggles.converttime = State
end)
guiElements["vars"]["converttime"] = farmsettings:Box("Convert Honey Time", 60, function(String)
    macrov2.vars.converttime = String
end)
local balloonPercentSlider = farmsettings:Slider("Balloon Blessing % To Convert At", function(Value)
    macrov2.vars.convertballoonpercent = Value
end, {Min = 0, Max = 100, Default = 50})
balloonPercentSlider:Tooltip("0% = Always convert balloon when converting bag")
guiElements["vars"]["convertballoonpercent"] = balloonPercentSlider
guiElements["toggles"]["donotfarmtokens"] = farmsettings:Toggle("Don't Farm Tokens", function(State)
    macrov2.toggles.donotfarmtokens = State
end)
guiElements["toggles"]["enabletokenblacklisting"] = farmsettings:Toggle("Enable Token Blacklisting", function(State)
    macrov2.toggles.enabletokenblacklisting = State
end)
guiElements["vars"]["walkspeed"] = farmsettings:Slider("Walk Speed", function(Value)
    macrov2.vars.walkspeed = Value
end, {Min = 0, Max = 120, Default = 70})
guiElements["vars"]["jumppower"] = farmsettings:Slider("Jump Power", function(Value)
    macrov2.vars.jumppower = Value
end, {Min = 0, Max = 120, Default = 70})

--guiElements["toggles"]["newtokencollection"] = farmsettings:CreateToggle("New Token Collection", nil, function(State)
--    macrov2.toggles.newtokencollection = State
--end)

local raresettings = setttab:Section("Rares Settings")

-- local tokenslist = raresettings:Dropdown("Rares List", macrov2.rares, function(Value) end)
-- local bltokenslist = raresettings:Dropdown("Blacklisted Rares", macrov2.bltokens, function(Value) end)

local raresListDropdown
raresListDropdown = raresettings:Dropdown("Rares List (select to remove)", macrov2.rares, function(option)
    if option == nil or option == "" then return end
    table.remove(macrov2.rares, table.find(macrov2.rares, option))
    api.notify("Macro v2 | Success", "Removed "..option.."\nfrom rares list", 2)
    task.spawn(function()
        raresListDropdown:Update(macrov2.rares)
        updateRareIdList()
        wait()
        raresListDropdown:Set("")
    end)
end)

raresettings:Box("Token Name - add to rares", "ex: Mythic Egg",function(Text)
    if not table.find(FormattedItems["NamesOnly"], Text) then
        api.notify("Macro v2 | Error", "Token not found!", 2)
        return
    elseif table.find(macrov2.rares, Text) then
        api.notify("Macro v2 | Error", "Token already added!", 2)
        return
    end
    table.insert(macrov2.rares,Text)
    raresListDropdown:Update(macrov2.rares)
    updateRareIdList()
    api.notify("Macro v2 | Success", "Added "..Text.."\nto rares list", 2)
end)

local tokenssettings = setttab:Section("Tokens Settings")

local blackListDropdown
blackListDropdown = tokenssettings:Dropdown("Blacklist (select to remove)", macrov2.bltokens, function(option)
    if option == nil or option == "" then return end
    table.remove(macrov2.bltokens, table.find(macrov2.bltokens, option))
    api.notify("Macro v2 | Success", "Removed "..option.."\nfrom blacklist", 2)
    task.spawn(function()
        blackListDropdown:Update(macrov2.bltokens)
        wait()
        blackListDropdown:Set("")
    end)
end)

tokenssettings:Box("Token Name - to blacklist", "ex: Surprise Party",function(Text)
    if not table.find(FormattedItems["NamesOnly"], Text) then
        api.notify("Macro v2 | Error", "Token not found!",2)
        return
    elseif table.find(macrov2.bltokens, Text) then
        api.notify("Macro v2 | Error", "Token already added!",2)
        return
    end
    table.insert(macrov2.bltokens,Text)
    blackListDropdown:Update(macrov2.bltokens)
    api.notify("Macro v2 | Success", "Added "..Text.."\nto blacklist", 2)
end)

-- raresettings:Button("Copy Token List Link", function()
--     api.notify("Macro v2 " .. temptable.version, "Copied link to clipboard!", 2)
--     setclipboard("https://pastebin.com/raw/wtHBD3ij")
-- end)


local dispsettings = setttab:Section("Auto Dispenser/Auto Boosters Settings")

local dispensersToggles = {
    rg = "Royal Jelly Dispenser",
    blub = "Blueberry Dispenser",
    straw = "Strawberry Dispenser",
    treat = "Treat Dispenser",
    coconut = "Coconut Dispenser",
    glue = "Glue Dispenser",
    white = "Mountain Top Booster",
    blue = "Blue Field Booster",
    red = "Red Field Booster"
}

for name, text in pairs(dispensersToggles) do
    guiElements["dispensesettings"][name] = dispsettings:Toggle(text, function(State)
        macrov2.dispensesettings[name] = State
    end)
end

local fieldsettings = setttab:Section("Fields Settings")

local mobsettings = combtab:Section("Mobs Settings")

guiElements["vars"]["blacklistmobdrop"] = mobsettings:Dropdown("Blacklisted Mobs", macrov2.vars.mobblack, function(Option) table.remove(macrov2.vars.mobblack, table.find(macrov2.vars.mobblack,  Option)) guiElements["vars"]["blacklistmobdrop"]:Update(macrov2.vars.mobblack) end)

guiElements["vars"]["mobblack"] = mobsettings:Box("Blacklist Mobs", "exam. Mantis, Lady, tis, pion", function(Option)
    local split = Option:split(',')
    for i, v in pairs(split) do
        local value = StringfindInTable(monsternames, v)
        if not value then api.notify("Macro v2 | Error", "Can't find Mob \""..v.."\"",2) continue end
        if value then
            table.insert(macrov2.vars.mobblack, value)
            api.notify("Macro v2 | Success", "Mob \""..value.."\" Successfully Added",2)
        end
    end
    guiElements["vars"]["blacklistmobdrop"]:Update(macrov2.vars.mobblack)
end)

blacklistfield = fieldsettings:Dropdown("Blacklisted Fields", macrov2.blacklistedfields, function(Option)
    if not table.find(macrov2.blacklistedfields, Option) then return nil end
    table.remove(macrov2.blacklistedfields, table.find(macrov2.blacklistedfields, Option))
    blacklistfield:Update(macrov2.blacklistedfields)
end)

guiElements["toggles"]["no35bee"] = fieldsettings:Toggle("No 35 Bees", function(State)
    macrov2.toggles.no35bee = State
    if State and not table.find(macrov2.blacklistedfields, "Pepper Patch") and not table.find(macrov2.blacklistedfields, "Coconut Field") then
        table.insert(macrov2.blacklistedfields, "Pepper Patch")
        table.insert(macrov2.blacklistedfields, "Coconut Field")
    elseif State and not table.find(macrov2.blacklistedfields, "Coconut Field") then
        table.insert(macrov2.blacklistedfields, "Coconut Field")
    elseif State and not table.find(macrov2.blacklistedfields, "Pepper Patch") then
        table.insert(macrov2.blacklistedfields, "Pepper Patch")
    elseif not State and table.find(macrov2.blacklistedfields, "Pepper Patch") and table.find(macrov2.blacklistedfields, "Coconut Field") then
        table.remove(macrov2.blacklistedfields, table.find(macrov2.blacklistedfields, "Pepper Patch"))
        table.remove(macrov2.blacklistedfields, table.find(macrov2.blacklistedfields, "Coconut Field"))
    elseif not State and table.find(macrov2.blacklistedfields, "Coconut Field") then
        table.remove(macrov2.blacklistedfields, table.find(macrov2.blacklistedfields, "Coconut Field"))
    elseif not State and table.find(macrov2.blacklistedfields, "Pepper Patch") then
        table.remove(macrov2.blacklistedfields, table.find(macrov2.blacklistedfields, "Pepper Patch"))
    end
    blacklistfield:Update(macrov2.blacklistedfields)
    
end)
guiElements["bestfields"]["white"] = fieldsettings:Dropdown("Best White Field", temptable.whitefields, function(Option)
    macrov2.bestfields.white = Option
end)
guiElements["bestfields"]["red"] = fieldsettings:Dropdown("Best Red Field", temptable.redfields, function(Option)
    macrov2.bestfields.red = Option
end)
guiElements["bestfields"]["blue"] = fieldsettings:Dropdown("Best Blue Field", temptable.bluefields, function(Option)
    macrov2.bestfields.blue = Option
end)
local wl;
local bl;

bl = fieldsettings:Dropdown("Blacklist Field", fieldstable, function(Option)
    table.insert(macrov2.blacklistedfields, Option)
    blacklistfield:Update(macrov2.blacklistedfields)
end)

local pts = setttab:Section("Autofarm Priority Tokens")

local priorityListDropdown
priorityListDropdown = pts:Dropdown("Priority list (select to remove)", macrov2.priority, function(option)
    if option == nil or option == "" then return warn(1) end
    table.remove(macrov2.priority, table.find(macrov2.priority, option))
    api.notify("Macro v2 | Success", "Removed "..option.."\nfrom priority list", 2)
    task.spawn(function()
        priorityListDropdown:Update(macrov2.priority)
        wait()
        priorityListDropdown:Set("")
    end)
end)

pts:Box("Token Name - add to priority", "ex: Surprise Party",function(Text)
    if not table.find(FormattedItems["NamesOnly"], Text) then
        api.notify("Macro v2 | Error", "Token not found!",2)
        return
    elseif table.find(macrov2.priority, Text) then
        api.notify("Macro v2 | Error", "Token already added!",2)
        return
    end
    table.insert(macrov2.priority,Text)
    priorityListDropdown:Update(macrov2.priority)
    api.notify("Macro v2 | Success", "Added "..Text.."\nto priority list", 2)
end)


local queststab = Window:Tab("Auto Quest")

local adq = queststab:Section("Auto Do Quests")
guiElements["toggles"]["autodoquest"] = adq:Toggle("Auto Quest", function(State) macrov2.toggles.autodoquest = State end)

adq:Label("")

-- guiElements["toggles"]["allquests"] = adq:Toggle("Non-Repeatable Quests", function(State) macrov2.toggles.allquests = State end)
guiElements["toggles"]["blackbearquests"] = adq:Toggle("Black Bear Quests", function(State) macrov2.toggles.blackbearquests = State end)
-- guiElements["toggles"]["motherbearquests"] = adq:Toggle("Mother Bear Quests", function(State) macrov2.toggles.motherbearquests = State end)
guiElements["toggles"]["brownbearquests"] = adq:Toggle("Brown Bear Quests", function(State) macrov2.toggles.brownbearquests = State end)
guiElements["toggles"]["pandabearquests"] = adq:Toggle("Panda Bear Quests", function(State) macrov2.toggles.pandabearquests = State end)
guiElements["toggles"]["sciencebearquests"] = adq:Toggle("Science Bear Quests", function(State) macrov2.toggles.sciencebearquests = State end)
guiElements["toggles"]["polarbearquests"] = adq:Toggle("Polar Bear Quests", function(State) macrov2.toggles.polarbearquests = State end)
guiElements["toggles"]["spiritbearquests"] = adq:Toggle("Spirit Bear Quests", function(State) macrov2.toggles.spiritbearquests = State end)
guiElements["toggles"]["buckobeequests"] = adq:Toggle("Bucko Bee Quests", function(State) macrov2.toggles.buckobeequests = State end)
guiElements["toggles"]["rileybeequests"] = adq:Toggle("Riley Bee Quests", function(State) macrov2.toggles.rileybeequests = State end)
guiElements["toggles"]["honeybeequests"] = adq:Toggle("Honey Bee Quests", function(State) macrov2.toggles.honeybeequests = State end)
guiElements["toggles"]["onettquests"] = adq:Toggle("Onett Quests", function(State) macrov2.toggles.onettquests = State end)


local aqs = queststab:Section("Auto Quest Settings")

guiElements["vars"]["questcolorprefer"] = aqs:Dropdown("Farm Ants From", {
    "Any NPC", "Bucko Bee", "Riley Bee", "Panda Bear"
}, function(Option) 
    macrov2.vars.questcolorprefer = Option
end)
guiElements["toggles"]["tptonpc"] = aqs:Toggle("Teleport To Npc", function(State) macrov2.toggles.tptonpc = State end)
-- guiElements["toggles"]["autoquesthoneybee"] = aqs:Toggle("Include Honey Bee Quests", function(State) macrov2.toggles.autoquesthoneybee = State end)
guiElements["toggles"]["buyantpass"] = aqs:Toggle("Buy Ant Pass When Needed", function(State) macrov2.toggles.buyantpass = State end)
guiElements["toggles"]["donatewindquest"] = aqs:Toggle("Donate Items To Wind Shrine", function(State) macrov2.toggles.donatewindquest = State end)

if scriptType == "Paid" then  -- Paid features
local paidtab = Window:Tab("Supporter")
local xtras = paidtab:Section("Features")
guiElements["toggles"]["smartbubbles"] = xtras:Toggle("Smart Bubble Bloat", function(State) macrov2.toggles.smartbubbles = State end)
guiElements["toggles"]["smartflame"] = xtras:Toggle("Smart Flame", function(State) macrov2.toggles.smartflame = State end)
-- guiElements["toggles"]["smartscorch"] = xtras:Toggle("Smart Scorching", function(State) macrov2.toggles.smartscorch = State end)
guiElements["toggles"]["slowshower"] = xtras:Toggle("Brain-Dead Star Shower", function(State) macrov2.toggles.slowshower = State end)
guiElements["toggles"]["fastcrosshairs"] = xtras:Toggle("Smart Precise Crosshairs", function(State) macrov2.toggles.fastcrosshairs = State end)
guiElements["toggles"]["unsafecrosshairs"] = xtras:Toggle("Smart Precise Crosshairs[".. Danger .. "]", function(State) macrov2.toggles.unsafecrosshairs = State end)
guiElements["toggles"]["farmguiding"] = xtras:Toggle("Farm Guiding Field", function(State) macrov2.toggles.farmguiding = State end)
guiElements["toggles"]["farmpuffshrooms"] = xtras:Toggle("Farm Puffshrooms", function(State) macrov2.toggles.farmpuffshrooms = State end)
guiElements["toggles"]["smartmobkill"] = xtras:Toggle("Mod. Mob Kill To Match Quests", function(State) macrov2.toggles.smartmobkill = State end)
guiElements["toggles"]["usegumdropsforquest"] = xtras:Toggle("Use Gumdrops For Goo Quests", function(State) macrov2.toggles.usegumdropsforquest = State end)
guiElements["toggles"]["autoequipmask"] = xtras:Toggle("Equip Mask Based on Field ["..Danger.."]", function(bool) macrov2.toggles.autoequipmask = bool end)
guiElements["toggles"]["farmduped"] = xtras:Toggle("Farm duped tokens", function(bool) macrov2.toggles.farmduped = bool end)
guiElements["toggles"]["smileyonly"] = xtras:Toggle("Smiley Faces only", function(bool) macrov2.toggles.smileyonly = bool end)
guiElements["toggles"]["faceBalloon"] = xtras:Toggle("Face Balloon", function(bool) macrov2.toggles.faceBalloon = bool end)
guiElements["toggles"]["faceFlame"] = xtras:Toggle("Face Flame", function(bool) macrov2.toggles.faceFlame = bool end)
guiElements["toggles"]["automemorymatch"] = xtras:Toggle("Auto Memory Match", function(bool) macrov2.toggles.automemorymatch = bool end)

local beesmas = paidtab:Section("Beesmas")
guiElements["toggles"]["farmsnowflakes"] = beesmas:Toggle("Farm Snowflakes", function(State) macrov2.toggles.farmsnowflakes = State end)
guiElements["toggles"]["collectgingerbreads"] = beesmas:Toggle("Auto Gingerbread Bears", function(State) macrov2.toggles.collectgingerbreads = State end)
guiElements["toggles"]["autosamovar"] = beesmas:Toggle("Auto Samovar", function(State) macrov2.toggles.autosamovar = State end)
guiElements["toggles"]["autostockings"] = beesmas:Toggle("Auto Stockings", function(State) macrov2.toggles.autostockings = State end)
guiElements["toggles"]["autocandles"] = beesmas:Toggle("Auto Honey Candles", function(State) macrov2.toggles.autocandles = State end)
guiElements["toggles"]["autofeast"] = beesmas:Toggle("Auto Beesmas Feast", function(State) macrov2.toggles.autofeast = State end)
guiElements["toggles"]["autoonettart"] = beesmas:Toggle("Auto Onett's Lid Art", function(State) macrov2.toggles.autoonettart = State end)
guiElements["toggles"]["autosnowmachine"] = beesmas:Toggle("Auto Snow Machine", function(State) macrov2.toggles.autosnowmachine = State end)
guiElements["toggles"]["autohoneywreath"] = beesmas:Toggle("Auto Honey Wreath", function(State) macrov2.toggles.autohoneywreath = State end)

local autojelly = paidtab:Section("Auto Jelly" .. Danger)

autojelly:Label(getgenv().Danger.." Only use this if you ")
autojelly:Label("know what you're doing "..getgenv().Danger)
autojelly:Box("Right Coordinate", "ex: 4", function(Value) 
    macrov2.autojelly.hiveslot["Right"] = tonumber(Value)
end)

autojelly:Box("Up Coordinate", "ex: 9", function(Value) 
    macrov2.autojelly.hiveslot["Up"] = tonumber(Value)
end)

local maxJellyUsageInput = autojelly:Box("Max Jelly Usage", "ex: 10000",function(Text)
		if not tonumber(Text) then
            api.notify("Only numbers allowed")
            return 
        end
        macrov2.autojelly.maxRoyalJellyUsage = tonumber(Text)
	end
)

for i,v in pairs(macrov2.autojelly.Settings) do
    autojelly:Toggle(i, function(bool) macrov2.autojelly.Settings[i] = bool 
end)
end

autojelly:Label("Rarities")
for i, v in pairs(macrov2.autojelly.AllowedRarities) do
    autojelly:Toggle(i,function(bool) macrov2.autojelly.AllowedRarities[i] = bool
    end, {Default = false})
end
autojelly:Label("Specific Bees")
local beename = ""
local gt = false
local visualList = {}
autojelly:Box("Bee Name", 'ex. Buoyant', function(Value) 
    local fixedBeeName = nil
    for i,v in pairs(BeeTable) do
        local newString=string.upper(i.."Bee")
        if string.find(newString,string.upper(Value)) then fixedBeeName = i.."Bee" end
    end
    if fixedBeeName ~= nil then 
        beename = fixedBeeName
        table.insert(macrov2.autojelly.specificbees, beename)
        api.notify("Selected "..fixedBeeName)
    else 
        api.notify("Bee does not exist!")
    end
end)

autojelly:Toggle("Require Gifted", function(bool)
    gt = bool
end)

local beeListDropdown
autojelly:Button("Add Bee to Bee List", function()
        local isg="Any"
        if gt then isg = "Gifted" end
        table.insert(macrov2.autojelly.specificbees, {beename,isg})
        table.insert(visualList,isg.." "..beename)
        beeListDropdown:UpdateOptions(visualList)
end)
autojelly:Button("Clear Bee List", function()
        visualList = {}
        macrov2.autojelly.specificbees = {}
        beeListDropdown:UpdateOptions(visualList)
end)
local DontEdit2 = 0
local emerStop=false
    function checkBee(BeeValue,IsGifted,starterRJ)
        local Settings = macrov2.autojelly.Settings
        local specificbees = macrov2.autojelly.specificbees
        local AllowedRarities = macrov2.autojelly.AllowedRarities
        local isokay = false
        DontEdit2 = DontEdit2 + 1
        
        local isAGiftedBee = true
        if IsGifted == nil then
            isAGiftedBee = false
        end
        if Settings["Roll For Specific Bees"] == true then
            for i,v in pairs(specificbees) do
            if v[1] == BeeValue then
                if v[2] == "Any" then
                    isokay = true
                else
                    if v[2] == "NonGifted" then
                        if isAGiftedBee == false then
                            isokay = true
                        end
                    else
                        if v[2] == "Gifted" then
                            if isAGiftedBee == true then
                                isokay = true
                            end
                        end
                    end
                end
            end
        end
    end
    
    --Roll for Rarities
    if isokay == false then
    if Settings["Roll For Rarity"] == true then
        local newString = string.gsub(BeeValue,"Bee","")
        for i,v in pairs(BeeTable) do
            if string.upper(i) == string.upper(newString) then
                for j,k in pairs(AllowedRarities) do
                    if k == true then
                        if v["Rarity"] == j then
                            isokay = true
                        end
                        if j == "Gifted" then
                            if isAGiftedBee then
                                isokay = true
                            end
                        end
                    end
                end
            end
        end
    end
    end
    
    if isokay then
        DontEdit2=(starterRJ-GetItemListWithValue().RoyalJelly)
        api.notify("In " .. tostring(DontEdit2).. "You rolled a "..string.gsub(BeeValue,"Bee","").." Bee!")
    end
    
    return isokay
  end
autojelly:Button("Run Auto Jelly", function() 
    task.spawn(function()
        local Left = macrov2.autojelly.hiveslot["Right"]
        local Up = macrov2.autojelly.hiveslot["Up"]
        local Settings = macrov2.autojelly.Settings
        local starterRJ = GetItemListWithValue().RoyalJelly
        local maxRoyalJellyUsage = macrov2.autojelly.maxRoyalJellyUsage
        if Settings["Use Star Jelly"] == true then DontEdit = "StarJelly" else DontEdit = "RoyalJelly" end
        local cell = plrHive.Cells["C" .. Left .. "," .. Up]
        repeat
            ReplicatedStorage.Events.ConstructHiveCellFromEgg:InvokeServer(Left, Up, DontEdit, 1)
        until
        checkBee(cell.CellType.Value, cell:FindFirstChild("GiftedCell"), starterRJ) == true or (starterRJ-GetItemListWithValue().RoyalJelly) >= maxRoyalJellyUsage or GetItemListWithValue().RoyalJelly == nil or GetItemListWithValue().RoyalJelly == 0 or emerStop == true
        
        if (starterRJ-GetItemListWithValue().RoyalJelly) >= maxRoyalJellyUsage then
            api.notify("You hit the spending limit.")
        end
        if GetItemListWithValue().RoyalJelly == nil then
            api.notify("You ran out of royal jellies.")
        end
        if GetItemListWithValue().RoyalJelly == 0 then
            api.notify("You ran out of royal jellies.")
        end
        if emerStop == true then
            api.notify("AutoJelly Paused.")
        end
    end)
end)
autojelly:Button("Emergency Stop", function() 
        task.spawn(function() emerStop=true 
        wait(1.5) 
        emerStop=false 
    end)
end)

beeListDropdown = autojelly:Dropdown("Bee List", visualList, function(Option)  
end)
end -- Paid features
debugNextStep(true)
local honeytoggleouyfyt = false
task.spawn(function()
    while task.wait(1) do
        if macrov2.toggles.honeymaskconv then
            if temptable.converting then
                if not honeytoggleouyfyt then
                    honeytoggleouyfyt = true
                    maskequip("Honey Mask")
                end
            else
                if honeytoggleouyfyt then
                    honeytoggleouyfyt = false
                    -- print(macrov2.vars.defmask)
                    maskequip(macrov2.vars.defmask)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        local buffs = fetchBuffTable(buffTable)
        for i, v in pairs(buffTable) do
            buffTable[i].b = macrov2.vars["autouse"..i]
            if v["b"] then
                local inuse = false
                for k, p in pairs(buffs) do
                    if k == i then inuse = true end
                end
                if not inuse then
                    PlayerActivesCommand:FireServer({["Name"] = i})
                end
            end
        end
    end
end)

local lastSnowflake,lastStinger,lastJB = 0,0,0
local autoItemsFunction = function() 
    while task.wait() do
        if macrov2.toggles.autouseSnowflake and getBuffTime("6087969886") < 0.95 and tick() - lastSnowflake > 3.1 then
            domapi.callEvent("PlayerActivesCommand", {["Name"] = "Snowflake"})
            lastSnowflake = tick()
        end
        if macrov2.toggles.autouseStinger and getBuffTime("2314214749") < 0.1 and tick() - lastStinger > 1.1 then
            domapi.callEvent("PlayerActivesCommand", {["Name"] = "Stinger"})
            lastStinger = tick()
        end
        if macrov2.toggles.autouseJellyBeans and tick() - lastJB > macrov2.vars.autouseJellyBeansInterval then
            domapi.callEvent("PlayerActivesCommand", {["Name"] = "Jelly Beans"})
            lastJB = tick()
        end
    end
end
task.spawn(autoItemsFunction)

task.spawn(function()
    while task.wait() do
        if macrov2.toggles.autofarm then
            if macrov2.toggles.farmbubbles then
                dobubbles()
            end
            if macrov2.toggles.collectcrosshairs then
                docrosshairs()
            end
            if macrov2.toggles.farmfuzzy then
                getfuzzy()
            end
        end
    end
end)

if scriptType == "Paid" then
    Workspace.Particles.ChildAdded:Connect(function(bubble)
        if macrov2.toggles.smartbubbles and not temptable.converting and bubble.Name == "Bubble" and macrov2.toggles.autofarm and not temptable.pathfinding.status then
            if Workspace.Particles:FindFirstChild("PopStars") then
                if Workspace.Particles.PopStars:FindFirstChild("Pop Star") ~= nil then
                    if player.Character then
                        if api.humanoidrootpart() then
                            if (Workspace.Particles.PopStars:FindFirstChild("Pop Star").Position - api.humanoidrootpart().Position).magnitude < 12 then
                                if (bubble.Position - api.humanoidrootpart().Position).magnitude < 60 then
                                    api.walkTo(bubble.Position)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    Workspace.PlayerFlames.ChildAdded:Connect(function(flame)
        if macrov2.toggles.smartflame and not temptable.converting and macrov2.toggles.autofarm and not temptable.pathfinding.status then
            if Workspace.Particles:FindFirstChild("ScorchingStars") then
                if Workspace.Particles.ScorchingStars:FindFirstChild("Scorching Star") ~= nil then
                    if player.Character then
                        if player.Character:FindFirstChild("HumanoidRootPart") then
                            if (Workspace.Particles.ScorchingStars:FindFirstChild("Scorching Star").Position - api.humanoidrootpart().Position).magnitude < 30 then
                                if (flame.Position - api.humanoidrootpart().Position).magnitude < 60 and flame:FindFirstChild("PF") and flame.PF.Color.Keypoints[1].Value.G == 0 and findField(flame.Position) == findField(api.humanoidrootpart().Position) then
                                    api.walkTo(flame.Position)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function farmWarningDisk(v, name)
    local method = "tween"
    local cframe

    if macrov2.toggles.slowshower then 
        method = "walk"
    end

    if temptable.lookat 
        then cframe = CFrame.new(v.CFrame.p, temptable.lookat) 
        else cframe = CFrame.new(v.CFrame.p)
    end

    if method == "walk" then
        pcall(function()
            api.walkTo(v.Position)
            repeat 
                task.wait()
            until not v.Parent or (v.Position -  api.humanoidrootpart().Position).Magnitude <= 5
        end)
    else
        api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
        api.tween(0.1, cframe)
        task.wait()
        api.tween(0.1, cframe)
    end
end

Workspace.Particles.ChildAdded:Connect(function(v)
    if (v:IsA("Part") or v:IsA("MeshPart")) and not temptable.started.ant and not temptable.started.vicious and not temptable.started.commando and macrov2.toggles.autofarm and not temptable.converting and not temptable.planting then
        if v.Name == "WarningDisk" and (macrov2.toggles.farmcoco or macrov2.toggles.farmshower or macrov2.toggles.slowshower) then
            task.wait(0.5)
            if v.BrickColor == BrickColor.new("Lime green") then
                task.wait(1.20)
                if (v.Position - api.humanoidrootpart().Position).magnitude > 100 then return end
                if (v.Size.X == 8 and macrov2.toggles.farmshower) 
                or (v.Size.X == 30 and macrov2.toggles.farmcoco) then
                    local name = math.random(10000)
                    v.Name = name
                    farmWarningDisk(v, name)
                end
            end
        elseif v.Name == "Crosshair" and macrov2.toggles.collectcrosshairs then
            local timestamp = Instance.new("NumberValue", v)
            timestamp.Name = "timestamp"
            timestamp.Value = tick()
        elseif string.find(v.Name, "Bubble") and getBuffTime("5101328809") > 0.2 and macrov2.toggles.farmbubbles then
            if not macrov2.toggles.farmpuffshrooms or (macrov2.toggles.farmpuffshrooms and not Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model")) then
                if (v.Position - api.humanoidrootpart().Position).magnitude > 100 then return end
                table.insert(temptable.bubbles, v)
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        temptable.magnitude = 50
        if player.Character:FindFirstChild("ProgressLabel", true) then
            local pollenprglbl = player.Character:FindFirstChild("ProgressLabel", true)
            local maxpollen = tonumber(pollenprglbl.Text:match("%d+$"))
            local pollencount = player.CoreStats.Pollen.Value
            temptable.pollenpercentage = pollencount / maxpollen * 100
            fieldselected = Workspace.FlowerZones[macrov2.vars.field]
            -- print("first",fieldselected)

            if macrov2.toggles.autouseconvertors then
                if tonumber(temptable.pollenpercentage) >= (macrov2.vars.convertat - (macrov2.vars.autoconvertWaitTime)) then
                    if not temptable.consideringautoconverting then
                        temptable.consideringautoconverting = true
                        task.spawn(function()
                            task.wait(macrov2.vars.autoconvertWaitTime)
                            if tonumber(temptable.pollenpercentage) >= (macrov2.vars.convertat - (macrov2.vars.autoconvertWaitTime)) then
                                useConvertors()
                            end
                            temptable.consideringautoconverting = false
                        end)
                    end
                end
            end

            if macrov2.toggles.autofarm then
                temptable.usegumdropsforquest = false
                if macrov2.toggles.autodoquest then
                    local quests = getNPCQuest()
                    local integer = 0
                    for i, v in pairs(quests) do
                        for k, x in pairs(getQuestProgress(v)) do
                            integer += 1
                            local iscompleted = x[1]
                            local progress = x[2]
                            local need = x[3]
                            -- print(v,i)
                            local todo = getQuestInfo(v).Tasks[k].Description
                            if typeof(todo) ~= "string" then
                                setIdentity(2)
                                todo = todo(ClientStatCache:Get())
                                setIdentity(7)
                            end
                            local questName = quests[i]
                            -- print(questName)
                            local pollentypes = {
                                "White Pollen", "Red Pollen", "Blue Pollen", "Blue Flowers", "Red Flowers", "White Flowers"
                            }
                            -- print(1)
                            if not string.find(todo, "Puffshroom") then
                                -- print(2)
                                if todo:find("Donate") and macrov2.toggles.donatewindquest and iscompleted < 1 then
                                    local amount = string.match(todo, "%D+")
                                    local itemstodonate = returnvalue(donatableItemsTable, todo)
                                    if itemstodonate then
                                        donateToShrine(itemstodonate, tonumber(amount))
                                        break
                                    end
                                end
                                if todo:find(" Goo ") then
                                    temptable.usegumdropsforquest = true  --rewrite the auto gumdrop thing 
                                end
                                if returnvalue(fieldstable, todo) and iscompleted < 1 and not table.find(macrov2.blacklistedfields, returnvalue(fieldstable, todo)) then  --blacklistedfields
                                    -- print(3)
                                    d = returnvalue(fieldstable, todo)
                                    fieldselected = Workspace.FlowerZones[d]  --this might be different in biohazard idk Coords
                                    -- print(fieldselected, " real")
                                    break
                                elseif returnvalue(pollentypes, todo) and iscompleted < 1 then 
                                    -- print(4)
                                    d = returnvalue(pollentypes, todo)
                                    if d == "Blue Flowers" or d == "Blue Pollen" then 
                                        fieldselected = Workspace.FlowerZones[macrov2.bestfields.blue]  --best field table blue
                                        break
                                    elseif d == "White Flowers" or d == "White Pollen" then
                                        fieldselected = Workspace.FlowerZones[macrov2.bestfields.white]  --best field table white
                                        break
                                    elseif d == "Red Flowers" or d == "Red Pollen" then
                                        fieldselected = Workspace.FlowerZones[macrov2.bestfields.red]  --best field table red
                                        break
                                    end 
                                elseif string.find(todo, "Feed") and iscompleted < 1 then 
                                    local amount, kind = unpack((todo:sub(6, todo:find("to")-2)):split(" ")) 
                                    local limit = macrov2.vars.limitfeed
                                    if amount and kind then 
                                        if amount and kind == "Blueberries" and limit >= amount then 
                                            ReplicatedStorage.Events.ConstructHiveCellFromEgg:InvokeServer(5, 3, "Blueberry", amount, false)
                                        elseif amount and kind == "Strawberries" and limit >= amount then
                                            ReplicatedStorage.Events.ConstructHiveCellFromEgg:InvokeServer(5, 3, "Strawberry", amount, false)
                                        end 
                                        break
                                    end
                                elseif string.find(todo, "Craft") and iscompleted < 1 then
                                    local amount = string.match(todo, "%d+")
                                    if amount then
                                        moveTo(Workspace.Toys.Blender.Platform.Position)
                                        ReplicatedStorage.Events.ToyEvent:FireServer("Blender")
                                        task.wait(0.1)
                                        
                                        ReplicatedStorage.Events.BlenderCommand:InvokeServer("PlaceOrder", {
                                            ["Recipe"] = "Gumdrops",
                                            ["Count"] = tonumber(amount)
                                        })
                                        task.wait(0.1)
                                        ReplicatedStorage.Events.BlenderCommand:InvokeServer("SpeedUpOrder")
                                        task.wait(0.2)
                                        ReplicatedStorage.Events.BlenderCommand:InvokeServer("StopOrder")
                                    end
                                elseif string.find(todo, "Ant") and iscompleted < 1 then 
                                    if updateClientStatCache().Eggs.AntPass == 0 and macrov2.toggles.buyantpass then
                                        moveTo(Workspace.Toys["Ant Pass Dispenser"].Platform.Position)
                                        ReplicatedStorage.Events.ToyEvent:FireServer("Ant Pass Dispenser")
                                        task.wait(0.5) 
                                    end 
                                    if not Workspace.Toys["Ant Challenge"].Busy.Value and updateClientStatCache().Eggs.AntPass > 0 then 
                                        farmant()
                                    end
                                end
                            end
                        end
                        if macrov2.toggles.followplayer then
                            local playerToFollow = Players:FindFirstChild(macrov2.vars.playertofollow)
                            if playerToFollow and playerToFollow.Character and playerToFollow.Character:FindFirstChild("HumanoidRootPart") then
                                fieldselected = findField(playerToFollow.Character.HumanoidRootPart.CFrame.p)
                                if not fieldselected or tostring(fieldselected) == "Ant Field" then
                                    fieldselected = Workspace.FlowerZones[macrov2.vars.field]
                                end
                            end
                        -- else
                            -- fieldselected = Workspace.FlowerZones[macrov2.vars.field]
                        end
                    end
                else
                    -- print(5)
                    if macrov2.toggles.followplayer then
                        local playerToFollow = Players:FindFirstChild(macrov2.vars.playertofollow)
                        if playerToFollow and playerToFollow.Character and playerToFollow.Character:FindFirstChild("HumanoidRootPart") then
                            fieldselected = findField(playerToFollow.Character.HumanoidRootPart.CFrame.p)
                            if not fieldselected then
                                fieldselected = Workspace.FlowerZones[macrov2.vars.field]
                            end
                        end
                    else
                        fieldselected = Workspace.FlowerZones[macrov2.vars.field]
                        -- print("second",fieldselected)
                    end
                end
                local colorGroup = fieldselected:FindFirstChild("ColorGroup")

                local onlyonesprinkler = false

                fieldpos = CFrame.new(fieldselected.Position + Vector3.new(0,3,0))
                fieldposition = fieldselected.Position
                if temptable.sprouts.detected and temptable.sprouts.coords and macrov2.toggles.farmsprouts and macrov2.toggles.autofarm then
                    onlyonesprinkler = true
                    fieldposition = temptable.sprouts.coords.Position
                    fieldpos = temptable.sprouts.coords
                end
                if macrov2.toggles.farmguiding and temptable.guiding.detected and temptable.guiding.coords and scriptType == "Paid" then
                    onlyonesprinkler = true
                    fieldposition = temptable.guiding.coords.Position
                    fieldpos = temptable.guiding.coords
                end

                if macrov2.toggles.farmpuffshrooms and Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model") and scriptType == "Paid" then
                    local mythics = {}
                    local legendaries = {}
                    local epics = {}
                    local rares = {}
                    local commons = {}
                    
                    local function isPuffInField(stem)
                        if stem and player.Character:FindFirstChild("HumanoidRootPart") then
                            return findField(stem.CFrame.p) == findField(api.humanoidrootpart().CFrame.p)
                        end
                        return false
                    end

                    local commons = {}
                    for _,puffshroom in pairs(Workspace.Happenings.Puffshrooms:GetChildren()) do
                        local stem = puffshroom:FindFirstChild("Puffball Stem")
                        if stem and findField(stem.Position) then
                            local field = findField(stem.Position)
                            if not table.find(macrov2.blacklistedfields, field.Name) then
                                if stem and player.Character:FindFirstChild("HumanoidRootPart") then
                                    local stem = puffshroom:FindFirstChild("Puffball Stem")
                                    if string.find(puffshroom.Name, "Mythic") then
                                        table.insert(mythics, {stem, isPuffInField(stem)})
                                    elseif string.find(puffshroom.Name, "Legendary") then
                                        table.insert(legendaries, {stem, isPuffInField(stem)})
                                    elseif string.find(puffshroom.Name, "Epic") then
                                        table.insert(epics, {stem, isPuffInField(stem)})
                                    elseif string.find(puffshroom.Name, "Rare") then
                                        table.insert(rares, {stem, isPuffInField(stem)})
                                    else
                                        table.insert(commons, {stem, isPuffInField(stem)})
                                    end
                                end
                            end
                        end
                    end
                    local smallest
                    if #mythics ~= 0 then
                        for _,v in pairs(mythics) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                            task.wait()
                            task.wait()
                        end
                        for _,v in pairs(mythics) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                                task.wait()
                                task.wait()
                            end
                        end
                    elseif #legendaries ~= 0 then
                        for _,v in pairs(legendaries) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                            task.wait()
                            task.wait()
                        end
                        for _,v in pairs(legendaries) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                                task.wait()
                                task.wait()
                            end
                        end
                    elseif #epics ~= 0 then
                        for _,v in pairs(epics) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                            task.wait()
                            task.wait()
                        end
                        for _,v in pairs(epics) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                                task.wait()
                                task.wait()
                            end
                        end
                    elseif #rares ~= 0 then
                        for _,v in pairs(rares) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                            task.wait()
                            task.wait()
                        end
                        for _,v in pairs(rares) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                                task.wait()
                                task.wait()
                            end
                        end
                    elseif #commons ~= 0 then
                        fieldpos = api.getbiggestmodel(Workspace.Happenings.Puffshrooms):FindFirstChild("Puffball Stem").CFrame
                        for _,v in pairs(commons) do
                            local stem, infield = unpack(v)
                            if infield then
                                dist = (stem.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if smallest == nil then smallest = dist end
                                if dist < smallest then
                                    fieldpos = stem.CFrame
                                    task.wait()
                                end
                            end
                        end
                    end

                    fieldposition = fieldpos.Position
                    temptable.magnitude = 35
                    onlyonesprinkler = true

                    fieldselected = findField(fieldposition)
                    if fieldselected then
                        local colorGroup = fieldselected:FindFirstChild("ColorGroup")
                        if macrov2.toggles.autoequipmask then 
                            if colorGroup then
                                if colorGroup.Value == "Red" then
                                    -- print("red")
                                    maskequip("Demon Mask")
                                elseif colorGroup and colorGroup.Value == "Blue" then
                                    maskequip("Diamond Mask")
                                else
                                    maskequip("Gummy Mask")
                                end
                            end
                        end
                    end
                end
                
                if macrov2.toggles.convertballoons and not temptable.planting and not temptable.started.vicious and not temptable.started.commando and macrov2.vars.convertballoonpercent and gethiveballoon() and getBuffTime("8083443467") < tonumber(macrov2.vars.convertballoonpercent) / 100 then
                    temptable.tokensfarm = false
                    local pos = (player.SpawnPos.Value * CFrame.fromEulerAnglesXYZ(0, 110, 0) + Vector3.new(0, 0, 9)).p
                    print("moveto 1")
                    moveTo(pos)
                    temptable.converting = true
                    repeat converthoney() until player.CoreStats.Pollen.Value == 0
                    if macrov2.toggles.convertballoons and gethiveballoon() then
                        task.wait(6)
                        repeat
                            task.wait()
                            converthoney()
                        until gethiveballoon() == false or not macrov2.toggles.convertballoons
                    end
                    temptable.converting = false
                    temptable.act = temptable.act + 1
                    task.wait(6)
                    if macrov2.toggles.autoant and not Workspace.Toys["Ant Challenge"].Busy.Value and updateClientStatCache().Eggs.AntPass > 0 then
                        farmant()
                    end
                    -- if macrov2.toggles.autoquest then
                    --     makequests()
                    -- end
                    if macrov2.toggles.autokillmobs then
                        if tick() - temptable.lastmobkill >= macrov2.vars.monstertimer * 60 then
                            temptable.lastmobkill = tick()
                            temptable.started.monsters = true
                            temptable.act = 0
                            killmobs()
                            temptable.started.monsters = false
                        end
                    end
                    --[[
                    if macrov2.vars.resetbeenergy then
                        if temptable.act2 >= macrov2.vars.resettimer then
                            temptable.started.monsters = true
                            temptable.act2 = 0
                            repeat 
                                task.wait()
                            until player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
                            player.Character:BreakJoints()
                            task.wait(6.5)
                            repeat 
                                task.wait()
                            until player.Character
                            player.Character:BreakJoints()
                            task.wait(6.5)
                            repeat
                                task.wait()
                            until player.Character
                            temptable.started.monsters = false
                        end
                    end
                    ]]
                end
                if tonumber(temptable.pollenpercentage) < tonumber(macrov2.vars.convertat) or macrov2.toggles.disableconversion and not temptable.planting then
                    if not temptable.tokensfarm then
                        -- print("going to field")
                        print("fieldpos:",fieldpos.p)
                        print("moveto 2")
                        moveTo(fieldpos.p)
                        task.wait(2)
                        temptable.tokensfarm = true
                        if macrov2.toggles.autosprinkler then
                            makesprinklers(fieldposition, onlyonesprinkler)
                            task.wait(0.5)
                            PlayerActivesCommand:FireServer({["Name"] = "Sprinkler Builder"})
                        end
                    else
                        if macrov2.toggles.killmondo then
                            while macrov2.toggles.killmondo and Workspace.Monsters:FindFirstChild("Mondo Chick (Lvl 8)") and not temptable.started.vicious and not temptable.started.commando and not temptable.started.monsters do
                                temptable.started.mondo = true
                                if not macrov2.toggles.killmondo then break end
                                while Workspace.Monsters:FindFirstChild("Mondo Chick (Lvl 8)") and macrov2.toggles.killmondo do
                                    if not macrov2.toggles.killmondo then break end
                                    disableall()
                                    Workspace.Map.Ground.HighBlock.CanCollide = false
                                    mondopition = Workspace.Monsters["Mondo Chick (Lvl 8)"].Head.Position
                                    local mondoUpCFrame = CFrame.newe(mondopition + Vector3.new(0,40,0))
                                    api.tween(domapi.TweenSpeed(mondoUpCFrame),mondoUpCFrame)
                                    task.wait(1)
                                    temptable.float = true
                                    print("float 1")
                                end
                                task.wait(.5)
                                Workspace.Map.Ground.HighBlock.CanCollide = true
                                temptable.float = false
                                task.wait(1)
                                for i = 0, 50 do
                                    gettoken(CFrame.new(73.2, 176.4, -164.2).Position)
                                end
						        task.wait(2)
                            end
                                enableall()
                                moveTo(fieldpos)
                                temptable.started.mondo = false
                        end
                        if lastfieldpos ~= fieldpos then
                            task.wait(0.5)
                            gettoken()
                        end
                        if (fieldposition - api.humanoidrootpart().Position).Magnitude > temptable.magnitude and findField(api.humanoidrootpart().CFrame.p) ~= findField(fieldposition) and not temptable.planting and not temptable.doingcrosshairs and not temptable.doingbubbles then
                            print("moveto 3")
                            moveTo(fieldpos.p)
                                task.wait(0.5)
                                if macrov2.toggles.autosprinkler then
                                    makesprinklers(fieldposition, onlyonesprinkler)
                                end
                        end
                        if not temptable.farmingDuped and not temptable.started.vicious then
                            getprioritytokens()
                            if macrov2.toggles.farmflame then 
                                getflame()
                            end
                            if macrov2.toggles.avoidmobs then
                                avoidmob()
                            end
                            if macrov2.toggles.farmclosestleaf then
                                closestleaf()
                            end
                            if macrov2.toggles.farmclouds then
                                getcloud()
                            end
                            if macrov2.toggles.farmunderballoons then
                                getballoons()
                            end
                            if not macrov2.toggles.donotfarmtokens then
                                gettoken(nil, macrov2.toggles.newtokencollection)
                            end
                            if not macrov2.toggles.farmflower then
                                getflower()
                            end
                            if macrov2.toggles.farmpuffshrooms then
                                getpuff()
                            end
                            if macrov2.toggles.autodispenses then
                                getToys()
                            end
                            if macrov2.toggles.autoant and not Workspace.Toys["Ant Challenge"].Busy.Value and updateClientStatCache().Eggs.AntPass > 0 then
                                farmant()
                            end
                            farmPlanters()
                            getToys() --print('gettoys checks')
                            if macrov2.toggles.autodoquest then
                                makequests()
                            end
                            if macrov2.toggles.autokillmobs then
                                if tick() - temptable.lastmobkill >= macrov2.vars.monstertimer * 60 then
                                    temptable.lastmobkill = tick()
                                    temptable.started.monsters = true
                                    temptable.act = 0
                                    killmobs()
                                    temptable.started.monsters = false
                                end
                            end
                            if temptable.usegumdropsforquest and macrov2.toggles.usegumdropsforquest and tick() - temptable.lastgumdropuse > 3 then
                                temptable.lastgumdropuse = tick()
                                PlayerActivesCommand:FireServer({["Name"] = "Gumdrops"})
                            end
                        end
                    end
                elseif tonumber(temptable.pollenpercentage) >= tonumber(macrov2.vars.convertat) and not temptable.started.vicious and not temptable.started.commando and not temptable.planting then
                    if not macrov2.toggles.disableconversion then
                        temptable.tokensfarm = false
                        local pos = (player.SpawnPos.Value * CFrame.fromEulerAnglesXYZ(0, 110, 0) + Vector3.new(0, 0, 9)).p
                        print("moveto 4")
                        moveTo(pos)
                        task.wait(2)
                        api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
                        print("moveto 5")
                        moveTo(pos)
                        task.wait()
                        temptable.converting = true
                        repeat converthoney() until player.CoreStats.Pollen.Value == 0
                        if macrov2.toggles.convertballoons and macrov2.vars.convertballoonpercent == 0 and gethiveballoon() then
                            task.wait(6)
                            repeat
                                task.wait()
                                converthoney()
                            until gethiveballoon() == false or not macrov2.toggles.convertballoons
                        end
                        task.wait(4)
                        equiptool(macrov2.vars.deftool)
                        temptable.converting = false
                        temptable.act = temptable.act + 1
                    end
                end
                lastfieldpos = fieldpos
            end
        end
    end
end)

-- Vicious 
task.spawn(function()
    while task.wait(1) do
        if macrov2.toggles.killvicious and temptable.detected.vicious and not temptable.converting and not temptable.started.monsters and not temptable.detected.windy and not temptable.sprouts.detected and not temptable.started.commando and not Workspace.Toys["Ant Challenge"].Busy.Value then
            temptable.started.vicious = true
            disableall()
            local vichumanoid = Players.LocalPlayer.Character.HumanoidRootPart
            for i, v in next, Workspace.Particles:GetChildren() do
                for x in string.gmatch(v.Name, "Vicious") do
                    if string.find(v.Name, "Vicious") then
                        for e, r in pairs(Workspace.Monsters:GetChildren()) do --["Vicious Bee (Lvl 11)"]
                            if string.find(r.Name, "Vicious") then
                                -- local ReName1 = string.gmatch(r.Name, "Vicious Bee (Lvl", "")
                                -- local ReName2 = string.gmatch(tostring(ReName1), ")", "")
                                local level = tonumber(string.gmatch(r.Name, "%d+")())
                                if level and level > macrov2.vars.viciousmax or level and macrov2.vars.viciousmin > level then
                                    break
                                else
                                    if v.Position then
                                        local viciouslocation = findField(v.Position)
                                        if viciouslocation and not table.find(macrov2.blacklistedfields, viciouslocation.Name) then
                                            moveTo(v.Position + Vector3.new(0, 3, 0))
                                            task.wait(1)
                                            moveTo(v.Position + Vector3.new(0, 3, 0))
                                            task.wait(.5)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            for i, v in next, Workspace.Particles:GetChildren() do
                for x in string.gmatch(v.Name, "Vicious") do
                    while macrov2.toggles.killvicious and
                        temptable.detected.vicious do
                        task.wait()
                        if string.find(v.Name, "Vicious") then
                            if v.Position then
                                local viciouslocation = findField(v.Position)
                                if viciouslocation and not table.find(macrov2.blacklistedfields, viciouslocation.Name) then
                                    for i = 1, 4 do
                                        temptable.float = true
                                        print("float 2")
                                        vichumanoid.CFrame =
                                            CFrame.new(
                                                v.Position + Vector3.new(10,0,0)
                                            )
                                        task.wait(.3)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            enableall()
            task.wait(1)
            temptable.float = false
            temptable.started.vicious = false
            vicioustable = {}
        end
    end
end)

LPH_NO_VIRTUALIZE(function()
    fourtimes = 0
    task.spawn(function()
        
        while task.wait() do
            if macrov2.toggles.killwindy and temptable.detected.windy and not temptable.converting and not temptable.started.vicious and not temptable.started.mondo and not temptable.started.monsters and not Workspace.Toys["Ant Challenge"].Busy.Value then
                -- print(typeof(temptable.windy))
                temptable.started.windy = true
                local windytokendb = false
                local windytokentp = false
                local wlvl = ""
                local aw = false
                local awb = false -- some variable for autowindy, yk?
                disableall()
                local oldmask = updateClientStatCache()["EquippedAccessories"]["Hat"]
                -- print("red for windy")
                maskequip("Demon Mask")
                while macrov2.toggles.killwindy and temptable.detected.windy do
                    task.wait()
                    if not aw then
                        for i, v in pairs(Workspace.Monsters:GetChildren()) do
                            if string.find(v.Name, "Windy") then
                                wlvl = v.Name
                                aw = true -- we found windy!
                            end
                        end
                    end
                    if aw then
                        for i, v in pairs(Workspace.Monsters:GetChildren()) do
                            if string.find(v.Name, "Windy") then
                                if v.Name ~= wlvl then
                                    temptable.float = false
                                    task.wait(2)
                                    api.humanoidrootpart().CFrame = temptable.gacf(temptable.windy, 5)
                                    task.wait(2)
                                    for i = 1, 3 do
                                        gettoken(api.humanoidrootpart().Position)
                                    end -- collect tokens :yessir:
                                    wlvl = v.Name
                                end
                            end
                        end
                    end
                    if not awb then
                        for e, r in pairs(Workspace.Monsters:GetChildren()) do --["Vicious Bee (Lvl 11)"]
                            if string.find(r.Name, "Windy") then
                                -- local ReName1 = string.gmatch(r.Name, "Windy Bee (Lvl", "")
                                -- local ReName2 = string.gmatch(tostring(ReName1), ")", "")
                                local level = tonumber(string.gmatch(r.Name, "%d+")())
                                if level and level > macrov2.vars.windymax then
                                    return nil
                                else
                                    if temptable.windy and temptable.windy.Position then
                                        -- print("ok1")
                                        local windylocation = findField(temptable.windy.Position)
                                        -- print(findField)
                                        -- print(table.find(macrov2.blacklistedfields, windylocation))
                                        if windylocation and not table.find(macrov2.blacklistedfields, windylocation.Name) then
                                            print("ok3")
                                            if player.Character.Humanoid.Health == 0 then return nil end
                                            if Object then
                                                local Info = TweenInfo.new((api.humanoidrootpart().Position - Object).Magnitude / 80, Enum.EasingStyle.Linear)
                                                local Tween = TweenService:Create(api.humanoidrootpart(), Info, {CFrame = CFrame.new(windylocation.Position)})
                                                if not api.humanoidrootpart():FindFirstChild("BodyVelocity-Tween") then
                                                    AntiFall = Instance.new("BodyVelocity", api.humanoidrootpart())
                                                    AntiFall.Velocity = Vector3.new(0, 0, 0)
                                                    AntiFall.Name = "BodyVelocity-Tween"
                                                    NoclipE = RunService.Stepped:Connect(Noclip)
                                                end
                                                Tween:Play()
                                                -- Tween.Completed:Connect(function()
                                                AntiFall:Destroy()
                                                NoclipE:Disconnect()
                                                -- end)
                                                task.wait()
                                            end
                                            task.wait(2)
                                            repeat task.wait()
                                                api.humanoidrootpart().CFrame = CFrame.new(temptable.windy.Position)
                                                fourtimes += 1
                                            until fourtimes >= 4
                                            fourtimes = 0
                                            awb = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if awb and temptable.windy and temptable.windy.Name == "Windy" then
                        task.spawn(function()
                            if not windytokendb then
                                for _,token in pairs(temptable.tokenpath:GetChildren()) do
                                    decal = token:FindFirstChildOfClass("Decal")
                                    if decal and decal.Texture == "rbxassetid://1629547638" and api.humanoidrootpart() then
                                        windytokendb = true
                                        windytokentp = true
                                        task.wait()
                                        for i=0,20 do
                                            api.humanoidrootpart().CFrame = token.CFrame
                                            task.wait()
                                        end
                                        windytokentp = false
                                        task.wait(3)
                                        windytokendb = false
                                        break
                                    end
                                end
                            end
                        end)
                        if not windytokentp and api.humanoidrootpart() then
                            pcall(function()
                                if temptable.windy and temptable.windy.Position then
                                    local windylocation = findField(temptable.windy.Position)
                                    if windylocation and not table.find(macrov2.blacklistedfields, windylocation.Name) then
                                        for e, r in pairs(Workspace.Monsters:GetChildren()) do --["Vicious Bee (Lvl 11)"]
                                            if string.find(r.Name, "Windy") then
                                                -- local ReName1 = string.gmatch(r.Name, "Windy Bee (Lvl", "")
                                                -- local ReName2 = string.gmatch(tostring(ReName1), ")", "")
                                                -- local level = tonumber(ReName2)
                                                local level = tonumber(string.gmatch(r.Name, "%d+")())
                                                if level and level > macrov2.vars.windymax then
                                                    break
                                                else
                                                    api.humanoidrootpart().CFrame = temptable.gacf(temptable.windy, 25)
                                                    temptable.float = true
                                                    print("float 3")
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                        task.wait()
                    end
                    -- print(temptable.started.windy)
                end
                temptable.float = false
                print("stop float")
                temptable.started.windy = false
                api.humanoidrootpart().Parent:BreakJoints()
                task.wait(25)
                maskequip(oldmask)
                enableall()
            end
        end
    end)
end)()

function farmcombattokens(v, pos, type)
    pcall(function()
        if type == 'crab' then
            if v.CFrame.YVector.Y == 1 and v.Transparency == 0 and v ~= nil and v.Parent ~= nil then
                if (v.Position - pos.Position).Magnitude < 50 then
                    repeat
                        task.wait(.5)
                        api.humanoid():MoveTo(v.Position)
                    until not v.Parent or v.CFrame.YVector.Y ~= 1 or not v
                    moveTo(pos)
                end
            end
        elseif type == 'snail' then
            if v.CFrame.YVector.Y == 1 and v.Transparency == 0 and v ~= nil and v.Parent ~= nil then
                if (v.Position - pos.Position).Magnitude < 50 then
                    repeat
                        task.wait(.5)
                        api.humanoid():MoveTo(v.Position)
                    until not v.Parent or v.CFrame.YVector.Y ~= 1 or not v
                    moveTo(pos)
                end
            end
        end
    end)
end

local function dig()
    local tool = player.Character:FindFirstChildOfClass("Tool") or nil
    if not tool then return end
    getsenv(tool.ClientScriptMouse).collectStart(player:GetMouse())
end

task.spawn(function()
    while task.wait() do
        if macrov2.toggles.autodig then
            pcall(function() dig() end)
        end
    end
end)

Workspace.Collectibles.ChildAdded:Connect(function(token) -- kometa
    if macrov2.toggles.traincrab then
        for i, v in pairs(workspace.Monsters:GetChildren()) do
            if string.find(v.Name, "Coconut Crab") then
                cc = true -- we found coco crab!
                cocotrue = true
                farmcombattokens(token, CFrame.new(-256, 110, 475), 'crab')
            else cocotrue = false continue end
        end
        if findField(token.Position) and findField(token.Position).Name == "Coconut Field" and cc == true and cocotrue == false then
            disableall()
            api.tween(1, CFrame.new(workspace.FlowerZones["Coconut Field"].Position))
            for i = 0, 10 do
                gettoken(CFrame.new(workspace.FlowerZones["Coconut Field"].Position))
            end
            task.wait(1)
            enableall()
            cc = false
        end
    end
end)

task.spawn(function()
    while wait() do
        if macrov2.toggles.traincrab and api.humanoidrootpart() and (api.humanoidrootpart().Position - cocopad.Position).magnitude > 25 then
            for i, v in pairs(Workspace.Monsters:GetChildren()) do
                if string.find(v.Name, "Coconut Crab") then
                    cc = true -- we found coco crab!
                else
                    continue
                end
            end
        end
        if macrov2.toggles.trainsnail and api.humanoidrootpart() then
            local fd = Workspace.FlowerZones["Stump Field"]
            pcall(function()
                api.tween(1, CFrame.new(fd.Position) + Vector3.new(0, -20, 0))
            end)
        end
        if macrov2.toggles.farmrares and not temptable.started.crab and not temptable.started.ant then
            for k, v in next, temptable.tokenpath:GetChildren() do
                if v.CFrame.YVector.Y == 1 then
                    if v.Transparency == 0 then
                        decal = v:FindFirstChildOfClass("Decal")
                        for e, r in next, macrov2.rares do
                            local rare, rareError = getItemByName(r) 
                            local rareTexture = rare and rare.Icon
                            if rareTexture and rareTexture == decal.Texture then
                                for i=1, 5 do 
                                    api.humanoidrootpart().CFrame = v.CFrame
                                    task.wait()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

function checkSprout()
    local Time = getCurrentTime()
    if macrov2.toggles.sproutatnight and Time == "Day" then
        return "Day"
    else
        for i,v in pairs(Workspace.Particles.Folder2:GetChildren()) do
            if v.Name == "Sprout" then
                field = findField(v.Position)
                if field and macrov2.blacklistedfields and table.find(macrov2.blacklistedfields, field.Name) then
                    return "Blacklisted"
                else
                    temptable.sprouts.detected = true
                    temptable.sprouts.coords = v.CFrame
                    break
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        if macrov2.toggles.farmsprouts then
            checkSprout()
        end
    end
end)

Workspace.Particles.Folder2.ChildRemoved:Connect(function(child)
    if child.Name == "Sprout" then
        task.wait(30)
        temptable.sprouts.detected = false
        temptable.sprouts.coords = ""
    end
end)
Workspace.Particles.ChildAdded:Connect(function(child)
    if child.Name == "Guiding Star" then
        temptable.guiding.detected = true
        temptable.guiding.coords = child.CFrame
    end
end)
Workspace.Particles.ChildRemoved:Connect(function(child)
    if child.Name == "Guiding Star" then
        task.wait(30)
        temptable.guiding.detected = false
        temptable.guiding.coords = ""
    end
end)

Workspace.Particles.ChildAdded:Connect(function(instance)
    if string.find(instance.Name, "Vicious") then
        temptable.detected.vicious = true
    end
end)
Workspace.Particles.ChildRemoved:Connect(function(instance)
    if string.find(instance.Name, "Vicious") then
        temptable.detected.vicious = false
    end
end)

Workspace.Monsters.ChildRemoved:Connect(function(instance)
    if string.find(instance.Name, "Commando") then
        temptable.started.commando = false
    end
end)

Workspace.NPCBees.ChildAdded:Connect(function(v)
    if v.Name == "Windy" then
        task.wait(3)
        temptable.windy = v
        temptable.detected.windy = true
    end
end)
Workspace.NPCBees.ChildRemoved:Connect(function(v)
    if v.Name == "Windy" then
        task.wait(3)
        temptable.windy = nil
        temptable.detected.windy = false
    end
end)

local activatingGlue = false
task.spawn(function()   
    while task.wait(2) do
        temptable.runningfor = temptable.runningfor + 1
        temptable.honeycurrent = statsget().Totals.Honey
        if macrov2.dispensesettings.glue and not activatingGlue then
            task.spawn(function() 
                activatingGlue = true
                while canToyBeUsed("Glue Dispenser") do
                    ReplicatedStorage.Events.ToyEvent:FireServer("Glue Dispenser")
                    task.wait(2.5)
                end
                activatingGlue = false
            end)
        end
        local timepassed = math.round(tick() - temptable.starttime)
        local honeygained = temptable.honeycurrent - temptable.honeystart
        local honeyperhourstring = api.suffixstring(math.floor(honeygained / timepassed) * 3600)
        gainedhoneylabel:Set("Gained Honey: " ..api.suffixstring(honeygained))
        honeyperhourlabel:Set("Honey per hour: "..honeyperhourstring)
        uptimelabel:Set("Uptime: " .. truncatetime(timepassed))
    end
end)

RunService.Heartbeat:connect(function()
    if macrov2.toggles.farmduped and macrov2.toggles.autofarm and not temptable.converting and scriptType == "Paid" then
        getDuped()
    end
end)

RunService.Heartbeat:connect(function()
    if macrov2.toggles.loopspeed and api.humanoid() then
        if not macrov2.toggles.weirdspeed then
            api.humanoid().WalkSpeed = macrov2.vars.walkspeed
        else
            api.humanoid().WalkSpeed = math.random(macrov2.vars.weirdspeedmin, macrov2.vars.weirdspeedmax)
        end
    end
    if macrov2.toggles.loopjump and api.humanoid() then
        api.humanoid().JumpPower = macrov2.vars.jumppower
    end
end)

RunService.Heartbeat:connect(function()
    for _, v in next, ScreenGui:WaitForChild("MinigameLayer"):GetChildren() do
        for _, q in next, v:WaitForChild("GuiGrid"):GetDescendants() do
            if q.Name == "ObjContent" or q.Name == "ObjImage" then
                q.Visible = true
            end
        end
    end
end)

RunService.Heartbeat:connect(function()
    if temptable.float and api.humanoid() then
        player.Character.Humanoid.BodyTypeScale.Value = 0
        floatpad.CanCollide = true
        floatpad.CFrame = CFrame.new(
            api.humanoidrootpart().Position.X,
            api.humanoidrootpart().Position.Y - 3.75,
            api.humanoidrootpart().Position.Z
        )
        task.wait(0)
    else
        floatpad.CanCollide = false
    end
end)

player.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

if scriptType == "Paid" then
    local doingsnowflake = false
    local snowflakeFarm = {}
    
    local function findSnowflake()
        for i,token in pairs(temptable.tokenpath:GetChildren()) do
            if token:FindFirstChild("FrontDecal") 
            and token.FrontDecal.Texture == "rbxassetid://6087969886" 
            and (token.Position - api.humanoidrootpart().Position).magnitude < 70 then
                return token
            end
        end
    end
    
    task.spawn(function()
        while task.wait() do
            if snowflakeFarm["Field"] and macrov2.toggles.farmsnowflakes then
                local field = snowflakeFarm["Field"]
                if not (field == findField(api.humanoidrootpart().Position)) then
                    api.tween(domapi.TweenSpeed(CFrame.new(field.CFrame.p)),CFrame.new(field.CFrame.p))
                end
                repeat task.wait() until not (snowflakeFarm["Particle"] and snowflakeFarm["Particle"].Parent)
                repeat farm(findSnowflake() or field) task.wait() until not findSnowflake() or not macrov2.toggles.farmsnowflakes
            end
        end
    end)
    Workspace.Particles.Snowflakes.ChildAdded:Connect(function(snowflake)
        if macrov2.toggles.farmsnowflakes and not doingsnowflake then
            local ray = Ray.new(snowflake.Position+Vector3.new(0, 1, 0), Vector3.new(0,-735, 0))
            local flower = workspace:FindPartOnRayWithWhitelist(ray, Workspace.Flowers:GetChildren())
    
            if flower then
                doingsnowflake = true
                local field = findField(flower.Position)
                snowflakeFarm["Field"] = field
                snowflakeFarm["Particle"] = snowflake
                repeat task.wait() until not snowflake.Parent or not macrov2.toggles.farmsnowflakes
                snowflakeFarm["Particle"] = nil
                task.wait(0.8)
                repeat task.wait() until not findSnowflake() or not macrov2.toggles.farmsnowflakes
                doingsnowflake = false
                snowflakeFarm["Field"] = nil
            end
        end
    end)
end

task.spawn(function()
    if Workspace:FindFirstChild('BuckoAtHQ') then
        Workspace.BuckoAtHQ:Destroy()
    end
    if Workspace.Decorations["30BeeZone"]:FindFirstChild("Pit") then
        Workspace.Decorations["30BeeZone"].Pit:Destroy()
    end
end)

local physProperties = PhysicalProperties.new(5,0.1,1,1,1)

player.CharacterAdded:Connect(function(char)
    local antiVelocitySignal = char:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal("Velocity"):Connect(function()
        if (char.HumanoidRootPart.Velocity * Vector3.new(0,1,0)).magnitude > 350
        or (char.HumanoidRootPart.Velocity * Vector3.new(1,0,1)).magnitude > 500 
        then
            -- print(char.HumanoidRootPart.Velocity)
            api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
        end
    end)
    char:WaitForChild("Humanoid")
    spawn(function()
        for i,v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                v.CustomPhysicalProperties = physProperties
            end
        end
    end)

    player.Character.Humanoid.Died:Connect(function()
        antiVelocitySignal:Disconnect()
        if macrov2.toggles.autofarm then
            temptable.dead = true
            macrov2.toggles.autofarm = false
            temptable.converting = false
            temptable.farmtoken = false
        end
        local old = macrov2.toggles.pathfind
        if old then
            macrov2.toggles.pathfind = false
        end
        if temptable.dead then
            print("after dead")
            task.wait(25)
            temptable.dead = false
            macrov2.toggles.autofarm = true
            temptable.converting = false
            temptable.tokensfarm = true
        end
        if old then
            macrov2.toggles.pathfind = old
        end
    end)
end)

for _, v in next, Workspace.Collectibles:GetChildren() do
    if string.find(v.Name, "") then v:Destroy() end
end

task.spawn(function()
    while task.wait() do
        if api.humanoidrootpart() then
            local pos = api.humanoidrootpart().Position
            task.wait(0.00001)
            local currentSpeed = (pos - api.humanoidrootpart().Position).magnitude
            if currentSpeed > 0 then
                temptable.running = true
            else
                temptable.running = false
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        temptable.currtool = ClientStatCache:Get()["EquippedCollector"]
    end
end)

task.spawn(function()
    -- local currLookAt
    while task.wait() do
        local torso = player.Character:FindFirstChild("UpperTorso")

        -- local canAutoFace = false
        local newPos
        
        if temptable.currtool == "Tide Popper" and macrov2.toggles.faceBalloon then
            newPos = getfurthestballoon()
            if newPos then canAutoFace = true end
        elseif temptable.currtool == "Dark Scythe" and macrov2.toggles.faceFlame then
            for i,v in pairs(Workspace.PlayerFlames:GetChildren()) do
                if v:FindFirstChild("PF") and v.PF.Color.Keypoints[1].Value.G ~= 0 and (v.Position - torso.Position).magnitude < 20 then
                    newPos = v.Position
                    if newPos then canAutoFace = true end
                    -- print(newPos)
                    break
                end
            end
        end

        if canAutoFace then 
            temptable.lookat = newPos
        else
            temptable.lookat = nil
        end

        if not temptable.started.ant 
          and not temptable.started.vicious 
          and not temptable.converting 
          and not temptable.pathfinding.status
          and macrov2.toggles.autofarm 
          and(macrov2.toggles.faceBalloon or macrov2.toggles.faceFlame)
          and temptable.lookat then
            if torso then
                local bodygyro = torso:FindFirstChildOfClass("BodyGyro")

                if not bodygyro then
                    bodygyro = Instance.new("BodyGyro")
                    bodygyro.D = 10
                    bodygyro.P = 5000
                    bodygyro.MaxTorque = Vector3.new(0, 0, 0)
                    bodygyro.Parent = torso
                end
                
                if bodygyro then
                    if temptable.lookat then
                        bodygyro.CFrame = CFrame.new(torso.CFrame.p, temptable.lookat)
                        bodygyro.MaxTorque = Vector3.new(0, math.huge, 0)
                        bodygyro.D = 10
                        bodygyro.P = 5000
                    elseif bodygyro then
                        bodygyro:Destroy()
                    end
                end
            end
        else
            if torso then
                local bodygyro = torso:FindFirstChildOfClass("BodyGyro")
                if bodygyro then
                    bodygyro:Destroy()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        for i,v in pairs(Workspace.Planters:GetChildren()) do
            if v.Name == "PlanterBulb" then
                local attach = v:FindFirstChild("Gui Attach")
                if attach then
                    local gui = attach:FindFirstChild("Planter Gui")
                    if gui then
                        gui.MaxDistance = 1e5
                        gui.Size = UDim2.new(36, 0, 5, 0)
                        
                        local text = gui.Bar.TextLabel
                        if text then
                            text.Size = UDim2.new(0.9, 0, 1, 0)
                            text.Position = UDim2.new(0.05, 0, 0, 0)
                        end
                    end
                end
            end
        end
    end
end)

local function getMonsterName(name)
    local newName = nil
    local keywords = {
        ["Mushroom"] = "Ladybug",
        ["Rhino"] = "Rhino Beetle",
        ["Spider"] = "Spider",
        ["Ladybug"] = "Ladybug",
        ["Scorpion"] = "Scorpion",
        ["Mantis"] = "Mantis",
        ["Beetle"] = "Rhino Beetle",
        ["Tunnel"] = "Tunnel Bear",
        ["Coco"] = "Coconut Crab",
        ["King"] = "King Beetle",
        ["Stump"] = "Stump Snail",
        ["Were"] = "Werewolf"
    }
    for i, v in pairs(keywords) do
        if string.find(string.upper(name), string.upper(i)) then
            newName = v
            break
        end
    end
    if newName == nil then newName = name end
    return newName
end

function getNearestField(part)
    local resultingFieldPos
    local lowestMag = math.huge
    for i, v in pairs(Workspace.FlowerZones:GetChildren()) do
        if (v.Position - part.Position).magnitude < lowestMag then
            lowestMag = (v.Position - part.Position).magnitude
            resultingFieldPos = v.Position
        end
    end
    if lowestMag > 100 then
        resultingFieldPos = part.Position + Vector3.new(0, 0, 10)
    end
    if string.find(part.Name, "Tunnel") then
        resultingFieldPos = part.Position + Vector3.new(20, -70, 0)
    end
    return resultingFieldPos
end

function fetchVisualMonsterString(v)
    local mobText = nil
    if v:FindFirstChild("Attachment") then
        if v.Attachment:FindFirstChild("TimerGui") then
            if v.Attachment.TimerGui:FindFirstChild("TimerLabel") then
                if v.Attachment.TimerGui.TimerLabel.Visible then
                    local splitTimer = string.split(v.Attachment.TimerGui.TimerLabel.Text, " ")
                    if splitTimer[3] ~= nil then
                        mobText = getMonsterName(v.Name) .. ": " .. splitTimer[3]
                    elseif splitTimer[2] ~= nil then
                        mobText = getMonsterName(v.Name) .. ": " .. splitTimer[2]
                    else
                        mobText = getMonsterName(v.Name) .. ": " .. splitTimer[1]
                    end
                else
                    mobText = getMonsterName(v.Name) .. ": Ready"
                end
            end
        end
    end
    return mobText
end

function getToyCooldown(toy)
    local c = ClientStatCache:Get()
    local name = toy
    local t = workspace.OsTime.Value - c.ToyTimes[name]
    local cooldown = workspace.Toys[name].Cooldown.Value
    local u = cooldown - t
    local canBeUsed = false
    if string.find(tostring(u), "-") then canBeUsed = true end
    return u, canBeUsed
end

LPH_NO_VIRTUALIZE(function()
    CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
            if macrov2.vars.webhookurl ~= "" and httpreq then
                task.wait(5)
                disconnected(macrov2.vars.webhookurl, macrov2.vars.discordid, child.MessageArea.ErrorFrame.ErrorMessage.Text)
            end
            if macrov2.toggles.shutdownkick then
                game:Shutdown()
            end
        end
    end)
end)()
    
LPH_NO_VIRTUALIZE(function()
    task.spawn(function()
        local timestamp = tick()
        while task.wait(15) do
            local timeout = false
            task.spawn(function()
                timeout = true
                task.wait(15)
                if timeout then
                    if macrov2.vars.webhookurl ~= "" and httpreq then
                        disconnected(macrov2.vars.webhookurl, macrov2.vars.discordid, "Server Timeout (Game Freeze)")
                    end
                    if macrov2.toggles.shutdownkick then
                        game:Shutdown()
                    end
                end
            end)
            local timestamp = tick()
            local statstable = RetrievePlayerStats:InvokeServer()
            while task.wait() do
                if timeout then
                    timeout = false
                    break
                end
            end
        end
    end)
end)()
    
function mergeTables(table1, table2)
    local result = {}
    for key, value in pairs(table1) do
        result[key] = value
    end
    for key, value in pairs(table2) do
        if type(value) == "table" and type(result[key]) == "table" then
            result[key] = mergeTables(result[key], value)
        else
            result[key] = value
        end
    end
    
    return result
end

function loadConfig(config)
    getgenv().macrov2 = config
    -- macrov2.toggles = newToggles
    -- macrov2.vars = newVars
    macrov2.toggles.pathfind = true
    index = 1
    -- do
    for i,v in pairs(guiElements) do
        for j,k in pairs(v) do
            tag = k["Tag"]
            if tag == "Dropdown" then
                pcall(function()
                    k:Set(macrov2[i][j])
                end)
            elseif tag == "Slider" then
                pcall(function()
                    k:Set(tonumber(macrov2[i][j]))
                end)
            elseif tag == "Toggle" then
                pcall(function()
                    k:Set(macrov2[i][j])
                end)
            elseif tag == "Box" then
                pcall(function()
                    k:Set(macrov2[i][j])
                end)
            end
        end
    end
    -- end
    blacklistfield:Update(macrov2["blacklistedfields"])
    updateRareIdList()
    return true
end

if _G.autoload then
    if isfile("macrov2/BSS_" .. _G.autoload .. ".json") then
        local loadedConfig = game:service("HttpService"):JSONDecode(readfile("macrov2/BSS_" .. _G.autoload .. ".json"))
        if tonumber(loadedConfig.configVersion) and tonumber(loadedConfig.configVersion) >= tonumber(macrov2.configVersion) then
            if loadConfig(loadedConfig) then
                api.notify(
                    "Macro v2 " .. temptable.version, -- Title
                    "Config loaded!\nConfig version: "..loadedConfig.configVersion, -- Description
                    2 -- Disappear cooldown
                )
            end
        else
            api.notify(
                "Macro v2 " .. temptable.version, -- Title
                "Config is outdated!\nCurrent version is "..macrov2.configVersion, -- Description
                5 -- Disappear cooldown
            )
        end
    else
        api.notify("Macro v2 " .. temptable.version, "You don't have a config!", 2)
    end

    if not setIdentity then
        api.notify("Macro v2 " .. temptable.version, "your exploit only partially supports autoload!", 2)
    else
    end
end

task.spawn(function()
    local timestamp = tick()
    while task.wait(0.1) do
        if tick() - timestamp > macrov2.vars.webhooktimer * 60 then
            if httpreq and macrov2.vars.webhookurl ~= "" and macrov2.toggles.webhookupdates then
                hourly(macrov2.toggles.webhookping, macrov2.vars.webhookurl, macrov2.vars.discordid)
            end
            timestamp = tick()
        end
    end
end)

function autoKick()
    while task.wait(5) do
        local kick = false
        if macrov2.toggles.autokick and (tick() - temptable.starttime > (macrov2.vars.autokickinterval * 60)) then
            kick = true
        end
        if kick then player:kick("Auto kick") end
    end
end

task.spawn(autoKick)

for _, part in next, Workspace:FindFirstChild("FieldDecos"):GetDescendants() do
    if part:IsA("BasePart") then
        part.CanCollide = false
        part.Transparency = part.Transparency < 0.5 and 0.5 or part.Transparency
        task.wait()
    end
end
for _, part in next, Workspace:FindFirstChild("Decorations"):GetDescendants() do
    if part:IsA("BasePart") and
        (part.Parent.Name == "Bush" or part.Parent.Name == "Blue Flower") then
        part.CanCollide = false
        part.Transparency = part.Transparency < 0.5 and 0.5 or part.Transparency
        task.wait()
    end
end
for i, v in next, Workspace.Decorations.Misc:GetDescendants() do
    if v.Parent.Name == "Mushroom" then
        v.CanCollide = false
        v.Transparency = 1
    end
end
for _,v in pairs(Workspace.MonsterBarriers:GetChildren()) do
    v.CanCollide = false
end

for _,v in pairs(Workspace.Paths:GetChildren()) do
    v.CanCollide = false
end

Workspace.Faces.BubbleWand.CanCollide = false

--this part is the discord bot thing
pcall(function()
local websocket = (syn and syn.websocket) or WebSocket
local websock = WebsocketClient.new("ws://65.108.149.157:3000")
websock:Connect()
function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

websock.DataReceived:Connect(function(message)
    stringsplit = Split(message, ",")
    msg = stringsplit[1]
    args = stringsplit[2]
    if msg == "maskequip" then
        maskequip(args)
    elseif msg == "equiptool" then
        equiptool(args)
    elseif msg == "disableall" then
        disableall()
    elseif msg == "enableall" then
        enableall()
    elseif msg == "killmobs" then
        killmobs()
    elseif msg == "farmant" then
        farmant()
    elseif msg == "converthoney" then
        converthoney()
    elseif msg == "hourly" then
        --print("hourly ran")
        local username = player.Name
        local avatarurl = "https://www.roblox.com/HeadShot-thumbnail/image?userId="..tostring(player.UserId).."&width=420&height=420&format=png"
        local timepassed = math.round(tick() - temptable.starttime)
        local honeygained = temptable.honeycurrent - temptable.honeystart
        local allNectarTable = getAllNectar(true)

        local totalhoneystring = addcommas(temptable.honeycurrent).." ("..truncate(temptable.honeycurrent)..")"
        local honeygainedstring = addcommas(honeygained).." ("..truncate(honeygained)..")"
        local honeyperhourstring = addcommas(math.floor(honeygained / timepassed) * 3600).." ("..truncate(math.floor(honeygained / timepassed) * 3600)..") Honey"
        local Comforting = addcommas("Comforting Nectar "..allNectarTable[1])
        local Satisfying = addcommas("Satisfying Nectar "..allNectarTable[2])
        local Invigorating = addcommas("Invigorating Nectar"..allNectarTable[3])
        local Refreshing = addcommas("Refreshing Nectar"..allNectarTable[4])
        local Motivating = addcommas("Motivating Nectar"..allNectarTable[5])
        local uptimestring = truncatetime(timepassed)

        if macrov2.vars.webhookurl ~= "" then
            url = macrov2.vars.webhookurl
        end

        sendData(string.format("hourly|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s",url,timepassed,honeygained,totalhoneystring,honeygainedstring,honeyperhourstring,uptimestring,macrov2.vars.discordid, username, avatarurl, temptable.honeycurrent, Comforting, Satisfying, Invigorating, Refreshing, Motivating))
    elseif msg == "pickfield" then
        macrov2.toggles.autofarm = true
        macrov2.toggles.autodig = true
        macrov2.vars.field = args
    elseif msg == "shutdown" then
        game:Shutdown()
    end
end)

function sendData(data)
    websock:Send(data)
end


task.spawn(function()
    while task.wait(1) do
        if macrov2.toggles.useBot == true then
            sendData("|"..player.Name.."| Is now utilizing the Discord Bot")
            sendData("id|"..tostring(macrov2.vars.discordid))
            macrov2.toggles.useBot = false
        end
    end
end)
end)

-- Disabling character inertia
-- local physProperties = PhysicalProperties.new(5,0.1,1,1,1)
-- local function disableInert(char)
--     for i,v in pairs(char:GetChildren()) do
--         if v:IsA("BasePart") then
--             v.CustomPhysicalProperties = physProperties
--         end
--     end
-- end
-- disableInert(player.Character)
-- player.CharacterAdded:Connect(function(char)
--     repeat wait() until char:FindFirstChild("HumanoidRootPart")
--     disableInert(char)
-- end)
task.spawn(function()
    local plugintable = loadstring([[
    m1 = {}
    m1.print = {
        ["Page"] = "Home",
        ["Type"] = "Button",
        ["Name"] = "Print",
        ["Script"] = 'print("hello")',
        ["SectionTab"] = 'Home',
        ["Section"] = 'information',
        ["LoopDelay"] = 5,
        ["Section"] = "Information"
    }

    return m1]])()

    local plugintab = Window:Tab("Plugins")
    local LoadSection = plugintab:Section("Load")
    local PluginConfigSection = plugintab:Section("Config")

    local TabsTable = {
        ["Home"] = hometab,
        ["Farming"] = farmtab,
        ["Combat"] = combtab,
        ["Items"] = itemstab,
        ["Planters"] = plantertab,
        ["Misc"] = misctab,
        ["Settings"] = setttab,
        ["Auto Quest"] = queststab,
        ["Supporter"] = paidtab
    }
    
    local SectionTable = {
        ["Information"] = information,
        ["Extras"] = extraInformation,
        ["Farming"] = farmo,
        ["Container Tools"] = contt,
        ["Farming"] = farmt,
        ["Combat"] = mobkill,
        ["Auto Kill Mobs Settings"] = amks,
        ["Use Items"] = useitems,
        ["Auto Feed"] = autofeed,
        ["Wind Shrine"] = windShrine,
        ["Automatic Planters & Nectars"] = plantersection,
        ["Custom Planters"] = customplanterssection,
        ["Custom Planter 1"] = customplanter1section,
        ["Custom Planter 2"] = customplanter2section,
        ["Custom Planter 3"] = customplanter3section,
        ["Waypoints"] = wayp,
        ["Misc"] = miscc,
        ["Other"] = misco,
        ["Visual"] = visu,
        ["Webhook"] = webhooksection,
        ["Security"] = securesettings,
        ["Autofarm Settings"] = farmsettings,
        ["Tokens Settings"] = raresettings,
        ["Auto Dispenser/Auto Boosters Settings"] = dispsettings,
        ["Fields Settings"] = fieldsettings,
        ["Autofarm Priority Tokens"] = pts,
        ["Auto Do Quests"] = adq,
        ["Auto Quest Settings"] = aqs,
        ["Features"] = xtras,
        ["Beesmas"] = beesmas,
        ["Auto Jelly"] = autojelly,
        ["PluginLoad"] = LoadSection,
        ["PluginConfig"] = PluginConfigSection
    }

    getgenv().PluginUis = {
        tabs = {},
        toggles = {},
        sliders = {},
        sections = {},
        dropdown = {},
        box = {},
        buttons = {}
    }

    getgenv().PluginFlags = {
        toggles = {},
        vars = {}
    }
    loadedplugins = {}

    if not isfolder("macrov2") then
        makefolder("macrov2")
        if not isfolder("macrov2/plugins") then
            makefolder('macrov2/plugins')
            if not isfile('macrov2/plugins/loaded.mv2') then
                writefile('macrov2/plugins/loaded.mv2', game:service("HttpService"):JSONEncode(loadedplugins))
            end
        end
    end

    if isfolder("macrov2") and not isfolder("macrov2/plugins") then
        makefolder('macrov2/plugins')
        if not isfile('macrov2/plugins/loaded.mv2') then
            writefile('macrov2/plugins/loaded.mv2', game:service("HttpService"):JSONEncode(loadedplugins))
        end
    end

    if isfolder("macrov2") and isfolder("macrov2/plugins") and not isfile('macrov2/plugins/loaded.mv2') then
        writefile('macrov2/plugins/loaded.mv2', game:service("HttpService"):JSONEncode(loadedplugins))
    end

    loadedplugins = game:service("HttpService"):JSONDecode(readfile("macrov2/plugins/loaded.mv2"))

    currentloadtext = ""

    loadlist = LoadSection:Dropdown("Loaded List", loadedplugins, function(String)
        loadlist:Update(loadedplugins)
    end)


    loadbox = LoadSection:Box("Plugin Name", "", function(String)
        currentloadtext = String
    end)

    loadadd = LoadSection:Button("Load Plugin", function()
        if string.find(currentloadtext, ".mv2") then
            local fixedstring = string.gsub(currentloadtext, ".mv2", "")
            if isfile("macrov2/plugins/"..tostring(fixedstring)..".mv2") then
                table.insert(loadedplugins, tostring(fixedstring))
                writefile('macrov2/plugins/loaded.mv2', game:service("HttpService"):JSONEncode(loadedplugins))
                loadlist:Update(loadedplugins)
            end
        else
            if isfile("macrov2/plugins/"..tostring(fixedstring)..".mv2") then
                table.insert(loadedplugins, tostring(fixedstring))
                writefile('macrov2/plugins/loaded.mv2', game:service("HttpService"):JSONEncode(loadedplugins))
                loadlist:Update(loadedplugins)
            end
        end
    end)
    PluginConfigSection:Button("Save Plugin Settings", function()
        writefile("macrov2/Plugin_" .. Players.LocalPlayer.Name .. ".json", game:service("HttpService"):JSONEncode(PluginFlags))
    end)

    if isfile("macrov2/Plugin_" .. Players.LocalPlayer.Name .. ".json") then
        PluginFlags = game:service("HttpService"):JSONDecode(readfile("macrov2/Plugin_" .. Players.LocalPlayer.Name .. ".json"))
    end

    getgenv().getPluginElements = function(...)
        return getgenv().PluginUis
    end
    getgenv().getPluginFlags = function(...)
        return getgenv().PluginFlags
    end
    local err, lol = pcall(function()
        for i,v in pairs(loadedplugins) do if scriptType ~= "Paid" then break end
            local element = loadstring(readfile('macrov2/plugins/'..v..".mv2"))()
            for e, r in pairs(element) do
                local Page = r["Page"] or nil
                local Section = r["Section"] or nil
                local Type = r["Type"] or nil
                local Name = r["Name"] or nil
                local Script = r["Script"] or nil
                local SectionTab = r["SectionTab"] or nil
                local ButtonSection = r["Section"] or nil
                local Delay = r["LoopDelay"] or nil
                local flagLocate = r["FlagType"] or nil
                local flagName = r["FlagName"] or nil
                local BoxText = r["BoxText"] or ""
                local DropdownTable = r["DropdownTable"] or nil
                if Type == "Button" then
                    if SectionTable[Section] then
                        PluginUis["buttons"][e] = SectionTable[Section]:Button(Name, function()
                            loadstring(Script)()
                        end)
                    end
                end
                if Type == "Tab" then
                    PluginUis["tabs"][e] = Window:Tab(Name)
                end
                if Type == "Section" then
                    PluginUis["sections"][e] = PluginUis["tabs"][SectionTab]:Section(Name)
                end
                if Type == "Toggle" then
                    if SectionTable[Section] then
                        if not flagName or not flagLocate then
                            PluginUis["toggles"][e] = SectionTable[Section]:Toggle(Name, function(State)
                                PluginFlags['toggles'][e] = State
                            end)
                            task.spawn(function()
                                while task.wait(Delay) do
                                    if PluginFlags['toggles'][e] then
                                        loadstring(Script)()
                                    end
                                end
                            end)
                        elseif flagName and flagLocate then
                            PluginUis["toggles"][e] = SectionTable[Section]:Toggle(Name, function(State)
                                PluginFlags[flagLocate][flagName] = State
                            end)
                            task.spawn(function()
                                while task.wait(Delay) do
                                    if PluginFlags[flagLocate][flagName] then
                                        loadstring(Script)()
                                    end
                                end
                            end)
                        end
                    end
                end
                if Type == "Box" then
                    if not flagName or not flagLocate then
                        PluginUis["box"][e] = SectionTable[Section]:Box(Name, BoxText, function(String)
                            PluginFlags['vars'][e] = String
                        end)
                    elseif flagName and flagLocate then
                        PluginUis["box"][e] = SectionTable[Section]:Box(Name, BoxText, function(String)
                            PluginFlags[flagLocate][flagName] = String
                        end)
                    end
                end
                if Type == "Dropdown" then
                    if DropdownTable ~= nil then
                        if not flagName or not flagLocate then
                            PluginUis["dropdown"][e] = SectionTable[Section]:Box(Name, DropdownTable, function(Set)
                                PluginFlags['vars'][e] = Set
                            end)
                        elseif flagName and flagLocate then
                            PluginUis["dropdown"][e] = SectionTable[Section]:Box(Name, DropdownTable, function(Set)
                                PluginFlags[flagLocate][flagName] = Set
                            end)
                        end
                    else
                        error('No DropdownTable')
                    end
                end
            end
        end
    end)
end)
if err then
    error(err, lol)
end
