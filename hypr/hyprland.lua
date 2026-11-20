-- Hyprland 0.57+ Lua config, ported from hyprland.conf (hyprlang support was removed in 0.57).
-- The old hyprland.conf is kept for reference only; Hyprland no longer reads it.

local mainMod = "SUPER"
local home = os.getenv("HOME")

-- Rewritten by ~/Scripts/random-wallpaper.sh; keep this on one line.
local active_border = "rgba(a50000ee)"

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
-- hl.monitor({ output = "eDP-1", disabled = true })
-- hl.monitor({ output = "DP-2", mode = "1680x1050", position = "1920x0", scale = 1 })

-----------------
---- ENV --------
-----------------
hl.env("WLR_DRM_NO_ATOMIC", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("SSH_AUTH_SOCK", (os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000") .. "/ssh-agent.socket")

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd(home .. "/Scripts/random-wallpaper.sh")
    hl.exec_cmd("wl-paste -t text --watch clipman store --max-items 1000 --histpath=\"$HOME/.local/share/clipman-primary.json\" --no-persist")
    hl.exec_cmd("pkill dunst")
    hl.exec_cmd(home .. "/.local/bin/ags")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("brave", { workspace = "2 silent" })
    hl.exec_cmd("keepassxc", { workspace = "9 silent" })
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        allow_tearing = false,
        border_size   = 2,
        col = {
            active_border   = active_border,
            inactive_border = "rgba(ffffffaa)",
        },
        gaps_in  = 5,
        gaps_out = 3,
        layout   = "dwindle",
    },

    decoration = {
        blur = {
            enabled = false,
            passes  = 1,
            size    = 3,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        force_split    = 2,
        preserve_split = true,
    },

    gestures = {
        workspace_swipe_distance = 200,
    },

    input = {
        kb_layout          = "us,fr",
        kb_options         = "compose:ralt,caps:escape,grp:win_space_toggle",
        follow_mouse       = 1,
        natural_scroll     = false,
        numlock_by_default = true,
        sensitivity        = 0,
        touchpad = {
            natural_scroll = true,
        },
    },

    misc = {
        force_default_wallpaper = 0,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",          enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",           enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 6,  bezier = "default" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4,  bezier = "default", style = "slidevert" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------
---- KEYBINDINGS ----
---------------------
local function exec(cmd) return hl.dsp.exec_cmd(cmd) end
local function bind(keys, dsp, opts) return hl.bind(keys, dsp, opts) end
local function M(k) return mainMod .. " + " .. k end
local function MS(k) return mainMod .. " + SHIFT + " .. k end

local screenshot_region = "grim -g \"$(slurp -w 0)\" - | wl-copy -t image/png && wl-paste > ~/Screenshots/$(zenity --entry --text=\"Enter screenshot name:\" --title=\"Save Screenshot\" --entry-text=\"Screenshot.png\") | dunstify \"Screenshot of the region taken\" -t 1000"
local screenshot_full   = "grim - | wl-copy -t image/png && wl-paste > ~/Screenshots/$(zenity --entry --text=\"Enter screenshot name:\" --title=\"Save Screenshot\" --entry-text=\"Screenshot.png\") | dunstify \"Screenshot of whole screen taken\" -t 1000"

bind(M("RETURN"),  exec("kitty"))
bind(M("B"),       exec("brave"))
bind(M("C"),       hl.dsp.window.close())
bind(MS("Q"),      hl.dsp.exit())
bind(M("E"),       exec("nautilus"))
bind(M("V"),       exec("clipman pick --tool=wofi"))
bind(MS("V"),      exec("clipman clear --all"))
bind(M("R"),       exec(home .. "/Scripts/random-wallpaper.sh"))
bind(MS("R"),      exec("pkill rofi || rofi -show run -show-icons"))
bind(MS("C"),      exec("pkill rofi || rofi -show ssh -show-icons"))
bind(M("ALT + L"), exec("swaylock"))
bind(M("I"),       hl.dsp.window.pseudo())
bind(M("T"),       hl.dsp.layout("togglesplit"))
bind(M("F"),       hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind(MS("F"),      hl.dsp.window.fullscreen({ mode = "maximized" }))
bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
bind(M("H"),       hl.dsp.window.cycle_next({ next = false }))
bind(M("J"),       hl.dsp.window.cycle_next())

-- Special workspaces
for key, name in pairs({ S = "magic", M = "music", D = "socials", O = "work", Y = "pip" }) do
    bind(M(key),  hl.dsp.workspace.toggle_special(name))
    bind(MS(key), hl.dsp.window.move({ workspace = "special:" .. name }))
end

bind(M("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
bind(M("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))
bind(M("Tab"),        hl.dsp.focus({ workspace = "previous" }))

-- Hex: forward press and release through the GlobalShortcuts portal.
bind("ALT + space", hl.dsp.global("anomaly.hex:dictation-ALT-space"))
bind(MS("space"),   hl.dsp.window.float({ action = "toggle" }))

bind("Print",         exec(screenshot_region))
bind("SHIFT + Print", exec(screenshot_full))
bind(M("G"),          exec("toipe"))
bind(M("W"),          exec(home .. "/.local/bin/ags"))
bind(MS("W"),         exec(home .. "/.local/bin/ags -q"))
bind(M("L"),          exec("hyprlock"))
bind(MS("L"),         exec("systemctl suspend && hyprlock"))
bind(M("minus"),      hl.dsp.focus({ workspace = 1 }))
bind(MS("minus"),     hl.dsp.window.move({ workspace = 11 }))
bind(M("bracketright"), exec("hyprctl keyword monitor HDMI-A-1,preferred,auto,auto,mirror,eDP-1"))
bind(M("bracketleft"),  exec("hyprctl keyword monitor HDMI-A-1,preferred,auto,auto"))

-- Workspaces 1-10 (key 0 = workspace 10)
for i = 1, 10 do
    local key = tostring(i % 10)
    bind(M(key),  hl.dsp.focus({ workspace = i }))
    bind(MS(key), hl.dsp.window.move({ workspace = i }))
end

bind(M("N"), exec("obsidian"))
bind(M("P"), hl.dsp.window.pin())

-- Media / hardware keys (repeat while held)
local rep = { repeating = true }
bind("XF86AudioRaiseVolume",  exec("wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+"), rep)
bind("XF86AudioLowerVolume",  exec("wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%-"), rep)
bind("XF86AudioMute",         exec("wpctl set-mute @DEFAULT_SINK@ toggle"), rep)
bind("XF86AudioMicMute",      exec("wpctl set-mute @DEFAULT_SOURCE@ toggle"), rep)
bind("XF86MonBrightnessUp",   exec("brillo -u 150000 -A 5"), rep)
bind("XF86MonBrightnessDown", exec("brillo -u 150000 -U 5"), rep)
bind("XF86AudioPlay",         exec("playerctl play-pause"), rep)
bind("XF86AudioNext",         exec("playerctl next"), rep)
bind("XF86AudioPrev",         exec("playerctl previous"), rep)
bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"), rep)
bind("XF86MonBrightnessUp",   exec("brightnessctl set +5%"), rep)

-- Mouse move/resize
bind(M("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
bind(M("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Passthrough submap: SUPER+Escape toggles all binds off/on
bind(M("Escape"), hl.dsp.submap("passthru"))
hl.define_submap("passthru", function()
    bind(M("Escape"), hl.dsp.submap("reset"))
end)

-------------------------
---- WORKSPACE RULES ----
-------------------------
hl.workspace_rule({ workspace = "11", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "special:magic",   on_created_empty = "kitty", gaps_out = 50 })
hl.workspace_rule({ workspace = "special:socials", on_created_empty = "brave --new-window discordapp.com/app web.whatsapp.com web.telegram.org", gaps_out = 25 })
hl.workspace_rule({ workspace = "special:work",    on_created_empty = "brave --new-window mail.google.com/mail/u/1/ | slack", gaps_out = 25 })
hl.workspace_rule({ workspace = "special:music",   on_created_empty = "spotify", gaps_out = 50 })
hl.workspace_rule({ workspace = "special:pip",     gaps_in = 0, gaps_out = 0, no_shadow = true })

----------------------
---- WINDOW RULES ----
----------------------
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    move  = "monitor_w*0.67 monitor_h*0.72",
    size  = "monitor_w*0.33 monitor_h*0.28",
    workspace = "special:pip",
})
hl.window_rule({ name = "rofi-float", match = { title = "^(rofi - drun)$" }, float = true })
hl.window_rule({ name = "kitty-opacity", match = { class = "^(kitty)$" }, opacity = "0.8 override 0.8 override 1 override" })
hl.window_rule({ name = "burp-max", match = { class = "^(install4j-burp-StartBurp)$" }, max_size = "1920 1040" })
