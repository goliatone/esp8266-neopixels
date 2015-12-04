local Config = {}

-- Default values
Config.SSID = {}
Config.SSID["<SSID>"] = "<YOUR_PASSWORD>"

Config.HOST = "192.168.1.4"
Config.PORT = 80

local config_exists = file.open("config.lc")
file.close("config.lc")

if config_exists then
    -- TODO: Table merge: http://goo.gl/O5b84h
    Config = dofile("config.lc")
end

return Config
