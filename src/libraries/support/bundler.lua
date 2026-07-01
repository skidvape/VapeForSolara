local bundler = {
    game = {}
}

local cloneref = cloneref or function(obj) return obj end
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/skidvape/VapeCompiled/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end

	return (func or readfile)(path)
end

local function downloadFolder(path, merge) -- automatically goes through the support and grabs the file required
    if not isfolder(path) then
        makefolder(path)
    end

    local suc, res = pcall(function()
		return game:HttpGet('https://api.github.com/repos/skidvape/VapeCompiled/contents/'..path:gsub('newvape/', '')..'?ref='..readfile('newvape/profiles/commit.txt'), true)
	end)

    if not suc or res == '404: Not Found' then
		error(res)
	end

	local tbl = {}
	for _, v in ipairs(httpService:JSONDecode(res)) do -- claude said ipairs should work, im sorry i don't have a working exec rn what am i supposed to do?? (ill test later)
		if v.type == 'dir' then
			if merge then
				for i, v in pairs(downloadFolder(path..'/'..v.name)) do
					tbl[i] = v
				end
			else
				tbl[v.name] = downloadFolder(path..'/'..v.name)
			end
		elseif v.type == 'file' and v.name:find('%.lua$') then
			tbl[v.name:gsub('%.lua$', '')] = loadstring(downloadFile(path..'/'..v.name))()
		end
	end

	return tbl
end

function bundler.Load(game: string)
    if not isfolder('newvape/libraries/support/'..game) then
        makefolder('newvape/libraries/support/'..game)
    end

    bundler.game = downloadFolder('newvape/libraries/support/'..game)
end

return bundler
