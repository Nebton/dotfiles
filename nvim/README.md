# Neovim Configuration Summary

This document outlines the most important plugins and keybindings configured in this Neovim setup.

## Leader Key

The leader key is set to **`<Space>`**. Many custom shortcuts use the leader key.

## Core Neovim & Basic Mappings

These are essential shortcuts for general Neovim usage within this configuration:

*   **Window Navigation:**
    *   `<C-h>`: Move focus to the left window
    *   `<C-l>`: Move focus to the right window
    *   `<C-j>`: Move focus to the lower window
    *   `<C-k>`: Move focus to the upper window
*   **Terminal:**
    *   `<C-\>` (Control + Backslash): Toggle floating terminal (`toggleterm.nvim`)
    *   `<Esc><Esc>` (in Terminal mode): Exit terminal mode
*   **Diagnostics:**
    *   `<leader>q`: Open diagnostic Quickfix list
    *   *(Diagnostics automatically show on hover)*
*   **Clipboard:**
    *   `<C-a><C-c>`: Copy the entire current file content to the system clipboard (requires `wl-copy` or similar).
*   **Search:**
    *   `<Esc>` (in Normal mode): Clear search highlighting (`nohlsearch`)

## Plugins Overview & Key Shortcuts

This configuration uses [`lazy.nvim`](https://github.com/folke/lazy.nvim) for plugin management. Key plugins and their associated shortcuts include:

### `folke/which-key.nvim`

*   **Function:** Displays available keybindings when you press `<leader>` and pause. Helps discover shortcuts.
*   **Keymap Groups Registered:**
    *   `<leader>c`: Code related actions
    *   `<leader>d`: Document related actions (LSP Document Symbols)
    *   `<leader>r`: Rename actions (LSP Rename)
    *   `<leader>s`: Search actions (Telescope)
    *   `<leader>w`: Workspace actions (LSP Workspace Symbols)
    *   `<leader>t`: Toggle actions (Inlay Hints)
    *   `<leader>h`: Git Hunk actions (requires gitsigns keymaps, potentially via commented-out section)

### `nvim-telescope/telescope.nvim`

*   **Function:** A highly extendable fuzzy finder.
*   **Key Shortcuts (Normal Mode):**
    *   `<leader>sf`: **[S]**earch **[F]**iles
    *   `<leader>sg`: **[S]**earch by **[G]**rep (live_grep)
    *   `<leader>sw`: **[S]**earch current **[W]**ord under cursor
    *   `<leader>sh`: **[S]**earch **[H]**elp tags
    *   `<leader>sk`: **[S]**earch **[K]**eymaps
    *   `<leader>sd`: **[S]**earch **[D]**iagnostics
    *   `<leader>sr`: **[S]**earch **[R]**esume last Telescope search
    *   `<leader>s.`: **[S]**earch Recent Files (oldfiles)
    *   `<leader>ss`: **[S]**earch **[S]**elect Telescope built-in pickers
    *   `<leader><leader>`: Search Buffers

### LSP (Language Server Protocol) Integration (`neovim/nvim-lspconfig`)

*   **Function:** Provides language intelligence features like go-to-definition, code actions, etc. Managed by `mason.nvim`.
*   **Key Shortcuts (Normal Mode, within LSP-supported files):**
    *   `gd`: **[G]**oto **[D]**efinition
    *   `gr`: **[G]**oto **[R]**eferences
    *   `gI`: **[G]**oto **[I]**mplementation
    *   `gD`: **[G]**oto **[D]**eclaration
    *   `<leader>D`: Show **[T]**ype **[D]**efinition
    *   `<leader>ds`: List **[D]**ocument **[S]**ymbols (via Telescope)
    *   `<leader>ws`: List **[W]**orkspace **[S]**ymbols (via Telescope)
    *   `<leader>rn`: **[R]**e**[n]**ame symbol
    *   `<leader>ca`: **[C]**ode **[A]**ction
    *   `<leader>th`: **[T]**oggle Inlay **[H]**ints (if supported by LSP)
    *   *(Hover over code to see diagnostics/signatures)*

### Autocompletion (`hrsh7th/nvim-cmp` with `L3MON4D3/LuaSnip`)

*   **Function:** Provides code completion suggestions and snippet expansion.
*   **Key Shortcuts (Insert Mode):**
    *   `<C-Space>`: Manually trigger completion
    *   `<C-j>`: Confirm selected completion item
    *   `<C-b>` / `<C-f>`: Scroll documentation window back/forward
    *   `<C-l>`: Jump forward in snippet placeholder (if available)
    *   `<C-h>`: Jump backward in snippet placeholder (if available)

### Formatting (`stevearc/conform.nvim`)

*   **Function:** Formats code using external tools (like `stylua`, `black`, `isort`, etc.).
*   **Key Shortcuts (Normal Mode):**
    *   `<leader>f`: **[F]**ormat the current buffer
    *   *(Also configured to format on save)*

### Git Integration (`lewis6991/gitsigns.nvim`)

*   **Function:** Shows git changes (added, modified, deleted lines) in the sign column.
*   **Key Shortcuts:** *(No explicit custom keymaps defined in this config, but standard ones might be available if `kickstart.plugins.gitsigns` is uncommented or through defaults. Check `:Telescope keymaps` or `which-key`)*

### File Explorer (`stevearc/oil.nvim`)

*   **Function:** A file explorer that edits the filesystem like a buffer.
*   **Key Shortcuts (Normal Mode):**
    *   `-`: Open Oil in the current directory (or parent, depending on context)
    *   *(Inside Oil buffer):* `g?` for help, `<CR>` to select/open, `<C-v>` for vsplit, `<C-h>` for split, `-` for parent dir, etc.

### Terminal Integration (`akinsho/toggleterm.nvim`)

*   **Function:** Provides easy access to toggleable terminal windows.
*   **Key Shortcuts (Normal Mode):**
    *   `<C-\>` (Control + Backslash): Toggle floating terminal.
    *   `<leader>g`: Toggle floating **[L]**azy**[g]**it terminal.

### Utility & UI Enhancements

*   **`echasnovski/mini.nvim`:**
    *   `mini.ai`: Provides improved text objects (`a`, `i`) for functions, arguments, etc. (e.g., `va)`, `ci'`).
    *   `mini.surround`: Easily add/delete/replace surrounding characters (e.g., `saiw)`, `sd'`, `sr)'`).
    *   `mini.statusline`: Provides the status line at the bottom.
*   **`folke/todo-comments.nvim`**: Highlights `TODO`, `FIXME`, `NOTE`, etc., in comments.
*   **`nvim-treesitter/nvim-treesitter`**: Provides advanced syntax highlighting and parsing, powering many other features.
*   **`github/copilot.vim` & `CopilotC-Nvim/CopilotChat.nvim`**: Integrates GitHub Copilot suggestions and chat.
    *   `<leader>co`: Open **[Co]**pilot Chat.
*   **`whatyouhide/vim-gotham` / `starrynight`**: Colorscheme (`starrynight` is activated).

## Finding More Keymaps

*   Press `<Space>` (leader) and wait for the `which-key` popup.
*   Use `<leader>sk` to search all keymaps with Telescope.
*   Run `:Telescope keymaps`

This README covers the most prominent features and shortcuts. Explore the configuration files (`init.lua` and potentially files in `lua/custom/plugins/` if enabled) for further details.
