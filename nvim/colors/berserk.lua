-- Berserk-inspired Neovim color scheme with mini.statusline integration

local M = {}

local highlight = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
  -- Color definitions
  local colors = {
    bg = '#000000',
    fg = '#ffffff',
    accent = '#a50000',
    keyword = '#a50000',
    func = '#ff8080',
    string = '#ffcccc',
    comment = '#880000',
    type = '#ff6666',
    constant = '#ff9999',
    variable = '#d72121',
    cursor = '#ffffff',
    line_nr = '#4d0000',
    line_nr_cursor = '#ff6666',
    visual = '#330000',
    search = '#a50000',
    match_paren = '#ff9900',
    status_line_bg = '#330000',
    status_line_fg = '#ffffff',
    status_line_nc_bg = '#1a0000',
    status_line_nc_fg = '#b3b3b3',
    normal_mode = '#00ff00',
    insert_mode = '#0000ff',
    visual_mode = '#ff00ff',
    command_mode = '#ffff00',
    line_col_bg = '#2a0000',
    line_col_fg = '#ff8080',
    tab_bg = '#1a0000',
    tab_fg = '#ffffff',
    tab_sel_bg = '#4d0000',
    tab_sel_fg = '#ffffff',
    pmenu_bg = '#1a0000',
    pmenu_fg = '#ffffff',
    pmenu_sel_bg = '#4d0000',
    pmenu_sel_fg = '#ffffff',
    diff_add = '#3a3a00',
    diff_change = '#4a3a00',
    diff_delete = '#4d0000',
    diff_text = '#ffcc00',
    error = '#ff0000',
    warning = '#ff9900',
    info = '#ffcc00',
    hint = '#ffff00',
  }

  -- Set the color scheme
  vim.cmd 'hi clear'
  vim.cmd 'set background=dark'
  vim.g.colors_name = 'berserk'

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
