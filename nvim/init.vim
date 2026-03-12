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

" Python provider — auto-detect across platforms
if has('win32') || has('win64')
    " Windows: prefer 'python3', fall back to 'python' / 'py'
    if exepath('python3') !=# ''
        let g:python3_host_prog = exepath('python3')
    elseif exepath('python') !=# ''
        let g:python3_host_prog = exepath('python')
    elseif exepath('py') !=# ''
        let g:python3_host_prog = exepath('py')
    endif
else
    " Unix: prefer python3 in PATH, fall back to common location
    if exepath('python3') !=# ''
        let g:python3_host_prog = exepath('python3')
    else
        let g:python3_host_prog = '/usr/bin/python3'
    endif
endif

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

" Persistent undo — resolve path per platform
if has('persistent_undo')
    if has('win32') || has('win64')
        let s:undodir = expand('$LOCALAPPDATA/nvim/undo')
    else
        let s:undodir = expand('$HOME/.config/nvim/undo')
    endif
    if !isdirectory(s:undodir)
        call mkdir(s:undodir, 'p', 0700)
    endif
    let &undodir = s:undodir
    set undofile
endif
