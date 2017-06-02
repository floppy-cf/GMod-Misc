local Tag = "FHUD"
local FHUD = {}

--Remove HUD Elements
local remove = {
	CHudHealth        = true,
	CHudBattery       = true,
	CHudAmmo          = true,
	CHudSecondaryAmmo = true,
}

hook.Add("HUDShouldDraw",Tag..".Hide",function(name)
	if remove[name] then return false end
end)

--Util Functions
local function DrawTextShadowed(text,font,x,y,color,xalign,yalign)
	xalign = xalign or TEXT_ALIGN_LEFT
	yalign = yalign or TEXT_ALIGN_BOTTOM

	draw.DrawText(text,font,x+2,y+2,Color(0,0,0,196),xalign,yalign)
	draw.DrawText(text,font,x,y,color,xalign,yalign)
end

local function NameNoCol(txt)
	local name_noc = txt
	name_noc = string.gsub(name_noc,"<hsv=(%d+%.?%d*),(%d+%.?%d*),(%d+%.?%d*)>","")
	name_noc = string.gsub(name_noc,"<color=(%d+%.?%d*),(%d+%.?%d*),(%d+%.?%d*)>","")
	name_noc = string.gsub(name_noc,"%^(%d+%.?%d*)","")
	return name_noc
end

local PlayerColors = {
	["0"]  = Color(0,0,0),
	["1"]  = Color(128,128,128),
	["2"]  = Color(192,192,192),
	["3"]  = Color(255,255,255),
	["4"]  = Color(0,0,128),
	["5"]  = Color(0,0,255),
	["6"]  = Color(0,128,128),
	["7"]  = Color(0,255,255),
	["8"]  = Color(0,128,0),
	["9"]  = Color(0,255,0),
	["10"] = Color(128,128,0),
	["11"] = Color(255,255,0),
	["12"] = Color(128,0,0),
	["13"] = Color(255,0,0),
	["14"] = Color(128,0,128),
	["15"] = Color(255,0,255),
	["16"] = Color(199, 76, 58),
	["17"] = Color(127, 0, 95),
}

local ColorModifiers = {
	function( txt )			-- ^N modifier
		local Colors = {}

		for before, n, s in txt:gmatch("(.-)%^(%d+)([^%^]+)") do -- before is the string before the modifier and s is the string after it
			if PlayerColors[ n ] then

				if before != "" then
					table.insert( Colors, before )
				end

				table.insert( Colors, PlayerColors[n] )
				table.insert( Colors, s )
			end
		end

		return Colors
	end,
	function( txt )			-- <color> modifier
		local Modifier, Colors = "<color=%s*(%d*)%s*,?%s*(%d*)%s*,?%s*(%d*)%s*,?%s*(%d*)%s*>", {}

		for before, r, g, b, a, s in txt:gmatch( "(.-)" .. Modifier .. "([^<]*)" ) do
			if before != "" then
				table.insert( Colors, before )
			end

			r = tonumber( r ); r = r and r or 0
			g = tonumber( g ); g = g and g or 0
			b = tonumber( b ); b = b and b or 0
			a = tonumber( a ); a = a and a or 255

			table.insert( Colors, Color( r, g, b, a ) )
			table.insert( Colors, s )
		end

		return Colors
	end
}

local function ParseName(v)

	local TextTable = { v }

	for _, GetColors in pairs( ColorModifiers ) do

		for k, v in pairs( TextTable ) do
			if not isstring( v ) then continue end

			local Colors = GetColors( v )

			if table.Count( Colors ) > 0 then
				TextTable[ k ] = nil

				for i, content in pairs( Colors ) do
					table.insert( TextTable, k + (i - 1), content )
				end
			end
		end

	end

	return TextTable
end

local function DrawTextSplit(txt, font, x, y, fallback, align)
	align = align or TEXT_ALIGN_LEFT
	local tbl = markup.Parse("<font="..font..">"..txt)
	local txtW = tbl.totalWidth
	local lastpos = 0

	for _,t in pairs(tbl.blocks) do
		local col = Color(t.colour.r,t.colour.g,t.colour.b)
		if #tbl.blocks == 1 then
			col = fallback
		end

		surface.SetTextColor(col)
		surface.SetTextPos(x-(txtW-(t.offset.x+lastpos)),y)
		surface.DrawText(t.text)
		lastpos = t.offset.x+lastpos-t.offset.x
	end

	return txtW
end

--Fonts
surface.CreateFont(Tag..".24",{
	font = "Roboto",
	size = 24,
	weight = 400,
})

