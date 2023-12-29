" =============================================================================
" Sources and runtimepath stuff
" =============================================================================

call plug#begin()
Plug 'dhruvasagar/vim-table-mode'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'fzf#install()' }
Plug 'junegunn/fzf.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'itsjunetime/rose-pine-vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'mattn/emmet-vim'

Plug 'dbeniamine/cheat.sh-vim'
Plug 'cespare/vim-toml'
Plug 'will133/vim-dirdiff'
Plug 'junegunn/vim-easy-align'
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
set number
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
let g:netrw_wiw=1
let g:netrw_usetab=40

" Store swap files in fixed location, not current directory.
set dir=~/.cache/vim/swap//
set undodir=~/.cache/vim/undo//
set undofile

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

" https://github.com/iamcco/markdown-preview.nvim
nmap <F8> <Plug>MarkdownPreviewToggle

" set to 1, nvim will open the preview window after entering the markdown buffer
" default: 0
let g:mkdp_auto_start = 0

" set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 1

" set to 1, the vim will refresh markdown when save the buffer or
" leave from insert mode, default 0 is auto refresh markdown as you edit or
" move the cursor
" default: 0
let g:mkdp_refresh_slow = 0

" set to 1, the MarkdownPreview command can be use for all files,
" by default it can be use in markdown file
" default: 0
let g:mkdp_command_for_global = 0

" set to 1, preview server available to others in your network
" by default, the server listens on localhost (127.0.0.1)
" default: 0
let g:mkdp_open_to_the_world = 0

" use custom IP to open preview page
" useful when you work in remote vim and preview on local browser
" more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
" default empty
let g:mkdp_open_ip = ''

" specify browser to open preview page
" for path with space
" valid: `/path/with\ space/xxx`
" invalid: `/path/with\\ space/xxx`
" default: ''
let g:mkdp_browser = ''

" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 0

" a custom vim function name to open preview page
" this function will receive url as param
" default is empty
let g:mkdp_browserfunc = ''

" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: mean the cursor position alway show at the middle of the preview page
"   top: mean the vim top viewport alway show at the top of the preview page
"   relative: mean the cursor position alway show at the relative positon of the preview page
" hide_yaml_meta: if hide yaml metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
" content_editable: if enable content editable for preview page, default: v:false
" disable_filename: if disable filename header for preview page, default: 0
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0,
    \ 'toc': {}
    \ }

" use a custom markdown style must be absolute path
" like '/Users/username/markdown.css' or expand('~/markdown.css')
let g:mkdp_markdown_css = ''

" use a custom highlight style must absolute path
" like '/Users/username/highlight.css' or expand('~/highlight.css')
let g:mkdp_highlight_css = ''

" use a custom port to start server or empty for random
let g:mkdp_port = ''

" preview page title
" ${name} will be replace with the file name
let g:mkdp_page_title = '「${name}」'

" recognized filetypes
" these filetypes will have MarkdownPreview... commands
let g:mkdp_filetypes = ['markdown']

" set default theme (dark or light)
" By default the theme is define according to the preferences of the system
let g:mkdp_theme = 'dark'


" =============================================================================
" Colorscheme
" =============================================================================
set background=dark
colorscheme habamax
"colorscheme wildcharm
"colorscheme zaibatsu
"colorscheme catppuccin_mocha
"colorscheme gruvbox

"" Lightline

set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'rosepine',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'absolutepath', 'modified' ] ],
      \ }
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

"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
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

nnoremap <Leader>x :clist<cr>
nnoremap <Leader>j :cnext<C-m>
nnoremap <Leader>k :cprev<C-m>
nnoremap <Leader>n :NERDTreeToggle<CR>
nnoremap <Leader>. :NERDTreeCWD<CR>
nnoremap <Leader>] :bnext<CR>
nnoremap <Leader>[ :bprev<CR>
nnoremap <Leader><F2> :call RenameFile()<cr>
nnoremap <Leader><Leader> :Files<CR>
nnoremap <Leader><Leader>g :GFiles<CR>
nnoremap <Leader>/ :Ag<CR>
nnoremap <Leader><CR> :source $DOTFILES_HOME/vimrc<CR>
nnoremap <Leader>q :q<cr>
nnoremap <Leader>w :w<cr>

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

" dhruvasagar/vim-table-mode
nnoremap <leader>tm :TableModeToggle<cr>
let g:table_mode_corner='|'



"Move lines while formatting
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"The opposite of J
nnoremap <c-j> a<cr><esc>k$

"Leader Commands
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

" session management
au FocusLost * silent! wa
function! MakeSession()
  let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
  if (filewritable(b:sessiondir) != 2)
    exe 'silent !mkdir -p ' b:sessiondir
    redraw!
  endif
  let b:filename = b:sessiondir . '/session.vim'
  exe "mksession! " . b:filename
endfunction

function! LoadSession()
  let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
  let b:sessionfile = b:sessiondir . "/session.vim"
  if (filereadable(b:sessionfile))
    exe 'source ' b:sessionfile
  else
    echo "No session loaded."
  endif
endfunction

" Adding automatons for when entering or leaving Vim
if(argc() == 0)
    au VimEnter * nested :call LoadSession()
endif
au VimLeave * :call MakeSession()

" =============================================================================
" FileTypes
" =============================================================================

autocmd FileType vim,sshconfig,bash,sh,yaml,yml,json,*.md setlocal shiftwidth=2 tabstop=2
autocmd FileType java,xml setlocal shiftwidth=4 tabstop=4
autocmd FileType * autocmd BufWritePre <buffer> %s/\s\+$//e
" Treat .json files as .js
autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
" Treat .md files as Markdown
autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
autocmd FileType gitrebase setlocal noswapfile
autocmd FileType xml exe ":silent %!xmllint --format --recover - 2>/dev/null"

" =============================================================================
" Plugin: DirDiff
" =============================================================================
let g:DirDiffExcludes = "draft.configuration.properties,local.properties,override.*"


" Plugin: EasyAlign

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
