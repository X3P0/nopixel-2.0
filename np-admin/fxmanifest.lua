fx_version 'cerulean'
games {'gta5'}

-- dependency "np-base"
-- dependency "ghmattimysql"

client_script "@np-errorlog/client/cl_errorlog.lua"
client_script "@warmenu/warmenu.lua"


client_script "@np-infinity/client/classes/blip.lua"
client_script "@np-lib/client/cl_infinity.lua"
server_script "@np-lib/server/sv_infinity.lua"



ui_page "html/index.html"

files({
    "html/index.html",
    "html/script.js",
    "html/styles.css"
})

server_script "shared/sh_admin.lua"
server_script "shared/sh_commands.lua"
server_script "shared/sh_ranks.lua"

client_script "shared/sh_admin.lua"

client_script "client/cl_menu.lua"
client_script "client/cl_blips.lua"

client_script "shared/sh_commands.lua"
client_script "shared/sh_ranks.lua"

server_script "server/sv_db.lua"
server_script "server/sv_admin.lua"

client_script "client/cl_admin.lua"
client_script "client/cl_noclip.lua"
