--  cmd /c mklink AddOns.txt  ..\..\AddOns.txt






local logFile = "AddOns.log"
local linksMap, linksList = {}, {}

AddonsRoot = [[d:\WowStore\addons\]]
AddDev = [[d:\WowStore\addons\dev\]]
ServerRoot = [[d:\WowStore\addons\server\]]

local linkAddOns = {}
_G.linkAddOns = linkAddOns
function linkAddOns.addons(ver)  return  function(categ)  return linkAddOns.acateg(ver, categ)  end  end
function linkAddOns.server(ver, server)  return  function(list) linkAddOns.list(ServerRoot ..ver.."-"..server.."/", list) end  end
function linkAddOns.acateg(ver, categ)   return  function(list) linkAddOns.list(AddonsRoot ..ver.."/"..(categ and categ~="" and categ.."/" or ""), list) end  end



A548Tau = ServerRoot .. [[548\AddOns-Tau-orig-548\]]
A548Fs  = ServerRoot .. [[548\AddOns-Fs-orig-548\]]
A623    = AddonsRoot .. [[623/AddOns/]]
A623Fs  = ServerRoot .. [[623/AddOns-Fs-orig/]]
A715    = AddonsRoot .. [[715/]]
A715Fs  = ServerRoot .. [[server/715-Fstorm/]]
A735Fs  = ServerRoot .. [[server/735-Fstorm/]]

function linkAddOns.Adev(list)  linkAddOns.list(Adev, list)  end
function linkAddOns.A548(categ)  return  function(list) linkAddOns.list(A548 .. categ .."/", list) end  end
function linkAddOns.A735(categ)  return  function(list) linkAddOns.list(A735 .. categ .."/", list) end  end
function linkAddOns.A548Tau(list)  linkAddOns.list(A548Tau, list)  end
function linkAddOns.A548Fs(list)  linkAddOns.list(A548Fs, list)  end
function linkAddOns.A623(list)  linkAddOns.list(A623, list)  end
function linkAddOns.A623Fs(list)  linkAddOns.list(A623Fs, list)  end
function linkAddOns.A715(list)  linkAddOns.list(A715, list)  end
function linkAddOns.A715Fs(list)  linkAddOns.list(A715Fs, list)  end
function linkAddOns.A735Fs(list)  linkAddOns.list(A735Fs, list)  end



local function pause(msg)
	print()
	if  msg  then  print(msg)  end
	os.execute('pause')
	print()
end

local count = 0
local function printCount(...)
	print(...)
	count = count + 1
end

local function printPause()
	if  count < 40  then  return  end
	count = 0
	pause()
end



--[[
local function mklinkFile(from, to)
	if  1 == os.execute('IF EXIST "'.. from ..'" exit 1')  then
		printCount('     EXISTS: '.. from)
		return
	end
	
	printCount('  ++ mklink: '.. from)
	local cmdline = 'mklink "'.. from .. '" "'.. to ..'"'
	local res = os.execute(cmdline)
	if  res ~= 0  then  printCount('    \- FAILED:  '.. cmdline)  end
	printPause()
end
--]]


local function mklinkDir(from, to)
	if  1 == os.execute('IF EXIST "'.. from ..'" exit 1')  then
		printCount('     EXISTS: '.. from)
		return
	end
	
	printCount('  ++ mklink: '.. from ..'  =>  '.. to)
	local cmdline = 'mklink /j "'.. from .. '" "'.. to ..'" >> '.. logFile
	local res = os.execute(cmdline)
	if  res ~= 0  then  printCount('    \- FAILED:  '.. cmdline)  end
	printPause()
end

local function dellinkDir(from, to, nopause)
	if  1 ~= os.execute('IF EXIST "'.. from ..'" exit 1')  then
		printCount(' NOT EXISTS: '.. from)
		return
	end
	
	printCount('  -- rmdir:  '.. from ..'  =>  '.. to)
	local cmdline = 'rmdir "'.. from .. '"'
	local res = os.execute(cmdline)
	if  res ~= 0  then  printCount('    \- FAILED:  '.. cmdline)  end
	if  not nopause  then  printPause()  end
end

