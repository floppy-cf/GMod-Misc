if CLIENT then
	net.Receive("\1ModuleCheck",function(len)
		local RequestPly = net.ReadEntity()
		if RequestPly == LocalPlayer() then
			net.Start("\1ModuleCheck")
			net.WriteTable(file.Find("lua/bin/*","MOD"))
			net.WriteBool(file.Exists("lua/menu_plugins","MOD"))
			net.WriteTable(file.Find("lua/menu_plugins/modules/*","MOD"))
			net.SendToServer()
		end
	end)
end

if SERVER then
	util.AddNetworkString("\1ModuleCheck")
	hook.Add("PlayerInitialSpawn","\1ModuleCheck",function(pl)
		net.Start("\1ModuleCheck")
		net.WriteEntity(pl)
		net.Broadcast()
	end)

	net.Receive("\1ModuleCheck",function(len,pl)
		local modules = net.ReadTable()
		local hasmp = net.ReadBool()
		local mplugins = net.ReadTable()
		if modules and table.Count(modules) != 0 then
			local m = {}
			for n,mod in pairs(modules) do
				mod = mod:gsub("_win32.dll",""):gsub("_linux.dll","")
				if mod:find("interstate") or mod:find("cvar3") or mod:find("roc") then
					table.insert(m,Color(255,0,0))
					table.insert(m,mod..(n == table.Count(modules) and "" or ", "))
				else
					table.insert(m,Color(255,255,255))
					table.insert(m,mod..(n == table.Count(modules) and "" or ", "))
				end
			end
			MsgC(Color(100,200,100),"[ModuleCheck] ",Color(255,128,0),tostring(pl),Color(255,255,255)," has modules: ")
			MsgC(unpack(m))
			MsgN("")
		end
		if hasmp and mplugins and table.Count(mplugins) != 0 then
			local m = {}
			for n,mod in pairs(mplugins) do
				mod = mod:gsub(".lua","")
				if mod:find("luaviewer") then
					pl.__luaviewer = true
					table.insert(m,Color(255,0,0))
					table.insert(m,mod..(n == table.Count(mplugins) and "" or ", "))
				else
					table.insert(m,Color(255,255,255))
					table.insert(m,mod..(n == table.Count(mplugins) and "" or ", "))
				end
			end
			MsgC(Color(100,200,100),"[ModuleCheck] ",Color(255,128,0),tostring(pl),Color(255,255,255)," has menu_plugins: ")
			MsgC(unpack(m))
			MsgN("")
		end
	end)

	function ModuleCheck(pl)
		if not pl then
			MsgC(Color(100,200,100),"[ModuleCheck] ",Color(255,0,0),"MANUAL SCANNING EVERYONE FOR MODULES\n")
			for _,p in next,player.GetAll() do
				net.Start("\1ModuleCheck")
				net.WriteEntity(p)
				net.Broadcast()
			end
		else
			MsgC(Color(100,200,100),"[ModuleCheck] ",Color(255,255,255),"Manual scanning ",Color(255,128,0),tostring(pl),Color(255,255,255)," for modules.\n")
			net.Start("\1ModuleCheck")
			net.WriteEntity(pl)
			net.Broadcast()
		end
	end
end