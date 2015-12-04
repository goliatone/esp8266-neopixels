local LED_PIN = 2 -- GPIO 2
local BRIGHTNESS = 6 -- NeoPixels are BRIGHT.

NO_PIXELS = 31
colours = {}
colours["red"] = 0
colours["green"] = 0
colours["blue"] = 0
colours["brightness"] = 0.5

--
function create_colour(red, green, blue, brightness)
    brightness = brightness and brightness or BRIGHTNESS
    brightness = brightness / 10
     -- takes the colours and makes single value for writing to the LEDs
     return string.char(green * brightness, red * brightness, blue * brightness)
end

function set_led_colour(colours, pixels)
    if colours == nil then return print("set_led_colour: undefined colours", colours) end
    if colours.red == nil or colours.green == nil or colours.blue == nil then
        return print("set_led_colour: undefined color component", colours)
    end
     -- takes the colour values and writes that to the number of pixels
     -- assmues a table colours{"red":val, "green":val, "blue":val}
     local colour = create_colour(colours["red"], colours["green"], colours["blue"], colours["brightness"]):rep(pixels)
     ws2812.write(LED_PIN, colour)
end

local App = {}

print("Application module required")

function App.start()
    print("App: start")
    Server.setup()
end

function App.before_setup()
    print("App: before setup")
    gpio.mode(0, gpio.OUTPUT)
    gpio.write(0, gpio.LOW)

    set_led_colour(colours, NO_PIXELS)
end

function rPrint(s, l, i) -- recursive Print (structure, limit, indent)
	l = (l) or 100; i = i or "";	-- default item limit, indent string
	if (l<1) then print "ERROR: Item limit reached."; return l-1 end;
	local ts = type(s);
	if (ts ~= "table") then print (i,ts,s); return l-1 end
	print (i,ts);           -- print "table"
	for k,v in pairs(s) do  -- print "[KEY] VALUE"
		l = rPrint(v, l, i.."\t["..tostring(k).."]");
		if (l < 0) then break end
	end
	return l
end

Server = {}

function Server.setup()

    if server ~= nil then
        server.close()
    end

    print("Setting up server")
    print("----- CURL COMMAND -----")
    print("curl 'http://"..wifi.sta.getip().."' --data 'red=120&green=123&blue=234' --compressed")
    print("------------------------")

    server = net.createServer(net.TCP)
    server:listen(config.PORT, Server.handler)
end

function sendHeader(conn)
     conn:send("HTTP/1.1 200 OK\r\n")
     conn:send("Access-Control-Allow-Origin: *\r\n")
     conn:send("Content-Type: application/json; charset=utf-8\r\n")
     conn:send("Server:NodeMCU\r\n")
     conn:send("Connection: close\r\n\r\n")
end

function Server.handler(conn)
    print("Server handler setup")
    -- conn:send('HTTP/1.1 200 OK\r\nAccess-Control-Allow-Origin: *\r\nAccess-Control-Allow-Methods", "PUT, POST, GET\r\nServer: ESP8266-1\r\n\n')
    conn:on("receive", function(client, payload)

        print(payload)

        local head = ""
        local body = ""
        colours = {}
        colours["red"] = 0
        colours["green"] = 0
        colours["blue"] = 0
        colours["brightness"] = BRIGHTNESS

        if (string.sub(payload, 1, 4) == "POST") then
            sendHeader(client)
            -- now we find the RGB components. Going to do this simply
            -- by ripping them out with a find statement
            for c, v in pairs(colours) do
                local match = c .. "=(%d*)"
                _, _, colours[c] = string.find(payload, match)
                -- put in a catch here incase it goes nil
            end
            rPrint(colours)

            set_led_colour(colours, NO_PIXELS)

            -- send the JSON back to confirm
            body = body .. cjson.encode(colours)
        else
            client:send("HTTP/1.1 500 Server Error\r\n")
            body = body .. "{\"message\": \"Please ensure you use a POST method}\""
        end

        client:send("Content-Length: " .. string.len(body) .. "\r\n\r\n")

        body = body .. "\r\n" -- just tidy up the end of the file
        --print(head .. body)
        client:send(body)
     end)

     conn:on("sent", function(client)
          client:close()
          collectgarbage()
     end)
end

return App
