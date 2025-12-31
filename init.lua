-- =============================================================================
--  BOOTSTRAP LAZY.NVIM (Plugin Manager)
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
--  GENERAL SETTINGS
-- =============================================================================
local opt = vim.opt

-- Indentation
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.autoindent = true
opt.smartindent = true

-- UI Configuration
opt.number = true
opt.showmatch = true
opt.scrolloff = 5
opt.laststatus = 2
opt.termguicolors = true
opt.background = "dark"

-- Safe colorscheme loading
pcall(vim.cmd.colorscheme, "retrobox")

-- OS-Agnostic Shell Configuration
if vim.fn.has("win32") == 1 then
    vim.opt.shell = "powershell"
else
    vim.opt.shell = "/bin/bash" 
end

-- Search
opt.hlsearch = true
opt.incsearch = true

-- Backspace & Windows
opt.backspace = { "indent", "eol", "start" }
opt.equalalways = false
opt.mouse = "a"

-- =============================================================================
--  PLUGINS
-- =============================================================================
require("lazy").setup({
    -- 1. Telescope (Fuzzy Finder)
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        end
    },

    -- 2. LSP Configuration (Using new Native API)
    -- We still install nvim-lspconfig as it provides the *default configs* -- (cmd paths, root patterns) for the servers, but we use native enable/config.
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- Note: We assume binaries are in PATH (via Mamba/Conda)

            -- PYTHON (Pyright)
            -- Equivalent to old: require'lspconfig'.pyright.setup{}
            vim.lsp.enable("pyright") 

            -- C/C++ (Clangd)
            vim.lsp.enable("clangd")

            -- VERILOG (Verible)
            -- We need to customize the command slightly, so we use vim.lsp.config first
            vim.lsp.config("verible", {
                cmd = { "verible-verilog-ls" },
                root_markers = { "verilog.f", ".git" } -- New native way to define root
            })
            vim.lsp.enable("verible")
        end
    }
})
