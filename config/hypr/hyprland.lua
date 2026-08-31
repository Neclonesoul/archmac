-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "thunar"
local home = os.getenv("HOME")
local menu = "qs -c archmac-galaxy ipc call launcher toggle"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function ()
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
-- end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")



-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "scrolling",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 0.94,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.94,

        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 5,
            passes    = 2,
            vibrancy  = 0.1696,
            new_optimizations = true,
            xray = false,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })

hl.animation({ leaf = "windows",       enabled = true, speed = 4.8, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.4, spring = "easy", style = "popin 94%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.8, bezier = "easeOutQuint", style = "popin 94%" })

hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2.8, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 4.0, bezier = "quick" })

hl.animation({ leaf = "layers",        enabled = true, speed = 4.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4.0, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.5, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 3.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.5, bezier = "almostLinear" })

hl.animation({ leaf = "workspaces",    enabled = true, speed = 4.2, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 4.2, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4.2, bezier = "easeOutQuint", style = "slide" })

hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({

    scrolling = {
        -- ARCHMAC scrolling layout
        --
        -- 0.60 gives a focused window useful working width on the
        -- MacBookPro9,2 1280x800 panel while retaining spatial context.
        column_width = 0.60,

        -- Bring newly focused columns completely into view.
        focus_fit_method = 1,
        follow_focus = true,
        follow_min_visible = 0.40,

        -- Natural horizontal tape.
        direction = "right",

        -- Useful width presets:
        -- 1/3, half, 60%, 2/3 and fullscreen-width.
        explicit_column_widths = "0.333, 0.5, 0.6, 0.667, 1.0",

        wrap_focus = true,
        wrap_swapcol = true,
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
    natural_scroll = true,
    tap_to_click = true,
    tap_and_drag = true,
    disable_while_typing = true,
    clickfinger_behavior = true,
    scroll_factor = 0.85,
},
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("qs -c archmac-galaxy ipc call dashboard toggle"))
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("qs -c archmac-galaxy ipc call overview toggle"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("qalculate-gtk"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move tiled windows with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + CTRL + " .. key,      hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Keyboard backlight
hl.bind("XF86KbdBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -d 'smc::kbd_backlight' set 10%+"),
    { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -d 'smc::kbd_backlight' set 10%-"),
    { locked = true, repeating = true })

-- ARCHMAC Fancy / Performance toggle
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd(home .. "/.local/bin/mac-mode"))

-- Lock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("qs -c archmac-galaxy ipc call session toggle"))

-- Screenshots
hl.bind(mainMod .. " + SHIFT + 3",
    hl.dsp.exec_cmd(home .. "/.local/bin/mac-screenshot full"))

hl.bind(mainMod .. " + SHIFT + 4",
    hl.dsp.exec_cmd(home .. "/.local/bin/mac-screenshot area"))

-- Clipboard history
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.on("hyprland.start", function ()

hl.exec_cmd(home .. "/.local/bin/archmac-shell start")





-- Scrolling navigation
--
-- Super + , / .          focus previous / next column
-- Super + Shift + , / .  move column left / right

hl.bind(mainMod .. " + comma", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + period", hl.dsp.layout("focus r"))

hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.exec_cmd("hyprpaper")
 hl.exec_cmd("nm-applet")
 hl.exec_cmd("blueman-applet")
  hl.exec_cmd("hypridle")
hl.exec_cmd(home .. "/.local/bin/archmac-cliphist")
end)

----------------------
-- ARCHMAC MODE BINDS


-- ARCHMAC v1.1 layout toggle
--
-- Super + G:
-- scrolling <-> dwindle
hl.bind(
    mainMod .. " + G",
    hl.dsp.exec_cmd(home .. "/.local/bin/archmac-layout-toggle")
)


----------------------

-- Fancy <-> Performance
hl.bind("SUPER + F12",
    hl.dsp.exec_cmd(home .. "/.local/bin/mac-mode"))

-- Explicit battery mode
hl.bind("SUPER + SHIFT + F12",
    hl.dsp.exec_cmd(home .. "/.local/bin/mac-battery"))

-- Explicit Fancy restore
hl.bind("SUPER + CTRL + F12",
    hl.dsp.exec_cmd(home .. "/.local/bin/mac-fancy"))

--------------------------
-- ARCHMAC LAYER POLISH
--------------------------

hl.layer_rule({
    name = "archmac-waybar-blur",
    match = { namespace = "waybar" },
    blur = true,
})

hl.layer_rule({
    name = "archmac-wofi-blur",
    match = { namespace = "wofi" },
    blur = true,
})

hl.layer_rule({
    name = "archmac-mako-blur",
    match = { namespace = "mako" },
    blur = true,
})
