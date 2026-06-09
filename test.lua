local API_URL  = "https://misc.reconnect-tool.tech"
local API_KEY  = "b906a02220b641dd835ce9053fd30b54"
local INTERVAL = 5

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")

local function getHttp()
    if syn and syn.request       then return syn.request    end
    if request                   then return request        end
    if http_request              then return http_request   end
    if http and http.request     then return http.request   end
    if fluxus and fluxus.request then return fluxus.request end
    return nil
end

local http = getHttp()
if not http then return end

local LP                = Players.LocalPlayer
local username          = LP and LP.Name or "TestUser"
local statusFile        = "ReconnectX/reconnect_status_" .. username .. ".json"
local disconnected      = false
local capturedErrorCode = nil
local capturedErrorName = nil

local function writeStatus(ts, status, errorCode, errorName)
    pcall(function()
        if not (writefile and makefolder and isfolder) then return end
        if not isfolder("ReconnectX") then makefolder("ReconnectX") end
        local data = { timestamp = ts, status = status }
        if errorCode then data.errorCode = errorCode end
        if errorName then data.errorName = errorName end
        writefile(statusFile, HttpService:JSONEncode(data))
    end)
end

local function onDisconnect(errorCode, errorName)
    if disconnected then return end
    disconnected = true
    local ts = os.time()

    writeStatus(ts, "Disconnect")

    if not errorCode and not capturedErrorCode then
        local deadline = os.clock() + 1
        while os.clock() < deadline do
            if capturedErrorCode then break end
            pcall(task.wait, 0.1)
        end
    end

    errorCode = errorCode or capturedErrorCode
    errorName = errorName or capturedErrorName

    if not errorCode then
        pcall(function()
            local code = game:GetService("GuiService"):GetErrorCode()
            if code and code.Value ~= 0 then
                errorCode = code.Value
                errorName = code.Name
            end
        end)
    end

    if errorCode then
        writeStatus(ts, "Disconnect", errorCode, errorName)
    end
end

pcall(function()
    Players.PlayerRemoving:Connect(function(p)
        if p == LP then onDisconnect() end
    end)
end)
pcall(function() game:BindToClose(onDisconnect) end)
pcall(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        local code = game:GetService("GuiService"):GetErrorCode()
        if code then
            capturedErrorCode = code.Value
            capturedErrorName = code.Name
        end
        onDisconnect(capturedErrorCode, capturedErrorName)
    end)
end)

local function clockWait(seconds)
    local deadline = os.clock() + seconds
    while os.clock() < deadline and not disconnected do
        pcall(task.wait, 0.1)
    end
end

while not disconnected do
    local ts = os.time()

    local ok, resp = pcall(http, {
        Url     = API_URL .. "/heartbeat",
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json", ["X-API-Key"] = API_KEY },
        Body    = HttpService:JSONEncode({ username = username }),
    })

    if disconnected then break end

    local code = ok and resp and resp.StatusCode or 0
    writeStatus(ts, code == 200 and "Online" or "Disconnect")

    clockWait(INTERVAL)
end
