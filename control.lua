local max_range = 20

local function setup()
	global.inserters = global.inserters or {}
	global.inserter_count = global.inserter_count or 0
	global.projectiles = global.projectiles or {}
	
	global.projectile_names = {}
	for name, _ in pairs(game.item_prototypes) do
		global.projectile_names[name] = 'thrower-inserter-projectile-' .. name
	end
end

script.on_init(setup)
script.on_configuration_changed(setup)

local prototypes_with_storage_inventory = {
	['container'] = defines.inventory.chest,
	['cargo-wagon'] = defines.inventory.cargo_wagon,
	['car'] = defines.inventory.car_trunk
}

script.on_nth_tick(7, function()
	for i = 1, global.inserter_count do
		local inserter = global.inserters[i]
		if inserter then
			if inserter.valid then
				local held_stack = inserter.held_stack
				if held_stack.valid_for_read then
					local orientation = inserter.orientation
					local position = inserter.position
					local held_stack_position = inserter.held_stack_position
					if (orientation == 0    and held_stack_position.y + 0.3 >= position.y)
					or (orientation == 0.25 and held_stack_position.x - 0.3 <= position.x)
					or (orientation == 0.50 and held_stack_position.y - 0.3 <= position.y)
					or (orientation == 0.75 and held_stack_position.x + 0.3 >= position.x) then
						local item_name = held_stack.name
						local stack_size = held_stack.count
						local surface = inserter.surface
						local pickup_position = inserter.pickup_position 
						local target_position = inserter.drop_position
						
						inserter.active = true
						
						if pickup_position.x ~= target_position.x and pickup_position.y ~= target_position.y then
							inserter.active = false
							goto inactive
						end
						
						local drop_target = inserter.drop_target
						local overflow
						if drop_target then
							local inventory_index = prototypes_with_storage_inventory[drop_target.type]
							if inventory_index then
								local inventory = drop_target.get_inventory(inventory_index)
								local bar = inventory.supports_bar() and #inventory - inventory.get_bar() + 1 or 0
								if inventory.count_empty_stacks() - bar <= 0 then
									inserter.active = false
									goto inactive
								end
							end
							overflow = stack_size - drop_target.insert{name = item_name, count = stack_size}
						else
							overflow = stack_size
						end
						
						if inserter.active then
							held_stack.clear()
							
							local projectile = surface.create_entity{
								name = global.projectile_names[item_name],
								position = position,
								source_position = held_stack_position,
								target_position = target_position
							}
							
							if overflow > 0 then
								global.projectiles[script.register_on_entity_destroyed(projectile)] = {
									surface,
									target_position,
									{name = item_name, count = overflow}
								}
							end
						end
						
						::inactive::
					end
				end
			else
				global.inserters[i] = false
			end
		end
	end
end)

local raw_fish = 'raw-fish'
local water_splash = 'water-splash'
local collision_mask = {'item-layer', 'object-layer'}
script.on_event(defines.events.on_entity_destroyed, function(event)
	local registration_number = event.registration_number
	local projectile_data = global.projectiles[registration_number]
	
	if projectile_data then
		local surface = projectile_data[1]
		local position = projectile_data[2]
		local stack = projectile_data[3]
		
		if surface.valid then
			if surface.count_tiles_filtered{position = position, radius = 1, limit = 1, collision_mask = collision_mask} == 1 then
				surface.create_entity{
					name = water_splash,
					position = position
				}
				if stack.name == raw_fish and surface.count_tiles_filtered{
					position = position,
					radius = 1,
					limit = 1,
					collision_mask = {'item-layer', 'object-layer', 'water-tile'}
				} == 1 then
					for i = 1, stack.count do
						surface.create_entity{
							name = 'thrown-fish',
							position = position
						}
					end
				end
			else
				surface.spill_item_stack(position, stack)
			end
		end
		
		global.projectiles[registration_number] = nil
	end
end)

script.on_nth_tick(60000, function()
	local new_inserters = {false, false, false, false, false}
	local i = 0
	for _, inserter in ipairs(global.inserters) do
		if inserter then
			i = i + 1
			new_inserters[i] = inserter
		end
	end
	global.inserter_count = i
	global.inserters = new_inserters
end)

