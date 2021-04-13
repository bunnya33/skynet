local skynet = require "skynet"
local pb = require "pb" -- 载入 pb.dll

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

skynet.start(function()
	skynet.error("Server start")
	

	assert(pb.loadfile "examples/addressbook.pb") -- 载入刚才编译的pb文件

	local person = { -- 我们定义一个addressbook里的 Person 消息
	name = "Alice",
	id = 12345,
	phones = {
		{ number = "1301234567" },
		{ number = "87654321", type = "WORK" },
	}
	}

	-- 序列化成二进制数据
	local data = assert(pb.encode("tutorial.Person", person))

	-- 从二进制数据解析出实际消息
	local msg = assert(pb.decode("tutorial.Person", data))

	-- 打印消息内容
	skynet.error(dump(msg))

	skynet.exit()
end)
