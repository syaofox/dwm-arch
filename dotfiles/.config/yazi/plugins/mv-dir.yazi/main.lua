local get_data = ya.sync(function()
	local tab = cx.active
	local urls = {}
	local is_cut = false

	for _, u in pairs(tab.selected) do
		urls[#urls + 1] = tostring(u)
	end

	if #urls == 0 then
		for i, url in pairs(cx.yanked) do
			urls[i] = tostring(url)
		end
		is_cut = cx.yanked.is_cut
	end

	if #urls == 0 and tab.current.hovered then
		urls[1] = tostring(tab.current.hovered.url)
	end

	return { urls = urls, cwd = tostring(tab.current.cwd), is_cut = is_cut }
end)

local function notify(title, content, level, timeout)
	ya.notify {
		title = title,
		content = content,
		level = level or "info",
		timeout = timeout or 3,
	}
end

local function dir_exists(path)
	local result = Command("test"):arg("-d"):arg(path):output()
	return result and result.status.success
end

local function find_available_name(cwd, base_name)
	local name = base_name
	local suffix = 2
	while dir_exists(cwd .. "/" .. name) do
		name = base_name .. "-" .. suffix
		suffix = suffix + 1
	end
	return name
end

local function prompt_name()
	local result, event = ya.input {
		pos = { "center", w = 50 },
		title = "Move to new directory",
		value = "",
	}
	if event ~= 1 then
		return nil
	end
	local name = result:gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		notify("mv-dir", "No directory name entered", "warn", 3)
		return nil
	end
	return name
end

return {
	entry = function(self, job)
		local data = get_data()
		if #data.urls == 0 then
			notify("mv-dir", "No files to move", "warn", 3)
			return
		end

		ya.emit("escape", { visual = true })

		local dir_name = prompt_name()
		if not dir_name then
			return
		end

		dir_name = find_available_name(data.cwd, dir_name)
		local dir_path = data.cwd .. "/" .. dir_name

		local mkdir = Command("mkdir"):arg("-p"):arg(dir_path):output()
		if not mkdir or not mkdir.status.success then
			notify("mv-dir", "Failed to create directory: " .. dir_name, "error", 5)
			return
		end

		local cmd = Command("mv")
		for _, url in ipairs(data.urls) do
			cmd = cmd:arg(url)
		end
		cmd = cmd:arg(dir_path .. "/")
		local result, err = cmd:output()
		if not result or not result.status.success then
			notify("mv-dir", "Failed to move files: " .. (err or "unknown"), "error", 5)
			return
		end

		if data.is_cut then
			ya.emit("unyank", {})
		end

		notify("mv-dir", ("Moved %d file(s) to '%s'"):format(#data.urls, dir_name), "info", 3)
		ya.emit("cd", {})
	end,
}
