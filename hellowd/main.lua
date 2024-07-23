local json = require "lua/json"

local level = -1


function consoleErr(s) if level > 1 then return end consoleLog(string.format("%s %s", "[ERROR]", s)) end
function consoleWarn(s) if level > 1 then return end consoleLog(string.format("%s %s", "[WARN]", s))  end
function consoleInfo(s) if level > 0 then return end consoleLog(string.format("%s %s", "[INFO]", s))  end
function consoleDebug(s) if level > -1 then return end consoleLog(string.format("%s %s", "[DEBUG]", s))  end
function consoleLog(s)
    print(s)
end

-- 命令中携带的参数
local params = {}

-- 文件名在参数table中的key
local KEY_FILE = "file"

function init(args)
    -- 处理命令中的传参 参数传递格式 在命令末尾追加[ -- key1=val1 key2=val2 ]
    for i = 1, #args do
        local key, value = string.match(args[i], "([^=]+)=([^=]+)")
        if key and value then
            params[key] = value
        end
    end

    consoleDebug(params[KEY_FILE])
    file = io.open(params[KEY_FILE], "r")
    io.input(file)
end

-- readLine 读取文件中的一行 读取结束后重新打开文件
readLine = function()
    line = io.read()
    if line == nil
    then
        io.close(file)
        file = io.open(params[KEY_FILE], "r")
        io.input(file)
        line = io.read()
    end

    consoleDebug(line)
    res = json.decode(line)
    -- 如果 uri中包含login则重新读取
    if string.find(res.uri, "login") ~= nil
    then
        return readLine()
    end
    return res
end

-- Function to get the next request details
local function next_request()
    local req = readLine()

    -- Construct the header table
    local headers = {}
    local headerMap = json.decode(req.header)
    for k, v in pairs(headerMap) do
        consoleDebug(string.format("key: [%s], value: [%s]", k, v))
        headers[k] = v
    end

    consoleInfo(string.format("method: [%s], uri: [%s]", req.method, req.uri))
    return wrk.format(req.method, req.uri, headers, req.reqBody)
end

-- Setup function to initialize wrk
function setup(thread)
   -- thread:set("next_request", next_request)
end

-- Request function to return the next request
function request()
    return next_request()
end

-- delay 延迟 单位 ms
function delay()
    return 0
 end
