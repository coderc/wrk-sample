local level = 0


function consoleErr(s) if level > 1 then return end consoleLog(string.format("%s %s", "[ERROR]", s)) end
function consoleWarn(s) if level > 1 then return end consoleLog(string.format("%s %s", "[WARN]", s))  end
function consoleInfo(s) if level > 0 then return end consoleLog(string.format("%s %s", "[INFO]", s))  end
function consoleDebug(s) if level > -1 then return end consoleLog(string.format("%s %s", "[DEBUG]", s))  end
function consoleLog(s)
    print(s)
end

-- ⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️必须检查⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️
-- 指定运行路径
local runPath = "/root/shaochong_dir/wrk-sample/"
-- 指定从哪个文件中读取request数据
local file = "request-02.txt"
local delayNumber = 0 -- 单位: ms
local splitChar = ","
-- ⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️必须检查⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️

-- 开启debug会显示每次请求的exchange和body
fileOpen = io.open(runPath .. file, "r")
io.input(fileOpen)

route = "/dsp/dsp_dispatcher"
wrk.method = "POST"
wrk.body   = io.read()
wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"
wrk.headers["host"] = "www.tualta.com"


findIdx = function(str, ch)
    idx = -1
    for i = 0, string.len(str) do
        if string.sub(str, i, i) == ch
        then
            idx = i
            break
        end
    end
    return idx
end

-- read single line from file
-- in: string, out: map{[body: post request body], [other: url params]}
readLine = function()
    line = io.read()
    if line == nil
    then
        io.close(fileOpen)
        fileOpen = io.open(runPath .. file, "r")
        io.input(fileOpen)
        line = io.read()
    end

    kvs = {}
    idx = findIdx(line, splitChar)
    if idx == -1
    then
        consoleErr(string.format("read line failed, line: [%s], splitChar: [%s]", line, splitChar))
        return nil, nil
    end
    kvs.exchange = string.sub(line, 1, idx - 1)
    kvs.debug = "false"
    kvs.body = string.sub(line, idx + 2, string.len(line) - 1)
    consoleDebug(map2str(kvs))
    return kvs
end

function map2str(kvs)
    s = ""
    for k, v in pairs(kvs) do
        s = s .. k .. "=" .. v
    end
    return s
end


function map2paramStr(kvs)
    s = ""
    for k, v in pairs(kvs) do
        if k ~= "body"
        then
            s = s .. k .. "=" .. v .. "&"
        end
    end
    return s
end

-- delay 设置每个请求的间隔时间(单位:毫秒)
delay = function()
    return delayNumber
end

request = function()
    -- 设置请求体
    kvs = readLine()

    if kvs.exchange == nil or kvs.body == nil
    then
        consoleErr("exchange or body is nil")
        return
    end
    wrk.path = route .. "?" .. map2paramStr(kvs)
    wrk.body = kvs.body
    consoleDebug(map2str(kvs))
    return wrk.format()
end

-- 单线程单连接的测试shell
-- ./wrk/wrk -d3s -c1 -t1 --latency -s main.lua http://127.0.0.1:8088
-- ./wrk/wrk -d3s -c1 -t1 --latency -s main.lua http://alb-27s6lgjph505zmdk5t.ap-southeast-1.alb.aliyuncs.com
-- ./wrk -d4s -c1 -t1 --latency -s main.luatest.tualta.com
-- 双线程双连接的测试shell
-- ./wrk/wrk -d10s -c2 -t2 --latency -s main.lua http://0.0.0.0:8088

-- 两万qps的压测
-- ./wrk -t16 -c1000 -d10s --latency http://adxalb-147739866.us-west-2.elb.amazonaws.com/v1/adx
-- ./wrk -t16 -c5000 -d610s --latency http://adxalb-147739866.us-west-2.elb.amazonaws.com/v1/adx
-- ./wrk -t1 -c1 -d3s --latency http://adxalb-147739866.us-west-2.elb.amazonaws.com/v1/adx

-- ./wrk/wrk -d1m -c1 -t1 -s main.lua http://192.168.3.57:8348
-- ./wrk/wrk -d1m -c4 -t4 -s main.lua http://13.212.91.81:8008
