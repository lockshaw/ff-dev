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

compiler gcc
set makeprg=cd\ build\ &&\ make

function GetMyPath()
  return expand('<stack>:p:h') .. "/../"
endfunction

function FixTerm() 
  1Tkill
  1Tclear!
endfunction

let g:buildpath = $MYDIR .. "/build/"

function RunCmake()
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
        \ -DCUDA_PATH="$(dirname $(which nvcc))/../lib/stubs"
        \ -DCMAKE_CUDA_ARCHITECTURES=60 
        \ -DCMAKE_CXX_COMPILER="clang++" 
        \ -DCMAKE_C_COMPILER="clang" 
        \ -DCMAKE_CUDA_COMPILER="clang++" 
        \ -DCMAKE_CUDA_HOST_COMPILER="clang++" .. 
        \ && compdb -p . list > ../compile_commands.json; 
        \ popd > /dev/null
        \ '
endfunction

function Build()     
  call FixTerm()
  1T pushd g:buildpath
      \ && clear 
      \ && make 2>&1; 
      \ popd > /dev/null
endfunction 

function Test()
  call FixTerm()
  1T pushd ~/hax/dev/ff/gfmgn/build 
      \ && clear 
      \ && make 
      \ && ctest --output-on-failure; 
      \ popd > /dev/null
endfunction

function Fix() 
  lua vim.lsp.buf.code_action()
endfunction

nnoremap BB :call Build()<CR>
command! RunCmake :call RunCmake()
command! Fix :call Fix()
nnoremap <leader>f :call Fix()<CR>