surface.CreateFont(Tag..".Icons.CS",{
	font = "csd",
	size = 48,
	weight = 400,
})

surface.CreateFont(Tag..".Icons.HL2",{
	font = "HalfLife2",
	size = 48,
	weight = 400,
})

surface.CreateFont(Tag..".MaterialIcons",{
	font = "Material Icons",
	size = 24,
	weight = 400,
	extended = true,
})

--Draw HUD
local x,y = 32,ScrH()-32
local x2  = ScrW()-164-32
local hp,ap = 0,0
local xp,lvl = 0,1
local money = 0
local vel = 0
local clip1,clip2 = 0,0
local res1,res2 = 0,0
local ab_ammo = 0

local function DrawHUD()
	surface.SetFont(Tag..".24")

	--Health
	hp = Lerp(0.05, hp, LocalPlayer():Health())
	ap = Lerp(0.05, ap, LocalPlayer():Armor())

	local r = hp <= 20 and math.Clamp(math.abs(math.sin(RealTime()*5)*255),192,255) or 192

	surface.SetFont(Tag..".MaterialIcons")
	local offset = surface.GetTextSize("\xEE\xA1\xBD")
	DrawTextShadowed("\xEE\xA1\xBD",Tag..".MaterialIcons",x+4,y-32-(24*0),Color(r,128,128))
	DrawTextShadowed(math.Round(hp).."/"..LocalPlayer():GetMaxHealth(),Tag..".24",x+8+offset,y-32-(24*0),Color(r,128,128))
	surface.SetFont(Tag..".24")
	DrawTextShadowed((LocalPlayer():Armor() > 0 and " (+"..math.Round(ap)..")" or ""),Tag..".24",x+8+surface.GetTextSize(math.Round(hp).."/"..LocalPlayer():GetMaxHealth())+offset,y-32-(24*0),Color(128,128,192))

	--Speed
	local v = LocalPlayer()
	if LocalPlayer():GetVehicle() != NULL then
		if LocalPlayer():GetVehicle():GetClass() == "prop_vehicle_prisoner_pod" then
			if IsValid(LocalPlayer():GetVehicle():GetParent()) then
				v = LocalPlayer():GetVehicle():GetParent()
				v = v.GetVelocity(v)
				v.z = 0
			end
		else
			v = LocalPlayer():GetVehicle()
			v = v.GetVelocity(v)
			v.z = 0
		end
	else
		v = LocalPlayer()
		v = v.GetVelocity(v)
		v.z = 0
	end

	vel = Lerp(0.05, vel, math.Round(v.Length(v)))
	DrawTextShadowed(LocalPlayer():GetVehicle() != NULL and "\xee\x94\xb1" or "\xEE\x95\xA6",Tag..".MaterialIcons",x+4,y-32-(24*1),Color(192,164,128))
	DrawTextShadowed(math.Round(vel).." ups",Tag..".24",x+8+surface.GetTextSize(LocalPlayer():GetVehicle() != NULL and "\xee\x94\xb1" or "\xEE\x95\xA6"),y-32-(24*1),Color(192,164,128))

	--Ammo
	if IsValid(LocalPlayer():GetActiveWeapon()) then
		local wep = LocalPlayer():GetActiveWeapon()
		if wep:GetMaxClip1() > -1 then
			if LocalPlayer():GetVehicle() != NULL and LocalPlayer():GetVehicle():GetClass() != "prop_vehicle_prisoner_pod" then return end
			if wep:GetClass() == "weapon_physcannon" then return end
			clip1 = Lerp(0.05, clip1, wep:Clip1())
			clip2 = Lerp(0.05, clip2, wep:Clip2())
			res1 = Lerp(0.05, res1, LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()))
			res2 = Lerp(0.05, res2, LocalPlayer():GetAmmoCount(wep:GetSecondaryAmmoType()))

			surface.SetFont(Tag..".MaterialIcons")
			DrawTextShadowed("\xEE\x85\xA9",Tag..".MaterialIcons",x2+4,y-32-(24*0),Color(164,192,128))
			DrawTextShadowed(math.Round(res1),Tag..".24",x2+8+surface.GetTextSize("\xEE\x85\xA9"),y-32-(24*0),Color(164,192,128))
			surface.SetFont(Tag..".Icons.HL2")
			DrawTextShadowed("p",Tag..".Icons.HL2",x2+6,y-32-(24*1)-12,Color(128,164,192))
			DrawTextShadowed(math.Round(clip1).."/"..wep:GetMaxClip1()..(wep:GetSecondaryAmmoType() > -1 and " | "..math.Round(res2) or ""),Tag..".24",x2+8+surface.GetTextSize("p"),y-32-(24*1),Color(128,164,192))
		end

		if wep:GetClass() == "weapon_rpg" or wep:GetClass() == "weapon_frag" then
			res1 = Lerp(0.05, res1, LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType()))
			surface.SetFont(Tag..".Icons.HL2")
			DrawTextShadowed("p",Tag..".Icons.HL2",x2+6,y-32-(24*0)-12,Color(128,164,192))
			DrawTextShadowed(math.Round(res1),Tag..".24",x2+8+surface.GetTextSize("p"),y-32-(24*0),Color(128,164,192))
		end
	end

	if LocalPlayer():GetVehicle() != NULL and LocalPlayer():GetVehicle():GetClass() == "prop_vehicle_airboat" then
		local _,__,ammo = LocalPlayer():GetVehicle():GetAmmo()
		--For some reason, vehicles have 3 values
		--Airboat returns 20, -1 and 100 when at full charge, dunno what the 20 is tho.
		--All other vehicles will do -1,-1,-1
		if ammo > -1 then
			ab_ammo = Lerp(0.05, ab_ammo, ammo)
			surface.SetFont(Tag..".Icons.HL2")
			DrawTextShadowed("p",Tag..".Icons.HL2",x2+6,y-32-(24*0)-12,Color(128,164,192))
			DrawTextShadowed(math.Round(ab_ammo),Tag..".24",x2+8+surface.GetTextSize("p"),y-32-(24*0),Color(128,164,192))
		end
	end
