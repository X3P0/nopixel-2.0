fx_version 'cerulean'
games {'gta5'}

-- dependency "np-base"
-- dependency "ghmattimysql"


client_script "@np-errorlog/client/cl_errorlog.lua"

client_script "client/cl_storage.lua"


exports {
	'tryGet',
	'remove',
	'set'
} 