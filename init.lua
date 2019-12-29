registry = { }

registry.player_list = { }
registry.rank_colors = { "#FFFFFF", "#80FFFF", "#80FF80", "#FFFF80", "#FF80FF" }
registry.rank_titles = { "Basic", "Guardian", "Moderator", "Administrator", "Owner/Operator" }

registry.PLAYER_RANK_BASIC = 1
registry.PLAYER_RANK_GUARD = 2
registry.PLAYER_RANK_STAFF = 3
registry.PLAYER_RANK_ADMIN = 4
registry.PLAYER_RANK_OWNER = 5

local next_pid = 1

registry.get_player = function( name )
	for i, p in ipairs( registry.player_list ) do
		if p.name == name then
			return p
		end
	end
end

registry.get_player_rank = function( name )
	if minetest.check_player_privs( name, { server = true } ) then			-- operator
		return registry.PLAYER_RANK_OWNER
	elseif minetest.check_player_privs( name, { privs = true } ) then		-- administrator
		return registry.PLAYER_RANK_ADMIN
	elseif minetest.check_player_privs( name, { basic_privs = true } ) then		-- moderator
		return registry.PLAYER_RANK_STAFF
	elseif minetest.check_player_privs( name, { spill = true } ) then		-- guardian/veteran
		return registry.PLAYER_RANK_GUARD
	else										-- basic
		return registry.PLAYER_RANK_BASIC
	end
end

--local old_record_login = core.get_auth_handler.record_login
--core.get_auth_handler.record_login = function ( )
--	for i, p in pairs( registry.player_list ) do
--	end	
--end

minetest.register_on_joinplayer( function( player )
	local pname = player:get_player_name( )
	local ptime = os.time( )
	local pseen = core.registered_auth_handler.get_last_login( pname )
	local ppriv = registry.get_player_rank( pname )
	local t = { }

	table.insert( registry.player_list, { pid = next_pid, obj = player, name = pname, time = ptime, rank = ppriv } )

	next_pid = next_pid + 1

--	minetest.chat_send_all( string.format( minetest.MESSAGE_PLAYER_JOIN, pname .. ( { "", "", " (staff)", " (admin)", " (owner)" } )[ ppriv ] ) )

	for i, p in ipairs( registry.player_list ) do
		table.insert( t, p.name .. ( { "", "", " (staff)", " (admin)", " (owner)" } )[ p.rank ] )
	end
--	minetest.chat_send_player( pname, string.format( "Player-List: %s", table.concat( t, ", " ) ) )
end )

minetest.register_on_leaveplayer( function( player, is_timeout )
	local pname = player:get_player_name( )

	for i, p in pairs( registry.player_list ) do
		if p.name == pname then
--			core.chat_send_all( string.format( minetest.MESSAGE_PLAYER_LEAVE,
--				p.name .. ( { "", "", " (staff)", " (admin)", " (owner)" } )[ p.rank ],
--				is_timeout and "(timed out)" or "(logged off)" ) )

			table.remove( registry.player_list, i )
			return
		end
	end
end )
