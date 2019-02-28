filetype plugin indent on	" load filetype-specific indent files


" minimalist
" set t_Co=256
let g:gruvbox_italic=0
colorscheme gruvbox 
set background=dark
let g:airline_theme='angr'
let g:gruvbox_contrast_dark='medium'

" UltiSnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsEditSplit="vertical"

" JS syntastic fix
let g:jsx_ext_required = 0 " Allow JSX in normal JS files
let g:syntastic_javascript_checkers = ['eslint']

" Force jedi to work with py3
let g:jedi#force_py_version = 3

" vim-commentary
autocmd FileType c   setlocal commentstring=//\ %s
autocmd FileType cpp setlocal commentstring=//\ %s

""" automatically change working directory to the directory of the current file
autocmd BufEnter * if expand('%:p') !~ '://' | :lcd %:p:h | endif

" Ignore pyc files
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

" Python syntax highlight
let python_highlight_all = 1
let python_no_operator_highlight = 1
let g:python_highlight_class_vars = 1

" DoxyGen-Syntax
let g:load_doxygen_syntax = 1

""" NERD Tree
" show hidden files
let NERDTreeShowHidden=1


" Ack
if executable('ag')
    let g:ackprg = 'ag --vimgrep'
endif

" Ale
" Signs
" let g:ale_sign_error = '❌'
" let g:ale_sign_warning = '❗'

"Echoed message
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

"Linters
" let g:ale_linters = {
" \   'c': ['clangd', 'uncrustify'],
" \   'python': ['flake8'],
" \}

" Syntastic settings for linting
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0

" let g:syntastic_python_checkers = ['flake8']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Filetype settings
" C
autocmd BufNewFile,BufRead *.h set filetype=c

" CSS
autocmd FileType css setlocal tabstop=2 softtabstop=2 shiftwidth=2

" HTML
autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2

" ino Arduino sketches
autocmd FileType ino setlocal tabstop=2 softtabstop=2 shiftwidth=2

" JavaScript
autocmd FileType javascript setlocal tabstop=2 softtabstop=2 shiftwidth=2

" JSON
autocmd BufNewFile,BufRead *.json set filetype=json

" make
" makefiles require tabs for indentation
autocmd FileType make setlocal noexpandtab

" Markdown
autocmd BufNewFile,BufRead *.md set filetype=markdown

" Python
autocmd FileType py setlocal textwidth=79 tabstop=4 softtabstop=4 shiftwidth=4 expandtab autoindent

" SQL
autocmd FileType sql setlocal tabstop=2 softtabstop=2 shiftwidth=2

" yaml
" yaml files require spaces for indentation
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2

""" strip trailing whitespace
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://vim.wikia.com/wiki/Remove_unwanted_spaces
" http://vimcasts.org/episodes/tidying-whitespace/
function! <SID>StripTrailingWhitespaces()
    " Preparation :save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

" strip trailing whitespace on save
" NOTE
" order file extensions alphabetically
autocmd BufWritePre *.c,*.css,*.cu,*.h,*.html,*.ino,*.md,*.markdown,*.js,*.py,*.sh,*.sql,*.tex,*.txt :call <SID>StripTrailingWhitespaces()

" map the <SID>StripTrailingWhitespaces function to a shortcut
" nnoremap <Leader>w :call <SID>StripTrailingWhitespaces()<CR>


""" create parent directories on save
" http://stackoverflow.com/questions/4292733/vim-creating-parent-directories-on-save
"function! s:MkNonExDir(file, buf)
"    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
"        let dir=fnamemodify(a:file, ':h')
"        if !isdirectory(dir)
"            call mkdir(dir, 'p')
"        endif
"    endif
"endfunction
"
"augroup BWCCreateDir
"    autocmd!
"    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
"augroup END
"
