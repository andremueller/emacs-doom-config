# Doom Emacs Configuration

Personal [Doom Emacs](https://github.com/doomemacs/doomemacs) configuration using XDG directories (`~/.config/emacs` and `~/.config/doom`).

## Overview

- **Completion**: `vertico` + `corfu` (`+orderless`)
- **Editor & UI**: `evil` (`+everywhere`), `doom-one` theme, `treemacs`, `tabs`, `workspaces`, `vc-gutter`, terminal mouse support (`xterm-mouse-mode`)
- **Tools & Terminal**: `magit`, `lsp` (`+eglot`), `debugger`, `docker`, `ghostel`
- **Languages**: C/C++ (`+lsp`), Go (`+lsp`), Python, JavaScript, Web, Shell, Emacs Lisp, Org (`~/org/`), Markdown, JSON, YAML

## Prerequisites

### Required

- **GNU Emacs** 29.1+ (30.x recommended)
- **Git** 2.23+
- **ripgrep** (`rg`) 11.0+
- **fd** (`fd-find`) 7.3+

#### Ubuntu / Debian

```bash
sudo apt update
sudo apt install emacs git ripgrep fd-find
```

#### macOS (Homebrew)

```bash
brew install git ripgrep fd
brew install --cask emacs-app
```

### Optional (Module Dependencies)

Install language servers and tools for the enabled modules as needed:

- **C / C++ (`cc +lsp`)**: `clangd`
- **Go (`go +lsp`)**: `go` and `gopls` (`go install golang.org/x/tools/gopls@latest`)
- **Docker**: `docker` CLI

### WSL2 / Windows Terminal

For `emacs -nw`, `config.el` connects directly to the Windows text clipboard
using `clip.exe` and `powershell.exe`. WSL interop must be enabled and both
commands must be on Emacs's `PATH`; no Linux clipboard utility is required.
Unicode, multiline text, and Windows CRLF line endings are handled explicitly.

- In Evil normal mode, `yy` copies a line and `p` pastes from the clipboard.
- The explicit `"+` clipboard register also works (`"+y` and `"+p`).
- Restart Emacs after changing this configuration; `doom sync` is not needed.

Terminal completion uses GitHub's NonGNU ELPA mirror for `corfu-terminal` and
`popon`. Their recipes must use separate `:local-repo` directories because they
live on different branches of the same upstream repository. Run `doom sync`
after changing these recipes.

## Installation

1. **Back up any existing Emacs configuration**:

   ```bash
   mv ~/.emacs.d ~/.emacs.d.bak 2>/dev/null || true
   mv ~/.config/emacs ~/.config/emacs.bak 2>/dev/null || true
   mv ~/.config/doom ~/.config/doom.bak 2>/dev/null || true
   ```

2. **Clone Doom Emacs**:

   ```bash
   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
   ```

3. **Clone this configuration into `~/.config/doom`**:

   ```bash
   git clone https://github.com/andremueller/emacs-doom-config.git ~/.config/doom
   mkdir -p ~/.config/doom/snippets
   ```

4. **Install Doom and sync packages**:

   ```bash
   ~/.config/emacs/bin/doom install
   ```

5. **Add Doom's `bin` directory to your `PATH`** (e.g., in `~/.bashrc` or `~/.zshrc`):

   ```bash
   export PATH="$HOME/.config/emacs/bin:$PATH"
   ```

6. **Install icon fonts** (inside Emacs):

   ```text
   M-x nerd-icons-install-fonts
   ```

7. **Verify the environment**:

   ```bash
   doom doctor
   ```

## Updating & Maintenance

| Command | Description |
| --- | --- |
| `doom sync` | Synchronize config after editing `init.el` or `packages.el` |
| `doom upgrade` | Update Doom Emacs and pinned packages |
| `doom doctor` | Diagnose missing dependencies or configuration issues |
| `doom env` | Regenerate the environment variables file |

> Changes to `config.el` take effect after restarting Emacs (or evaluating the buffer) without running `doom sync`.

## Structure

- `init.el` — Enabled Doom modules and module flags
- `config.el` — Personal settings, theme, Org directory, and keybindings
- `packages.el` — Additional third-party package declarations
