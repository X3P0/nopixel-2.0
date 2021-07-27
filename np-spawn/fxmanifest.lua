fx_version 'cerulean'
games {'gta5'}

-- dependency "np-base"
-- dependency "raid_clothes"

ui_page "html/index.html"
files({
	"html/*",
	"html/images/*",
	"html/css/*",
	"html/webfonts/*",
	"html/js/*"
})

client_script '@np-lib/client/cl_rpc.lua'
client_script "@np-errorlog/client/cl_errorlog.lua"
client_script "client/*"

shared_script "shared/sh_spawn.lua" 
server_script "server/*"
server_scripts {
  '@np-lib/server/sv_sql.lua',
}
