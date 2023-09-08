"echom 'Loading .vimrc'

augroup ff_cpp
  autocmd!
  autocmd FileType cpp set tabstop=2 shiftwidth=2 expandtab
  autocmd FileType cpp set cino+=g0
augroup END

augroup ff_bash
  autocmd!
  autocmd FileType sh set tabstop=2 shiftwidth=2 expandtab
augroup END

augroup ff_vimscript
  autocmd!
  autocmd FileType vim set tabstop=2 shiftwidth=2 expandtab
augroup END

augroup ff_cmake
  autocmd!
  autocmd FileType cmake set tabstop=2 shiftwidth=2 expandtab
augroup END

compiler gcc
set makeprg=cd\ build\ &&\ make

function! GetMyPath()
  return fnamemodify(resolve(expand('<script>:p')), ':h')
endfunction

function! FixTerm() 
  1Tkill
  1Tclear!
endfunction

let g:mydir = $MYDIR
let g:buildpath = $MYDIR .. "/build/"
if !exists("g:target")
  if exists("g:test_target")
    let g:target = g:test_target
  else
    let g:target = "all"
  endif
endif
if !exists("g:test_target")
  let g:test_target = g:target
endif

function! RunCmake()
  call FixTerm()
  exec '1T mkdir -p '..g:buildpath..
      \ ' && pushd '..g:buildpath..
      \ ' && 
        \ cmake 
        \ -DCMAKE_CXX_FLAGS="-ftemplate-backtrace-limit=0" 
        \ -DCMAKE_BUILD_TYPE=Debug 
        \ -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 
        \ -DCMAKE_CXX_COMPILER_LAUNCHER=ccache 
        \ -DFF_CUDA_ARCH=60 
        \ -DCUDA_PATH="$(dirname $(which nvcc))/../"
        \ -DCMAKE_CUDA_ARCHITECTURES=60 
        \ -DCMAKE_CXX_COMPILER="clang++" 
        \ -DCMAKE_C_COMPILER="clang" 
        \ -DCMAKE_CUDA_COMPILER="clang++" 
        \ -DCMAKE_CUDA_HOST_COMPILER="clang++" .. 
        \ && compdb -p . list > ../compile_commands.json; 
        \ popd > /dev/null
        \ '
endfunction

function! Build()     
  call FixTerm()
  exec '1T pushd '..g:buildpath..'
      \ && clear 
      \ && CCACHE_BASEDIR=/home/lockshaw/hax/dev/ff make '..g:target..' 2>&1; 
      \ popd > /dev/null
      \ '
endfunction 

function! Test()
  call FixTerm()
  exec '1T pushd '..g:buildpath..'
      \ && clear 
      \ && CCACHE_BASEDIR=/home/lockshaw/hax/dev/ff make '..g:test_target..' 2>&1
      \ && ctest --progress --output-on-failure;
      \ popd > /dev/null
      \ '
endfunction

function! Fix() 
  lua vim.lsp.buf.code_action()
endfunction

let s:snippets_dir = GetMyPath() .. '/.snippets/'

let g:UltiSnipsEditSplit = "context"
let g:UltiSnipsSnippetStorageDirectoryForUltiSnipsEdit = s:snippets_dir
let g:UltiSnipsSnippetDirectories=[s:snippets_dir]
let g:UltiSnipsExpandTrigger = '<c-g>'
" let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsListSnippets = "<c-tab>"
let g:UltiSnipsJumpForwardTrigger = "<c-f>"
let g:UltiSnipsJumpBackwardTrigger = "<c-F>"
"
"
" let g:UltiSnipsJumpForwardTrigger = '<C-f>'
" let g:UltiSnipsJumpBackwardTrigger = '<C-F>'
" let g:UltiSnipsListSnippets = '<C-E>'

nnoremap BB :call Build()<CR>
nnoremap TT :call Test()<CR>
command! RunCmake :call RunCmake()
command! Fix :call Fix()
nnoremap <leader>f :call Fix()<CR>
