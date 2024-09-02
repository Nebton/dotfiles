-- Vagabond-inspired Neovim color scheme with mini.statusline integration

local M = {}

local highlight = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  -- Color definitions
  local colors = {
    bg = '#1c1c1c', -- Dark gray background
    fg = '#d0d0d0', -- Light gray text
    accent = '#8f8f8f', -- Medium gray accent
    keyword = '#a8a8a8', -- Light gray keywords
    func = '#b2b2b2', -- Slightly lighter gray functions
    string = '#c6c6c6', -- Even lighter gray strings
    comment = '#707070', -- Darker gray comments
    type = '#9e9e9e', -- Medium-light gray types
    constant = '#b8b8b8', -- Light gray constants
    variable = '#a0a0a0', -- Medium-light gray variables
    cursor = '#ffffff', -- White cursor
    line_nr = '#4d4d4d', -- Dark gray line numbers
    line_nr_cursor = '#b2b2b2', -- Light gray current line number
    visual = '#3a3a3a', -- Slightly lighter bg for visual selection
    search = '#5f5f5f', -- Medium gray for search highlight
    match_paren = '#8f8f8f', -- Medium gray for matching parentheses
    status_line_bg = '#2e2e2e', -- Slightly lighter bg for status line
    status_line_fg = '#d0d0d0', -- Light gray text for status line
    status_line_nc_bg = '#262626', -- Darker bg for inactive status line
    status_line_nc_fg = '#808080', -- Medium gray text for inactive status line
    normal_mode = '#8f8f8f', -- Medium gray for normal mode
    insert_mode = '#a8a8a8', -- Light gray for insert mode
    visual_mode = '#707070', -- Dark gray for visual mode
    command_mode = '#9e9e9e', -- Medium-light gray for command mode
    line_col_bg = '#2a2a2a', -- Dark gray bg for line/col info
    line_col_fg = '#b2b2b2', -- Light gray text for line/col info
    tab_bg = '#262626', -- Dark gray bg for tabs
    tab_fg = '#d0d0d0', -- Light gray text for tabs
    tab_sel_bg = '#3a3a3a', -- Slightly lighter bg for selected tab
    tab_sel_fg = '#ffffff', -- White text for selected tab
    pmenu_bg = '#262626', -- Dark gray bg for popup menu
    pmenu_fg = '#d0d0d0', -- Light gray text for popup menu
    pmenu_sel_bg = '#3a3a3a', -- Slightly lighter bg for selected popup item
    pmenu_sel_fg = '#ffffff', -- White text for selected popup item
    diff_add = '#3a3a3a', -- Slightly lighter bg for added lines in diff
    diff_change = '#4a4a4a', -- Medium gray for changed lines in diff
    diff_delete = '#2e2e2e', -- Dark gray for deleted lines in diff
    diff_text = '#5f5f5f', -- Medium gray for changed text in diff
    error = '#8f3f3f', -- Dark red for errors
    warning = '#7f6f3f', -- Dark yellow for warnings
    info = '#5f5f7f', -- Dark blue for info
    hint = '#5f7f5f', -- Dark green for hints
  }

  -- Set the color scheme
  vim.cmd 'hi clear'
  vim.cmd 'set background=dark'
  vim.g.colors_name = 'vagabond'

  -- Syntax highlighting
  highlight('Normal', { fg = colors.fg, bg = colors.bg })
  highlight('Keyword', { fg = colors.keyword, bold = true })
  highlight('Function', { fg = colors.func })
  highlight('String', { fg = colors.string })
  highlight('Comment', { fg = colors.comment })
  highlight('Type', { fg = colors.type })
  highlight('Constant', { fg = colors.constant })
  highlight('Identifier', { fg = colors.variable })

  -- UI elements
  highlight('Cursor', { fg = colors.bg, bg = colors.cursor })
  highlight('CursorLine', { bg = colors.visual })
  highlight('LineNr', { fg = colors.line_nr })
  highlight('CursorLineNr', { fg = colors.line_nr_cursor, bold = true })
  highlight('Visual', { bg = colors.visual })
  highlight('Search', { fg = colors.fg, bg = colors.search })
  highlight('IncSearch', { fg = colors.fg, bg = colors.bg })
  highlight('MatchParen', { fg = colors.match_paren, bold = true })

  -- Status line
  highlight('StatusLine', { fg = colors.status_line_fg, bg = colors.status_line_bg, bold = true })
  highlight('StatusLineNC', { fg = colors.status_line_nc_fg, bg = colors.status_line_nc_bg, bold = true })

  -- Tabline
  highlight('TabLine', { fg = colors.tab_fg, bg = colors.tab_bg })
  highlight('TabLineFill', { bg = colors.tab_bg })
  highlight('TabLineSel', { fg = colors.tab_sel_fg, bg = colors.tab_sel_bg, bold = true })

  -- Popup menu
  highlight('Pmenu', { fg = colors.pmenu_fg, bg = colors.pmenu_bg })
  highlight('PmenuSel', { fg = colors.pmenu_sel_fg, bg = colors.pmenu_sel_bg })

  -- Diff
  highlight('DiffAdd', { bg = colors.diff_add })
  highlight('DiffChange', { bg = colors.diff_change })
  highlight('DiffDelete', { bg = colors.diff_delete })
  highlight('DiffText', { bg = colors.diff_text })

  -- Errors and warnings
  highlight('Error', { fg = colors.error })
  highlight('Warning', { fg = colors.warning })
  highlight('Info', { fg = colors.info })
  highlight('Hint', { fg = colors.hint })

  -- Special highlights
  highlight('Title', { fg = colors.accent, bold = true })
  highlight('Bold', { bold = true })
  highlight('Italic', { italic = true })
  highlight('Underlined', { underline = true })
  highlight('YankHighlight', { bg = colors.accent, fg = colors.fg, bold = true })

  -- Mini.statusline integration
  local statusline = require 'mini.statusline'

  -- Custom mode_highlight function
  local function mode_highlight()
    local mode = vim.fn.mode(1)
    if mode == 'n' then
      return { fg = colors.bg, bg = colors.normal_mode }
    elseif mode == 'i' then
      return { fg = colors.bg, bg = colors.insert_mode }
    elseif mode:find 'v' or mode:find 'V' then
      return { fg = colors.bg, bg = colors.visual_mode }
    elseif mode == 'c' then
      return { fg = colors.bg, bg = colors.command_mode }
    else
      return { fg = colors.status_line_fg, bg = colors.status_line_bg }
    end
  end

  statusline.setup {
    use_icons = vim.g.have_nerd_font,
    content = {
      active = function()
        local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
        local git = statusline.section_git { trunc_width = 75 }
        local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
        local filename = statusline.section_filename { trunc_width = 140 }
        local fileinfo = statusline.section_fileinfo { trunc_width = 120 }
        local location = statusline.section_location { trunc_width = 75 }
        return statusline.combine_groups {
          { hl = mode_highlight(), strings = { mode } },
          { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
          '%<', -- Mark general truncate point
          { hl = 'MiniStatuslineFilename', strings = { filename } },
          '%=', -- End left alignment
          { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
          { hl = mode_highlight(), strings = { location } },
        }
      end,
    },
  }

  -- Customize the location section if needed
  statusline.section_location = function()
    return '%2l:%-2v'
  end

  -- Additional highlights for mini.statusline
  highlight('MiniStatuslineDevinfo', { fg = colors.status_line_fg, bg = colors.status_line_bg })
  highlight('MiniStatuslineFilename', { fg = colors.status_line_fg, bg = colors.status_line_bg })
  highlight('MiniStatuslineFileinfo', { fg = colors.status_line_fg, bg = colors.status_line_bg })
end

M.setup()

return M
