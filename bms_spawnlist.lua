--[[
Black Mesa Prop Generator
By Flex

Based off of PAC3 generator
--]]

if (SERVER) then AddCSLuaFile() return end

local SpawnTables = {}

local function AppendToSpawnlist(kvtype, kvdata, kvtab)
	if kvtype == "header" then
		kvtab.ContentsNum = kvtab.ContentsNum+1
		local kvContainer = {}
		kvContainer[tostring(kvtab.ContentsNum)] = {}
		kvContainer[tostring(kvtab.ContentsNum)]["type"] = "header"
		kvContainer[tostring(kvtab.ContentsNum)]["text"] = kvdata
		table.Add(kvtab.Contents, kvContainer)
	elseif kvtype == "model" then
		kvtab.ContentsNum = kvtab.ContentsNum+1
		local kvContainer = {}
		kvContainer[tostring(kvtab.ContentsNum)] = {}
		kvContainer[tostring(kvtab.ContentsNum)]["type"] = "model"
		kvContainer[tostring(kvtab.ContentsNum)]["model"] = kvdata
		table.Add(kvtab.Contents, kvContainer)
	end
end

local function GenerateSpawnlist(uid, name, id, parent, icon)
	SpawnTables[uid] = {}
	SpawnTables[uid].UID = id.."-"..uid
	SpawnTables[uid].Name = name
	SpawnTables[uid].Contents = {}
	SpawnTables[uid].ContentsNum = 0
	SpawnTables[uid].Icon = icon
	SpawnTables[uid].ID = id
	if parent and SpawnTables[parent] then
		SpawnTables[uid].ParentID = SpawnTables[parent].ID
	else
		SpawnTables[uid].ParentID = 0
	end
end

local function GetModels(path,tbl)
	for _,mdl in pairs(file.Find(path.."/*","GAME")) do
		if not mdl:find(".mdl") then continue end
		if mdl:find("_arms") then continue end
		if mdl:find("_animations") then continue end
		AppendToSpawnlist("model", path.."/"..mdl, SpawnTables[tbl])
	end
end

local function GetModelsFromSub(path,tbl)
	for _,dir in next,select(2,file.Find(path.."/*","GAME")) do
		for _,mdl in pairs(file.Find(path.."/"..dir.."/*","GAME")) do
			if not mdl:find(".mdl") then continue end
			if mdl:find("_arms") then continue end
			if mdl:find("_animations") then continue end
			AppendToSpawnlist("model", path.."/"..dir.."/"..mdl, SpawnTables[tbl])
		end
	end
end

