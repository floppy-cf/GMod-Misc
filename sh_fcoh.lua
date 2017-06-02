--[[
Flex's Chat Overhaul v1
Contains
- Server -> Client chat.AddText
- Syntax
- Join/Leave
- Connecting
--]]
local Colors = {
	Red    = Color(192, 128, 128),
	Orange = Color(192, 164, 128),
	Yellow = Color(192, 192, 128),
	Green  = Color(128, 192, 128),
	Teal   = Color(128, 192, 192),
	Blue   = Color(128, 128, 192),
	Purple = Color(164, 128, 164),
	Pink   = Color(192, 128, 192),
	White  = Color(255, 255, 255),
	Black  = Color(0,   0,   0),
	Gray1  = Color(128, 128, 128),
	Gray2  = Color(164, 164, 164),
	Gray3  = Color(192, 192, 192),
}

if SERVER then
	util.AddNetworkString("FCOH_ChatAddText")

	local bullet = "\xE2\x97\x8F"

	--chat.AddText Server -> Client
	function ChatAddText(...)
		net.Start("FCOH_ChatAddText")
		net.WriteTable({...})
		net.Broadcast()
	end

	--Gameevents
	gameevent.Listen("player_connect")
	gameevent.Listen("player_disconnect")

	hook.Add("player_connect","FCOH",function(data)
		ChatAddText(Colors.Green," "..bullet.." ",Colors.Blue,data.name,Colors.Gray1," ("..data.networkid..") ",Colors.White,"is ",Colors.Green,"connecting",Colors.White,".")
	end)
	hook.Add("player_disconnect","FCOH",function(data)
		ChatAddText(Colors.Red," "..bullet.." ",Colors.Blue,data.name,Colors.Gray1," ("..data.networkid..") ",Colors.White,"has ",Colors.Red,"disconnected",Colors.White,".",Colors.Gray2," ("..data.reason..")")
	end)
	hook.Add("PlayerInitialSpawn","FCOH",function(pl)
		timer.Simple(0.05,function()
			ChatAddText(Colors.Green," "..bullet.." ",team.GetColor(pl:Team()),pl:Name(),Colors.Gray1," ("..pl:SteamID()..") ",Colors.White,"has ",Colors.Green,"spawned",Colors.White,".")
		end)
	end)
	hook.Remove("PlayerChangeName","\1nickname")
	hook.Add("PlayerChangeName","FCOH",function(pl)
		if pl:oldGetName() == pl:Name() then return end
		timer.Simple(0.1,function()
			ChatAddText(pl,Colors.White," is now called ",team.GetColor(pl:Team()),pl:Name(),Colors.White,".")
		end)
		return true
	end)
end

