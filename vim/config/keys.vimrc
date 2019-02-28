" map leader
let mapleader = ","

" bind nohl
" removes highlight of the last search
noremap <C-n> :nohl<CR>
vnoremap <C-n> :nohl<CR>
inoremap <C-n> :nohl<CR>

" Disable vims ex mode
nnoremap Q <Nop>

" quicksave command with F2
noremap <F2> :update<CR>
vnoremap <F2> <C-C>:update<CR>
inoremap <F2> <C-O>:update<CR>

" Hack to make arrows work in insert mode
map <ESC>oA <ESC>ki
imap <ESC>oB <ESC>ji
imap <ESC>oC <ESC>li
imap <ESC>oD <ESC>hi

" Maps for copy paste vim to clipboard
vnoremap <C-c> "+y
map <C-p> "+P

" easier moving between tabs with <leader>{n, m}
map <Leader>n <esc>:tabprevious<CR>
map <Leader>m <esc>:tabnext<CR>


" easier moving of code blocks
" Go into visual mode (v), then select several lines of code and press `>`
vnoremap < <gv  " better indentation
vnoremap > >gv  " better indentation

" relative line numbers
nnoremap <Leader>3 :NumbersToggle<CR>

" open ack.vim
nnoremap <Leader>a :Ack
