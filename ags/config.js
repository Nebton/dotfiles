import GLib from "gi://GLib"
import { NotificationPopups } from "./notificationPopups.js"
import { createBatteryAlert, isLowBattery } from "./batteryAlert.js"
const hyprland = await Service.import("hyprland")
const audio = await Service.import("audio")
const battery = await Service.import("battery")
const systemtray = await Service.import('systemtray')
const powerProfiles = await Service.import('powerprofiles')

const checkBattery = createBatteryAlert(percent => {
    Utils.notify({
        appName: "Battery",
        summary: "Low battery",
        body: `Battery is at ${percent}%. Connect your charger.`,
        iconName: "battery-caution-symbolic",
        urgency: "critical",
        timeout: 0,
    }).catch(logError);
});
battery.connect("changed", () => checkBattery(battery));
checkBattery(battery);


// Top-level widgets
function Workspaces() {
    let signature = null;
    const updateActive = box => box.children.forEach(button => {
        button.toggleClassName("focused",
            button.attribute.workspaceId === hyprland.active.workspace.id);
    });
    const refresh = box => {
        const ids = hyprland.workspaces
            .filter(({ id }) => id > 0)
            .map(({ id }) => id)
            .sort((a, b) => a - b);
        const next = ids.join(",");
        // Window-title events also notify workspaces. Keep existing buttons
        // unless the actual workspace list changes to avoid redraw flicker.
        if (next === signature)
            return;
        signature = next;
        box.children = ids.map(id => Widget.Button({
            attribute: { workspaceId: id },
            tooltip_text: `Workspace ${id}`,
            on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
            child: Widget.Label(`${id}`),
        }));
        updateActive(box);
    };
    return Widget.Box({
        class_name: "workspaces",
        setup: box => box
            .hook(hyprland, refresh, "notify::workspaces")
            .hook(hyprland.active.workspace, updateActive, "notify::id"),
    });
}

function Clock() {
    const showDate = Variable(false);
    const now = Variable(GLib.DateTime.new_now_local(), {
        poll: [1000, () => GLib.DateTime.new_now_local()],
    });
    return Widget.Button({
        class_name: "clock",
        child: Widget.Label({
            label: Utils.merge([now.bind(), showDate.bind()], (date, expanded) =>
                date.format(expanded ? "%a, %d %b %Y" : "%H:%M")),
        }),
        tooltip_text: "Click for date · Middle click for calendar",
        on_clicked: () => showDate.value = !showDate.value,
        on_middle_click: () => Utils.execAsync([
            "bash", "-c", "pkill -x gsimplecal || gsimplecal",
        ]).catch(logError),
        setup: self => self.connect("destroy", () => { now.dispose(); showDate.dispose(); }),
    });
}


const truncateText = (text, maxLength) => {
    return text.length > maxLength ? text.slice(0, maxLength) + "..." : text;
};


function Volume() {
    const icons = {
        67: "audio-volume-high",
        34: "audio-volume-medium",
        1: "audio-volume-low",
        0: "audio-volume-muted",
    }


    function getIcon() {
        const icon = audio.speaker.is_muted ? 0 : [67, 34, 1, 0].find(
            threshold => threshold <= audio.speaker.volume * 100)

        return `${icons[icon]}`
    }

    const icon = Utils.watch(getIcon(), audio.speaker, getIcon)


    const volume = Utils.watch(audio.speaker.is_muted
        ? "is_muted"
        : Math.floor(audio.speaker.volume * 100).toString(),
        audio, "speaker-changed", () => {
            return audio.speaker.is_muted
                ? "MUTED"
                : Math.floor(audio.speaker.volume * 100).toString();
        }
    );

    function adjustVolume(increase) {
        if (audio.speaker.is_muted) {
            audio.speaker.is_muted = false; // Unmute if muted
        }
        let newVolume = audio.speaker.volume + (increase ? 0.02 : -0.02); // Increase or decrease volume by 2%
        newVolume = Math.max(0, Math.min(1, newVolume)); // Clamp between 0 and 1
        audio.speaker.volume = newVolume;
    }

    function toggleMute() {
        audio.speaker.is_muted = !audio.speaker.is_muted;
    }

    return Widget.Button({
        class_name: "volume",
        on_clicked: toggleMute,
        on_scroll_up: () => adjustVolume(true),
        on_scroll_down: () => adjustVolume(false),
        on_hover: self => self.cursor = "pointer",
        child: Widget.Box({
            class_name: "volume",
            children: [
                Widget.Icon({
                    icon: icon,
                    css: "margin-right: 0.25em;",
                }),
                Widget.Label({ label: volume })
            ],
        }),
    });
}

function SystemTray() {
    /** @param {import('types/service/systemtray').TrayItem} item */
    const SysTrayItem = item => Widget.Button({
        className: 'SystemTray',
        child: Widget.Icon({ icon: item.bind('icon') }),
        tooltipMarkup: item.bind('tooltip_markup'),
        // Several StatusNotifier apps expose a menu but no Activate method.
        onPrimaryClick: (_, event) => item.openMenu(event),
        onSecondaryClick: (_, event) => item.openMenu(event),
    });
    const sysTray = Widget.Box({
        children: systemtray.bind('items').as(i => i.map(SysTrayItem)),
    })

    return sysTray
}



