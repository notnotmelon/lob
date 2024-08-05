if mods.RenaiTransportation then
	data.raw.inserter['RTThrower-thrower-inserter'] = nil
	data.raw.item['RTThrower-thrower-inserter-Item'] = nil
	data.raw.recipe['RTThrower-thrower-inserter-Recipe'] = nil
	
	local new_effects = {}
	for _, effect in ipairs(data.raw.technology['RTThrowerTime'].effects) do
		if effect.type ~= 'unlock-recipe' or effect.recipe ~= 'RTThrower-thrower-inserter-Recipe' then
			new_effects[#new_effects + 1] = effect
		end
	end
	data.raw.technology['RTThrowerTime'].effects = new_effects
end

local shadow = settings.startup['render-shadows-under-items'].value and table.deepcopy(data.raw.stream['acid-stream-spitter-small'].shadow) or nil

local function hook_newindex(table, hook) -- https://mods.factorio.com/mod/crafting_combinator
	local raw_mt = getmetatable(table) or {}
	setmetatable(table, raw_mt)
	local super_newindex = raw_mt.__newindex or rawset
	function raw_mt.__newindex(self, key, value)
		hook(self, key, value, function() return super_newindex(self, key, value) end)
	end
end

local function create_projectile(item)
	local particle = {}
	if item.icons then
		particle.layers = {}
		local layers = particle.layers
		for i, icon in ipairs(item.icons) do
			local size = icon.icon_size or item.icon_size
			layers[i] = {
				filename = icon.icon,
				priority = 'high',
				scale = 16 / size * (icon.scale or 1),
				size = size,
				tint = icon.tint,
				shift = icon.shift and {icon.shift[1] / 16, icon.shift[2] / 16}
			}
		end
	elseif item.icon_size then
		particle = {
			filename = item.icon,
			priority = 'high',
			scale = 16 / item.icon_size,
			size = item.icon_size
		}
	else
		particle = {
			filename = '__core__/graphics/icons/unknown.png',
			priority = 'high',
			scale = 0.25,
			size = 64
		}
	end
	
	data:extend{{
		type = 'stream',
		name = 'thrower-inserter-projectile-' .. item.name,
		particle_spawn_interval = 0,
		particle_horizontal_speed = 0.3,
		particle_horizontal_speed_deviation = 0,
		particle_vertical_acceleration = 0.012,
		particle = particle,
		oriented_particle = true,
		shadow = shadow
	}}
end

for _, prototype in pairs(data.raw) do
	for _, item in pairs(prototype) do
		if item.stack_size == nil then goto not_an_item end
		create_projectile(item)
	end
	
	hook_newindex(prototype, function(self, key, value, super)
		if value == nil then
			data.raw.stream['thrower-inserter-projectile-' .. key] = nil
		else
			create_projectile(value)
		end
		super()
	end)
	::not_an_item::
end
