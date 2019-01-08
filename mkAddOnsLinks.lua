--  cmd /c mklink AddOns.txt  ..\..\AddOns.txt

Adev = [[d:/Games/WowSync/dev/]]
A548 = [[d:/Games/WowSync/548/addons/]]
A548Tau = [[d:/Games/WowSync/548/Iface/AddOns-Tau-orig/]]
A548Fs = [[d:/Games/WowSync/548/Iface/AddOns-Fs-orig/]]
A623 = [[d:/Games/WowSync/623/Iface/AddOns/]]
A623Fs = [[d:/Games/WowSync/623/Iface/AddOns-Fs-orig/]]
A715 = [[d:/Games/WowSync/715/Iface/AddOns/]]
A715Fs = [[d:/Games/WowSync/715/Iface/AddOns-Fs-orig/]]
A735 = [[d:/Games/WowSync/735/addons/]]
A735Fs = [[d:/Games/WowSync/735/Iface/AddOns-Fs-orig/]]

linkAddOns = {}
function linkAddOns.A548(categ)  return  function(list) linkAddOnsList(A548 .. categ .."/", list) end  end
function linkAddOns.A735(categ)  return  function(list) linkAddOnsList(A735 .. categ .."/", list) end  end
function linkAddOns.Adev(list)  linkAddOnsList(Adev, list)  end
function linkAddOns.A548Tau(list)  linkAddOnsList(A548Tau, list)  end
function linkAddOns.A548Fs(list)  linkAddOnsList(A548Fs, list)  end
function linkAddOns.A623(list)  linkAddOnsList(A623, list)  end
function linkAddOns.A623Fs(list)  linkAddOnsList(A623Fs, list)  end
function linkAddOns.A715(list)  linkAddOnsList(A715, list)  end
function linkAddOns.A715Fs(list)  linkAddOnsList(A715Fs, list)  end
--function linkAddOns.A735(list)  linkAddOnsList(A735, list)  end
function linkAddOns.A735Fs(list)  linkAddOnsList(A735Fs, list)  end


function pause(msg)
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
	if  count < 20  then  return  end
	count = 0
	pause()
end




function mklinkDir(from, to)
	if  1 == os.execute('IF EXIST "'.. from ..'" exit 1')  then
		--printCount('exists:  '.. from)
		return
	end
	
	printCount('  ++ link: '.. from)
	local cmdline = 'mklink /j "'.. from .. '" "'.. to ..'"'
	local res = os.execute(cmdline)
	if  res ~= 0  then  printCount('    \- FAILED:  '.. cmdline)  end
	printPause()
end

function mklinkFile(from, to)
	if  1 == os.execute('IF EXIST "'.. from ..'" exit 1')  then
		--printCount('exists:  '.. from)
		return
	end
	
	printCount('  ++ link: '.. from)
	local cmdline = 'mklink "'.. from .. '" "'.. to ..'"'
	local res = os.execute(cmdline)
	if  res ~= 0  then  printCount('    \- FAILED:  '.. cmdline)  end
	printPause()
end

function dellinkDir(from)
	if  1 ~= os.execute('IF EXIST "'.. from ..'" exit 1')  then
		return
	end
	
	printCount('  -- delete: '.. from)
	local cmdline = 'rmdir "'.. from .. '"'
	local res = os.execute(cmdline)
	if  res ~= 0  then  printCount('    \- FAILED:  '.. cmdline)  end
	printPause()
end




function linkAddOnsMap(list)
	for  addon, where  in  pairs(list)  do
		mklinkDir(addon, where .. addon)
	end
end

function linkAddOnsList(where, list)
	for  addon, enabled  in  pairs(list)  do
		if  enabled  then
		  mklinkDir(addon, where .. addon)
		else
		  dellinkDir(addon)
		end
	end
end

function linkAddOnsTo(where)
	return  function (list)  linkAddOnsList(list, where)  end
end