--Categories
GenerateSpawnlist("NPCs",     "NPCs",                    1,   nil,     "icon16/user.png")
GenerateSpawnlist("Props",    "Props",                   2,   nil,     "icon16/bricks.png")
GenerateSpawnlist("Props.AM", "Anomalous Materials",     21,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.AP", "Apprehension",            22,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.AR", "Architecture",            23,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.BM", "Black Mesa Labs",         24,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.BP", "Blast Pit",               25,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.BN", "Bounce",                  26,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.CT", "Canteen",                 27,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.CR", "Construction",            28,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.CF", "Crossfire",               29,  "Props", "icon16/brick.png")
GenerateSpawnlist("Props.DS", "Desert",                  210, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.EQ", "Equipment",               211, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.GW", "Gasworks",                212, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.IB", "Inbound",                 213, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.IN", "Industrial",              214, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.LC", "Lambda Core",             215, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.LB", "Lambda Bunker",           216, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.MA", "Marine Props",            217, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.MI", "Mill",                    218, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.OR", "Oar",                     219, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.OF", "Office Props",            220, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.PU", "Power Up",                221, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.QE", "Questionable Ethics",     222, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.RS", "Residue Processing",      223, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.SW", "Sewer Props",             224, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.SP", "Snark Pit",               225, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.ST", "Surface Tension",         226, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.SK", "Stack",                   227, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.SY", "Stalkyard",               228, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.SU", "Subtransit",              229, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.UC", "Unforeseen Consequences", 230, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.UT", "Undertow",                231, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.WG", "\"We Got Hostiles\"",     232, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.XE", "Xen",                     233, "Props", "icon16/brick.png")
GenerateSpawnlist("Props.Z1", "",                        234, "Props", "vgui/null")
GenerateSpawnlist("Props.Z2", "Misc",                    235, "Props", "icon16/brick_add.png")

--Models to add

--NPCs
AppendToSpawnlist("model", "models/humans/guard.mdl",             SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/guard_02.mdl",          SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/guard_hurt.mdl",        SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/hassassin.mdl",         SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/hev_gordon.mdl",        SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/hev_male.mdl",          SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/marine.mdl",            SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/marine_02.mdl",         SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/scientist.mdl",         SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/scientist_02.mdl",      SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/scientist_female.mdl",  SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/scientist_hurt.mdl",    SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/scientist_hurt_02.mdl", SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/scientist_kliener.mdl", SpawnTables["NPCs"])
--NPC Items
AppendToSpawnlist("header", "Items", SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/props/marine_beret.mdl",      SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/props/marine_cigar.mdl",      SpawnTables["NPCs"])
AppendToSpawnlist("model", "models/humans/props/scientist_syringe.mdl", SpawnTables["NPCs"])

--Props
GetModels("models/props_am",           "Props.AM")
AppendToSpawnlist("header", "Gib Models", SpawnTables["Props.AM"])
GetModels("models/props_am/gibs",            "Props.AM")
GetModels("models/props_apprehension",       "Props.AP")
GetModels("models/props_architecture",       "Props.AR")
GetModels("models/props_blackmesa",          "Props.BM")
GetModels("models/props_blastpit",           "Props.BP")
GetModels("models/props_bounce",             "Props.BN")
GetModels("models/props_canteen",            "Props.CT")
GetModels("models/props_construction",       "Props.CR")
GetModels("models/props_crossfire",          "Props.CF")
GetModels("models/props_desert",             "Props.DS")
GetModels("models/props_equipment",          "Props.EQ")
GetModels("models/props_gasworks",           "Props.GW")
GetModels("models/props_inbound",            "Props.IB")
GetModels("models/props_industrial",         "Props.IN")
GetModels("models/props_lambda",             "Props.LC")
GetModels("models/props_lambdabunker",       "Props.LB")
GetModels("models/props_marines",            "Props.MA")
GetModels("models/props_mill",               "Props.MI")
GetModels("models/props_oar",                "Props.OR")
GetModels("models/props_office",             "Props.OF")
GetModels("models/props_powerup",            "Props.PU")
GetModels("models/props_questionableethics", "Props.QE")
GetModels("models/props_residue",            "Props.RS")
GetModels("models/props_sewer",              "Props.SW")
GetModels("models/props_snarkpit",           "Props.SP")
GetModels("models/props_st",                 "Props.ST")
GetModels("models/props_stu",                "Props.ST")
GetModels("models/props_stack",              "Props.SK")
GetModels("models/props_stalkyard",          "Props.SY")
GetModels("models/props_subtransit",         "Props.SU")
GetModels("models/props_uc",                 "Props.UC")
GetModels("models/props_undertow",           "Props.UT")
GetModels("models/props_wgh",                "Props.WG")
GetModels("models/props_zen",                "Props.XE")

hook.Add("PopulateContent", "Spawnlist.BlackMesa", function(pc,tree,node)
	local ViewPanel = vgui.Create( "ContentContainer", pc )
	ViewPanel:SetVisible( false )

	local root_node = tree:AddNode("Black Mesa Props","games/16/hl1.png")
	root_node.DoClick = function()
		ViewPanel:Clear( true )
		pc:SwitchPanel( ViewPanel )
	end

	local nodes = {}

	for _,t in SortedPairs(SpawnTables) do
		nodes[t.ID] = root_node:AddNode(t.Name,t.Icon)

		nodes[t.ID].DoClick = function(self,node)
			if ( ViewPanel and ViewPanel.CurrentNode and ViewPanel.CurrentNode == node ) then return end
			ViewPanel:Clear( true )
			ViewPanel.CurrentNode = node

			if t.Contents then
				for _,c in pairs(t.Contents) do
					if c.type == "model" then
						local cp = spawnmenu.GetContentType("model")
						if cp then
							cp( ViewPanel, { model = c.model} )
						end
					elseif c.type == "header" then
						local cp = spawnmenu.GetContentType("header")
						if cp then
							cp( ViewPanel, { text = c.text} )
						end
					end
				end
			end

			local parent = self:GetRoot()

			if parent.LastActiveNode then
				parent.LastActiveNode.Icon:SetImageColor(Color(255,255,255))
			end

			self.Icon:SetImageColor(Color(0,255,0))
			parent.LastActiveNode = self

			pc:SwitchPanel( ViewPanel )
			ViewPanel.CurrentNode = node
		end

		if t.Icon == "vgui/null" then
			nodes[t.ID].ShowIcons = function() return false end
			nodes[t.ID].oldPerformLayout = nodes[t.ID].PerformLayout
			nodes[t.ID].PerformLayout = function(s)
				s.oldPerformLayout(s)
				s.Label:SetTall(2)
				s:SetTall(2)
			end
			nodes[t.ID].Paint = function(s,w,h)
				surface.SetDrawColor(derma.Color("DLabel",s.Label,Color(255,255,255)))
				surface.DrawLine(9,0,200,0)
				surface.DrawLine(9,0,9,h)
			end
		end
	end

	for _,n in pairs(nodes) do
		for _,t in SortedPairs(SpawnTables) do
			if t.ParentID and nodes[t.ParentID] then
				nodes[t.ParentID]:InsertNode(nodes[t.ID])
			end
		end
	end
end)