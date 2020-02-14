--------------------------------------------------------
-- Minetest :: Player Registry Mod v2.0 (registry)
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
registry.connected_players = { }
registry.rank_list = { }
registry.rank_privs = { }
registry.rank_colors = { }
registry.rank_titles = { }
registry.rank_labels = { }
registry.rank_badges = { }

local next_pid = 1

---------------------
-- Private Methods --
---------------------

local define_ranks = loadfile( minetest.get_modpath( "registry" ) .. "/ranks.lua" )

local function register_rank( name, def )
	registry.rank_privs[ name ] = def.privs
	registry.rank_colors[ name ] = assert( def.color, "Invalid color for rank '" .. name .. "'" )
	registry.rank_titles[ name ] = assert( def.title, "Invalid title for rank '" .. name .. "'" )
	registry.rank_labels[ name ] = assert( def.label, "Invalid label for rank '" .. name .. "'" )
	registry.rank_badges[ name ] = assert( def.badge, "Invalid badge for rank '" .. name .. "'" )
	table.insert( registry.rank_list, name )

	print( string.format( "Registered rank '%s' (level %d)", name, #registry.rank_list ) )
end

local function is_rank_valid( rank )
	return registry.rank_privs[ rank ] ~= nil
end

local function get_player_rank( name )
	-- walk through ranks from highest to lowest to determine most privileges
	for idx = #registry.rank_list, 1, -1 do
		local rank = registry.rank_list[ idx ]
		local privs = registry.rank_privs[ rank ]
		if not privs or minetest.check_player_privs( name, privs ) then                  -- operator
			return rank
		end
	end
end

local function get_player_idx( src_name )
	for idx, name in ipairs( registry.player_list ) do
		if name == src_name then
			return idx
		end
	end
end

local function get_command_ls( rank )
	local player_list = { }
	for name, data in registry.iterate( ) do
		if not rank or data.rank == rank then
			table.insert( player_list, name .. registry.rank_labels[ data.rank ] )
		end
	end
	return string.format( "Player-List: %s", table.concat( player_list, ", " ) )
end

--------------------
-- Public Methods --
--------------------

registry.is_player_rank_above = function ( name, min_rank )
	local rank = registry.connected_players[ name ].rank
	for _, cur_rank in ipairs( registry.rank_list ) do
		if cur_rank == min_rank then 
			return true
		elseif cur_rank == rank then
			return false
		end
	end
end

registry.get_last_pid = function ( )
	return next_pid > 1 and next_pid or nil
end

registry.iterate = function ( min_idx, max_idx )
	local player_list = registry.player_list
	local player_map = registry.connected_players
	local idx = min_idx or 1

	if not max_idx then max_idx = #registry.player_list end
	return function ( )
		if idx <= max_idx then
			local name = player_list[ idx ]
			idx = idx + 1
			return name, player_map[ name ], idx
		end
		return nil
	end
end

registry.join_player_list = function ( sep, func )
	local str = ""
	local player_list = registry.player_list
	local player_map = registry.connected_players

	for idx, name in ipairs( player_list ) do
		local res = func( name, player_map[ name ] )
                if res ~= nil then
			str = idx > 1 and str .. sep .. res or str .. res
		end
	end

	return str
end

------------------------------
-- Registered Chat Commands --
------------------------------

minetest.register_chatcommand( "ls", {
	description = "Show the list of online players, optionally filtered by rank (staff, admin, or owner)",
	func = function( name, param )
		if param == "" or is_rank_valid( param ) then
			return true, get_command_ls( param ~= "" and param )
		else
			return false, "Invalid rank specified."
		end
	end,
} )

--------------------------
-- Registered Callbacks --
--------------------------

minetest.register_on_joinplayer( function( player )
	local player_name = player:get_player_name( )
	local data = {
		pid = next_pid, obj = player, time = os.time( ), rank = get_player_rank( player_name )
	}

	registry.connected_players[ player_name ] = data
	table.insert( registry.player_list, player_name )

	next_pid = next_pid + 1

	minetest.chat_send_all( string.format( registry.MESSAGE_PLAYER_JOIN, player_name .. registry.rank_labels[ data.rank ] ) )
	minetest.chat_send_player( player_name, get_command_ls( ) )
end )

minetest.register_on_leaveplayer( function( player, is_timeout )
	local player_name = player:get_player_name( )
	local data = registry.connected_players[ player_name ]

	minetest.chat_send_all( string.format( registry.MESSAGE_PLAYER_LEAVE,
		player_name .. registry.rank_labels[ data.rank ],
		is_timeout and "(timed out)" or "(logged off)" ) )

	table.remove( registry.player_list, get_player_idx( player_name ) )
	registry.connected_players[ player_name ] = nil
end )

--------------------------

define_ranks( register_rank )
