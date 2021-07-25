-- Aliases
local command = vim.api.nvim_command
local keymap = vim.api.nvim_set_keymap
local exec = vim.api.nvim_exec

local g = vim.g
local o = vim.o
local wo = vim.wo

-- Set leader key to space
keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
g.mapleader = ' '
g.maplocalleader = ' '

local cache_root = vim.fn.stdpath('cache')
local data_path = vim.fn.stdpath('data')
local packer_install_path = data_path .. '/site/pack/packer/start/packer.nvim'

-- Install packer if it is not installled already
if vim.fn.isdirectory(packer_install_path) == 0 then
    command('!git clone https://github.com/wbthomason/packer.nvim ' .. packer_install_path)
end

-- Chack for cache subdirs
local cache_dirs = { '/tags', '/backup', '/undo', '/swap' }
for i = 1, #cache_dirs do
    local dir = cache_root .. cache_dirs[i]
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir)
    end
end

-- Recompile packer on editing init.lua
exec([[
    augroup packer
        autocmd!
        autocmd BufWritePost init.lua PackerCompile
    augroup end
]], false)

require('packer').startup(function()
    local use = require('packer').use

    -- Package manager
    use 'wbthomason/packer.nvim'
    -- Colorscheme
    use 'arcticicestudio/nord-vim'
    -- Match Pairs
    use 'jiangmiao/auto-pairs'
    -- Collection of configurations for built-n lsp client
    use 'neovim/nvim-lspconfig'
    -- Autocomplete plugin
    use 'hrsh7th/nvim-compe'
    -- UI to select things (files, grep results, open buffers... etc.)
    use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}}
    -- Extra syntax highlighting
    use 'nvim-treesitter/nvim-treesitter'
    -- Status line
    use { 'hoob3rt/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true} }
    -- Now where the root of the project is always
    use 'dbakker/vim-projectroot'
    -- Comment niceness
    use 'tomtom/tcomment_vim'
end)

-- Incremental live completion
o.inccommand = 'split'

-- Set highlight on search
o.hlsearch = true
o.incsearch = true

-- Set relative/absolute line numbering
wo.number = true
wo.relativenumber = true

-- Do not save when swithcing buffers
o.hidden = true

-- Enable mouse
-- o.mouse = 'a'

-- Indent settings
o.breakindent = true
o.autoindent = true
o.smarttab = true
o.expandtab = true
o.shiftround = true
o.shiftwidth = 4
o.softtabstop = 4
o.tabstop = 4

-- Enable/Disable undo/backup/swap
vim.cmd[[set undofile]]
o.backup = false
o.swapfile = true
o.undoreload = 10000
o.undodir = cache_root .. '/undo//'
o.backupdir = cache_root .. '/backup//'
o.directory = cache_root .. '/swap//'

-- Timeout settings
o.timeout = true
o.ttimeout = true
o.timeoutlen = 600
o.ttimeoutlen = 0

-- Search settings
o.ignorecase = true
o.smartcase = true
o.gdefault = true
o.showmatch = true

-- Do not show mode in prompt
o.showmode = false

-- List character settings
o.list = true
o.listchars = 'extends:»,precedes:«,tab:│·,eol:¬,nbsp:.,trail:.'

-- Wildmenu settings
o.wildmenu = true
o.wildignorecase = true
o.wildmode = 'list:longest'
o.wildignore = '*/.git/*,*/.hg/*,*/.svn/*,*.jpg,*.bmp,*.gif,*.png,*.jpeg,*.mp3,*.wav,*.wav,*.class,*.o,*.pyc'

-- Change preview window location
o.splitbelow = true

-- Word wrap disable
vim.cmd[[set nowrap]]

-- Set completeopt to have a better completion experience
o.completeopt="menuone,noinsert,noselect"

-- Set title of tabs
o.titlestring = '%t'

-- Color settings
o.termguicolors = true
vim.cmd[[colorscheme nord]]

-- List of files that identify a root directory
g.rootmarkers = {
    '.projectroot',
    '.git'
}

-- CD to project root on buffer enter
exec([[
   augroup cd_to_project_root
       autocmd!
       autocmd BufEnter * call ProjectRootCD()
   augroup end
]], false)

-- Unmap tcomment default maps
g.tcomment_mapleader1 = ''
g.tcomment_mapleader2 = ''

-- Unmap colorizer default maps
g.colorizer_nomap = 1

-- Telescope settings
local actions = require('telescope.actions')
local sorters = require('telescope.sorters')

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
        ['<esc>'] = actions.close
      },

      n = {
          ['<esc>'] = actions.close
      }
    },
    generic_sorter =  sorters.get_fzy_sorter,
    file_sorter =  sorters.get_fzy_sorter,
  }
}

-- Compe settings
require('compe').setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = false;
    calc = true;
    vsnip = false;
    nvim_lsp = true;
    nvim_lua = true;
    spell = true;
    tags = false;
    snippets_nvim = true;
    treesitter = true;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end

keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

-- Tree-sitter settings
require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'c',
        'bash',
        'python',
        'php',
        'ruby',
        'lua',
        'json',
        'toml'
    },

    highlight = {
        enable = true
    }
}

-- Lualine settings
require('nvim-web-devicons').setup()

require('lualine').setup {
    options = {
        theme = 'nord',
        section_separators = '',
        component_separators = '',
	icons_enabled = 0
    }
}

-- LSP settings
local lspconfig = require('lspconfig')

local on_attach = function(_client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap=true, silent=true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
end

-- Disable diagnostics. I know what I'm doing, maybe
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        signs = false,
        update_in_insert = false
    }
)

-- Enable python lsp server
lspconfig['pyright'].setup {
    cmd = { data_path .. '/lsp_servers/python/node_modules/.bin/pyright-langserver', '--stdio' },
    on_attach = on_attach
}

