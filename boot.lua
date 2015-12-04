-- Create a global variable holding our app
app = dofile("app.lua")
app.before_setup()

-- Create a global variable holding config
config = dofile("config.lua")

dofile("setup.lua").run(function()
    print("Setup complete")
    app.start()
end)
