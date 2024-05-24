local mod_gui = require("mod-gui")

local function add_button(player)
    -- Check if player is valid
    if not player then
        return
    end

    -- Add the button for the given player if not exists
    local button_flow = mod_gui.get_button_flow(player)
    if not button_flow.taunt then
        button_flow.add {
            type = "sprite-button",
            name = "taunt",
            sprite = "taunt-icon",
            style = mod_gui.button_style
        }
    end
end

script.on_init(function()
    -- Add the button for every player
    for _, player in pairs(game.players) do
        add_button(player)
    end
end)

script.on_configuration_changed(function()
    -- Add the button for every player
    for _, player in pairs(game.players) do
        add_button(player)
    end
end)

script.on_event(defines.events.on_player_created, function(e)
    -- Add the button for the player that was just created
    local player = game.players[e.player_index]
    add_button(player)
end)

script.on_event(defines.events.on_gui_click, function(e)
    -- Check if our button was pressed
    if e.element.name == "taunt" then
        -- Get some variables to work with
        local player = game.players[e.player_index]
        local surface = player.surface
        local prop = {
            type = "unit",
            force = "enemy"
        }

        -- Validity check
        if not player or not surface or not player.character then
            game.print("Trying to taunt enemies but failed (due to invalid character, surface or player)")
            return
        end

        -- Get all the enemies on the surface
        local enemies = surface.find_entities_filtered(prop)

        if enemies and #enemies > 0 then
            -- Have all enemies attack the player that pressed the button
            local prop = {
                type = defines.command.attack,
                target = player.character
            }
            for _, enemy in pairs(enemies) do
                enemy.set_command(prop)
            end

            -- Inform the player(s)
            local name = "you"
            if #game.players > 1 then
                name = player.name
            end
            game.print(#enemies .. " enemies heard the taunt and are preparing to attack " .. player.name)
        else
            -- No enemies on this surface
            game.print("No enemies present on this world")
        end
    end
end)
