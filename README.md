# 🌌 dientruonggg's Dotfiles

Personal Arch Linux dotfiles tailored for **Hyprland** with **Caelestia Shell** (Quickshell).

---

## 🖥️ System Overview
- **OS**: Arch Linux
- **WM / Compositor**: Hyprland (with Wayland support & Caelestia dotfiles)
- **Desktop Shell & Bar**: Quickshell (`caelestia`)
- **Shells**: Fish & Bash (with Starship prompt)
- **Terminals**: Kitty, Foot
- **Launcher**: Caelestia Launcher (Quickshell) / Fuzzel
- **Input Method**: Fcitx5 (Lotus Telex/VNI)
- **Browser Flags**: Wayland & ANGLE GPU-accelerated Chromium (`chromium-flags.conf`)
- **Code Editors**: Neovim, Zed, Micro

---

## 📁 Repository Structure
```text
dotfiles/
├── .config/
│   ├── btop/               # System monitor theme & config
│   ├── caelestia/          # Caelestia Hyprland user configs & layout
│   ├── cava/               # Audio visualizer config
│   ├── fastfetch/          # Neofetch replacement (presets & Daft Punk ASCII art)
│   ├── fcitx5/             # Vietnamese input method settings
│   ├── fish/               # Fish shell config, completions & custom functions
│   ├── foot/               # Fast, lightweight Wayland terminal
│   ├── fuzzel/             # Application launcher fallback
│   ├── hypr/               # Hyprland core configuration & keybinds
│   ├── kitty/              # Kitty terminal configuration
│   ├── micro/              # Micro terminal text editor
│   ├── nvim/               # Neovim theme & plugin settings
│   ├── quickshell/         # Caelestia Quickshell desktop shell source
│   ├── spicetify/          # Spotify Caelestia custom theme
│   ├── uwsm/               # Universal Wayland Session Manager
│   ├── zed/                # Zed editor settings & keymaps
│   ├── chromium-flags.conf # Hardware accelerated Chromium flags
│   ├── code-flags.conf     # VS Code Wayland flags
│   ├── codium-flags.conf   # VSCodium Wayland flags
│   └── starship.toml       # Cross-shell prompt theme
├── .local/
│   └── bin/                # Custom utility scripts (display-switcher, todo, notify, etc.)
├── .bashrc                 # Bash interactive configuration
├── .bash_profile           # Bash login profile
├── .gitignore              # Strict ignore rules (preventing credential & system leaks)
├── sync.sh                 # Automatic sync & push script
└── README.md
```

---

## 🚀 Usage

### 1. Update & Push to GitHub
When you make changes to your local system configs and want to update this repository:
```bash
cd ~/dotfiles
./sync.sh push "Your commit message"
```

### 2. Export / Sync from Local System
To just copy the latest local configs into the repository without committing/pushing:
```bash
./sync.sh export
```

### 3. Restore / Apply on a New Machine
To apply these dotfiles onto a new setup:
```bash
git clone https://github.com/dientruonggg/dotfiles.git ~/dotfiles
cd ~/dotfiles
./sync.sh install
```

---

## 🔒 Security & Secrets Note
To prevent accidental leakage of sensitive credentials, the repository automatically ignores:
- `~/.bashrc.local` (Private environment variables for Bash)
- `~/.config/fish/conf.d/*secrets*.fish` (Private environment variables for Fish)
- Git credentials, API keys, tokens, session caches, and database files.
