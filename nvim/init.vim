" ============================================================================
" Neovim Configuration
" ============================================================================

" Source vim configuration files
source $HOME/.vim/config/init.vimrc
source $HOME/.vim/config/general.vimrc
source $HOME/.vim/config/plugins.vimrc
source $HOME/.vim/config/keys.vimrc
source $HOME/.vim/config/line.vimrc

" ============================================================================
" Neovim-specific settings
" ============================================================================

" Python provider settings
let g:python3_host_prog = '/usr/bin/python3'

" Terminal settings
" ESC to exit terminal mode
tnoremap <Esc> <C-\><C-n>

" Better terminal navigation
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

" Airline symbols configuration (neovim-specific)
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" Disable visual bell (neovim doesn't use 'vb')
set visualbell
set t_vb=

" NERDTree auto-open removed from here (will be in vimrc)
" Use :NERDTreeToggle instead or set up a keybinding

" ============================================================================
" Neovim enhancements
" ============================================================================

" Use true colors if available
if has('termguicolors')
    set termguicolors
endif

" Faster updates
set updatetime=300

" Always show signcolumn (for git gutter, ale, etc.)
set signcolumn=yes

" Better splits
set splitbelow
set splitright

" Persistent undo
if has('persistent_undo')
    set undodir=$HOME/.config/nvim/undo
    set undofile
endif

" Create undo directory if it doesn't exist
if !isdirectory($HOME.'/.config/nvim/undo')
    call mkdir($HOME.'/.config/nvim/undo', 'p', 0700)
endif
