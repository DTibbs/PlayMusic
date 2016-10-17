function Initialize()
	sJSONParser = SELF:GetOption('JSONParser')
	sFileToRead = SELF:GetOption('FileToRead')
	
	--load the external JSON library
	JSON = assert(loadfile(sJSONParser))()
    	JSON.strictTypes = true
end

function Update()
	--Create oldSongInfo if it doesn't exist
	if oldSongInfo == nill then
		local oldSongInfo
	end
	
	local File = io.open(sFileToRead)
	-- HANDLE ERROR OPENING FILE.
	if not File then
		print('ReadFile: unable to open file at ' .. sFileToRead)
		return
	end

	-- READ FILE CONTENTS AND CLOSE.
	local FileContents = File:read("*all")
	File:close()
	
	--Convert JSON to lua table and set meters
	nowPlaying_info = JSON:decode(FileContents)
	if nowPlaying_info ~= nill then
		SKIN:Bang('!SetVariable', 'Shuffle', nowPlaying_info.shuffle)
		if nowPlaying_info.playing or oldSongInfo == nil then
		SKIN:Bang('!SetVariable', 'SongPlaying', 1)
		SKIN:Bang('!SetVariable', 'GPMDPOpen', 1)
			if oldSongInfo == nil or oldSongInfo.title ~= nowPlaying_info.song.title then
				--Set all variables
				SKIN:Bang('!SetVariable', 'CoverUrl', nowPlaying_info.song.albumArt)
				SKIN:Bang('!SetVariable', 'SongTitle', nowPlaying_info.song.title)
				SKIN:Bang('!SetVariable', 'SongArtist', nowPlaying_info.song.artist)
				SKIN:Bang('!SetVariable', 'SongAlbum', nowPlaying_info.song.album)
				SKIN:Bang('!CommandMeasure', 'MeasureImageDownload', "Update")
			end
			local seconds = nowPlaying_info.time.total/1000
			if  SKIN:GetMeter(SKIN:GetVariable("MeterTotalTime")) ~= nil then
				if math.floor(seconds/(60*60)) ~= 0  then
					SKIN:GetMeter(SKIN:GetVariable("MeterTotalTime")):SetText(string.format("%.2d:%.2d:%.2d", seconds/(60*60), seconds/60%60, seconds%60))
				else
					SKIN:GetMeter(SKIN:GetVariable("MeterTotalTime")):SetText(string.format("%.2d:%.2d", seconds/60%60, seconds%60))
				end
			end
			local currentSeconds = nowPlaying_info.time.current/1000
			if SKIN:GetMeter(SKIN:GetVariable("MeterCurrentTime")) ~= nil then
				if math.floor(currentSeconds/(60*60)) ~= 0 then
					SKIN:GetMeter(SKIN:GetVariable("MeterCurrentTime")):SetText(string.format("%.2d:%.2d:%.2d", currentSeconds/(60*60), currentSeconds/60%60, currentSeconds%60))
				else
					SKIN:GetMeter(SKIN:GetVariable("MeterCurrentTime")):SetText(string.format("%.2d:%.2d", currentSeconds/60%60, currentSeconds%60))
				end
			end
			SKIN:Bang('!SetVariable', 'Length', nowPlaying_info.time.current / nowPlaying_info.time.total)
			oldSongInfo = nowPlaying_info.song
		else
			SKIN:Bang('!SetVariable', 'SongPlaying', 0)
			-- if nowPlaying_info.song.title == nil and nowPlaying_info.song.artist == nil then
			if nowPlaying_info.song.artist == nil or nowPlaying_info.time.total == 0 then
				SKIN:Bang('!SetVariable', 'GPMDPOpen', 0)
			end
		end
	end
end