local function listLinks()
	-- Capturing command output based on:  https://www.gammon.com.au/scripts/doc.php?lua=os.execute
	-- get a temporary file name
	tmpfile = os.tmpname()
	if  tmpfile:sub(1,1) == '\\'  then  tmpfile = tmpfile:sub(2)  end
	tmpfile = "dir-".. tmpfile
	-- local tmpfile = io.tmpfile()
	-- dir /al = attribute:link - list only links / junctions (folder links on windows)
	local cmdline = 'dir /al > '.. tmpfile
	-- print('    '.. cmdline)
	local res = os.execute(cmdline)
	if  res ~= 0  then  printCount('    \- FAILED listing links:  '.. cmdline)  end

	-- Parse links (junctions)
	local prevList, prevMap = {}, {}
	for  line  in io.lines(tmpfile) do
		local from, to = string.match(line, "<JUNCTION>%s*(.*) %[(.*)%]")
		if  from  then
			if  not to  then
				printCount("Target unmatched:  ".. line)
				to = true
			end
			prevMap[from] = to
			prevList[#prevList+1] = from
		else
			-- printCount("Unmatched dir line:  ".. line)
		end
		printPause()
	end
	
	os.remove(tmpfile)
	return prevList, prevMap
end


local function tindexof(array, item)
	for  i= 1,#array	do
		if  array[i] == item  then  return i  end
	end
end

local function tremovevalue(array, item)
	local i= tindexof(array, item)
	return  i  and  table.remove(array, i)
end

local function setlinkDir(addon, rootFolder, subFolder)
	assert(type(addon) == 'string')
	local linkTo
	if  subFolder == true  then
		linkTo = rootFolder .. addon
	elseif  type(subFolder) == 'string'  then
		linkTo = rootFolder .. subFolder:gsub('/', '\\')
		if  linkTo:sub(-1) == '\\'  then  linkTo = linkTo .. addon  end
	elseif  subFolder  then
		error("Invalid addon location, subFolder must be string: ".. addon .." = ".. tostring(subFolder))
	end
	local prevTo = linksMap[addon]
	if  prevTo  then
		printCount("Addon  ".. addon .."  target overridden:  ".. prevTo .."  ->  ".. tostring(linkTo))
		printPause()
		tremovevalue(linksList, addon)
	end
	linksMap[addon] = linkTo
	if  linkTo  then  linksList[#linksList+1] = addon  end
end




function linkAddOns.str(rootFolder, list)
	rootFolder = rootFolder:gsub('/', '\\')
	for  line  in  list:gmatch('[^\n]+')  do
		--line = line:trim()
		local addon, subFolder = strsplit('=:', line, 2)
		addon, subFolder = addon:trim(), subFolder and subFolder:trim()
		
		if  subFolder == 'false'  or  subFolder == 'disabled'  then    -- or  subFolder == ''  then
			-- skip disabled
		elseif  addon == ''  or  addon:sub(1,2) == '--'  then
			-- skip empty and comment
		else
			if  subFolder == nil  or  subFolder == ''  or  subFolder == 'true'  or  subFolder == 'enabled'  then  subFolder = true  end
			setlinkDir(addon, rootFolder, subFolder)
		end
	end
end

function linkAddOns.arr(rootFolder, list)
	rootFolder = rootFolder:gsub('/', '\\')
	for  addon, subFolder  in  pairs(list)  do
		setlinkDir(addon, rootFolder, subFolder)
	end
end

function linkAddOns.list(rootFolder, list)
	if  type(list) == 'string'  then  return linkAddOns.str(rootFolder, list)
	elseif  type(list) == 'table'  then  return linkAddOns.arr(rootFolder, list)
	else  error("Expecting  list  to be a string or table")
	end
end



function linkAddOns.commitLinks()
	os.remove(logFile)
	
	-- Delete removed addons
	local prevList, prevMap = listLinks()
	for  i, addon  in  ipairs(prevList)  do
		if  not linksMap[addon]  then  dellinkDir(addon, prevMap[addon])  end
	end
	
	-- Relink moved addons
	for  i, addon  in  ipairs(linksList)  do
		local linkTo = linksMap[addon]
		local prevTo = prevMap[addon]
		if  prevTo  and  linkTo  and  strlower(prevTo) ~= strlower(linkTo)  then  dellinkDir(addon, prevTo, true) ; mklinkDir(addon, linkTo)  end
	end
	
	-- Link new addons
	for  i, addon  in  ipairs(linksList)  do
		local linkTo = linksMap[addon]
		if  linkTo  and  not prevMap[addon]  then  mklinkDir(addon, linkTo)  end
	end
	
	pause('Finished')
end



