local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local default_skin = minetest.setting_get("multiskin_skin") or "character.png"
local default_format = minetest.setting_get("multiskin_format") or "1.0"
local player_skins = {}
local player_format = {}
local player_preview = {}
local player_textures = {}

-- 3rd party skin-switcher support
-- may be removed from future versions as these mods do not
-- use the proper api method for setting player textures

local skin_mod = modname
local skin_mods = {"skins", "u_skins", "simple_skins", "wardrobe"}
for _, mod in pairs(skin_mods) do
	local path = minetest.get_modpath(mod)
	if path then
		local dir_list = minetest.get_dir_list(path.."/textures")
		for _, fn in pairs(dir_list) do
			if fn:find("_preview.png$") then
				player_preview[fn] = true
			end
		end
		skin_mod = mod
	end
end
local function get_player_skin(player)
	local name = player:get_player_name()
	if name then
		local skin = nil
		if skin_mod == "skins" or skin_mod == "simple_skins" then
			skin = skins.skins[name]
		elseif skin_mod == "u_skins" then
			skin = u_skins.u_skins[name]
		elseif skin_mod == "wardrobe" then
			local skins = wardrobe.playerSkins or {}
			if skins[name] then
				return skins[name]
			end
		end
		if skin then
			return skin..".png"
		end
		local dir_list = minetest.get_dir_list(modpath.."/textures")
		for _, fn in pairs(dir_list) do
			if fn == "player_"..name..".png" then
				return fn
			end
		end
	end
	return default_skin
end

multiskin = {
	model = "multiskin.b3d",
	skins = player_skins,
	textures = player_textures,
}

multiskin.set_player_skin = function(player, skin)
	local name = player:get_player_name()
	player_skins[name].skin = skin
	player:set_attribute("multiskin_skin", skin)
end

multiskin.set_player_format = function(player, format)
	local name = player:get_player_name()
	player_format[name] = format
	player:set_attribute("multiskin_format", format)
end

multiskin.add_preview = function(texture)
	player_preview[texture] = true
end

multiskin.get_preview = function(player)
	local preview = get_player_skin(player).."_preview.png"
	if skin_previews[preview] then
		return preview
	end
end

multiskin.update_player_visuals = function(player)
	local anim = default.player_get_animation(player) or {}
	if anim.model == "character.b3d" then
		default.player_set_model(player, multiskin.model)
	elseif anim.model ~= multiskin.model then
		return
	end
	local name = player:get_player_name()
	local textures = player_textures[name] or {}
	local skin = player_skins[name].skin or "blank.png"
	local layers = {}
	for k, v in pairs(player_skins[name]) do
		if k ~= "skin" then
			table.insert(layers, v)
		end
	end
	local overlay = table.concat(layers, "^")
	local format = player_format[name] or default_format
	if format == "1.8" then
		if overlay ~= "" then
			skin = skin.."^"..overlay
		end
		textures[1] = "blank.png"
		textures[2] = skin
	else
		if overlay == "" then
			overlay = "blank.png"
		end
		textures[1] = skin
		textures[2] = overlay
	end
	default.player_set_textures(player, table.copy(textures))
end

default.player_register_model("multiskin.b3d", {
	animation_speed = 30,
	textures = {
		"blank.png",
		"blank.png",
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
	},
})

minetest.register_on_joinplayer(function(player)
	minetest.after(0, function(player)
		local name = player:get_player_name()
		local skin = player:get_attribute("multiskin_skin") or
			get_player_skin(player)
		local anim = default.player_get_animation(player) or {}
		player_textures[name] = anim.textures or {}
		player_skins[name] = {skin=skin}
		player_format[name] = player:get_attribute("multiskin_format")
		multiskin.update_player_visuals(player)
	end, player)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	for field, _ in pairs(fields) do
		if string.find(field, "skins_set") then
			minetest.after(0, function(player)
				local name = player:get_player_name()
				local skin = get_player_skin(player)
				multiskin.set_player_skin(player, skin)
				multiskin.update_player_visuals(player)
			end, player)
		end
	end
end)

minetest.register_chatcommand("multiskin", {
	params = "<cmd> [name] [args]",
	description = "Multiskin player skin and format management",
	func = function(name, param)
		if not minetest.is_singleplayer() and
				not minetest.check_player_privs(name, {server=true}) then
			return false, "Insufficient privileges"
		end
		local cmd, player_name, args = string.match(param, "^([^ ]+) (.-) (.+)$")
		if not args then
			cmd, player_name = string.match(param, "([^ ]+) (.+)")
		end
		local player = nil
		if player_name then
			player = minetest.get_player_by_name(player_name)
		else
			cmd = string.match(param, "([^ ]+)")
		end
		if cmd == "help" then
			local msg = "\nUsage: /multiskin <cmd> [name] [args]\n\n"..
				"   format <player_name> <format> (1.0 or 1.8)\n"..
				"   set    <player_name> <texture>\n"..
				"   unset  <player_name>\n"..
				"   help (show this message)\n\n"
			minetest.chat_send_player(name, msg)
		elseif cmd == "format" and player and args then
			multiskin.set_player_format(player, args)
			multiskin.update_player_visuals(player)
		elseif cmd == "set" and player and args then
			multiskin.set_player_skin(player, args)
			multiskin.update_player_visuals(player)
		elseif cmd == "unset" and player then
			player_skins[player_name].skin = get_player_skin(player)
			player:set_attribute("multiskin_skin", nil)
			multiskin.update_player_visuals(player)
		else
			return false, "Invalid parameters, see /multiskin help"
		end
	end,
})
