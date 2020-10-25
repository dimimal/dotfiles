" All status line configuration goes here
set cmdheight=1
set display+=lastline

" general config
set laststatus=2	" always show status line
set showtabline=2	" always show tabline
set noshowmode		" hide default mode text (e.g. INSERT) as airline already displays it

" airline config
" let g:airline_theme = 'minimalist'
" let g:airline_powerline_fonts=1
" let g:airline#extensions#tabline#enabled=1  " buffers at the top as tabs
" let g:airline#extensions#tabline#show_tabs=1
" let g:airline#extensions#tabline#show_tab_type=0
" let g:airline#extensions#tmuxline#enabled=0
" let g:airline#extensions#branch = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

"make Esc happen without waiting for timeoutlen
" fixes Powerline delay 
if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
  augroup END
endif

" unicode symbols
let g:airline_left_sep      = '▶'
let g:airline_left_alt_sep  = '»'
let g:airline_right_sep     = '◀'
let g:airline_right_alt_sep = '«'
let g:airline_branch_prefix     = '⎇'
let g:airline_readonly_symbol   = '⭤'
let g:airline_linecolumn_prefix = '⭡'
let g:airline#extensions#tabline#left_sep       = '▶'
let g:airline#extensions#tabline#left_alt_sep   = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.readonly = ''
