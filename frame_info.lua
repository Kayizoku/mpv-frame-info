local assdraw = require "mp.assdraw"
local options = require "mp.options"
local mp = require 'mp'
local utils = require "mp.utils"

local date = os.date("*t")
local datestring = ("%02d-%02d-%02d_%02d-%02d-%02d"):format(date.year, date.month, date.day, date.hour, date.min, date.sec)

-- https://github.com/Kagami/mpv_frame_info updated by Kayi
-- https://github.com/oltodosel/mpv-scripts/blob/master/total_playtime.lua integrated into the script

package.path = mp.command_native({"expand-path", "~~/script-modules/?.lua;"})..package.path
local filesize = require "filesize"
local info_active = true
local o = {
    font_size = 9.25,
    font_color = "FFFFFF",
    border_size = 0.8,
    border_color = "000000",
    font_name = "Source Sans Pro"
}
options.read_options(o)
function get_formatting()
    return string.format(
        "{\\fs%d}{\\1c&H%s&}{\\bord%f}{\\3c&H%s&}{\\fn%s}",
        o.font_size, o.font_color, o.border_size, o.border_color, o.font_name
    )
end

-- converts seconds to days, hours, minutes and seconds
-- function timestamp(duration)
-- 	 local total_seconds = math.floor(duration)
-- 	 hours = (math.floor(total_seconds / 3600))
-- 	 total_seconds = (total_seconds % 3600)
-- 	 minutes = (math.floor(total_seconds / 60))
-- 	 seconds = (total_seconds % 60)
-- 	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
-- end

function timestamp(duration)
	local seconds = tonumber(duration/mp.get_property("speed"))
	if seconds > 0 then
	if not seconds then return "00:00:00" end
	  hours = string.format("%02.f", math.floor(seconds/3600)) 
	  mins = string.format("%02.f", math.floor(seconds/60 - (hours*60))) 
	  secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60)) 
	  return (hours..":"..mins..":"..secs) 
	end
end

local function readable_bytes(size) 
	if not size then return nil end
	return filesize(size)
	
end

function get_info()
 total_time()
    return string.format(
        "%s%s ({\\b1}%s{\\b0})\\NDisplay Resolution: %s\\N\\N %s (Speed: {\\b1}%s{\\b0})\\N %s\\NPlaylist Position: %s, Dropped Frames: %s, Clock: {\\b1}%s{\\b0}\\N\\NFile Ends at: {\\b1}%s{\\b0}, Playlist Ends at: {\\b1}%s{\\b0}\\N\\NVideo Bitrate: {\\b1}%s{\\b0}  X  Audio Bitrate: {\\b1}%s{\\b0}",
        get_formatting(),
        mp.get_property_native("filename"),
		readable_bytes( mp.get_property_native('file-size')),
		display_resolution(),
		total_duration_remaining(),
		show_playback_speed(),
		total_duration_left(),
	    playlist_position(),
		dropped_frames(),
		show_current_time(),
		time_end(),
		--time_end_playlist(),
		time_end_playlist(),
		readable_bytes(mp.get_property_native('video-bitrate')),
		readable_bytes(mp.get_property_native('audio-bitrate')))

end

function show_playback_speed()
    return string.format(("%.2f"):format(math.floor(mp.get_property("speed") * 1000) / 1000))
end

function show_current_time()
	return string.format(os.date('%H:%M'))
end

-- function show_end_time_fn()
-- 	clock_hour = tonumber(os.date("%I"))
-- 	clock_minutes = tonumber(os.date("%M"))

-- 	local remaining_t_seconds = mp.get_property_number("playtime-remaining") or 0
-- 	remaining_t_hours = math.floor(remaining_t_seconds / 3600)
-- 	remaining_t_min = (remaining_t_seconds / 60) % 60

-- 	end_hour = clock_hour + remaining_t_hours
-- 	end_min = math.floor(clock_minutes + remaining_t_min)

-- 	if end_min >= 60 then
-- 		end_hour = math.floor(end_hour + (end_min / 60))
-- 		end_min = math.floor(end_min % 60)
-- 	end

