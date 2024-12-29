# gitopenweb.nvim

Simple plugin that allows to open current file & current line with cursor on it in browser.

Plugin comes with 2 keymaps
```lua
vim.keymap.set('n', '<leader>go', M.open, { noremap = true, silent = true, desc = "[G]it [O]pen in Web" })
vim.keymap.set('v', '<leader>go', M.open_multiline, { noremap = true, silent = true, desc = "[G]it [O]pen in Web" })
```

In normal mode it opens a file with line selected under curson, in visual opens file with selected lines.
