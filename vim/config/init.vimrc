call plug#begin('~/.vim/plugged')



" Colorschemes
Plug 'tomasr/molokai'
" Plug 'junegunn/seoul256.vim'
" Plug 'goatslacker/mango.vim'
" Plug 'w0ng/vim-hybrid'
" Plug 'davb5/wombat256dave'
Plug 'dikiaap/minimalist'
Plug 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
Plug 'drewtempelmeyer/palenight.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'morhetz/gruvbox'
Plug 'crusoexia/vim-monokai'
Plug 'joshdick/onedark.vim'

" For onedark colorscheme
Plug 'sheerun/vim-polyglot'

" For asynchronous calls
Plug 'neomake/neomake'

" Vim-jupyter
Plug 'szymonmaszke/vimpyter' "vim-plug


" Tagbar
" " a class outline viewer
" " https://github.com/majutsushi/tagbar
" " http://majutsushi.github.io/tagbar/
Plug 'majutsushi/tagbar'

"
"Plug 'junegunn/seoul256.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'jnurmine/Zenburn'
Plug 'altercation/vim-colors-solarized'

" General
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'mileszs/ack.vim'
"Plug 'nvie/vim-flake8'

" Git/mercurial/others diff icons on the side of the file lines
Plug 'mhinz/vim-signify'

" Automatically sort python imports
Plug 'fisadev/vim-isort'

" Drag visual blocks arround
Plug 'fisadev/dragvisuals.vim'

" Tmux integration — Unix only (tmux not available on Windows)
if !has('win32') && !has('win64')
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'tmux-plugins/vim-tmux'
endif

" Terminal Vim with 256 colors colorscheme
Plug 'fisadev/fisa-vim-colorscheme'

" Surround
Plug 'haya14busa/incsearch.vim'
Plug 'tpope/vim-surround'

" Autoclose
Plug 'Townk/vim-autoclose'
" Indent text object
Plug 'michaeljsmith/vim-indent-object'

" Indentation based movements
Plug 'jeetsukumaran/vim-indentwise'
"Python and other languages code checker
" Plug 'scrooloose/syntastic'
" Paint css colors with the real color
Plug 'lilydjwg/colorizer'

" Editing
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
Plug 'w0rp/ale'

" Eye candy
Plug 'myusuf3/numbers.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'  " File icons for NERDTree, airline, etc.

" Jedi Vim Python 
" Plug 'davidhalter/jedi-vim'

" Complete Syntax highlighting
Plug 'kh3phr3n/python-syntax'

" Json plugin
Plug 'elzr/vim-json'

"Vim javascript
Plug 'pangloss/vim-javascript'

" C/C++
Plug 'octol/vim-cpp-enhanced-highlight'

" Doxygen
Plug 'vim-scripts/DoxyGen-Syntax'

" Search results counter
Plug 'vim-scripts/IndexedSearch'

" XML/HTML tags navigation
Plug 'vim-scripts/matchit.zip'

" Plug 'vim-misc'
" Plug 'vim-session'

" Gvim colorscheme
" Plug 'vim-scripts/Wombat'

" Yank history  avigation
" Plug 'vim-scripts/YankRing.vim'

" EasyMotion
" " improved motion shortcuts
" " https://github.com/easymotion/vim-easymotion
Plug 'Lokaltog/vim-easymotion'

" Latex 
Plug 'lervag/vimtex'
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }

" Vim bracketed-paste
" Fixes the paste indentation from external applications
" https://github.com/ConradIrwin/vim-bracketed-paste
Plug 'ConradIrwin/vim-bracketed-paste'

" Supertab
Plug 'ervandew/supertab'

if has('nvim')
    Plug 'Shougo/deoplete.nvim'
    Plug 'zchee/deoplete-jedi', { 'for' : 'python'}
    Plug 'Shougo/neoinclude.vim'
    Plug 'Shougo/echodoc.vim'
    " zsh completion — Unix only
    if !has('win32') && !has('win64')
        Plug 'zchee/deoplete-zsh', { 'for' : 'zsh'}
    endif
    Plug 'zchee/deoplete-clang', { 'for' : ['c','cpp']}
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif

let g:deoplete#enable_at_startup = 1

" Mouse support for vim (neovim doesn't need this)
if !has('nvim')
    set ttymouse=xterm2
endif

" Terminal mappings are now handled in ~/.config/nvim/init.vim for neovim

call plug#end()
