local LED_PIN = 2 -- GPIO 2
local BRIGHTNESS = 0.2 -- NeoPixels are BRIGHT.

NO_PIXELS = 12
colours = {}
colours["red"] = 0
colours["green"] = 0
colours["blue"] = 0

--
function create_colour(red, green, blue)
     -- takes the colours and makes single value for writing to the LEDs
     local colour = string.char(green * BRIGHTNESS, red * BRIGHTNESS, blue * BRIGHTNESS)
     return colour
end

function set_led_colour(colours, pixels)
    if colours == nil then return print("set_led_colour: undefined colours", colours) end
    if colours.red == nil or colours.green == nil or colours.blue == nil then
        return print("set_led_colour: undefined color component", colours)
    end
     -- takes the colour values and writes that to the number of pixels
     -- assmues a table colours{"red":val, "green":val, "blue":val}
     ws2812.write(LED_PIN, create_colour(colours["red"], colours["green"], colours["blue"]):rep(pixels))
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

function Server.handler(conn)
    print("Server handler setup")
    conn:on("receive", function(client, payload)

        print(payload)

        local head = ""
        local body = ""
        colours = {}
        colours["red"] = 0
        colours["green"] = 0
        colours["blue"] = 0

        if (string.sub(payload, 1, 4) == "POST") then
            head = head .. "HTTP/1.1 200 OK\r\n"
            head = head .. "Content-Type: application/json\r\n"
            -- now we find the RGB components. Going to do this simply
            -- by ripping them out with a find statement
            for c, v in pairs(colours) do
                local match = c .. "=(%d*)"
                print(c, match, string.find(payload, match))
                _, _, colours[c] = string.find(payload, match)
                -- put in a catch here incase it goes nil
            end
            print(colours)

            set_led_colour(colours, NO_PIXELS)

            -- send the JSON back to confirm
            -- body = body .. "{\"r\":" .. colours["red"] .. ", "
            -- body = body .. "\"g\":" .. colours["green"] .. ", "
            -- body = body .. "\"b\":" .. colours["blue"] .. "}"
        else
            head = head .. "HTTP/1.1 500 Server Error\r\n"
            body = body .. "Please ensure you use a POST method"
        end

        body = body .. "\r\n" -- just tidy up the end of the file
        head = head .. "Content-Length: " .. string.len(body) .. "\r\n\r\n"

        --print(head .. body)
        client:send(head..body)
     end)

     conn:on("sent", function(client)
          client:close()
          collectgarbage()
     end)
end

return App
