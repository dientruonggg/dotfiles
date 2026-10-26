-- ~/.config/caelestia/hypr-user.lua

local vars = require("variables")
local laptop_mon = vars.laptopMonitor or "eDP-1"

-- Bật tự động điều hướng chuyển màn hình / workspace khi kích hoạt ứng dụng qua thông báo
hl.config({
    misc = {
        focus_on_activate = true,
    }
})

-- Ngăn Messenger PWA tự động cướp focus trong nền khi có tin nhắn mới (trừ khi người dùng click vào thông báo)
hl.window_rule({
    match = { class = "^(FFPWA-01M1RC47J0DJ20A84BX30FA5RG)$" },
    suppress_event = "activate",
})

-- Cấu hình cho YouTube PWA
hl.window_rule({
    match  = { initial_class = "^(FFPWA-01M1RA3EGMEHWAR449RF6QXRT2)$" },
    float  = true,
    size   = "1000 700",
    center = true,
})

-- ==========================================
-- Clamshell Mode (Gập nắp lap dùng màn ngoài)
-- ==========================================

-- Kiểm tra xem có màn hình ngoài nào đang kết nối không
local function has_external_monitor()
    local monitors = hl.get_monitors()
    for _, m in ipairs(monitors) do
        if m.name ~= laptop_mon then
            return true
        end
    end

    -- Kiểm tra dự phòng sysfs
    local ports = {
        "/sys/class/drm/card1-HDMI-A-1/status",
        "/sys/class/drm/card1-DP-1/status",
        "/sys/class/drm/card1-DP-2/status",
        "/sys/class/drm/card0-HDMI-A-1/status",
        "/sys/class/drm/card0-DP-1/status",
    }
    for _, port in ipairs(ports) do
        local f = io.open(port, "r")
        if f then
            local status = f:read("*l")
            f:close()
            if status == "connected" then
                return true
            end
        end
    end

    return false
end

-- Kiểm tra trạng thái nắp máy từ ACPI
local function is_lid_closed()
    local f = io.open("/proc/acpi/button/lid/LID/state", "r") or io.open("/proc/acpi/button/lid/LID0/state", "r")
    if f then
        local content = f:read("*a")
        f:close()
        return content:find("closed") ~= nil
    end
    return false
end

-- Quản lý systemd-inhibit:
-- Luôn chặn systemd tự động sleep khi gập máy (để Hyprland tự kiểm soát hành vi gập nắp)
local function update_clamshell_inhibit()
    hl.exec_cmd("systemctl --user is-active --quiet hyprland-inhibit-lid || systemd-run --user --unit=hyprland-inhibit-lid systemd-inhibit --what=handle-lid-switch --who=Hyprland --why='Prevent sleep on lid close' sleep infinity")
end

-- Khởi chạy fcitx5, discord và cập nhật trạng thái inhibitor khi Hyprland start
hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5 -d") 
    hl.exec_cmd("discord")
    update_clamshell_inhibit()
end)

-- Cập nhật trạng thái inhibitor ngay lập tức (cho trường hợp reload cấu hình)
update_clamshell_inhibit()

-- Khi gập nắp laptop (Lid Closed)
hl.bind("switch:on:Lid Switch", function()
    if has_external_monitor() then
        -- Có màn ngoài: tắt màn hình laptop để chỉ dùng duy nhất màn ngoài
        hl.monitor({
            output   = laptop_mon,
            disabled = true,
        })
        -- Reload lại Caelestia shell để giao diện bars và các panel cập nhật hoàn hảo sang màn hình ngoài
        hl.exec_cmd("sleep 0.3; qs -c caelestia kill; sleep 0.2; caelestia shell -d")
    else
        -- Không có màn ngoài (1 màn laptop duy nhất):
        -- Khóa màn hình và tắt đèn màn hình bằng DPMS, máy KHÔNG sleep (vẫn chạy ngầm)
        hl.dispatch(hl.dsp.global("caelestia:lock"))
        hl.dispatch(hl.dsp.dpms("off", laptop_mon))
    end
end, { locked = true })

-- Khi mở nắp laptop (Lid Opened)
hl.bind("switch:off:Lid Switch", function()
    if has_external_monitor() then
        -- Bật lại màn hình laptop khi có màn ngoài
        hl.monitor({
            output   = laptop_mon,
            mode     = "preferred",
            position = "0x0",
            scale    = 1,
            disabled = false,
        })
        -- Reload lại Caelestia shell để thanh bars hiển thị lại đầy đủ trên cả hai màn hình
        hl.exec_cmd("sleep 0.3; qs -c caelestia kill; sleep 0.2; caelestia shell -d")
    else
        -- Chỉ có màn laptop: bật lại màn hình bằng DPMS
        -- TUYỆT ĐỐI KHÔNG kill Caelestia shell ở đây để tránh sập lockscreen (gây lỗi đỏ)!
        hl.dispatch(hl.dsp.dpms("on", laptop_mon))
    end
end, { locked = true })

