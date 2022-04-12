" =============================================================================
" Sources and runtimepath stuff
" =============================================================================

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'gruvbox-community/gruvbox'
Plug 'vim-syntastic/syntastic'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
call plug#end()

" =============================================================================
" Simple vanilla settings
" =============================================================================

set cmdheight=1
set colorcolumn=120
set cursorline
set encoding=utf-8
set expandtab
set ff=unix
set fileformat=unix
set ignorecase
set incsearch
set lazyredraw
set modifiable
set mouse=a
set nocompatible
set noerrorbells
set nohlsearch
set novisualbell
set path+=.**
set path+=~/.config/**
set relativenumber
set ruler
set scrolloff=8
set shiftround " When at 3 spaces and I hit >>, go to 4, not 5.
set shiftwidth=4
set signcolumn=yes
set smartindent
set smarttab
set softtabstop=4
set tabstop=4
set textwidth=120
set updatetime=50
set wildmenu
set wildmode=longest,list,full
set wrap
syntax enable

" Ignore files
set wildignore+=*.pyc
set wildignore+=*.class
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*

" netrw
let g:netrw_browse_split = 0
let g:netrw_banner = 0
let g:netrw_winsize = 25
let g:netrw_localrmdir='rm -r'

" Store swap files in fixed location, not current directory.
set dir=~/.cache/vim/swap//
set undodir=~/.cache/vim/undo//

" au groups by filetype



" =============================================================================
" Plugin settings
" =============================================================================

" [netrw]
let g:netrw_browse_split = 0
let g:netrw_banner = 0
let g:netrw_winsize = 25
let g:netrw_localrmdir = 'rm -r'
augroup AutoDeleteNetrwHiddenBuffers
	au!
	au FileType netrw setlocal bufhidden=wipe
augroup end

" [filetype]
filetype plugin indent on

" =============================================================================
" Colorscheme
" =============================================================================
set background=dark
colorscheme gruvbox

"" Lightline

set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'apprentice',
      \ }
"function! LightlineFilename()
"  let root = fnamemodify(get(b:, 'git_dir'), ':h')
"  let path = expand('%:p')
"  if path[:len(root)-1] ==# root
"    return path[len(root)+1:]
"  endif
"  return expand('%')
"endfunction

"" Syntastic

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"" =============================================================================
"" Functions
"" =============================================================================

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE (thanks Gary Bernhardt)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" sudo save
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cabbrev w!! w !sudo tee % > /dev/null

" =============================================================================
" My custom Keybindings
" =============================================================================

"Resize splits
map <silent> <C-h> <C-w><
map <silent> <C-j> <C-W>-
map <silent> <C-k> <C-W>+
map <silent> <C-l> <C-w>>

"Leader Commands
let mapleader = " "

nnoremap <Leader>j :cnext<cr>
nnoremap <Leader>k :cprev<cr>
nnoremap <Leader>n :NERDTreeToggle<CR>
nnoremap <Leader>. :NERDTreeCWD<CR>
nnoremap <Leader>] :bnext<CR>
nnoremap <Leader>[ :bprev<CR>
nnoremap <Leader><F2> :call RenameFile()<cr>
nnoremap <Leader><Leader> :Files<CR>
nnoremap <Leader><Leader>g :GFiles<CR>
nnoremap <Leader>/ :Ag<CR>
nnoremap <Leader><CR> :source $DOTFILES_HOME/vimrc<CR>

" Buffer pane with file tree sidebar
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>

" replace selected text with whatever you paste in
vnoremap <leader>p "_dP

" yank to clipboard
nnoremap <leader>y "*y
vnoremap <leader>y "*y
nnoremap <leader>Y gg"*vGy

autocmd TextYankPost * call system('echo '.shellescape(join(v:event.regcontents, "\<CR>")).' | pbcopy')

" unescape \t and \n on current line (unwraps stacktraces)
nnoremap <leader>ue :.s/\\t/    /ge<cr>  :.s/\\n/\r/ge<cr>

" json formatting
nnoremap <leader>jq :.!jq<cr>v%:s/\\t/    /ge<cr>gv:s/\\n/\r/ge<cr>gvOv
vnoremap <leader>jq :'<,'>*!jq<cr>gv:s/\\t/    /ge<cr>gv:s/\\n/\r/ge<cr>gvOv

" remove trailing whitespace
nnoremap <leader>f :%s/\ *$//g<cr>
vnoremap <leader>f :'<,'>s/\ *$//g<cr>

" URL encode/decode selection
vnoremap <leader>en :!python3 -c 'import sys; from urllib import parse; print(parse.quote_plus(sys.stdin.read().strip()))'<cr>
vnoremap <leader>de :!python3 -c 'import sys; from urllib import parse; print(parse.unquote_plus(sys.stdin.read().strip()))'<cr>

"Move lines while formatting
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"The opposite of J
nnoremap <c-j> a<cr><esc>k$

"Leader Commands
let mapleader = " "
nnoremap <leader><leader> :FZF<cr>
nnoremap <leader>v :vs ~/.vimrc<cr>
nnoremap <leader><F2> :call RenameFile()<cr>
nnoremap <leader>1 :Lexplore<cr>

"Typo maps
command! Q q " Bind :Q to :q
map Q <Nop> " Disable Ex mode
command! W w " Instead of opening a Window manager, just write
map W <Nop>
command! Wq wq
map <F1> <Nop>

"Use :w!! to save a file with sudo
cabbrev w!! w !sudo tee % >/dev/null

" vimrc and journal
nnoremap <Leader>vv :vsplit $DOTFILES_HOME/vimrc<CR>
nnoremap <Leader>vj :vsplit $_HOME/Documents/notes/Vim.md<CR>

" the opposite of J
nnoremap <C-J> a<CR><Esc>k$

" unindent
nnoremap <S-Tab> <<
inoremap <S-Tab> <C-d>

" =============================================================================
" FileTypes
" =============================================================================

autocmd FileType yaml,yml,json,*.md setlocal shiftwidth=2 tabstop=2
autocmd FileType * autocmd BufWritePre <buffer> %s/\s\+$//e
" Treat .json files as .js
autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
" Treat .md files as Markdown
autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
autocmd FileType gitrebase setlocal noswapfile