function BatteryStatus() {

    const progress = Widget.CircularProgress({
        className: "Battery",
        setup: self => self.hook(battery, () => {
            self.toggleClassName("low-battery", isLowBattery(battery));
            self.tooltip_text = `Battery: ${battery.percent}%${battery.charging ? " (charging)" : ""}`;
        }),
        rounded: false,
        inverted: false,
        startAt: 0.75,
        value: battery.bind('percent').as(p => p / 100),
        child: Widget.Icon({
            icon: battery.bind(`icon_name`),
            css: `font-size: 12px`,
        }),
    })

    return Widget.Button({
        child: progress,
        on_clicked: self => {
            switch (powerProfiles.active_profile) {
                case 'balanced':
                    powerProfiles.active_profile = 'performance';
                    Utils.notify("Power profile set to Performance");
                    break;
                default:
                    powerProfiles.active_profile = 'balanced';
                    Utils.notify("Power profile set to Balanced");
                    break;
            };
            self.cursor = "pointer"
        },

    })


}


function Processor() {
    const readCpu = () => {
        // guest/guest_nice are already included in user/nice counters.
        const ticks = Utils.readFile("/proc/stat").split("\n")[0]
            .trim().split(/\s+/).slice(1, 9).map(Number);
        return { total: ticks.reduce((sum, n) => sum + n, 0), idle: ticks[3] + ticks[4] };
    };
    let previous = readCpu();
    const cpuUsage = Variable(0, {
        poll: [3000, () => {
            const current = readCpu();
            const elapsed = current.total - previous.total;
            const idle = current.idle - previous.idle;
            previous = current;
            return elapsed > 0 ? Math.max(0, Math.min(100, 100 * (1 - idle / elapsed))) : 0;
        }],
    });
    return Widget.Button({
        class_name: "processor",
        setup: self => self.connect("destroy", () => cpuUsage.dispose()),
        child:
            Widget.Box({
                children: [
                    Widget.Label({
                        css: "margin-right: 0.5em;",
                        label: '󰍛'
                    }),
                    Widget.Label({
                        label: cpuUsage.bind().transform(usage => `${Math.ceil(usage)}%`)
                    })
                ]
            }),
        on_clicked: () => Utils.execAsync(`bash -c "pkill htop || kitty htop"`),
        on_hover: self => self.cursor = 'pointer'

    })
}

function Memory() {
    const readMemory = () => {
        const info = Object.fromEntries(Utils.readFile("/proc/meminfo")
            .trim().split("\n").map(line => {
                const [key, value] = line.split(":");
                return [key, Number.parseInt(value, 10)];
            }));
        return 100 * (1 - info.MemAvailable / info.MemTotal);
    };
    const ramUsage = Variable(readMemory(), { poll: [5000, readMemory] });
    return Widget.Button({
        class_name: "memory",
        setup: self => self.connect("destroy", () => ramUsage.dispose()),
        child:
            Widget.Box({
                children: [

                    Widget.Label({
                        css: "margin-right: 0.5em;",
                        label: '󰻠',
                    }),
                    Widget.Label({
                        label: ramUsage.bind().transform(usage => `${Math.ceil(usage)}%`)
                    }),

                ]

            }),


        on_clicked: () => Utils.execAsync(`bash -c "pkill htop || kitty htop"`),
        on_hover: self => self.cursor = 'pointer'


    })
}

function PowerMenu() {
    return Widget.Box({
        class_name: "power-menu",
        children: [
            Widget.Button({
                child: Widget.Icon("system-shutdown-symbolic"),
                on_clicked: () => Utils.exec("shutdown now"),
            }),
            Widget.Button({
                child: Widget.Icon("system-reboot-symbolic"),
                on_clicked: () => Utils.exec("reboot"),
            }),
            Widget.Button({
                child: Widget.Icon("system-log-out-symbolic"),
                on_clicked: () => hyprland.messageAsync("dispatch exit"),
            }),
            Widget.Button({
                child: Widget.Icon("system-lock-screen-symbolic"),
                on_clicked: () => Utils.exec("swaylock"),
            }),
        ],
    })
}

function AppLauncherButton() {
    return Widget.Box({
        class_name: "app-launcher",
        child: Widget.Button({
            child: Widget.Icon({
                icon: "view-app-grid-symbolic",
                size: 24,
            }),
            on_clicked: () => {
                Utils.execAsync(`bash -c "pkill -x rofi || rofi -show drun -show-icons "`).catch(error => {
                    if (error) {
                        Utils.notify(`Error: ${error}`);
                    }
                })
            },
            on_hover: self => {
                self.cursor = "pointer";
            }
        })
    });
}
function Left() {
    return Widget.Box({
        spacing: 8,
        children: [
            AppLauncherButton(),
            Workspaces(),
        ],
    })
}

function Center() {
    return Widget.Box({
        spacing: 8,
        children: [
            Clock(),
        ],
    })
}

function Right() {
    return Widget.Box({
        hpack: 'end',
        spacing: 6,
        children: [
            Volume(),
            Processor(),
            Memory(),
            SystemTray(),
            BatteryStatus(),
        ],
    })
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar - ${monitor} `,
        class_name: "bar",
        monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Left(),
            center_widget: Center(),
            end_widget: Right(),
        }),
    })
}

App.config({
    style: App.configDir + "/style.css",
    windows: [
        NotificationPopups(),
        Bar(),
    ],
})


export { }