end

--FPS values
local surface=surface
local FrameTime=FrameTime
local min,max=1/33,1/33
local sc=400

local function FPSMeter()
	--FPS
	local q=0.0001
	local ft=FrameTime()

	local qq=1-ft*0.5
	qq=qq<0.001 and 0.001 or qq


	min=math.min(ft,min)
	min=min*qq+ft*(1-qq)

	max=math.max(ft,max)
	max=max*qq+ft*(1-qq)
	surface.SetFont"BudgetLabel"
	surface.SetTextColor(255,255,255,255)

	surface.SetDrawColor(255,255,255,255)
	surface.DrawRect(10,10,ft*sc,5)

	surface.SetDrawColor(222,222,255,255)
	surface.DrawRect(10+ft*sc,8,1,8)

	if max>(1/23) then -- below acceptable fps
		surface.SetDrawColor(255,150,150,255)
		surface.DrawRect(10+(1/23)*sc-1,6,2,12)
	end
	if max>0.5 then -- 2 fps, lol
	surface.SetDrawColor(200,150,150,255)
	surface.DrawRect(10+0.5*sc-3,6,6,12)
	end
	surface.SetDrawColor(200,100,100,255)
	surface.DrawRect(10+ft*sc,10,(max-ft)*sc,5)
	surface.SetTextPos(10+(max)*sc,5)
	surface.DrawText(math.Round(1/max)..' fps')

	surface.SetDrawColor(100,200,100,255)
	surface.DrawRect(10,10,min*sc,5)
	local txt=math.Round(1/min)..' fps'
	local w,h=surface.GetTextSize(txt)
	surface.SetTextPos(math.floor(10+(min)*sc-w*0.2),10+8)
	surface.DrawText(txt)

	surface.SetTextColor(255,255,255,255)
	surface.SetDrawColor(255,255,255,255)
end

hook.Add("HUDPaint",Tag..".DrawHUD",DrawHUD)
hook.Add("HUDPaint",Tag..".FPSMeter",FPSMeter)

--Death notif

