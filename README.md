# Surrounder

## 1. Installation
### 1.a. Installation with [Vim-Plug](https://github.com/junegunn/vim-plug)
1. Add `Plug 'aben20807/vim-surrounder'` to your vimrc file.
2. Reload your vimrc or restart.
3. Run `:PlugInstall`

### 1.b. Installation with [Vundle](https://github.com/VundleVim/Vundle.vim)
1. Add `Plugin 'aben20807/vim-surrounder'` to your vimrc file.
2. Reload your vimrc or restart
3. Run `:PluginInstall`

## 2. Usage
### 2.a. Supported symbols
+ '', "", (), [], {}, <>

### 2.b. Demonstration
+ Note: ` ` marked text is cursor position.

|Before|key pressed|After|
|:-:|:-:|:-:|
|h`e`llo world   | `<leader>s "`   |  "h`e`llo" world|
|h`e`llo world   | `2<leader>s "`  | "h`e`llo world"|
|"h`e`llo world" | `<leader>d "`   |  h`e`llo world|
|"h`e`llo world" | `<leader>f "(`  | (h`e`llo world)|

### 2.c. Settings
```vim
" Feel free to change mapping you like.
" Use key mappings setting from this plugin by default.
let g:surrounder_use_default_mapping = 1

" Add surround in n mode
let g:surrounder_n_add_key = "<leader>s"

" Add surround in v mode
let g:surrounder_v_add_key = "<leader>s"

" Delete surround in n mode
let g:surrounder_n_del_key = "<leader>d"

" Replace surround in n mode
let g:surrounder_n_rep_key = "<leader>f"

" Show the surround information by default.
let g:surrounder_show_info = 1
```

![img](https://imgur.com/DR5QWxl.png)
