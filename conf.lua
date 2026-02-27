-- configures the game before main runs
function love.conf(t)
    t.window.title = "pong"
    t.window.width = 1920
    t.window.height = 1080
    t.window.resizable = false
    t.window.vsync = 1
end