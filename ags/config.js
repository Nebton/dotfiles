import { NotificationPopups } from "./notificationPopups.js"
const hyprland = await Service.import("hyprland")
const audio = await Service.import("audio")
const battery = await Service.import("battery")
const network = await Service.import("network")
const systemtray = await Service.import('systemtray')
const powerProfiles = await Service.import('powerprofiles')

// Top-level widgets
function Workspaces() {
    const activeId = hyprland.active.workspace.bind("id")
    const workspaces = hyprland.bind("workspaces")
        .as(ws => ws
            .filter(({ id }) => id > 0)
            .sort((a, b) => a.id - b.id)
            .map(({ id }) => Widget.Button({
                on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
                child: Widget.Label(`${id}`),
                class_name: activeId.as(i => `${i === id ? "focused" : ""}`),
            }))
        )
    return Widget.Box({
        class_name: "workspaces",
        children: workspaces,
    })
}

function Clock() {
    //Two time formats 
    const timeFormat = Variable("", {
        poll: [1000, 'date "+%H:%M 󰥔"'],
    })
    const dateFormat = Variable("", {
        poll: [1000, 'date "+%A, %B %d, %Y 📆"'],
    })

    let showingTime = true;
    return Widget.Box({
        class_name: "clock",
        children: [
            Widget.Button({
                child: Widget.Label({
                    class_name: `clock`,
                    label: timeFormat.bind()
                }),
                on_clicked: self => {
                    if (showingTime) {
                        self.set_label(dateFormat.getValue());
                    } else {
                        self.set_label(timeFormat.getValue());
                    }
                    dateFormat.bind();
                    showingTime = !showingTime
                },
                on_middle_click: () => Utils.execAsync(`bash -c "pkill gsimplecal || gsimplecal"`).catch(error => {
                    if (error) {
                        Utils.notify(`Error: ${error}`);
                    }
                }
                ),
                on_hover: self => {
                    self.cursor = "pointer";
                }

            }),
        ],
    })
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
    const SysTrayItem = item => {
        const icon = network.wifi.bind("icon_name")
        return Widget.Button({
            className: 'SystemTray',
            child: Widget.Box({
                children: [
                    Widget.Icon({ icon })
                ]
            }),
            onPrimaryClick: (self, event) => item.openMenu(event),
            onMiddleClick: () => Utils.execAsync(`bash -c "killall nm-connection-editor || nm-connection-editor"`).catch(error => Utils.notify(`Error : ${error}`)),

        });
    };
    const sysTray = Widget.Box({
        children: systemtray.bind('items').as(i => i.map(SysTrayItem)),
    })

    return sysTray
}



function BatteryStatus() {

    const progress = Widget.CircularProgress({
        className: "Battery",
        rounded: false,
        inverted: false,
        startAt: 0.75,
        value: battery.bind('percent').as(p => p / 100),
        child: Widget.Icon({
            icon: battery.bind(`icon_name`),
            css: `font-size: 14px`,
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
    const cpuUsage = Variable(0, {
        poll: [2000, ['bash', '-c', `LC_ALL=C top -bn1 -p0 | awk '/^%Cpu/{print 100-$8}'`]],
    });
    return Widget.Button({
        class_name: "processor",
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
    const ramUsage = Variable(0, {
        poll: [2000, ['bash', '-c', `free -m | awk '/Mem:/ { printf("%.2f", $3/$2 * 100.0) }'`]],
    });
    return Widget.Button({
        class_name: "processor",
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
