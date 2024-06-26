
minetest.register_node("digiline_clock:clock", {
	description = "Digilines Clock",
	groups = {cracky=3},
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec","field[channel;Channel;${channel}")
	end,
	tiles = {
		"digiline_clock_clock.png",
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
	},
	inventory_image = "digiline_clock_clock.png",
	drawtype = "nodebox",
	selection_box = {
		--From luacontroller
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16}, -- Bottom slab
			{-5/16, -7/16, -5/16, 5/16, -6/16, 5/16}, -- Circuit board
			{-3/16, -6/16, -3/16, 3/16, -5/16, 3/16}, -- IC
		}
	},
	node_box = {
		--From Luacontroller
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16}, -- Bottom slab
			{-5/16, -7/16, -5/16, 5/16, -6/16, 5/16}, -- Circuit board
			{-3/16, -6/16, -3/16, 3/16, -5/16, 3/16}, -- IC
		}
	},
	_digistuff_channelcopier_fieldname = "channel",
	paramtype = "light",
	sunlight_propagates = true,
	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		if minetest.is_protected(pos,name) and not minetest.check_player_privs(name,{protection_bypass=true}) then
			minetest.record_protection_violation(pos,name)
			return
		end
		local meta = minetest.get_meta(pos)
		if fields.channel then meta:set_string("channel",fields.channel) end
	end,
	on_timer = function(pos)
		local meta = minetest.get_meta(pos)
		local channel = meta:get_string("channel")
		digilines.receptor_send(pos,digilines.rules.default,channel,"done")
		local loop = meta:get_int("loop") > 0
		return loop
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function(pos,node,channel,msg)
					local meta = minetest.get_meta(pos)
					if meta:get_string("channel") ~= channel then return end
					if msg == "loop_on" then
						meta:set_int("loop",1)
					elseif msg == "loop_off" then
						meta:set_int("loop",0)
					else
						local time = tonumber(msg)
						if time and time >= 0.5 and time <= 3600 then
							local timer = minetest.get_node_timer(pos)
							timer:start(time)
						end
					end
				end
		},
	},

})
minetest.register_craft({
	output = "digiline_clock:clock",
	recipe = {
		{"digilines:wire_std_00000000"},
		{"mesecons_microcontroller:microcontroller0000"},
		{"mesecons_blinkyplant:blinky_plant_off"},
	}
})
