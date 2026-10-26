return {
    -- Đổi phím tắt đóng cửa sổ thành SUPER + W
    kbCloseWindow = "SUPER + W",
    -- Đổi phím mở browser thành SUPER + Q
    kbBrowser = "SUPER + Q",
    -- Đổi trình duyệt mặc định thành Chromium
    browser = "chromium",
    -- Vô hiệu hóa SUPER + R (Todo workspace mặc định)
    kbTodoWs = "",
    -- Đổi trình quản lý tệp thành Nautilus và gán phím tắt SUPER + E
    fileExplorer = "nautilus",
    kbFileExplorer = "SUPER + E",
    -- Đổi terminal mặc định
    terminal = "kitty",

    -- Hệ thống chưa có hibernate -> dùng suspend thay thế cho suspend-then-hibernate
    sleepGestureCmd = "systemctl suspend",

    -- Màn hình laptop cho chế độ Clamshell mode
    laptopMonitor = "eDP-1",

    -- Chuyển phím ghim cửa sổ sang SUPER + ALT + P để nhường SUPER + P cho menu màn hình
    kbPinWindow = "SUPER + ALT + P",

    -- Vô hiệu hóa Alt+Tab mặc định bị lỗi để dùng smart Alt+Tab mới
    kbWindowCycleNext = "",
    kbWindowCyclePrev = "",

    -- Tối ưu cho Intel UHD Graphics 620 (Comet Lake-U i3)
    blurPasses        = 1,
    blurSize          = 5,
    shadowRenderPower = 2,
    shadowRange       = 10,

    -- No offset / viền sát mép màn hình (zero gaps)
    workspaceGaps       = 0,
    windowGapsIn        = 0,
    windowGapsOut       = 0,
    singleWindowGapsOut = 0,
}