-- Áp dụng trạng thái ngay nếu nắp laptop đang gập sẵn và có màn ngoài
if is_lid_closed() and has_external_monitor() then
    hl.monitor({
        output   = laptop_mon,
        disabled = true,
    })
end

-- Khi cắm thêm màn hình ngoài
hl.on("monitor.added", function()
    update_clamshell_inhibit()
    if is_lid_closed() and has_external_monitor() then
        hl.monitor({
            output   = laptop_mon,
            disabled = true,
        })
        hl.exec_cmd("sleep 0.3; qs -c caelestia kill; sleep 0.2; caelestia shell -d")
    end
end)

-- Khi rút màn hình ngoài
hl.on("monitor.removed", function()
    update_clamshell_inhibit()
    if not has_external_monitor() then
        if is_lid_closed() then
            -- Nắp đang gập mà rút màn ngoài -> đảm bảo bật lại output laptop (tránh 0 monitors), khóa và tắt DPMS
            hl.monitor({
                output   = laptop_mon,
                mode     = "preferred",
                position = "0x0",
                scale    = 1,
                disabled = false,
            })
            hl.dispatch(hl.dsp.global("caelestia:lock"))
            hl.dispatch(hl.dsp.dpms("off", laptop_mon))
        else
            -- Bật lại màn hình laptop nếu đang tắt
            hl.monitor({
                output   = laptop_mon,
                mode     = "preferred",
                position = "0x0",
                scale    = 1,
                disabled = false,
            })
            hl.exec_cmd("sleep 0.3; qs -c caelestia kill; sleep 0.2; caelestia shell -d")
        end
    end
end)

-- Phím tắt tiện ích reload nhanh thanh bars Caelestia shell nếu cần: SUPER + ALT + B
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd("qs -c caelestia kill; sleep 0.2; caelestia shell -d"))

-- Phím tắt chuyển đổi chế độ màn hình (Duplicate, Extend, Second only, Laptop only) tương tự Win + P
hl.bind("SUPER + P", hl.dsp.exec_cmd("display-switcher"))
hl.bind("XF86Display", hl.dsp.exec_cmd("display-switcher"))

-- ==========================================
-- Sửa lỗi & Nâng cấp Alt + Tab thông minh
-- ==========================================
local function smart_window_cycle(forward)
    local a = hl.get_active_window()
    if not a then return end

    if a.group and a.group.size and a.group.size > 1 then
        -- Đang trong Group: Chuyển tab trong group
        local next_idx
        if forward then
            next_idx = (a.group.current_index % a.group.size) + 1
        else
            next_idx = a.group.current_index - 1
            if next_idx < 1 then next_idx = a.group.size end
        end
        hl.dispatch(hl.dsp.group.active({ index = next_idx }))
    else
        -- Cửa sổ thường: Chuyển cửa sổ tiếp theo và đưa lên trên cùng
        hl.dispatch(hl.dsp.window.cycle_next({ next = forward }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end

-- Alt + Tab: Chuyển cửa sổ / tab tới
hl.bind("ALT + TAB", function()
    smart_window_cycle(true)
end, { repeating = true })

-- Shift + Alt + Tab: Chuyển cửa sổ / tab lùi
hl.bind("SHIFT + ALT + TAB", function()
    smart_window_cycle(false)
end, { repeating = true })

-- Super + Tab: Bật menu chọn cửa sổ toàn hệ thống (Window Switcher Fuzzel UI)
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("window-switcher"))

-- =========================================================
-- Cấu hình Thanh Taskbar Caelestia luôn ghim cố định (Stick / Persistent Bar)
-- =========================================================
local function ensure_bar_persistent()
    local shell_json_path = os.getenv("HOME") .. "/.config/caelestia/shell.json"
    local f = io.open(shell_json_path, "r")
    if not f then return end
    local content = f:read("*a")
    f:close()

    if content:find('"persistent"%s*:%s*false') then
        local new_content = content:gsub('("persistent"%s*:%s*)false', '%1true')
        local out = io.open(shell_json_path, "w")
        if out then
            out:write(new_content)
            out:close()
            -- Reload shell để áp dụng ghim cố định thanh bar ngay lập tức
            hl.exec_cmd("sleep 0.2; caelestia shell -r")
        end
    end
end

ensure_bar_persistent()