local type = {'locomotive', 'cargo-wagon', 'artillery-wagon', 'container', 'logistic-container', 'roboport', 'boiler', 'reactor', 'furnace', 'assembling-machine', 'lab', 'ammo-turret', 'rocket-silo'}
local function inserter_built(event)
	local entity = event.created_entity or event.entity
	global.inserter_count = global.inserter_count + 1
	global.inserters[global.inserter_count] = entity
	
	local position_x = entity.position.x
	local position_y = entity.position.y
	
	local x = entity.drop_position.x - position_x
	local y = entity.drop_position.y - position_y
	local axis = math.abs(x) > math.abs(y)
	local surface = entity.surface
	
	if event.player_index then
		for i = 1, max_range do
			if surface.count_entities_filtered{
				area = {{math.floor(entity.drop_position.x), math.floor(entity.drop_position.y)}, {math.ceil(entity.drop_position.x), math.ceil(entity.drop_position.y)}},
				collision_mask = 'object-layer',
				limit = 1,
				type = type
			} == 1 then
				return
			end
			if axis then
				if x > 0 then
					entity.drop_position = {x + position_x - i, y + position_y}
				else
					entity.drop_position = {x + position_x + i, y + position_y}
				end
			else
				if y > 0 then
					entity.drop_position = {x + position_x, y + position_y - i}
				else
					entity.drop_position = {x + position_x, y + position_y + i}
				end
			end
		end
		
		entity.drop_position = {x + position_x, y + position_y}
	end
end

local filter = {{filter = 'name', name = 'thrower-inserter'}}
script.on_event(defines.events.on_built_entity, inserter_built, filter)
script.on_event(defines.events.on_robot_built_entity, inserter_built, filter)
script.on_event(defines.events.on_entity_cloned, inserter_built, filter)
script.on_event(defines.events.script_raised_built, inserter_built, filter)
script.on_event(defines.events.script_raised_revive, inserter_built, filter)

script.on_event(defines.events.on_player_rotated_entity, function(event)
	local entity = event.entity
	if entity.name == 'thrower-inserter' then
		entity.direction = event.previous_direction
		
		local x = entity.drop_position.x - entity.position.x
		local y = entity.drop_position.y - entity.position.y
		
		if math.abs(x) > math.abs(y) then
			if x > 0 then
				x = x - 1
				if x < 1 then
					x = max_range + 0.7
				end
			else
				x = x + 1
				if x > -1 then
					x = -max_range - 0.7
				end
			end
		else
			if y > 0 then
				y = y - 1
				if y < 1 then
					y = max_range + 0.7
				end
			else
				y = y + 1
				if y > -1 then
					y = -max_range - 0.7
				end
			end
		end
		
		entity.drop_position = {x + entity.position.x, y + entity.position.y}
	end
end)

script.on_event(defines.events.on_pre_entity_settings_pasted, function(event)
	local source = event.source
	local destination = event.destination
	
	if source.name ~= 'thrower-inserter' or destination.name ~= 'thrower-inserter' then return end
	
	local sd = source.direction
	local dd = destination.direction
	
	if ((sd == defines.direction.north or sd == defines.direction.south) and (dd == defines.direction.east or dd == defines.direction.west)) or
	((dd == defines.direction.north or dd == defines.direction.south) and (sd == defines.direction.east or sd == defines.direction.west)) then
		local surface = destination.surface
		local position = destination.position
		destination.destroy{raise_destroy = true}
		surface.spill_item_stack(position, {name = 'thrower-inserter'})
	end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
	local source = event.source
	local destination = event.destination
	local prototype = destination.prototype

	if prototype.allow_custom_vectors and source.name == 'thrower-inserter' and destination.name ~= 'thrower-inserter' then
		local position = destination.position
		local x = position.x
		local y = position.y
	
		local inserter_pickup_position = prototype.inserter_pickup_position
		inserter_pickup_position[1] = inserter_pickup_position[1] + x
		inserter_pickup_position[2] = inserter_pickup_position[2] + y
	
		local inserter_drop_position = prototype.inserter_drop_position
		inserter_drop_position[1] = inserter_drop_position[1] + x
		inserter_drop_position[2] = inserter_drop_position[2] + y
	
		destination.direction = defines.direction.north
		destination.pickup_position = inserter_pickup_position
		destination.drop_position = inserter_drop_position
	end
end)
