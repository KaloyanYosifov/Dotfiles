-- This file can be loaded by calling `lua require("plugins")` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")

    use({
        "nvim-telescope/telescope.nvim",
        tag = "0.1.x",
        requires = { { "nvim-lua/plenary.nvim" } }
    })

    -- Style
    use("rakr/vim-one")
    use("Yggdroot/indentLine")
    use("nvim-tree/nvim-web-devicons")

    -- Treesitter
    use({
        "nvim-treesitter/nvim-treesitter",
        run = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end
    })
    use("nvim-treesitter/nvim-treesitter-context")

    -- LSP

    use({
        "VonHeikemen/lsp-zero.nvim",
        branch = "v1.x",
        requires = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            { "jay-babu/mason-nvim-dap.nvim" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
        }
    })
    use("lukas-reineke/lsp-format.nvim")

    -- Managing Projects
    use("ahmedkhalf/project.nvim")

    -- functionality
    use("mbbill/undotree")
    use("tpope/vim-surround")
    use("tpope/vim-commentary")
    use("gbprod/substitute.nvim")
    use("KaloyanYosifov/toggleterm.nvim")
    use("ThePrimeagen/harpoon")
    use({ "ms-jpq/chadtree", run = "python3 -m chadtree deps" })

    -- debugging
    use("mfussenegger/nvim-dap")

    -- other
    use("laytan/cloak.nvim")
    use("windwp/nvim-autopairs")
    use("gpanders/editorconfig.nvim")
    use("nvim-lualine/lualine.nvim")
    use("vimwiki/vimwiki")
end)
