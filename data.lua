local function merge(prototype, new_data)
	prototype = table.deepcopy(prototype)
	for k, v in pairs(new_data) do
		if v == 'nil' then
			prototype[k] = nil
		else
			prototype[k] = v
		end
	end
	return prototype
end

data:extend{
	merge(data.raw.inserter['fast-inserter'], {
		name = 'thrower-inserter',
		allow_custom_vectors = true,
		stack = settings.startup['stack-thrower-inserter'].value,
		hand_size = 2.25,
		insert_position = {0, 20.7},
		pickup_position = {0, -1.5},
		collision_box = {{-0.15, -0.65}, {0.15, 0.65}},
		selection_box = {{-0.4, -0.9}, {0.4, 0.9}},
		energy_per_movement = '35kJ',
		energy_per_rotation = '35kJ',
		energy_source = {
			drain = '5kW',
			type = 'electric',
			usage_priority = 'secondary-input'
		},
		extension_speed = 0.07,
		rotation_speed = 0.02,
		minable = {
			mining_time = 0.2,
			result = 'thrower-inserter'
		},
		platform_picture = {sheet = {
			filename = '__lob__/graphics/entity/thrower-inserter/thrower-inserter-platform.png',
			height = 40,
			hr_version = {
				filename = '__lob__/graphics/entity/thrower-inserter/hr-thrower-inserter-platform.png',
				height = 79,
				priority = 'extra-high',
				scale = 0.5,
				shift = {0.046875, 0.203125},
				width = 105
			},
			priority = 'extra-high',
			shift = {0.046875 / 2, 0.203125 / 2},
			width = 52
		}},
		hand_open_picture = {
			filename = '__lob__/graphics/entity/thrower-inserter/thrower-inserter-hand-open.png',
			height = 82,
			hr_version = {
				filename = '__lob__/graphics/entity/thrower-inserter/hr-thrower-inserter-hand-open.png',
				height = 164,
				priority = 'extra-high',
				scale = 0.5,
				width = 72
			},
			priority = 'extra-high',
			width = 36
		},
		hand_closed_picture = {
			filename = '__lob__/graphics/entity/thrower-inserter/thrower-inserter-hand-closed.png',
			height = 82,
			hr_version = {
				filename = '__lob__/graphics/entity/thrower-inserter/hr-thrower-inserter-hand-closed.png',
				height = 164,
				priority = 'extra-high',
				scale = 0.5,
				width = 72
			},
			priority = 'extra-high',
			width = 36
		},
		hand_base_picture = {
			filename = '__lob__/graphics/entity/thrower-inserter/thrower-inserter-hand-base.png',
			height = 68,
			hr_version = {
				filename = '__lob__/graphics/entity/thrower-inserter/hr-thrower-inserter-hand-base.png',
				height = 136,
				priority = 'extra-high',
				scale = 0.5,
				width = 32
			},
			priority = 'extra-high',
			width = 16
		},
		fast_replaceable_group = 'nil',
		next_upgrade = 'nil',
		icon = '__lob__/graphics/icons/thrower-inserter.png',
		icon_mipmaps = 4,
		icon_size = 64
	}),
	{
		icon = '__lob__/graphics/icons/thrower-inserter.png',
		icon_mipmaps = 4,
		icon_size = 64,
		name = 'thrower-inserter',
		place_result = 'thrower-inserter',
		order = 'h[thrower-inserter]',
		stack_size = 25,
		subgroup = 'inserter',
		type = 'item'
	},
	{
		type = 'recipe',
		name = 'thrower-inserter',
		enabled = false,
		result = 'thrower-inserter',
		ingredients = {
			{'stack-inserter', 1},
			{'advanced-circuit', 4},
			{'low-density-structure', 4}
		}
	},
	{
		type = 'technology',
		name = 'thrower-inserter',
		unit = {
			count = 100,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1}
			},
			time = 30
		},
		prerequisites = {
			'low-density-structure',
			'stack-inserter'
		},
		effects = {{
			recipe = 'thrower-inserter',
			type = 'unlock-recipe'
		}},
		icon = '__lob__/graphics/technology/thrower-inserter.png',
		icon_size = 128
	},
	merge(data.raw.fish.fish, {
		name = 'thrown-fish',
		localised_name = {'entity-name.fish'},
		localised_description = {'entity-description.fish'}
	})
}

data.raw.fish['thrown-fish'].minable.count = 1
