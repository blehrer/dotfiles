" =============================================================================
" Sources and runtimepath stuff
" =============================================================================

" Vim 8 has native package management so we don't need Pathogen anymore
"" execute pathogen#infect()
"
" ### How to add new plugins
"
" ```
" newVimPlugin https://github.com/namespace/repo.git
" ```
"
" =============================================================================
" Color scheme
" =============================================================================
set termguicolors
colorscheme gruvbox
set background=dark

" =============================================================================
" Simple vanilla settings
" =============================================================================
set number
set relativenumber
set cursorline
set noerrorbells
set smartindent
syntax enable
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set encoding=utf-8
set shiftround " When at 3 spaces and I hit >>, go to 4, not 5.
set ignorecase
set smartcase
set smarttab
set wildmode=longest,list,full
set wildmenu
set incsearch
set colorcolumn=100
set scrolloff=8
set signcolumn=yes
highlight ColorColumn guibg=lightgrey
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
set fileformat=unix
set ff=unix
set path+=.**
set path+=~/.config/**
set cmdheight=1
set updatetime=50

" netrw
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_browse_split = 2
let g:netrw_winsize = 30
let g:netrw_wiw=1
let g:netrw_usetab = 1

" Store swap files in fixed location, not current directory.
set dir=~/.vimswap//,/var/tmp//,/tmp//,.
set backupdir=.backup/,~/.backup/,/tmp//
set directory=.swp/,~/.swp/,/tmp//
set undodir=.undo/,~/.undo/,/tmp//

" =============================================================================
" Plugin settings
" =============================================================================
" NerdTree
"let NERDTreeShowHidden=1

" Lightline
set laststatus=2
let g:lightline = {
    \ 'colorscheme': 'gruvbox'
\}

" =============================================================================
" Functions
" =============================================================================

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quit if you've closed everything except NERDTree
" @see http://tiny/6c84f5av/jleroux
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"function! NERDTreeQuit()
"  redir => buffersoutput
"  silent buffers
"  redir END
""                     1BufNo  2Mods.     3File           4LineNo
"  let pattern = '^\s*\(\d\+\)\(.....\) "\(.*\)"\s\+line \(\d\+\)$'
"  let windowfound = 0
"
"  for bline in split(buffersoutput, "\n")
"    let m = matchlist(bline, pattern)
"
"    if (len(m) > 0)
"      if (m[2] =~ '..a..')
"        let windowfound = 1
"      endif
"    endif
"  endfor
"
"  if (!windowfound)
"    quitall
"  endif
"endfunction
"autocmd WinEnter * call NERDTreeQuit()

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
"map <silent> <C-h> <C-w><
"map <silent> <C-j> <C-W>-
"map <silent> <C-k> <C-W>+
"map <silent> <C-l> <C-w>>
"Leader Commands
let mapleader = " "

nnoremap <Leader>n :NERDTreeToggle<CR>
nnoremap <Leader>] :bnext<CR>
nnoremap <Leader>[ :bprev<CR>
map <Leader><F2> :call RenameFile()<cr>
"nmap <Leader><Leader> :NERDTreeToggle<cr>
nmap <Leader><Leader> <Plug>NetrwShrink
" replace selected text with whatever you paste in
vnoremap <leader>p "_dP

" yank to clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG

"Typo maps
command! Q q " Bind :Q to :q
map Q <Nop> " Disable Ex mode
command! W w " Instead of opening a Window manager, just write
map W <Nop>

"Use :w!! to save a file with sudo
cabbrev w!! w !sudo tee % >/dev/null
cnoremap vs vsplit
cnoremap rc :vsplit ~/.config/dotfiles/vimrc<cr>
cnoremap vj :vsplit ~/Documents/notes/Vim.md<cr>