timer.Simple(.1, function()

surface.CreateFont("DeathNotice", {
	font = "Roboto",
	size = 24,
	weight = 400
})

local GM = istable(GM) and GM or GAMEMODE

local hud_deathnotice_time = CreateConVar( "hud_deathnotice_time", "6", FCVAR_REPLICATED, "Amount of time to show death notice" )

local NPC_Color = Color( 192,128,128, 255 )

local Deaths = {}
local cache = {}

function GM:AddDeathNotice( Attacker, team1, Inflictor, Victim, team2 )


	Inflictor= '#'..Inflictor==Attacker and "" or Inflictor

	local cached = cache[Attacker or ""] and cache[Attacker or ""][Victim or ""] and cache[Attacker or ""][Victim or ""][Inflictor or ""]
	if cached then
		cached.time = RealTime()
		cached.times = cached.times + 1

		return
	end

	local Death = {}
	Death.Attacker 	= 	Attacker
	Death.Victim	=	Victim
	Death.time		=	RealTime()

	Death.times		= 1


	local Attacker_text = language.GetPhrase(Attacker or "")
	if Attacker_text:sub(1,1)=='#' then
		Attacker_text=Attacker_text:gsub("^#",""):gsub("_"," ")
	end

	local Victim_text = language.GetPhrase(Victim or "")
	if Victim_text:sub(1,1)=='#' then
		Victim_text=Victim_text:gsub("^#",""):gsub("_"," ")
	end

	Death.left		= 	Attacker_text
	Death.right		= 	Victim_text
	Death.icon		=	Inflictor

	if ( team1 == -1 ) then Death.color1 = table.Copy( NPC_Color )
	elseif istable(team1) then Death.color1 = table.Copy(team1)
	else Death.color1 = table.Copy( team.GetColor( team1 ) ) end

	if ( team2 == -1 ) then Death.color2 = table.Copy( NPC_Color )
	elseif istable(team2) then Death.color2 = table.Copy(team2)
	else Death.color2 = table.Copy( team.GetColor( team2 ) ) end

	if (Death.left == Death.right) then
		Death.left = nil
		Death.icon = "suicide"
	end

	if not cache[Attacker or ""] then
		cache[Attacker or ""] = {}
	end

	if not cache[Attacker or ""][Victim or ""] then
		cache[Attacker or ""][Victim or ""] = {}
	end

	cache[Attacker or ""][Victim or ""][Inflictor or ""] = Death
	table.insert( Deaths, Death )

end

local margin = 16
local space = 8
local text_height = 32
local txtcache={}
local function DrawDeath( x, y, info, hud_deathnotice_time )

	x = ScrW() - margin

	surface.SetAlphaMultiplier(( info.time + hud_deathnotice_time ) - RealTime())
	surface.SetFont("DeathNotice")

	if info.times > 1 then
		local line = "x " .. info.times

		local scale = math.max(1, 1 + (info.time + 0.1 - RealTime())/0.1)
		local mx = Matrix()
		mx:Translate(Vector(x - surface.GetTextSize(line), y, 1))
		mx:Scale(Vector(scale, scale, 1))

		x = x - surface.GetTextSize(line) - space

		cam.PushModelMatrix(mx)
			surface.SetTextPos(2, 2)
			surface.SetTextColor(Color(0,0,0,196))
			surface.DrawText(line)

			surface.SetTextPos(0, 0)
			surface.SetTextColor(Color(255,255,255))
			surface.DrawText(line)
		cam.PopModelMatrix()
	end

	draw.SimpleText(NameNoCol(info.right), "DeathNotice", x + 2, y + 2, Color(0,0,0,196), TEXT_ALIGN_RIGHT )
	x = x - DrawTextSplit(info.right, "DeathNotice", x, y, info.color2, TEXT_ALIGN_RIGHT ) - space

	local a = 64 + 64 * math.abs(math.sin((RealTime() - info.time)*8))
	local txt = txtcache[info.icon]
	if not txt then
		local copy =  weapons.Get(info.icon)
		local phrase = language.GetPhrase(info.icon)

		if phrase == info.icon then

			phrase=phrase:gsub("^weapon_","")
			phrase=phrase:gsub("_"," ")
			phrase=phrase:gsub("^.",function(s) return string.upper(s) end)
		end

		txt = phrase=="" and "››" or "[" .. (copy and copy.PrintName or phrase) .. "]"
		txtcache[info.icon] = txt
	end
	draw.SimpleText(txt, "DeathNotice", x + 2, y + 2, Color(0,0,0,196), TEXT_ALIGN_RIGHT )
	x = x - draw.SimpleText(txt, "DeathNotice", x, y, Color(128,128,192), TEXT_ALIGN_RIGHT ) - space

	if info.left then -- we actually have a killer, right??
		draw.SimpleText(NameNoCol(info.left), "DeathNotice", x + 2, y + 2, Color(0,0,0,196), TEXT_ALIGN_RIGHT )
		x = x - DrawTextSplit(info.left, "DeathNotice", x, y, info.color1, TEXT_ALIGN_RIGHT ) - space
	end

	surface.SetAlphaMultiplier(1)

	return (y + text_height)

end


function GM:DrawDeathNotice( x, y )

	local hud_deathnotice_time = hud_deathnotice_time:GetFloat()

	x = ScrW() - margin
	y = margin

	-- Draw
	for k, Death in pairs( Deaths ) do

		if (Death.time + hud_deathnotice_time > RealTime()) then

			if (Death.lerp) then
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
			end

			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y

			y = DrawDeath( x, y, Death, hud_deathnotice_time )

		end

	end

	-- We want to maintain the order of the table so instead of removing
	-- expired entries one by one we will just clear the entire table
	-- once everything is expired.
	for k, Death in pairs( Deaths ) do
		if (Death.time + hud_deathnotice_time > RealTime()) then
			return
		end
	end

	Deaths = {}
	cache = {}

end

usermessage.Hook( "PlayerKilledByPlayer", function( message )
	local victim 	= message:ReadEntity();
	local inflictor	= message:ReadString();
	local attacker 	= message:ReadEntity();

	if ( !IsValid( attacker ) ) then return end
	if ( !IsValid( victim ) ) then return end

	GAMEMODE:AddDeathNotice(attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team())
end)


usermessage.Hook( "PlayerKilledSelf", function( message )
	local victim 	= message:ReadEntity();
	if ( !IsValid( victim ) ) then return end

	GAMEMODE:AddDeathNotice( nil, 0, "suicide", victim:Name(), victim:Team() )
end)

usermessage.Hook( "PlayerKilled", function( message )
	local victim 	= message:ReadEntity();
	if ( !IsValid( victim ) ) then return end
	local inflictor	= message:ReadString();
	local attacker 	= "#" .. message:ReadString();

	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim:Name(), victim:Team() )
end)

