-- Ethereal Mist Neovim color scheme inspired by a misty castle image
-- with #726558 as the main accent color

local M = {}

local highlight = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  -- Color definitions
  local colors = {
    bg = '#1c2023', -- Dark grayish background
    fg = '#d8d8d8', -- Light gray text
    accent = '#726558', -- Main accent color (warm gray)
    keyword = '#a7adba', -- Soft blue-gray for keywords
    func = '#b48ead', -- Soft purple for functions
    string = '#a3be8c', -- Muted green for strings
    comment = '#65737e', -- Medium gray for comments
    type = '#8fa1b3', -- Light blue-gray for types
    constant = '#d08770', -- Soft orange for constants
    variable = '#bf616a', -- Soft red for variables
    cursor = '#c0c5ce', -- Light gray cursor
    line_nr = '#4f5b66', -- Dark gray line numbers
    line_nr_cursor = '#726558', -- Accent color for current line number
    visual = '#4f5b66', -- Dark gray for visual selection
    search = '#726558', -- Accent color for search highlight
    match_paren = '#ebcb8b', -- Soft yellow for matching parentheses
    status_line_bg = '#2b303b', -- Dark blue-gray for status line
    status_line_fg = '#c0c5ce', -- Light gray for status line text
    status_line_nc_bg = '#1c2023', -- Darker background for inactive status line
    status_line_nc_fg = '#65737e', -- Medium gray for inactive status line text
    normal_mode = '#8fa1b3', -- Light blue-gray for normal mode
    insert_mode = '#a3be8c', -- Muted green for insert mode
    visual_mode = '#b48ead', -- Soft purple for visual mode
    command_mode = '#ebcb8b', -- Soft yellow for command mode
    line_col_bg = '#2b303b', -- Dark blue-gray for line/column background
    line_col_fg = '#c0c5ce', -- Light gray for line/column text
    tab_bg = '#1c2023', -- Dark background for tabs
    tab_fg = '#c0c5ce', -- Light gray for tab text
    tab_sel_bg = '#2b303b', -- Dark blue-gray for selected tab
    tab_sel_fg = '#d8d8d8', -- Light gray for selected tab text
    pmenu_bg = '#2b303b', -- Dark blue-gray for popup menu
    pmenu_fg = '#c0c5ce', -- Light gray for popup menu text
    pmenu_sel_bg = '#4f5b66', -- Medium gray for selected popup item
    pmenu_sel_fg = '#d8d8d8', -- Light gray for selected popup item text
    diff_add = '#3a4235', -- Dark green for diff add
    diff_change = '#4a4940', -- Dark yellow for diff change
    diff_delete = '#4a3537', -- Dark red for diff delete
    diff_text = '#5b5e61', -- Medium gray for changed text
    error = '#bf616a', -- Soft red for errors
    warning = '#ebcb8b', -- Soft yellow for warnings
    info = '#8fa1b3', -- Light blue-gray for info
    hint = '#a3be8c', -- Muted green for hints
  }

  -- Set the color scheme
  vim.cmd 'hi clear'
  vim.cmd 'set background=dark'
  vim.g.colors_name = 'ethereal_mist'

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
  highlight('CursorLine', { bg = colors.bg })
  highlight('LineNr', { fg = colors.line_nr })
  highlight('CursorLineNr', { fg = colors.line_nr_cursor, bold = true })
  highlight('Visual', { bg = colors.visual })
  highlight('Search', { fg = colors.fg, bg = colors.search })
  highlight('IncSearch', { fg = colors.fg, bg = colors.bg })
  highlight('MatchParen', { fg = colors.match_paren, bold = true })

  -- Status line
  highlight('StatusLine', { fg = colors.status_line_fg, bg = colors.status_line_bg, bold = true })
  highlight('StatusLineNC', { fg = colors.status_line_nc_fg, bg = colors.status_line_nc_bg })

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
