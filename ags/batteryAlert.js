export const LOW_BATTERY_PERCENT = 20;
const RESET_PERCENT = 22;

export function isLowBattery(battery) {
    return battery.available && Number.isFinite(battery.percent)
        && battery.percent >= 0 && battery.percent < LOW_BATTERY_PERCENT
        && !battery.charging && !battery.charged;
}

// One warning per episode, with hysteresis around the 20% threshold.
export function createBatteryAlert(notify) {
    let warned = false;
    return battery => {
        if (!battery.available || !Number.isFinite(battery.percent) || battery.percent < 0)
            return;
        if (battery.charging || battery.charged || battery.percent >= RESET_PERCENT) {
            warned = false;
            return;
        }
        if (isLowBattery(battery) && !warned) {
            warned = true;
            notify(Math.floor(battery.percent));
        }
    };
}
