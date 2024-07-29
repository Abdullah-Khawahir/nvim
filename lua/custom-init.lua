vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.tabstop = 4
-- vim.o.path = vim.o.path .. '**'
vim.opt.scrolloff = 10
vim.opt.inccommand = 'split'
vim.opt.clipboard = 'unnamedplus'
vim.o.colorcolumn = '80'
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.signcolumn = 'yes'
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '[q', vim.cmd.cp, { desc = 'Go to previous [Q]uickfix' })
vim.keymap.set('n', ']q', vim.cmd.cn, { desc = 'Go to next [Q]uickfix' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require('lazy').setup {
	{
		'folke/tokyonight.nvim',
		lazy = false, -- ensure the colorscheme loads during startup
		priority = 1000, -- ensure this loads before other plugins
		config = function()
			vim.cmd [[colorscheme tokyonight-night]]
		end,
	},
	{
		'folke/which-key.nvim',
		event = 'VimEnter',
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			require('which-key').setup()
		end,
	},
	{ 'numToStr/Comment.nvim',    opts = {} },
	{ 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
		},
		config = function()
			local cmp = require 'cmp'

			cmp.setup {
				completion = { completeopt = 'menu,menuone,noselect' },
				mapping = cmp.mapping.preset.insert {
					['<C-n>'] = cmp.mapping.select_next_item(),
					['<C-p>'] = cmp.mapping.select_prev_item(),
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<CR>'] = cmp.mapping.confirm {},
					['<Tab>'] = cmp.mapping.select_next_item(),
					['<S-Tab>'] = cmp.mapping.select_prev_item(),
					['<C-Space>'] = cmp.mapping.complete {},
				},
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'path' },
				},
			}
		end,
	},
	{
		'nvim-tree/nvim-web-devicons',
		lazy = true,
	},
	{ -- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		opts = {
			ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
			auto_install = true,
			highlight = {
				enable = true,
			},
		},
		config = function(_, opts)
			require('nvim-treesitter.install').prefer_git = true
			---@diagnostic disable-next-line: missing-fields
			require('nvim-treesitter.configs').setup(opts)
		end,
	},
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.8',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			local t = require 'telescope.builtin'
			local map = function(key, command, desc)
				vim.keymap.set('n', '<leader>s' .. key, command, { desc = desc })
			end
			map('f', t.fd, 'find files')
			map('h', t.help_tags, 'help tags')
			map('h', t.help_tags, 'help tags')
		end,
	},
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			{ 'folke/neodev.nvim', opts = {} },
		},
		config = function()
			local lspconfig = require 'lspconfig'
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend('force', capabilities,
				require('cmp_nvim_lsp').default_capabilities())
			lspconfig.rust_analyzer.setup {}
			-- Setup `lua_ls` with capabilities
			lspconfig.lua_ls.setup {
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							version = 'LuaJIT',
						},
						diagnostics = {
							globals = { 'vim' },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file('', true),
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			}

			-- Autocommand for attaching LSP keymaps and capabilities
			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set('n', keys, func,
							{ buffer = event.buf, desc = 'LSP: ' .. desc })
					end
					map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
					map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
					map('gI', require('telescope.builtin').lsp_implementations,
						'[G]oto [I]mplementation')
					map('<leader>D', require('telescope.builtin').lsp_type_definitions,
						'Type [D]efinition')
					map('<leader>ds', require('telescope.builtin').lsp_document_symbols,
						'[D]ocument [S]ymbols')
					map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
						'[W]orkspace [S]ymbols')
					map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
					map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
					map('K', vim.lsp.buf.hover, 'Hover Documentation')
					map('<leader>f', vim.lsp.buf.format, 'Code [F]ormat')
					vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help,
						{ desc = 'Hover Documentation in insert mode' })
					map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight',
							{ clear = false })
						vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd('LspDetach', {
							group = vim.api.nvim_create_augroup('lsp-detach',
								{ clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
							end,
						})
					end

					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						map('<leader>th', function()
							---@diagnostic disable-next-line: missing-parameter
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
						end, '[T]oggle Inlay [H]ints')
					end
				end,
			})
		end,
	},
	{ -- Collection of various small independent plugins/modules
		'echasnovski/mini.nvim',
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [']quote
			--  - ci'  - [C]hange [I]nside [']quote
			require('mini.ai').setup { n_lines = 500 }

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require('mini.surround').setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require 'mini.statusline'
			-- set use_icons to true if you have a Nerd Font
			statusline.setup { use_icons = vim.g.have_nerd_font }
			require('mini.diff').setup {}
			require('mini.git').setup {}
			require('mini.pairs').setup {}
			require('mini.bracketed').setup {}
			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return '%2l:%-2v'
			end
			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	},
	install = { colorscheme = { 'habamax' } },
	checker = { enabled = true },
}
