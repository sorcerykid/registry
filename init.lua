--------------------------------------------------------
-- Minetest :: Player Registry Mod v1.0 (registry)
--
-- See README.txt for licensing and other information.
-- Copyright (c) 2018-2019, Leslie Ellen Krause
--
-- ./games/minetest_game/mods/registry/init.lua
--------------------------------------------------------

registry = { }

registry.MESSAGE_PLAYER_JOIN = "*** %s joined the game."
registry.MESSAGE_PLAYER_LEAVE = "*** %s left the game %s."

registry.player_list = { }
registry.rank_colors = { "#FFFFFF", "#80FFFF", "#80FF80", "#FFFF80", "#FF80FF" }
registry.rank_titles = { "Basic", "Guardian", "Moderator", "Administrator", "Owner/Operator" }
registry.rank_labels = { "", "", " (staff)", " (admin)", " (owner)" }

registry.PLAYER_RANK_BASIC = 1
registry.PLAYER_RANK_GUARD = 2
registry.PLAYER_RANK_STAFF = 3
registry.PLAYER_RANK_ADMIN = 4
registry.PLAYER_RANK_OWNER = 5

local next_pid = 1

registry.get_last_pid = function ( )
	return next_pid > 1 and next_pid or nil
end

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

-- hook into the authentication handler to preserve the last login time
local old_record_login = minetest.get_auth_handler( ).record_login

minetest.get_auth_handler( ).record_login = function ( player_name )
	local obj = minetest.get_player_by_name( player_name )
	local newtime = os.time( )
	local oldtime = minetest.get_auth_handler( ).get_auth( player_name ).last_login
	local rank = registry.get_player_rank( player_name )

	old_record_login( player_name ) 

	table.insert( registry.player_list, {
		pid = next_pid, obj = obj, name = player_name, rank = rank, newtime = newtime, oldtime = oldtime }
	)

	next_pid = next_pid + 1

--	minetest.chat_send_all( string.format( registry.MESSAGE_PLAYER_JOIN, pname .. registry.labels[ ppriv ] ) )
end

minetest.register_on_leaveplayer( function( player, is_timeout )
	local pname = player:get_player_name( )

	for i, p in pairs( registry.player_list ) do
		if p.name == pname then
--			minetest.chat_send_all( string.format( registry.MESSAGE_PLAYER_LEAVE,
--				p.name .. registry.labels[ p.rank ],
--				is_timeout and "(timed out)" or "(logged off)" ) )

			table.remove( registry.player_list, i )
			return
		end
	end
end )
