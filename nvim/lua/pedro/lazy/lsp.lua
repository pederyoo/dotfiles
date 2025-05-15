return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",          -- Core completion engine
      "hrsh7th/cmp-nvim-lsp",      -- LSP source
      "hrsh7th/cmp-buffer",        -- Buffer source
      "hrsh7th/cmp-path",          -- Path source
      "hrsh7th/cmp-cmdline",       -- Cmdline completions
      "L3MON4D3/LuaSnip",          -- Snippet engine
      "saadparwaiz1/cmp_luasnip",  -- Snippet completions
      "j-hui/fidget.nvim",         -- LSP progress UI
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Completion setup
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- Fidget (optional LSP UI)
      require("fidget").setup({})

      -- Mason
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "lua_ls",
          "pyright",
          "terraformls",
        },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
          end,

          -- Lua: custom settings
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = { globals = { "vim" } },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                },
              },
            })
          end,

          -- Python: pyright custom settings
          ["pyright"] = function()
            require("lspconfig").pyright.setup({
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              settings = {
                pyright = {
                  disableOrganizeImports = true,
                },
                python = {
                  analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    ignore = { "*" },
                    useLibraryCodeForTypes = true,
                  },
                },
              },
            })
          end,
        },
      })

      -- Ruff (manual, not mason)
      require("lspconfig").ruff.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        init_options = {
          settings = {
            configurationPreference = "filesystemFirst",
            lint = {
              enable = true,
              select = { "E", "F", "I", "B", "C90" },
              ignore = { "E501" },
              preview = true,
            },
            format = {
              quoteStyle = "single",
              preview = true,
            },
            codeAction = {
              disableRuleComment = { enable = false },
              fixViolation = { enable = true },
            },
            exclude = {
              "**/tests/**",
              "**/migrations/**",
            },
            lineLength = 100,
            showSyntaxErrors = true,
            logLevel = "warn",
          },
        },
      })

      -- Disable hover for Ruff
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_disable_ruff_hover", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
        desc = "Disable hover from Ruff (handled by Pyright instead)",
      })

      -- Optional: configure LSP diagnostics appearance
      vim.diagnostic.config({
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
        },
      })
    end,
  },
}

