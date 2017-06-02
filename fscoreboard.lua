local Tag = "fscoreboard"
fscoreboard = {}

local stripes = surface.GetTextureID"vgui/alpha-back"
local gradient = surface.GetTextureID"vgui/gradient-l"

-- Fonts --
surface.CreateFont("fscoreboard_48",{
	font = "Roboto",
	size = 48,
	weight = 400
})

surface.CreateFont("fscoreboard_24",{
	font = "Roboto",
	size = 24,
	weight = 400
})

-- Utils --
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
	function( txt )
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

local function NameNoCol(pl)
	local name_noc = pl:Name()
	name_noc = string.gsub(name_noc,"<hsv=(%d+%.?%d*),(%d+%.?%d*),(%d+%.?%d*)>","")
	name_noc = string.gsub(name_noc,"<color=(%d+%.?%d*),(%d+%.?%d*),(%d+%.?%d*)>","")
	name_noc = string.gsub(name_noc,"%^(%d+%.?%d*)","")
	return name_noc
end

-- Create Panels --
local PANEL = {}

local icons = {
	ping    = Material("icon16/transmit_blue.png"),
	pingbad = Material("icon16/transmit.png")
}

function PANEL:Init()
	self.player = {}
	self.avatar = vgui.Create("AvatarImage",self)
	self.avatar:SetSize(32,32)
	self.avatar:Dock(LEFT)

	self.avatar.OnMouseReleased = function(s,mc)
		if mc~=MOUSE_RIGHT then return end
		local pl = self.player
		self.scoreboard.avatarmenu = DermaMenu()
		local a = self.scoreboard.avatarmenu
		a:AddOption("Open Profile URL",function()
			local url="http://steamcommunity.com/profiles/" .. tostring(pl:SteamID64())
			gui.OpenURL(url)
		end):SetImage'icon16/book.png'
		a:AddOption("Copy Profile URL",function()
			SetClipboardText("http://steamcommunity.com/profiles/"..tostring(pl:SteamID64()))
		end):SetImage'icon16/book_link.png'
		a:AddSpacer()
		a:AddOption("Copy SteamID",function()
			SetClipboardText(pl:SteamID())
		end):SetImage'icon16/tag_blue.png'
		a:AddOption("Copy Community ID",function()
			SetClipboardText(tostring(pl:SteamID64()))
		end):SetImage'icon16/tag_yellow.png'

		a:Open()
	end

	self.ping = vgui.Create("EditablePanel",self)
	self.ping:Dock(RIGHT)
	self.ping:SetWide(64)
	self.ping.Paint = function(s,w,h)
		local pl = self.player
		if not IsValid(pl) then return end
		draw.RoundedBox(0,0,0,1,h,Color(0,0,0,128))
		surface.SetMaterial(pl:Ping() >= 200 and icons.pingbad or icons.ping)
		surface.SetDrawColor(Color(255,255,255))
		surface.DrawTexturedRect(4,8,16,16)

		draw.DrawText(pl:Ping(),"fscoreboard_24",24,4,Color(128,128,128),TEXT_ALIGN_LEFT)
	end
end

function PANEL:Paint(w,h)
	local pl = self.player

	draw.RoundedBox(0,36,0,w-36,h,team.GetColor(pl:Team()))
	draw.RoundedBox(0,36,0,w-36,h,Color(0,0,0,250))
	--Name
	draw.DrawText(NameNoCol(pl),"fscoreboard_24",40,4,Color(128,128,128),TEXT_ALIGN_LEFT)
end

function PANEL:Setup(pl)
	if not IsValid(pl) then return end
	self.player = pl
	self.avatar:SetPlayer(pl)
end

function PANEL:GotoDoubleclick()
	local pl = self.player
	if not self.__doubleclickwindow or self.__doubleclickwindow<RealTime() then
		self.__doubleclickwindow = RealTime()+0.4
		return
	end

	self.__doubleclickwindow = nil

	if IsValid(pl) and pl==LocalPlayer() then
		RunConsoleCommand("aowl","tp")
	elseif IsValid(pl) then
		RunConsoleCommand("aowl","goto",'_'..pl:EntIndex())
		self.__gotoed = true
	end
end

function PANEL:OnMousePressed(mc)
	if mc==MOUSE_LEFT then
		self.__mleftdown = true
		self:GotoDoubleclick()
	end
end

local plrow = vgui.RegisterTable(PANEL,"EditablePanel")

local PANEL = {}
function PANEL:Init()
	self:SetWide(1024)
	self:SetTall(70)
	self:Center()
	self:DockPadding(4,70,4,4)
	self.scroll = vgui.Create("DScrollPanel",self)
	self.scroll:Dock(FILL)
	self.rows = {}
end

function PANEL:Think()
	self.rows = self.rows or {}
	for _,pl in next,player.GetAll() do
		if ( IsValid(self.rows[pl:EntIndex()]) ) then continue end
		self.rows[pl:EntIndex()] = vgui.CreateFromTable(plrow,self.rows[pl:EntIndex()])
		local pnl = self.rows[pl:EntIndex()]
		pnl:Setup(pl)
		pnl:SetTall(32)
		pnl:Dock(TOP)
		pnl:DockMargin(4,4,4,0)
		pnl.scoreboard = self
		self.scroll:AddItem(pnl)
	end
	for e,p in next,self.rows do
		if not IsValid(player.GetByID(e)) then
			p:Remove()
			self.scroll:PerformLayout()
		end
	end
	self:SetWide(hscore_width and math.Clamp(hscore_width:GetInt(),800,ScrW()-64) or 1024)
	self:SetTall(138+math.Clamp((40*#player.GetAll()),0,ScrH()-128))
	self:Center()
end

local pos = 1024

function PANEL:Paint(w,h)
	pos = pos+0.2

	for i = 1,2 do
		draw.RoundedBox(0,0,62+i,w,2,Color(0,0,0,100))
	end
	surface.SetTexture(stripes)
	surface.SetDrawColor(26,29,35,255)
	surface.DrawTexturedRectUV( -(pos%128),0,pos+(pos%128),72, 0,0,-(pos+(pos%128))/128,1 )
	surface.SetTexture(gradient)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawTexturedRect(0,0,w/2,72)
	draw.DrawText(GetHostName(),"fscoreboard_48",15,11,Color(0,0,0,128))
	draw.DrawText(GetHostName(),"fscoreboard_48",14,10,Color(255,255,255))
end

local scoreboard = vgui.RegisterTable(PANEL,"EditablePanel")

hook.Add("Think",Tag,function()
    hook.Remove("Think",Tag)
    if IsValid(fscoreboard) and ispanel(fscoreboard) then fscoreboard:Remove() end
    fscoreboard = vgui.CreateFromTable(scoreboard)
    fscoreboard:SetVisible(false)
end)

-- hooks
hook.Add("ScoreboardShow",Tag,function()
	if not IsValid(fscoreboard) then fscoreboard = vgui.CreateFromTable(scoreboard) end
	fscoreboard:SetVisible(true)
	return true
end)

hook.Add("ScoreboardHide",Tag,function()
	if IsValid(fscoreboard) then
		fscoreboard:SetVisible(false)
	end
	CloseDermaMenus()
	gui.EnableScreenClicker(false)
	return true
end)

hook.Add("PlayerBindPress",Tag,function(pl,bind,pressed)
	if pressed and bind == "+attack2" and IsValid(fscoreboard) and fscoreboard:IsVisible() then
		gui.EnableScreenClicker(true)
		return true
	end
end)