-- 	if end_hour >= 24 then
-- 		end_hour = math.abs(end_hour % 24)
-- 	end

-- 	return string.format("Playback will end at: %02d:%02d", end_hour, end_min)
-- end

function time_end_playlist()
	if not mp.get_property("speed") then return nil end
     local ending_time = os.date("%H:%M - %a %d %b",os.time()+(total_dur_left/mp.get_property("speed")))
    return string.format(ending_time)
end	


function time_end()
	if not mp.get_property("playtime-remaining") then return nil end

     local ending_time = os.date('%H:%M',os.time()+(mp.get_property("playtime-remaining")/mp.get_property("speed")))
	
    return string.format(ending_time)
end


function dropped_frames(frames_dropped)
	if not frames_dropped then return nil end

	 frames_dropped = mp.get_property_native('frame-drop-count')

	return string.format("{\\b1}%s{\\b0}", tonumber(frames_dropped) )

end

function playlist_position()
	local playlist_playing_position = mp.get_property('playlist-playing-pos') + 1
	local playlist_count = mp.get_property('playlist-count')

 if not playlist_playing_position and playlist_count then return "" end

return string.format("{\\b1}%s{\\b0}{\\b1}/%s{\\b0}", playlist_playing_position, playlist_count)
end

function total_duration_remaining() 
	if not played_dur then return "00:00:00" end

-- Total playlist

-- Current Playing Entry

  total_playtime = mp.get_property_native('duration') 
  total_playing_duration= timestamp(total_playtime) 
  total_playlist_time = timestamp(total_dur) or "00:00:00" 

		
  if not total_playtime and total_playing_duration and total_playlist_time then return "00:00:00" end

	return string.format("Total Playlist Time: {\\b1}%s{\\b0} / {\\b1}%s{\\b0}",
	total_playing_duration, total_playlist_time)

end

-- function total_duration_left()
    
--     if not played_dur and total_dur then return "00:00:00" end
    
--     return string.format("%s / %s (%s%%)", timestamp(played_dur), timestamp(total_dur), math.floor(played_dur*100/total_dur))
-- end

function total_duration_left()

	if not played_dur then return "00:00:00" end

	total_dur_left = (total_dur - played_dur) or "00:00:00"
	-- local total_dur_left = total_dur_left/mp.get_property("speed")
	remaining_playtime = mp.get_property_native('playtime-remaining')
	total_playlist_time_left = timestamp(total_dur_left) or "00:00:00" 
	total_playlist_prencentage = math.floor(played_dur*100/total_dur) 

	if not remaining_playtime and total_playlist_time_left and total_playlist_prencentage then return "00:00:00" end

	return string.format('Total Time Remaining: {\\b1}%s{\\b0} / {\\b1}%s{\\b0} ({\\b1}%s%%{\\b0})', 
	timestamp(remaining_playtime), timestamp(total_dur_left), total_playlist_prencentage)
end

function display_resolution() 

	local scaled_width = mp.get_property_native('osd-width')
    local scaled_height = mp.get_property_native('osd-height')

    local native_width = mp.get_property_native('width')
	local native_height = mp.get_property_native('height')

	if not native_width and native_height and scaled_width and scaled_height then return nil end
    
    return string.format("{\\b1}%s{\\b0}x{\\b1}%s{\\b0} X {\\b1}%s{\\b0}x{\\b1}%s{\\b0} ", native_width, native_height, scaled_width, scaled_height)
end

function render_info()
    ass = assdraw.ass_new()
    ass:pos(10, 10)
    ass:append(get_info())
    mp.set_osd_ass(0, 0, ass.text)
end

function clear_info()
    mp.set_osd_ass(0, 0, "") 
end

function toggle_info()
    if info_active then
		mp.register_event("tick", render_info)
        render_info()
		mp.add_key_binding("CTRL+TAB", "calculating_time", calculating_time)
	
    else
        -- TODO: Rewrite to timer + pause/unpause handlers.
		mp.unregister_event(render_info)
        clear_info()
    end
    info_active = not info_active
end

