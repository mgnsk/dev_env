### Notes

`earlyoom` is started on each bash session. It terminates `gopls` when memory gets full allowing `coc.nvim` to restart it quickly. `coc.nvim` should sort itself out, the next `gd` or equivalent should automatically trigger a new `gopls` instance. The instance is also shared with `vim-go`. If everything automatic fails, use `:CocRestart`.