if CLIENT then
	net.Receive("FCOH_ChatAddText",function(len)
		local data = net.ReadTable()
		chat.AddText(unpack(data))
	end)

	--Syntax
	local syntax = {}

	syntax.DEFAULT    = 1
	syntax.KEYWORD    = 2
	syntax.IDENTIFIER = 3
	syntax.STRING     = 4
	syntax.NUMBER     = 5
	syntax.OPERATOR   = 6

	syntax.types = {
		"default",
		"keyword",
		"identifier",
		"string",
		"number",
		"operator",
		"ccomment",
		"cmulticomment",
		"comment",
		"multicomment"
	}

	syntax.patterns = {
		[2]  = "([%a_][%w_]*)",
		[4]  = "(\".-\")",
		[5]  = "([%d]+%.?%d*)",
		[6]  = "([%+%-%*/%%%(%)%.,<>~=#:;{}%[%]])",
		[7]  = "(//[^\n]*)",
		[8]  = "(/%*.-%*/)",
		[9]  = "(%-%-[^%[][^\n]*)",
		[10] = "(%-%-%[%[.-%]%])",
		[11] = "(%[%[.-%]%])",
		[12] = "('.-')",
		[13] = "(!+)",
	}

	syntax.colors = {
		Color(255, 255, 255),
		Color(127, 159, 191),
		Color(223, 223, 223),
		Color(191, 127, 127),
		Color(127, 191, 127),
		Color(191, 191, 159),
		Color(159, 159, 159),
		Color(159, 159, 159),
		Color(159, 159, 159),
		Color(159, 159, 159),
		Color(191, 159, 127),
		Color(191, 127, 127),
		Color(255,   0,   0),
	}

	syntax.keywords = {
		["local"]    = true,
		["function"] = true,
		["return"]   = true,
		["break"]    = true,
		["continue"] = true,
		["end"]      = true,
		["if"]       = true,
		["not"]      = true,
		["while"]    = true,
		["for"]      = true,
		["repeat"]   = true,
		["until"]    = true,
		["do"]       = true,
		["then"]     = true,
		["true"]     = true,
		["false"]    = true,
		["nil"]      = true,
		["in"]       = true
	}

	function syntax.process(code)
		local output, finds, types, a, b, c = {}, {}, {}, 0, 0, 0

		while true do
			local temp = {}

			for k, v in pairs(syntax.patterns) do
				local aa, bb = code:find(v, b + 1)
				if aa then
					table.insert(temp, {k, aa, bb})
				end
			end

			if #temp == 0 then break end
			table.sort(temp, function(a, b) return (a[2] == b[2]) and (a[3] > b[3]) or (a[2] < b[2]) end)
			c, a, b = unpack(temp[1])

			table.insert(finds, a)
			table.insert(finds, b)

			table.insert(types, c == 2 and (syntax.keywords[code:sub(a, b)] and 2 or 3) or c)
		end

		for i = 1, #finds - 1 do
			local asdf = (i - 1) % 2
			local sub = code:sub(finds[i + 0] + asdf, finds[i + 1] - asdf)

			table.insert(output, asdf == 0 and syntax.colors[types[1 + (i - 1) / 2]] or Color(0, 0, 0, 255))
			table.insert(output, (asdf == 1 and sub:find("^%s+$")) and sub:gsub("%s", " ") or sub)
		end

		return output
	end

	local methods = {
		["l"]      = "server",
		["lb"]	   = "both",
		["lc"]     = "clients",
		["lm"]     = "self",
		["ls"]     = "shared",
		["p"]      = "server",
		["pc"]     = "clients",
		["pm2"]    = "self",
		["pm"]     = "self",
		["ps"]     = "shared",
		["print"]  = "server",
		["printb"] = "both",
		["printc"] = "clients",
		["printm"] = "self",
		["table"]  = "server table",
		["keys"]   = "server keys",
		["lfind"]  = "server find",
		["lmfind"] = "self find",
		["cexec"]  = "cexec",
		["cmd"]    = "cmd",
		["rcon"]   = "rcon"
	}

	local colors = {
		["l"]      = Colors.Orange,
		["lc"]     = Colors.Teal,
		["lm"]	   = Colors.Teal,
		["p"]	   = Colors.Orange,
		["pc"]     = Colors.Teal,
		["pm2"]    = Colors.Teal,
		["pm"]     = Colors.Teal,
		["print"]  = Colors.Orange,
		["printc"] = Colors.Teal,
		["printm"] = Colors.Teal,
		["table"]  = Colors.Orange,
		["keys"]   = Colors.Orange,
		["lfind"]  = Colors.Orange,
		["lmfind"] = Colors.Teal,
		["cexec"]  = Colors.Teal,
		["cmd"]    = Colors.Teal,
		["rcon"]   = Colors.Orange,
	}

	local commandprefix = "^[!./]"

	hook.Add("OnPlayerChat","FCOH_Syntax",function(pl,txt,t,d)
		local method, color -- for overrides
		local cmd, code = txt:match(commandprefix .. "(l[bcms]?) (.*)$")
		if not code then cmd, code = txt:match(commandprefix .. "(p[sc]?) (.*)$") end
		if not code then cmd, code = txt:match(commandprefix .. "(pm2) (.*)$") end
		if not code then cmd, code = txt:match(commandprefix .. "(print[bcms]?) (.*)$") end
		if not code then cmd, code = txt:match(commandprefix .. "(table[bcms]) (.*)$") end
		if not code then cmd, code = txt:match(commandprefix .. "(keys) (.*)$") end
		if not code then cmd, code = txt:match(commandprefix .. "(l[m]?find) (.*)$") end
		if not code then cmd, code = txt:match(commandprefix .. "(cmd) (.*)$") end
		if not code then cmd, code = txt:match(commandprefix .. "(rcon) (.*)$") end

		if not code then
			method, code = txt:match(commandprefix .. "lsc ([^,]+),(.*)$")
			color = colors["lc"]
			method = "lua -> "..(IsValid(easylua.FindEntity(method)) and easylua.FindEntity(method):Name() or tostring(method) == "#me" and "self" or tostring(method) == "#all" and "everyone" or tostring(method))
		end

		if not code then
			method, code = txt:match(commandprefix .. "cexec ([^,]+),(.*)$")
			color = colors["lc"]
			method = "cmd -> "..(IsValid(easylua.FindEntity(method)) and easylua.FindEntity(method):Name() or tostring(method) == "#me" and "self" or tostring(method) == "#all" and "everyone" or tostring(method))
		end

		if not code then return end

		local method = method or methods[cmd]
		chat.AddText(pl, Colors.Gray3, '@', color or colors[cmd] or Colors.Teal, method, Colors.Gray3, ": ", unpack(syntax.process(code)))

		return true
	end)
end