usermessage.Hook( "PlayerKilledNPC", function( message )
	local victimtype = message:ReadString();
	local victim 	= "#" .. victimtype;
	local inflictor	= message:ReadString();
	local attacker 	= message:ReadEntity();

	--
	-- For some reason the killer isn't known to us, so don't proceed.
	--
	if ( !IsValid( attacker ) ) then return end

	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim, -1 )

	local bIsLocalPlayer = (IsValid(attacker) and attacker == LocalPlayer())

	local bIsEnemy = IsEnemyEntityName( victimtype )
	local bIsFriend = IsFriendEntityName( victimtype )

	if ( bIsLocalPlayer and bIsEnemy ) then
		achievements.IncBaddies();
	end

	if ( bIsLocalPlayer and bIsFriend ) then
		achievements.IncGoodies();
	end

	if ( bIsLocalPlayer and (!bIsFriend and !bIsEnemy) ) then
		achievements.IncBystander();
	end
end)

usermessage.Hook( "NPCKilledNPC", function( message )
	local victim 	= "#" .. message:ReadString();
	local inflictor	= message:ReadString();
	local attacker 	= "#" .. message:ReadString();

	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim, -1 )
end)

end)

hook.Add("HUDWeaponPickedUp",Tag..".WeaponPickup",function(wep)

	if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end
	if ( !IsValid( wep ) ) then return end
	if ( !isfunction( wep.GetPrintName ) ) then return end

	local pickup = {}
	pickup.time			= CurTime()
	pickup.name			= wep:GetPrintName()
	pickup.holdtime		= 5
	pickup.font			= Tag..".24"
	pickup.fadein		= 0.04
	pickup.fadeout		= 0.3
	pickup.color		= Color(192,192,128)
	pickup.type			= "weapon"
	pickup.class        = wep:GetClass()

	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height		= h
	pickup.width		= w

	if ( GAMEMODE.PickupHistoryLast >= pickup.time ) then
		pickup.time = GAMEMODE.PickupHistoryLast + 0.05
	end

	table.insert( GAMEMODE.PickupHistory, pickup )
	GAMEMODE.PickupHistoryLast = pickup.time

	return true
end)

hook.Add("HUDItemPickedUp",Tag..".ItemPickup",function(itemname)

	if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end

	local pickup = {}
	pickup.time			= CurTime()
	pickup.name			= "#"..itemname
	pickup.holdtime		= 5
	pickup.font			= Tag..".24"
	pickup.fadein		= 0.04
	pickup.fadeout		= 0.3
	pickup.color		= Color(164,192,128)
	pickup.type			= "item"

	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height		= h
	pickup.width		= w

	if ( GAMEMODE.PickupHistoryLast >= pickup.time ) then
		pickup.time = GAMEMODE.PickupHistoryLast + 0.05
	end

	table.insert( GAMEMODE.PickupHistory, pickup )
	GAMEMODE.PickupHistoryLast = pickup.time

	return true
end)


