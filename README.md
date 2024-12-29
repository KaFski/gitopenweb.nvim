# gitopenweb.nvim

Simple plugin that allows to open current file & current line with cursor on it in browser.

Plugin comes with 2 keymaps
```lua
vim.keymap.set({ 'n', 'v' }, '<leader>go', M.open, { noremap = true, silent = true, desc = "[G]it [O]pen in Web" })
vim.keymap.set({ 'n', 'v' }, '<leader>gs', M.select, { noremap = true, silent = true, desc = "[G]it [S]elect to clipboard" })
```

In normal mode `<leader>go` opens a file with line selected under curson, in visual opens file with selected lines.

It allows to copy to clipboard with `<leader>gs` instead of opening it in browser.
