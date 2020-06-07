-- returns the PID of current process in active
-- tmux pane (or 0 if no pane is active)
local function shellpid()
	local p = io.popen("tmux list-panes -F '#{pane_active} #{pane_pid}'")
	for line in p:lines() do
		if line:match '^1' then
			p:close()
			return tonumber(line:match '^1 ([0-9]+)$') or 0
		end
	end
	p:close()
	return 0
end

-- returns the working directory of the process with given pid
local function procdir(pid)
	local p = io.popen("readlink -e /proc/"..pid.."/cwd")
	local result = p:read()
	p:close()
	return result
end

local command = os.getenv("TMUX_FILETREE_COMMAND") or "tree -C -L 1 %s"

-- returns the desired output for files in given directory
local function ls(dir)
	local cmdline = command:gsub("%%s", dir or '.')
	local p = io.popen(cmdline)
	local lines = {}
	for line in p:lines() do
		lines[#lines + 1] = line
--[[
		if #lines > ((os.getenv("LINES") or 12) - 2) then
			lines[#lines + 1] = "..."
			break
		end ]]
	end
	p:close()
	return table.concat(lines, "\n")
end

local oldtext = ""

while true do
	local dir = procdir(shellpid())
	local text = ls(dir)
	-- only clear terminal when text has changed
	if text ~= oldtext then
		oldtext = text
		os.execute 'tput reset; tput cup 0 0'
		print(text)
		os.execute 'sleep 0.2'
	end
end