hook.Add("HUDAmmoPickedUp",Tag..".AmmoPickup",function( itemname, amount )

	if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end

	-- Try to tack it onto an exisiting ammo pickup
	if ( GAMEMODE.PickupHistory ) then

		for k, v in pairs( GAMEMODE.PickupHistory ) do

			if ( v.name == "#" .. itemname .. "_ammo" ) then

				v.amount = tostring( tonumber( v.amount ) + amount )
				v.time = CurTime() - v.fadein
				return

			end

		end

	end


	local pickup = {}
	pickup.time			= CurTime()
	pickup.name			= "#" .. itemname .. "_ammo"
	pickup.holdtime		= 5
	pickup.font			= Tag..".24"
	pickup.fadein		= 0.04
	pickup.fadeout		= 0.3
	pickup.color		= Color(128,164,192)
	pickup.amount		= tostring( amount )
	pickup.type			= "ammo"

	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height	= h
	pickup.width	= w

	local w, h = surface.GetTextSize( pickup.amount )
	pickup.xwidth	= w
	pickup.width	= pickup.width + w + 16

	if ( GAMEMODE.PickupHistoryLast >= pickup.time ) then
		pickup.time = GAMEMODE.PickupHistoryLast + 0.05
	end

	table.insert( GAMEMODE.PickupHistory, pickup )
	GAMEMODE.PickupHistoryLast = pickup.time

	return true
end)

local icons = {
	["item"] = {icon="\xee\x83\x9a ",font=Tag..".MaterialIcons"},
	["ammo"] = {icon="p",font=Tag..".Icons.HL2"},
	["weapon"] = {icon="c",font=Tag..".Icons.CS"},
}

local nblacklist = {
	["#HL2_SLAM"] = true,
	["#HL2_RPG"] = true,
}

