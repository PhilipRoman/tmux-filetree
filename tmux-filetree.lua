local delay = 1.0
local command = os.getenv("TMUX_FILETREE_COMMAND") or "tree -C -L 1 $(readlink -e %s)"

local function err(...)
	io.stderr:write(table.concat {...}, "\n")
	os.exit(1)
end

-- parse command-line arguments
arg = arg or {...}
do
	local i = 1
	while i <= #arg do
		if arg[i] == '-c' then
			i = i + 1
			command = arg[i] or err("Expected COMMAND after -c")
		elseif arg[i]:match '^%-d.+$' then
			delay = tonumber(arg[i]:match '^%-d([0-9.]+)$') or err("Expected '-dNUMBER', got: ", arg[i])
		elseif arg[i] == '-d' then
			i = i + 1
			delay = tonumber(arg[i] and arg[i]:match '^([0-9.]+)$') or err("Expected '-d NUMBER', got: '-d ", arg[i] or '', "'")
		elseif arg[i] == '-h' then
			print "Usage: tmux-filetree [-d NUMBER]"
			print "  -d NUMBER         Delay between updates in seconds"
			print "  -c COMMAND        Command to execute to view files, %s is the target directory"
			print "  -h                Show this help message"
			print "See manual page tmux-filetree(1) for more information"
			os.exit(0)
		end
		i = i + 1
	end
end

-- returns the PID of current process in active
-- tmux pane (or 0 if no pane is active)
local function activepid()
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

-- returns [a symlink to] the working directory of the process with given pid
local function workingdir(pid)
	return '/proc/'..pid..'/cwd'
end

-- returns the desired output for files in given directory
local function listfiles(dir)
	local cmdline = command:gsub("%%s", dir or '.')
	local p = io.popen(cmdline)
	local lines = {}
	for line in p:lines() do
		lines[#lines + 1] = line
	end
	p:close()
	return table.concat(lines, "\n")
end

-- read the terminal control byte sequence once
-- (it may vary for each terminal)
-- write it to stdout to clear terminal
local TPUT_CLEAR = io.popen'tput reset; tput cup 0 0':read 'a'


local oldhash = ""
local function fileschanged(dir)
	-- this isn't used for output; it is a faster way of checking if any files have changed
	local procfilehash = io.popen('echo ' .. dir .. '/**')
	local filehash = procfilehash:read 'a'
	procfilehash:close()
	local changed = filehash ~= oldhash
	oldhash = filehash
	return changed
end

while true do
	local dir = workingdir(activepid())
	-- only clear terminal when text has changed
	if fileschanged(dir) then
		io.write(TPUT_CLEAR)
		print(listfiles(dir))
		os.execute('sleep ' .. delay)
	end
end
