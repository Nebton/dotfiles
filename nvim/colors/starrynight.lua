-- Vagabond Starry Night-inspired Neovim color scheme with mini.statusline integration

local M = {}

local highlight = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  -- Color definitions
  local colors = {
    bg = '#0a0a15', -- Very dark blue background
    fg = '#c0c0d0', -- Light blue-gray text
    accent = '#6a8bff', -- Bright blue accent
    keyword = '#9f87ff', -- Light purple keywords
    func = '#87afff', -- Light blue functions
    string = '#afd7ff', -- Pale blue strings
    comment = '#5f5f87', -- Muted purple comments
    type = '#8787af', -- Muted blue-purple types
    constant = '#afafd7', -- Light purple constants
    variable = '#8787c0', -- Medium blue-purple variables
    cursor = '#ffffff', -- White cursor
    line_nr = '#3a3a5a', -- Dark blue-purple line numbers
    line_nr_cursor = '#8787af', -- Medium blue-purple current line number
    visual = '#1c1c2e', -- Slightly lighter bg for visual selection
    search = '#3a3a5a', -- Dark blue-purple for search highlight
    match_paren = '#6a8bff', -- Bright blue for matching parentheses
    status_line_bg = '#1c1c2e', -- Slightly lighter bg for status line
    status_line_fg = '#c0c0d0', -- Light blue-gray text for status line
    status_line_nc_bg = '#0f0f1a', -- Darker bg for inactive status line
    status_line_nc_fg = '#5f5f87', -- Muted purple text for inactive status line
    normal_mode = '#6a8bff', -- Bright blue for normal mode
    insert_mode = '#9f87ff', -- Light purple for insert mode
    visual_mode = '#5f5f87', -- Muted purple for visual mode
    command_mode = '#8787af', -- Medium blue-purple for command mode
    line_col_bg = '#1c1c2e', -- Dark blue-purple bg for line/col info
    line_col_fg = '#8787af', -- Medium blue-purple text for line/col info
    tab_bg = '#0f0f1a', -- Very dark blue bg for tabs
    tab_fg = '#c0c0d0', -- Light blue-gray text for tabs
    tab_sel_bg = '#1c1c2e', -- Slightly lighter bg for selected tab
    tab_sel_fg = '#ffffff', -- White text for selected tab
    pmenu_bg = '#0f0f1a', -- Very dark blue bg for popup menu
    pmenu_fg = '#c0c0d0', -- Light blue-gray text for popup menu
    pmenu_sel_bg = '#1c1c2e', -- Slightly lighter bg for selected popup item
    pmenu_sel_fg = '#ffffff', -- White text for selected popup item
    diff_add = '#1c2e1c', -- Dark green for added lines in diff
    diff_change = '#1c1c2e', -- Dark blue for changed lines in diff
    diff_delete = '#2e1c1c', -- Dark red for deleted lines in diff
    diff_text = '#3a3a5a', -- Medium blue-purple for changed text in diff
    error = '#ff5f5f', -- Bright red for errors
    warning = '#ffaf5f', -- Bright orange for warnings
    info = '#5f87ff', -- Bright blue for info
    hint = '#5faf5f', -- Bright green for hints
  }

  -- Set the color scheme
  vim.cmd 'hi clear'
  vim.cmd 'set background=dark'
  vim.g.colors_name = 'vagabond_starry_night'

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
