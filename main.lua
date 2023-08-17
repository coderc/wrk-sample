-- example HTTP POST script which demonstrates setting the
-- HTTP method, body, and adding a header

-- ⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️必须检查⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️
-- 指定运行路径
local runPath = "/Users/shaochong/iplayable/wrk/"
-- 指定从哪个文件中读取request数据
local file = "sample.request"
-- ⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️必须检查⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️

-- 开启debug会显示每次请求的exchange和body
local debug = true

fileOpen = io.open(runPath .. file, "r")
io.input(fileOpen)
-- local body = io.read("*a")
-- io.close(fileOpen)

-- 设置target server的ip和端口
wrk.scheme = "http"
wrk.host = "127.0.0.1"
wrk.port = 8088
path = "/dsp/dsp_dispatcher"
wrk.method = "POST"
wrk.body   = io.read()
wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"

findIdx = function(str, ch)
    idx = 0
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
readLine = function()
    line = io.read()
    if line == nil
    then
        io.close(fileOpen)
        fileOpen = io.open(runPath .. file, "r")
        io.input(fileOpen)
        line = io.read()
    end

    idx = findIdx(line, ",")
    exchange = string.sub(line, 1, idx - 1)
    body = string.sub(line, idx + 2, string.len(line) - 1)

    if debug
    then
        print("exchange: [" .. exchange .. "]")
        print("body: [" .. body .. "]")
    end
    return exchange, body
end

-- delay 设置每个请求的间隔时间(单位:毫秒)
delay = function()
    return 2000
end

request = function()
    -- 设置请求体
    exchange, body = readLine()

    if exchange == nil or body == nil
    then
        print("exchange or body is nil")
        return
    end
    wrk.path = path .. "?exchange=" .. exchange
    wrk.body   = body
    return wrk.format()
end

-- 单线程单连接的测试shell
-- ./wrk/wrk -d4s -c1 -t1 --latency -s main.lua http://0.0.0.0:8088
-- 双线程双连接的测试shell
-- ./wrk/wrk -d10s -c2 -t2 --latency -s main.lua http://0.0.0.0:8088

-- 两万qps的压测
-- ./wrk -t16 -c1000 -d10s --latency http://adxalb-147739866.us-west-2.elb.amazonaws.com/v1/adx
-- ./wrk -t16 -c5000 -d610s --latency http://adxalb-147739866.us-west-2.elb.amazonaws.com/v1/adx
-- ./wrk -t1 -c1 -d3s --latency http://adxalb-147739866.us-west-2.elb.amazonaws.com/v1/adx


-- ./wrk/wrk -d1m -c1 -t1 -s main.lua http://192.168.3.57:8348
-- ./wrk/wrk -d1m -c4 -t4 -s main.lua http://192.168.3.57:8348