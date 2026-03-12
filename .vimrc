source $HOME/.vim/config/init.vimrc
source $HOME/.vim/config/general.vimrc
source $HOME/.vim/config/plugins.vimrc
source $HOME/.vim/config/keys.vimrc
source $HOME/.vim/config/line.vimrc


" air-line (try mode )
"let g:airline_powerline_fonts = 1
"
"if !exists('g:airline_symbols')
"    let g:airline_symbols = {}
"endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" Auto-open NERDTree on startup and focus on file if one is opened
autocmd VimEnter * NERDTree | if argc() > 0 || argv()[0] =~ '^\/' | wincmd p | endif

" Close vim if NERDTree is the only window remaining
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Toggle NERDTree with <leader>t
nnoremap <leader>t :NERDTreeToggle<CR>

" Visual bell (only for vim, neovim handles this differently)
if !has('nvim')
    set vb t_vb=
    " Hack to work key arrows in vim in tmux
    if &term =~ '^screen'
        " tmux will send xterm-style keys when its xterm-keys option is on
        execute "set <xUp>=\e[1;*A"
        execute "set <xDown>=\e[1;*B"
        execute "set <xRight>=\e[1;*C"
        execute "set <xLeft>=\e[1;*D"
    endif
endif
