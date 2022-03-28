" Gradle and Groovy set up for Tagbar plugin
" (https://github.com/majutsushi/tagbar).

if !exists(':Tagbar')
    finish
endif

let g:tagbar_type_gradle = {
    \ 'ctagstype' : 'Gradle',
    \ 'kinds'     : [
        \ 't:tasks',
        \ 'm:methods'
    \ ],
    \ 'deffile'   : expand('<sfile>:p:h:h') . '/ctags/gradle.ctags'
\ }
