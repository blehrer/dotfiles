" =============================================================================
" Sources and runtimepath stuff
" =============================================================================

" Vim 8 has native package management so we don't need Pathogen anymore
"" execute pathogen#infect()
"
" ### How to add new plugins (taken from https://shapeshed.com/vim-packages/)
"
" ```
" @dfd
" git submodule init
" git submodule add https://github.com/preservim/nerdtree.git homedir/.vim/pack/vendor/start/nerdtree
" git add .gitmodules  homedir/.vim/pack/vendor/start/nerdtree
" git commit
" ```
"
" #### Commit message format
"
" ```
" [vim plugin] nerdtree
"
" Source: https://github.com/preservim/nerdtree
"
" Process:
" ```
" git submodule init
" git submodule add https://github.com/preservim/nerdtree.git homedir/.vim/pack/vendor/start/nerdtree
" git add .gitmodules  homedir/.vim/pack/vendor/start/nerdtree
" git commit
" ```
"
" See https://shapeshed.com/vim-packages/
" ```

" =============================================================================
" Simple vanilla settings
" =============================================================================
set number
set relativenumber
set cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40
syntax enable
set tabstop=8
set shiftwidth=4
set encoding=utf-8
set shiftround " When at 3 spaces and I hit >>, go to 4, not 5.
set ignorecase
set smartcase
set smarttab
set wildmenu
set ruler
set lazyredraw
set undofile
set fileformat=unix

" Store swap files in fixed location, not current directory.
set dir=~/.vimswap//,/var/tmp//,/tmp//,.

" =============================================================================
" Plugin settings
" =============================================================================
let NERDTreeShowHidden=1

"au VimEnter * RainbowParenthesesToggle
"au Syntax * RainbowParenthesesLoadRound
"au Syntax * RainbowParenthesesLoadSquare
"au Syntax * RainbowParenthesesLoadBraces

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
map <silent> <C-h> <C-w><
map <silent> <C-j> <C-W>-
map <silent> <C-k> <C-W>+
map <silent> <C-l> <C-w>>

"Leader Commands
let mapleader = ","

nmap <Leader>f :CtrlP<CR>
nmap <Leader>m :NERDTreeToggle<CR>
nmap <Leader>n :TlistToggle<CR>
map <Leader><F2> :call RenameFile()<cr>

"Typo maps
command! Q q " Bind :Q to :q
map Q <Nop> " Disable Ex mode

"Use :w!! to save a file with sudo
cabbrev w!! w !sudo tee % >/dev/null