local function DrawPickups()
	if ( GAMEMODE.PickupHistory == nil ) then return end
	local x, y = ScrW()/2, ScrH()-(32*4)
	local wide = 0

	for k, v in pairs( GAMEMODE.PickupHistory ) do

		if ( !istable( v ) ) then
			GAMEMODE.PickupHistory[ k ] = nil
			return
		end

		if ( v.time < CurTime() ) then

			if ( v.y == nil ) then v.y = y end

			v.y = ( v.y * 5 + y ) / 6

			local delta = ( v.time + v.holdtime ) - CurTime()
			delta = delta / v.holdtime

			local alpha = 255
			local colordelta = math.Clamp( delta, 0.6, 0.7 )

			-- Fade in/out
			if ( delta > 1 - v.fadein ) then
				alpha = math.Clamp( ( 1.0 - delta ) * ( 255 / v.fadein ), 0, 255 )
			elseif ( delta < v.fadeout ) then
				alpha = math.Clamp( delta * ( 255 / v.fadeout ), 0, 255 )
			end

			v.x = x

			local name = v.name

			if v.type == "weapon" and name:sub(0,4) == "#HL2" then
				if !nblacklist[name] then
					local names = string.Explode(" ",language.GetPhrase(name))
					for _,n in pairs(names) do
						local new = n:lower()
						new = new:sub(0,1):upper()..new:sub(2,#new)
						names[_] = new
					end
					name = string.Implode(" ",names)
				end
			end

			if v.class and v.class == "weapon_ar2" then name = "AR2" end
			if v.class and v.class == "weapon_citizenpackage" then name = "NPC Rations" end
			if v.class and v.class == "weapon_citizensuitcase" then name = "NPC Suitcase" end
			if v.class and v.class == "weapon_oldmanharpoon" then name = "NPC Harpoon" end

			surface.SetFont(icons[v.type].font)
			local iconsize = surface.GetTextSize(icons[v.type].icon)
			surface.SetFont(Tag..".24")
			local iconoffset = surface.GetTextSize((v.amount and "+"..v.amount.." " or "")..language.GetPhrase(name))
			iconoffset = iconoffset/2
			iconoffset = iconoffset + iconsize/2

			DrawTextShadowed(icons[v.type].icon, icons[v.type].font, v.x - iconoffset, v.y - ( v.height/(icons[v.type].font == Tag..".Icons.HL2" and 1 or 2) ), Color( v.color.r, v.color.g, v.color.b, alpha ), TEXT_ALIGN_CENTER)
			DrawTextShadowed((v.amount and "+"..v.amount.." " or "")..language.GetPhrase(name), Tag..".24", v.x, v.y - ( v.height / 2 ), Color( v.color.r, v.color.g, v.color.b, alpha ), TEXT_ALIGN_CENTER)

			y = y + ( v.height )
			wide = v.width

			if ( alpha == 0 ) then GAMEMODE.PickupHistory[ k ] = nil end

		end

	end

	GAMEMODE.PickupHistoryWide = ( GAMEMODE.PickupHistoryWide * 5 + wide ) / 6

	return true
end

hook.Add("HUDDrawPickupHistory",Tag..".Pickups",DrawPickups)

--Weapon Switcher
--[[FHUD.WeaponSwitcher = {}

FHUD.WeaponSwitcher.Show = false
FHUD.WeaponSwitcher.Selected = -1
FHUD.WeaponSwitcher.NextSwitch = -1
FHUD.WeaponSwitcher.Weapons = {}

local delay = 0.03
local showtime = 5

local col_active = Color(255,255,255,255)
local wcol = Vector(GetConVar("cl_weaponcolor"):GetString())
local col_dark = Color(wcol[1]*255,wcol[2]*255,wcol[3]*255,192)

function FHUD.WeaponSwitcher:DrawWeapon(x, y, c, wep, sel)
	if not IsValid(wep) then return false end

	local name = wep:GetPrintName() or wep.PrintName or "<unnamed>"
	if name:sub(0,4) == "#HL2" and wep:GetClass() ~= "weapon_slam" and wep:GetClass() ~= "weapon_rpg" or wep:GetClass() == "weapon_physgun" then
		local names = string.Explode(" ",language.GetPhrase(name))
		for _,n in pairs(names) do
			local new = n:lower()
			new = new:sub(0,1):upper()..new:sub(2,#new)
			names[_] = new
		end
		name = string.Implode(" ",names)
	end

	if wep:GetClass() == "weapon_ar2" then name = "AR2" end
	if wep:GetClass() == "weapon_citizenpackage" then name = "NPC Rations" end
	if wep:GetClass() == "weapon_citizensuitcase" then name = "NPC Suitcase" end
	if wep:GetClass() == "weapon_oldmanharpoon" then name = "NPC Harpoon" end

	DrawTextShadowed((sel and "> " or "")..language.GetPhrase(name),Tag..".24",x,y,c,TEXT_ALIGN_RIGHT)

	return true
end

function FHUD.WeaponSwitcher:Draw()
	if not FHUD.WeaponSwitcher.Show then return end

	local weps = FHUD.WeaponSwitcher.Weapons

	local x = ScrW()-32
	local y = ScrH()-32-(24*4)

	local sel = false

	local col = col_dark
	for k, wep in pairs(weps) do
		if FHUD.WeaponSwitcher.Selected == k then
		col = col_active
		sel = true
	else
		col = col_dark
		sel = false
	end

	if not FHUD.WeaponSwitcher:DrawWeapon(x, y, col, wep, sel) then
		FHUD.WeaponSwitcher:UpdateWeaponCache()
		return
	end

	y = y - 24
	end
end

local function SlotSort(a, b)
	return a and b and (a.Slot or 0) and (b.Slot or 0) and (a.Slot or 0) > (b.Slot or 0)
end

local function CopyVals(src, dest)
	table.Empty(dest)
	for k, v in pairs(src) do
		if IsValid(v) then
			table.insert(dest, v)
		end
	end
end

function FHUD.WeaponSwitcher:UpdateWeaponCache()

	FHUD.WeaponSwitcher.Weapons = {}
	CopyVals(LocalPlayer():GetWeapons(), FHUD.WeaponSwitcher.Weapons)

	table.sort(FHUD.WeaponSwitcher.Weapons, SlotSort)
end

function FHUD.WeaponSwitcher:SetSelected(idx)
	FHUD.WeaponSwitcher.Selected = idx

	FHUD.WeaponSwitcher:UpdateWeaponCache()
end

function FHUD.WeaponSwitcher:SelectNext()
	if FHUD.WeaponSwitcher.NextSwitch > CurTime() then return end
	FHUD.WeaponSwitcher:Enable()

	local s = FHUD.WeaponSwitcher.Selected + 1
	if s > #FHUD.WeaponSwitcher.Weapons then
		s = 1
	end

	FHUD.WeaponSwitcher:DoSelect(s)

	FHUD.WeaponSwitcher.NextSwitch = CurTime() + delay
end

function FHUD.WeaponSwitcher:SelectPrev()
	if FHUD.WeaponSwitcher.NextSwitch > CurTime() then return end
	FHUD.WeaponSwitcher:Enable()

	local s = FHUD.WeaponSwitcher.Selected - 1
	if s < 1 then
		s = #FHUD.WeaponSwitcher.Weapons
	end

	FHUD.WeaponSwitcher:DoSelect(s)

	FHUD.WeaponSwitcher.NextSwitch = CurTime() + delay
end

-- Select by index
function FHUD.WeaponSwitcher:DoSelect(idx)
	FHUD.WeaponSwitcher:SetSelected(idx)

	if GetConVar("hud_fastswitch"):GetBool() then
		-- immediately confirm if fastswitch is on
		FHUD.WeaponSwitcher:ConfirmSelection(true)
	end
end

-- Numeric key access to direct slots
function FHUD.WeaponSwitcher:SelectSlot(slot)
	if not slot then return end

	FHUD.WeaponSwitcher:Enable()

	FHUD.WeaponSwitcher:UpdateWeaponCache()

	slot = slot - 1

	-- find which idx in the weapon table has the slot we want
	local toselect = FHUD.WeaponSwitcher.Selected
	for k, w in pairs(FHUD.WeaponSwitcher.Weapons) do
		if w.Slot == slot then
			toselect = k
			break
		end
	end

	FHUD.WeaponSwitcher:DoSelect(toselect)

	FHUD.WeaponSwitcher.NextSwitch = CurTime() + delay
end

-- Show the weapon switcher
function FHUD.WeaponSwitcher:Enable()
	if FHUD.WeaponSwitcher.Show == false then
		FHUD.WeaponSwitcher.Show = true

		local wep_active = LocalPlayer():GetActiveWeapon()

		FHUD.WeaponSwitcher:UpdateWeaponCache()

		-- make our active weapon the initial selection
		local toselect = 1
		for k, w in pairs(FHUD.WeaponSwitcher.Weapons) do
			if w == wep_active then
				toselect = k
				break
			end
		end
		FHUD.WeaponSwitcher:SetSelected(toselect)
	end
end

-- Hide switcher
function FHUD.WeaponSwitcher:Disable()
	FHUD.WeaponSwitcher.Show = false
end

-- Switch to the currently selected weapon
function FHUD.WeaponSwitcher:ConfirmSelection(noHide)
	if not noHide then FHUD.WeaponSwitcher:Disable() end

	for k, w in pairs(FHUD.WeaponSwitcher.Weapons) do
		if k == FHUD.WeaponSwitcher.Selected and IsValid(w) then
			RunConsoleCommand("use", w:GetClass())
			return
		end
	end
end

-- Allow for suppression of the attack command
function FHUD.WeaponSwitcher:PreventAttack()
	return FHUD.WeaponSwitcher.Show and not GetConVar("hud_fastswitch"):GetBool()
end

function FHUD.WeaponSwitcher:Think()
	if (not FHUD.WeaponSwitcher.Show) then return end

	-- hide after period of inaction
	if FHUD.WeaponSwitcher.NextSwitch < (CurTime() - showtime) then
		FHUD.WeaponSwitcher:Disable()
	end
end

-- Instantly select a slot and switch to it, without spending time in menu
function FHUD.WeaponSwitcher:SelectAndConfirm(slot)
	if not slot then return end
	FHUD.WeaponSwitcher:SelectSlot(slot)
	FHUD.WeaponSwitcher:ConfirmSelection()
end

hook.Add("HUDPaint",Tag..".WeaponSwitcher",function()
	FHUD.WeaponSwitcher:Draw()
	FHUD.WeaponSwitcher:Think()
end)
timer.Simple(0,function()
	hook.Add("PlayerBindPress",Tag..".WeaponSwitcher",function(ply, bind, pressed)
		if not IsValid(ply) then return end

		if bind == "invnext" and pressed then
			FHUD.WeaponSwitcher:SelectNext()
			return true
		elseif bind == "invprev" and pressed then
			FHUD.WeaponSwitcher:SelectPrev()
			return true
		elseif bind == "+attack" then
			if FHUD.WeaponSwitcher:PreventAttack() then
				if not pressed then
					FHUD.WeaponSwitcher:ConfirmSelection()
				end
				return true
			end
		elseif string.sub(bind, 1, 4) == "slot" and pressed then
			local idx = tonumber(string.sub(bind, 5, -1)) or 1

			FHUD.WeaponSwitcher:SelectSlot(idx)
			return true
		end
	end)
end)--]]