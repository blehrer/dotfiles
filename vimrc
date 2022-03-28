"-to-on-prem =============================================================================
" Sources and runtimepath stuff
" =============================================================================

" Vim 8 has native package management so we don't need Pathogen anymore
"" execute pathogen#infect()
"
" ### How to add new plugins
"
" ``` shell
" newVimPlugin https://github.com/namespace/repo.git
" ```
" ```vim
" :helptags ~/.vim/pack/vendor/start/
" ```
" =============================================================================
" Color scheme
" =============================================================================
set termguicolors
"colorscheme desert
colorscheme gruvbox
set background=dark

" =============================================================================
" Simple vanilla settings
" =============================================================================
set nocompatible
set wrap
set number
set relativenumber
set cursorline
set novisualbell
set noerrorbells
set smartindent
syntax enable
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set encoding=utf-8
set shiftround " When at 3 spaces and I hit >>, go to 4, not 5.
set ignorecase
set smartcase
set smarttab
set wildmode=longest,list,full
set wildmenu
set incsearch
set textwidth=120
set colorcolumn=120 
set scrolloff=8
set signcolumn=yes
highlight ColorColumn ctermbg=darkgrey ctermfg=black
highlight Cursor ctermbg=darkgrey ctermfg=black
set hlsearch

" Ignore files
set wildignore+=*.pyc
set wildignore+=*.class
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*
set ruler
set lazyredraw
set undofile
set modifiable
set fileformat=unix
set ff=unix
set path+=.**
set path+=~/.config/**
set cmdheight=1
set updatetime=50
set mouse=a

" netrw
let g:netrw_browse_split = 0
let g:netrw_banner = 0
let g:netrw_winsize = 25
let g:netrw_localrmdir='rm -r'

" Store swap files in fixed location, not current directory.
set dir=~/.vimswap//,/var/tmp//,/tmp//,.
set backupdir=.backup/,~/.backup/,/tmp//
set directory=.swp/,~/.swp/,/tmp//
set undodir=.undo/,~/.undo/,/tmp//

" au groups by filetype

filetype plugin indent on
autocmd FileType yaml,yml,json setlocal shiftwidth=2 tabstop=2 
autocmd FileType yaml,yml,json autocmd BufWritePre <buffer> %s/\s\+$//e

"" =============================================================================
"" Plugin settings
"" =============================================================================
"" NerdTree
""let NERDTreeShowHidden=1
"
"" Lightline

set laststatus=2
"let g:lightline = {
"    \ 'colorscheme': 'gruvbox',
"      \ 'active': {
"      \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'absolutepath', 'modified' ] ],
"      \ }
"\}
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \ }
      \ }

function! LightlineFilename()
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

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
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Quit if you've closed everything except NERDTree
"" @see http://tiny/6c84f5av/jleroux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""function! NERDTreeQuit()
""  redir => buffersoutput
""  silent buffers
""  redir END
"""                     1BufNo  2Mods.     3File           4LineNo
""  let pattern = '^\s*\(\d\+\)\(.....\) "\(.*\)"\s\+line \(\d\+\)$'
""  let windowfound = 0
""
""  for bline in split(buffersoutput, "\n")
""    let m = matchlist(bline, pattern)
""
""    if (len(m) > 0)
""      if (m[2] =~ '..a..')
""        let windowfound = 1
""      endif
""    endif
""  endfor
""
""  if (!windowfound)
""    quitall
""  endif
""endfunction
""autocmd WinEnter * call NERDTreeQuit()

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

autocmd TextYankPost * call system('echo '.shellescape(join(v:event.regcontents, "\<CR>")).' |  clip.exe')

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

" move lines while formatting
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

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