-- function test()
-- 	--mp.observe_property('playlist-count', "number", calculating_time)
-- 	--mp.observe_property("playlist-count", "number", on_pause_change)
-- 	end

mp.add_key_binding("TAB", "toggle_info", toggle_info)

-- function on_pause_change(name, value)
-- 	--playlist_count = mp.get_property_native('playlist-count')
--     if value > 1 then
--         calculating_time()
--     end
-- end


--~ Shows total playtime of current playlist.
--~ If number of items in playlist didn't change since last calculation - it doesn't probe files anew.
--~ requires ffprobe (ffmpeg)

--key_binding = 'F11'
-- save probed files for future reference -- ${fname} \t ${duration}

save_probed = true

saved_probed_filename = "~/mpv/total_playtime.log" -- not in use when save_probed is set to false

-----------------------------------

saved_probed_filename = saved_probed_filename:gsub('~', os.getenv('APPDATA'))

local utils = require 'mp.utils'

playlist = {}
playlist_total = -1			

-- Save current playlist_position, only run code if current_playlistposition is not equal to itself

function total_time()
		if save_probed then
			if io.open(saved_probed_filename, "rb") then
				probed_file = {}
				for line in io.lines(saved_probed_filename) do
					for k, v in line:gmatch("(.+)\t(.+)") do
						probed_file[k] = v
					end
				end
			else
				probed_file = {}
			end

function calculating_time()			
		-- total_old_dur = total_dur
		-- total_old_dur = 0
		-- played_old_dur = played_dur
		-- played_old_dur = 0`
		
		if #playlist ~= playlist_total then
		local cwd = utils.getcwd()
		for pl_num, f in ipairs(mp.get_property_native("playlist")) do
			f = utils.join_path(cwd, f.filename)
			-- attempt basic path normalization
			if true then
				f = string.gsub(f, "\\", "/")
			end
			f = string.gsub(f, "/%./", "/")
			local n
			repeat
				f, n = string.gsub(f, "/[^/]*/%.%./", "/", 1)
			until n == 0
			
			f = string.gsub(f, "\"", "\\\"")
			
			if save_probed and probed_file[f] then
				fprobe = probed_file[f]
			else
				--fprobe = io.popen('ffprobe -v quiet -of csv=p=0 -show_entries format=duration "'.. f .. '"'):read()
				fprobe = io.popen('ffprobe -v quiet -of csv=p=0 -show_entries format=duration "'.. f .. '"'):read()
				if fprobe and save_probed then
					file = io.open(saved_probed_filename, "a")
					file:write(f .. '\t' .. fprobe .."\n")
					file:close()
				end
			end
		--if playlist ~= mp.get_property("playlist-count") then
			playlist[#playlist + 1] = { f, tonumber(fprobe), pl_num }
			mp.osd_message(string.format("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nCalculating: %s/%s", #playlist, mp.get_property("playlist-count")))
		end

	--	if not total_dur ~= prev_total_dur and played_dur ~= prev_played_dur then
		playlist_total = #playlist
		--playlist_total = -1 --can keep calculating and exceeding playlist
		end
	end
--end

	total_dur = 0
	
	-- prev_total_dur = 0
	-- prev_played_dur = 0

	played_dur = mp.get_property_number("time-pos")
	current_pos = mp.get_property_number("playlist-pos-1", 0)

	for i, fn in pairs(playlist) do
		if fn ~= nil then
			total_dur = total_dur + fn[2]
			-- prev_total_dur = total_dur
			if i < current_pos then
				if not played_dur then return nil end
				played_dur = played_dur + fn[2]
				-- prev_played_dur = played_dur
			end
		end
	end	
end	

--If playlist count is updated after initial calcuation, then add in the item to overall calculation and spit out a new total remaining time for the entire duration of the playlist
	
end
--	mp.osd_message(string.format("%s/%s (%s%%) \n %s/%s", disp_time(played_dur), disp_time(total_dur), math.floor(played_dur*100/total_dur), mp.get_property("playlist-pos-1"), mp.get_property("playlist-count")))


-- mp.add_key_binding("total_time", total_time)
