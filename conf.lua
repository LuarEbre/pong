-- configures the game before main runs
function love.conf(t)
    t.window.title = "pong"
    t.window.width = 1000
    t.window.height = 800
    t.window.resizable = false
    t.window.vsync = 1
end