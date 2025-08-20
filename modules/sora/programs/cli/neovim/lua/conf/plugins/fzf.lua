-- Find git root (same as before)
local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = current_file == "" and vim.fn.getcwd() or vim.fn.fnamemodify(current_file, ":h")
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Using cwd")
    return vim.fn.getcwd()
  end
  return git_root
end

local function live_grep_git_root()
  local root = find_git_root()
  if root then
    require('fzf-lua').grep({ cwd = root })
  end
end

return {
  {
    "fzf-lua",
    for_cat = 'general.utils',  -- can rename category if desired
    cmd = { "FzfLua", "LiveGrepGitRoot" },
    -- Telescope/fzf-lua keybinds
    keys = {
      { "ff", function() require('fzf-lua').files() end, mode = {"n"}, desc = '[F]ind [F]iles' },
      { "fw", function() require('fzf-lua').grep() end, mode = {"n"}, desc = '[F]ind [W]ord (Grep)' },
      { "fg", function() require('fzf-lua').grep({ search = vim.fn.expand("<cword>") }) end, mode = {"n"}, desc = '[F]ind [G]rep on Current Word' },
      { "fr", function() require('fzf-lua').oldfiles() end, mode = {"n"}, desc = '[F]ind [R]ecent Files' },
      { "fk", function() require('fzf-lua').keymaps() end, mode = {"n"}, desc = '[F]ind [K]eymaps' },
      { "fh", function() require('fzf-lua').help_tags() end, mode = {"n"}, desc = '[F]ind [H]elp Tags' },
      { "fM", '<cmd>lua require("fzf-lua").notify()<CR>', mode = {"n"}, desc = '[F]ind [M]essages' },
      { "fp", live_grep_git_root, mode = {"n"}, desc = '[F]ind in [P]roject Root' },
      { "fb", function() require('fzf-lua').buffers() end, mode = {"n"}, desc = '[F]ind [B]uffers' },
      { "fr", function() require('fzf-lua').resume() end, mode = {"n"}, desc = '[F]ind [R]esume' },
      { "fs", function() require('fzf-lua').builtin() end, mode = {"n"}, desc = '[F]ind [S]elect Builtin' },
      { "fd", function() require('fzf-lua').diagnostics() end, mode = {"n"}, desc = '[F]ind [D]iagnostics' },
      { "fW", function() require('fzf-lua').grep({ grep_open_files = true, prompt = 'Live Grep in Open Files' }) end, mode = {"n"}, desc = '[F]ind in Open Files' },
    },

    load = function(name)
      vim.cmd.packadd(name)
    end,
    after = function()
      require('fzf-lua').setup({
        winopts = { preview = { vertical = "down:50%" } },
        keymap = { builtin = { ["<c-enter>"] = "toggle-all" } },
        fzf_bin = "fzf",
      })

      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
    end,
  },
}

