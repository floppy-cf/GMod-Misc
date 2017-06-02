--[[
PAC3 Spawnlist Generator
by Flex

Based off of Homestuck Playset's spawnlist generator by ¦i?C (http://steamcommunity.com/profiles/76561198018719108/)
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

GenerateSpawnlist("TF2Weapons", "TF2 Weapons", 1, nil, "games/16/tf.png")
GenerateSpawnlist("TF2Hats", "Hats", 2, nil, "spawnicons/models/player/items/all_class/all_domination_b_medic.png")
GenerateSpawnlist("WS", "Workshop", 3, nil, "icon16/wrench.png")
GenerateSpawnlist("MvM", "MvM", 4, nil, "spawnicons/models/player/items/mvm_loot/all_class/mvm_badge.png")
GenerateSpawnlist("PModels", "Playermodels", 5, nil, "icon16/user.png")
GenerateSpawnlist("PACMDL", "PAC Models", 6, nil, "spawnicons/models/pac/default.png")

--Hats
GenerateSpawnlist("AllClass", "All Class", 21, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Scout", "Scout", 22, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Soldier", "Soldier", 23, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Pyro", "Pyro", 24, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Demo", "Demoman", 25, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Heavy", "Heavy", 26, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Engineer", "Engineer", 27, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Medic", "Medic", 28, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Sniper", "Sniper", 29, "TF2Hats", "icon16/folder.png")
GenerateSpawnlist("Spy", "Spy", 210, "TF2Hats", "icon16/folder.png")

--Workshop
GenerateSpawnlist("WSAllClass", "All Class", 31, "WS", "icon16/folder.png")
GenerateSpawnlist("WSScout", "Scout", 32, "WS", "icon16/folder.png")
GenerateSpawnlist("WSSoldier", "Soldier", 33, "WS", "icon16/folder.png")
GenerateSpawnlist("WSPyro", "Pyro", 34, "WS", "icon16/folder.png")
GenerateSpawnlist("WSDemo", "Demoman", 35, "WS", "icon16/folder.png")
GenerateSpawnlist("WSHeavy", "Heavy", 36, "WS", "icon16/folder.png")
GenerateSpawnlist("WSEngineer", "Engineer", 37, "WS", "icon16/folder.png")
GenerateSpawnlist("WSMedic", "Medic", 38, "WS", "icon16/folder.png")
GenerateSpawnlist("WSSniper", "Sniper", 39, "WS", "icon16/folder.png")
GenerateSpawnlist("WSSpy", "Spy", 310, "WS", "icon16/folder.png")
GenerateSpawnlist("WSWep", "Weapons", 311, "WS", "icon16/gun.png")

--Playermodels
GenerateSpawnlist("PM_HL2", "Half-Life 2", 51, "PModels", "games/16/hl2.png")
GenerateSpawnlist("PM_CIT", "Citizens", 511, "PM_HL2", "icon16/user_green.png")
GenerateSpawnlist("PM_CSS", "Counter-Strike", 52, "PModels", "games/16/cstrike.png")
GenerateSpawnlist("PM_GM", "Other", 53, "PModels", "games/16/garrysmod.png")

-- Not gonna automate because we dunno what players have --

--HL2--
AppendToSpawnlist("header", "Resistance", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/alyx.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/barney.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/eli.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/gman_high.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/kleiner.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/magnusson.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/monk.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/mossman_arctic.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/odessa.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("header", "Combine", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/breen.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/combine_soldier.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/combine_soldier_prisonguard.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/combine_super_soldier.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/police.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/police_fem.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/soldier_stripped.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("header", "Zombies/Misc", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/charple.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/corpse1.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/zombie_classic.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/zombie_fast.mdl", SpawnTables["PM_HL2"])
AppendToSpawnlist("model", "models/player/zombie_soldier.mdl", SpawnTables["PM_HL2"])

--HL2 Citizens--
AppendToSpawnlist("header", "City", SpawnTables["PM_CIT"])
for i = 1,9 do
	AppendToSpawnlist("model", "models/player/group01/male_0"..i..".mdl", SpawnTables["PM_CIT"])
end
for i = 1,6 do
	AppendToSpawnlist("model", "models/player/group01/female_0"..i..".mdl", SpawnTables["PM_CIT"])
end
AppendToSpawnlist("header", "Refugees", SpawnTables["PM_CIT"])
AppendToSpawnlist("model", "models/player/group02/male_02.mdl", SpawnTables["PM_CIT"])
AppendToSpawnlist("model", "models/player/group02/male_04.mdl", SpawnTables["PM_CIT"])
AppendToSpawnlist("model", "models/player/group02/male_06.mdl", SpawnTables["PM_CIT"])
AppendToSpawnlist("model", "models/player/group02/male_08.mdl", SpawnTables["PM_CIT"])
AppendToSpawnlist("header", "Resistance", SpawnTables["PM_CIT"])
for i = 1,9 do
	AppendToSpawnlist("model", "models/player/group03/male_0"..i..".mdl", SpawnTables["PM_CIT"])
end
for i = 1,6 do
	AppendToSpawnlist("model", "models/player/group03/female_0"..i..".mdl", SpawnTables["PM_CIT"])
end
AppendToSpawnlist("header", "Medics", SpawnTables["PM_CIT"])
for i = 1,9 do
	AppendToSpawnlist("model", "models/player/group03m/male_0"..i..".mdl", SpawnTables["PM_CIT"])
end
for i = 1,6 do
	AppendToSpawnlist("model", "models/player/group03m/female_0"..i..".mdl", SpawnTables["PM_CIT"])
end

--CSS--
AppendToSpawnlist("header", "Terrorists", SpawnTables["PM_CSS"])
AppendToSpawnlist("model", "models/player/arctic.mdl", SpawnTables["PM_CSS"])
AppendToSpawnlist("model", "models/player/guerilla.mdl", SpawnTables["PM_CSS"])
AppendToSpawnlist("model", "models/player/leet.mdl", SpawnTables["PM_CSS"])
AppendToSpawnlist("model", "models/player/phoenix.mdl", SpawnTables["PM_CSS"])

AppendToSpawnlist("header", "Counter-Terrorists", SpawnTables["PM_CSS"])
AppendToSpawnlist("model", "models/player/gasmask.mdl", SpawnTables["PM_CSS"])
AppendToSpawnlist("model", "models/player/swat.mdl", SpawnTables["PM_CSS"])
AppendToSpawnlist("model", "models/player/urban.mdl", SpawnTables["PM_CSS"])
AppendToSpawnlist("header", "Hostages", SpawnTables["PM_CSS"])
for i = 1,4 do
	AppendToSpawnlist("model", "models/player/hostage/hostage_0"..i..".mdl", SpawnTables["PM_CSS"])
end

--Other--
AppendToSpawnlist("model", "models/player/dod_american.mdl", SpawnTables["PM_GM"])
AppendToSpawnlist("model", "models/player/dod_german.mdl", SpawnTables["PM_GM"])
AppendToSpawnlist("model", "models/player/p2_chell.mdl", SpawnTables["PM_GM"])
AppendToSpawnlist("model", "models/player/skeleton.mdl", SpawnTables["PM_GM"])

--PAC Models--
AppendToSpawnlist("model", "models/pac/default.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/female/base_female.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/female/base_female_jiggle.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/female/base_female_arm_l.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/female/base_female_arm_r.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/female/base_female_leg_l.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/female/base_female_leg_r.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/female/base_female_torso.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/female/base_female_torso_jiggle.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/male/base_male.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/male/base_male_arm_l.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/male/base_male_arm_r.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/male/base_male_leg_l.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/male/base_male_leg_r.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/male/base_male_torso.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("header", "Jiggles", SpawnTables["PACMDL"])
for i = 0,5 do
	AppendToSpawnlist("model", "models/pac/jiggle/base_cloth_"..i..".mdl", SpawnTables["PACMDL"])
end
for i = 0,5 do
	AppendToSpawnlist("model", "models/pac/jiggle/base_cloth_"..i.."_gravity.mdl", SpawnTables["PACMDL"])
end
for i = 0,5 do
	AppendToSpawnlist("model", "models/pac/jiggle/base_jiggle_"..i..".mdl", SpawnTables["PACMDL"])
end
for i = 0,5 do
	AppendToSpawnlist("model", "models/pac/jiggle/base_jiggle_"..i.."_gravity.mdl", SpawnTables["PACMDL"])
end
AppendToSpawnlist("header", "Capes", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/jiggle/clothing/base_cape_1.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/jiggle/clothing/base_cape_2.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/jiggle/clothing/base_cape_1_gravity.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/jiggle/clothing/base_cape_2_gravity.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/jiggle/clothing/base_trench_1.mdl", SpawnTables["PACMDL"])
AppendToSpawnlist("model", "models/pac/jiggle/clothing/base_trench_1_gravity.mdl", SpawnTables["PACMDL"])

-- AUTOMATION BELOW --
--Weapons
GetModels("models/weapons/c_models","TF2Weapons")
GetModelsFromSub("models/weapons/c_models","TF2Weapons")

--Hats
GetModels("models/player/items/all_class","AllClass")
GetModels("models/player/items/scout","Scout")
GetModels("models/player/items/soldier","Soldier")
GetModels("models/player/items/pyro","Pyro")
GetModels("models/player/items/demo","Demo")
GetModels("models/player/items/heavy","Heavy")
GetModels("models/player/items/engineer","Engineer")
GetModels("models/player/items/medic","Medic")
GetModels("models/player/items/sniper","Sniper")
GetModels("models/player/items/spy","Spy")

--MvM
GetModelsFromSub("models/player/items/mvm_loot","MvM")

--Workshop
GetModelsFromSub("models/workshop/player/items/all_class","WSAllClass")
GetModelsFromSub("models/workshop/player/items/scout","WSScout")
GetModelsFromSub("models/workshop/player/items/soldier","WSSoldier")
GetModelsFromSub("models/workshop/player/items/pyro","WSPyro")
GetModelsFromSub("models/workshop/player/items/demo","WSDemo")
GetModelsFromSub("models/workshop/player/items/heavy","WSHeavy")
GetModelsFromSub("models/workshop/player/items/engineer","WSEngineer")
GetModelsFromSub("models/workshop/player/items/medic","WSMedic")
GetModelsFromSub("models/workshop/player/items/sniper","WSSniper")
GetModelsFromSub("models/workshop/player/items/spy","WSSpy")
GetModelsFromSub("models/workshop/weapons/c_models","WSWep")

hook.Add("PopulateContent", "Spawnlist.PAC", function(pc,tree,node)
	local ViewPanel = vgui.Create( "ContentContainer", pc )
	ViewPanel:SetVisible( false )

	local pac_node = tree:AddNode("PAC3","icon16/user_edit.png")
	pac_node.DoClick = function()
		ViewPanel:Clear( true )
		pc:SwitchPanel( ViewPanel )
	end

	local nodes = {}

	for _,t in SortedPairs(SpawnTables) do
		nodes[t.ID] = pac_node:AddNode(t.Name,t.Icon)

		nodes[t.ID].DoClick = function(self,node)
			if ( ViewPanel && ViewPanel.CurrentNode && ViewPanel.CurrentNode == node ) then return end
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
	end

	for _,n in pairs(nodes) do
		for _,t in SortedPairs(SpawnTables) do
			if t.ParentID and nodes[t.ParentID] then
				nodes[t.ParentID]:InsertNode(nodes[t.ID])
			end
		end
	end
end)