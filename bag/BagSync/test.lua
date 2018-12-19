print('"'.. tostring(string.match("Mitem:14","item:([^:]+)")) ..'"')
print('"'.. tostring(string.match("Mitem:14","item:([^:]+)[:$]")) ..'"')
print('"'.. tostring(string.match("Mitem:14:","item:([^:]+)[:$]")) ..'"')
print('"'.. tostring(string.match("Mitem:14:","item:([^:]+):$")) ..'"')
print('"'.. tostring(strsub('abcd', 8)) ..'"')
print('"', tostring(strsub('abcd', 2)), '"')

for  i,s  in pairs({ nil, -1, '', '0', 'a' })  do
	print(tostring(s), '->', tostring(string.match(s, '0')))
end

for  i,rest  in ipairs({ ',0', ',1,', '2,3', ',4,a' })  do
	local a,b = rest:match("^,(%d+)(.*)")
	print(rest, '->', tostring(a), tostring(b) )
end




