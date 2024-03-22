fx_version 'cerulean'
game 'gta5'
ui_page "ui/index.html"
author 'sw1ndle'
description 'h2o_hud'
version '1.0'
files {
  "ui/assets/css/*.css",
  'ui/assets/css/*.ttf',
	'ui/assets/css/*.woff',
	'ui/assets/css/*.woff2',
	'ui/assets/css/*.eot',
	'ui/assets/css/*.svg',
  'ui/assets/fonts/*.otf',
  "ui/assets/img/seatbelt.png",
  "ui/assets/img/seatbelt-on.png",
  "ui/*.html",
  "ui/assets/img/*.png",
  "ui/assets/js/gauge.min.js",
  "ui/assets/js/hud.js",
  "ui/assets/js/loading-bar.js",
  'stream/*'
}

client_scripts{ 
  "@vrp/client/Tunnel.lua",
  "@vrp/client/Proxy.lua",
  "config.lua",
  "client/client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "server/server.lua"
}
exports {
    'set_hud_vis'
}