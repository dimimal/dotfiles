set encoding=UTF-8

" no vi-compatible
set nocompatible

" Colors
syntax on
syntax enable	" enable syntax processing

"python with virtualenv support
let g:ycm_python_binary_path = 'python3'

" allow plugins by file type (required for plugins!)
filetype plugin on
filetype indent on 

" Spaces & tabs
set tabstop=4		" number of visual spaces per TAB
set softtabstop=4	" number of spaces in tab when editing
set shiftwidth=4	" number of spaces using `<<` & `>>`
set expandtab		" tabs are spaces
set smarttab
set autoindent
set smartindent

""" command line completion
set wildmode=longest,full
set wildmenu

" case insensitive filename completion
set wildignorecase

" Always show status bar
set ls=2

" UI Config
set number      " show line numbers
set showcmd     " show command in bottom bar
set cursorline  " highlight current line
set wildmenu    " visual autocomplete for command menu
set lazyredraw  " redraw only whe we need to
set showmatch   " highlight matching [{()}]

if has('mouse')
    set mouse=a " use mouse
endif

""" Tagbar
" toggle Tagbar
nnoremap <F8> :TagbarToggle<CR>

" Searching
set incsearch   " search as characters are entered
set hlsearch    " highlight matches
set ignorecase  " make search case insensitive


" Disable stupid backup and swap files
set nobackup
set nowritebackup
set noswapfile


" Folding
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
set foldmethod=indent   " fold based on indent level


" Text wrapping
set nowrap              " do not automatically wrap on load
set formatoptions-=t    " do not automatically wrap text when typing
