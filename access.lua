redis = require "resty.redis"

ngx.log(ngx.ERR,ngx.req.raw_header())

local rate=0.5 -- 每秒钟可访问0.5次
local varName ="name" --name参数为用户标识
local args = ngx.req.get_uri_args()
local name= args[varName]

if type(name) == "nil" then
    ngx.req.read_body()
    local err;
    args, err = ngx.req.get_post_args()
    if err then
        ngx.say(err)
    return
    end
    name =args[varName]
end
if type(name) == "nil" then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

local red = redis:new()
red:set_timeout(1000) -- 1 sec
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local ss= ""                  
local tokens, err = red:hget(name,"tokens")
tokens=tonumber(tokens)
if type(tokens)=="nil" then
    red:hset(name,"tokens",5)
    tokens=5
end
-- ss=ss.."tokens: "..res .."<br/>"
local now=os.time()
local time, err = red:hget(name,"time")
time =tonumber(time)
if type(time)=="nil" then
    red:hset(name,"time",now)
    time=now
end

--ngx.log(ngx.ERR,time)


if now > time+60*5 then --间隔太长，重置为5
    tokens=5
else
    tokens=tokens+(now-time)*rate
end
if tokens<1 then
    red:hset(name,"tokens",tokens)
    red:hset(name,"time",now)
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

res,err = red:hset(name,"tokens",tokens-1)
if not res then
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    return
end

res,err = red:hset(name,"time",now)
if not res then
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    return
end

--ss=ss.."timestamp: "..res

--ngx.ctx.foo=ss   