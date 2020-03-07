--[[Convert ticks to human-readable object

In the output table plural give unit since start without removing next units
(i.e more minutes=120 -> minute=0)

Arguments:
total_ticks (int) -- the number of ticks (IRL or local)

Returns:
table -- a time table describing the time in the world
]]--
function ticks_to_time(total_ticks)
  local seconds = math.floor(total_ticks/60)
  local minutes = math.floor(total_ticks/60/60)
  local hours = math.floor(total_ticks/60/60/60)
  local days = 1 + math.floor(total_ticks/60/60/60/24)
  return {
    ticks=total_ticks,
    tick=total_ticks % 60,
    seconds=seconds,
    second=seconds % 60,
    seconds=seconds,
    minutes=minutes,
    minute=minutes % 60,
    hours=hours,
    hour=hours % 24,
    days=days
  }
end

--[[Format a human readable dict to a string

Arguments:
time (table) -- a table given from `ticks_to_time`

Returns:
string -- a string representation of time
]]--
function format_time(time)
  local time_format = '%03dT%02d:%02d:%02d.%02d'
  return string.format(
    time_format,
    time['day'],
    time['hour'],
    time['minute'],
    time['second'],
    time['tick']
  )
end

function move_entities(name_list, move_x, move_y, search_area)
  local logo_entities = game.surfaces['nauvis'].find_entities_filtered({area = search_area, name = name_list})
  for _, e in pairs(logo_entities) do
    e.teleport({e.position.x+move_x, e.position.y+move_y})
  end  
end

function timelapse_screenshot(tick)
  local arg_filename_base = 'built-in-timelapse'
  local arg_position = {20, -46}
  local tile_px = 32
  local chunk_tiles = 32
  local arg_zoom = 1
  local resolution_multiplier = 1/2

  if tick > 1 *60*60*60 then
    arg_zoom = 1/2
  end
  if tick > 9 *60*60*60 then
    arg_zoom = 1/4
  end
  if tick > 30 *60*60*60 then
    arg_zoom = 1/8
  end

  local arg_resolution = {16*resolution_multiplier*tile_px*chunk_tiles, 9*resolution_multiplier*tile_px*chunk_tiles}

  local timelapse_subfolder = 'test/'

  local time = ticks_to_time(tick)
  local arg_path = 'built-in-timelapse/' .. timelapse_subfolder .. arg_filename_base .. '_' .. format_time(time) .. '.png'
  game.take_screenshot{path = arg_path, position = arg_position, resolution = arg_resolution, zoom = arg_zoom, render_tiles = true};
end


-- prepare
script.on_init(
  function()
    --move logo entities
    local logo_name_list =
    {
      'factorio-logo-0',
      'factorio-logo-1',
      'factorio-logo-2',
      'factorio-logo-3',
      'factorio-logo-4',
      'factorio-logo-5',
      'factorio-logo-6',
    }
    move_entities( logo_name_list, 0, 5, {left_top = {-15.5-1, -41.5-1}, right_bottom = {56.5+1, -41.5+1}} )
    -- change player colour
    for p, player in pairs(game.players) do
      player.color = { r = 0.869, g = 0.5, b = 0.130, a = 0.5 };
    end

    for s, surface in pairs(game.surfaces) do
      -- set day
      surface.daytime = 1;
      -- chart a minimum area
      surface.request_to_generate_chunks({0,0}, 9);
      surface.force_generate_chunk_requests();
    end

    for f, force in pairs(game.forces) do
      force.chart_all();
    end
  end
)

script.on_event(defines.events.on_player_joined_game,
  function()  
    -- change player colour
    for p, player in pairs(game.players) do
      player.color = { r = 0.869, g = 0.5, b = 0.130, a = 0.5 };
    end
  end
)

-- take screenshot
script.on_event(defines.events.on_tick,
  function()
    if game.tick % (1 *1) == 0 then
      timelapse_screenshot(game.tick)
    end
  end
)