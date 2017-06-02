
properties.Add( "removeallwelds",
{
        MenuLabel       =       "#Remove all welds",
        Order           =       1000,
        MenuIcon        =       "icon16/delete.png",

        Filter          =       function( self, ent, ply )

                                                if ( !gamemode.Call( "CanProperty", ply, "remover", ent ) ) then return false end
                                                if ( !IsValid( ent ) ) then return false end
                                                if ( ent:IsPlayer() ) then return false end
                                                return true
                                        end,

        Action          =       function( self, ent )

                                                self:MsgStart()
                                                        net.WriteEntity( ent )
                                                self:MsgEnd()

                                        end,

        Receive         =       function( self, length, ply )

                                                local ent = net.ReadEntity()

                                                if ( !IsValid( ent ) ) then return false end
                                                if ( !IsValid( ply ) ) then return false end
                                                if ( ent:IsPlayer() ) then return false end
                                                if ( !self:Filter( ent, ply ) ) then return false end

                                                local tbl=constraint.GetAllConstrainedEntities(ent)
												for k,ent in pairs(tbl) do
													
													if ( gamemode.Call( "CanProperty", ply, "remover", ent ) ) then
														local ed = EffectData()
                                                        ed:SetEntity( ent )
                                                		util.Effect( "entity_remove", ed, true, true )
														constraint.RemoveConstraints( ent, "Weld" )
														if not ent:IsWorld() and ent:IsEFlagSet(EFL_NOTIFY) and not constraint.HasConstraints(ent) then
															ent:RemoveEFlags(EFL_NOTIFY)
														end
													end
												end



                                        end

});

local function RemoveEntity( ent )
	if ent:IsValid() then
		ent:Remove()
	end
end

local function DoRemoveEntity( Entity )

	if ( !IsValid( Entity ) or Entity:IsPlayer() ) then return false end

	-- Nothing for the client to do here
	if ( CLIENT ) then return true end

	-- Remove all constraints (this stops ropes from hanging around)
	constraint.RemoveAll( Entity )
	
	-- Remove it properly in 1 second
	timer.Simple( 1, function() RemoveEntity( Entity ) end )
	
	-- Make it non solid
	Entity:SetNotSolid( true )
	Entity:SetMoveType( MOVETYPE_NONE )
	Entity:SetNoDraw( true )
	
	-- Send Effect
	local ed = EffectData()
		ed:SetEntity( Entity )
	util.Effect( "entity_remove", ed, true, true )
	
	return true

end

properties.Add( "removeall",
{
        MenuLabel       =       "#Remove contraption",
        Order           =       1000,
        MenuIcon        =       "icon16/delete.png",

        Filter          =       function( self, ent, ply )

                                                if ( !gamemode.Call( "CanProperty", ply, "remover", ent ) ) then return false end
                                                if ( !IsValid( ent ) ) then return false end
                                                if ( ent:IsPlayer() ) then return false end
                                                return true
                                        end,

        Action          =       function( self, ent )

                                                self:MsgStart()
                                                        net.WriteEntity( ent )
                                                self:MsgEnd()

                                        end,

        Receive         =       function( self, length, ply )

                                                local ent = net.ReadEntity()

                                                if ( !IsValid( ent ) ) then return false end
                                                if ( !IsValid( ply ) ) then return false end
                                                if ( ent:IsPlayer() ) then return false end
                                                if ( !self:Filter( ent, ply ) ) then return false end

                                                local tbl=constraint.GetAllConstrainedEntities(ent)
												for k,ent in pairs(tbl) do
										
													if not gamemode.Call( "CanProperty", ply, "remover", ent ) then
													else
														--print("DEL",ent)
														DoRemoveEntity( ent )
													end
												end



                                        end

});


properties.Add( "removewelds",
{
        MenuLabel       =       "#Remove welds",
        Order           =       1000,
        MenuIcon        =       "icon16/delete.png",

        Filter          =       function( self, ent, ply )

                                                if ( !gamemode.Call( "CanProperty", ply, "remover", ent ) ) then return false end
                                                if ( !IsValid( ent ) ) then return false end
                                                if ( ent:IsPlayer() ) then return false end
                                                return true
                                        end,

        Action          =       function( self, ent )

                                                self:MsgStart()
                                                        net.WriteEntity( ent )
                                                self:MsgEnd()

                                        end,

        Receive         =       function( self, length, ply )

                                                local ent = net.ReadEntity()

                                                if ( !IsValid( ent ) ) then return false end
                                                if ( !IsValid( ply ) ) then return false end
                                                if ( ent:IsPlayer() ) then return false end
                                                if ( !self:Filter( ent, ply ) ) then return false end

													
												if ( gamemode.Call( "CanProperty", ply, "remover", ent ) ) then
													local ed = EffectData()
													ed:SetEntity( ent )
													util.Effect( "entity_remove", ed, true, true )
													constraint.RemoveConstraints( ent, "Weld" )
												end
                                        end

});
