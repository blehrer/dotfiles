" Gradle and Groovy set up for Tagbar plugin
" (https://github.com/majutsushi/tagbar).

if !exists(':Tagbar')
    finish
endif

let g:tagbar_type_groovy = {
    \ 'ctagstype' : 'Groovy',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'c:classes',
        \ 'i:interfaces',
        \ 't:traits',
        \ 'e:enums',
        \ 'r:constructors',
        \ 'm:methods',
        \ 'f:fields:1'
    \ ],
    \ 'deffile'   : expand('<sfile>:p:h:h') . '/ctags/groovy.ctags'
\ }
