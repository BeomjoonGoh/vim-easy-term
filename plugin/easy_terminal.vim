if exists("g:loaded_easy_terminal_plugin") || !has('terminal')
  finish
endif
let g:loaded_easy_terminal_plugin = 1

function! s:SetAlias() abort
  let l:script_dir = expand("<sfile>:p:h:h") . '/script'
  let l:default_alias = {
      \ ''     : 'bash --rcfile '.l:script_dir.'/setup_bash.sh',
      \ 'bash' : 'bash --rcfile '.l:script_dir.'/setup_bash.sh',
      \ 'py3'  : 'python3 -i '.l:script_dir.'/setup_python.py',
      \ 'ex'   : 'vim -e',
      \}
  let l:alias = get(g:, 'easy_terminal_alias', l:default_alias)
  for l:prog in keys(l:default_alias)
    let l:alias[l:prog] = get(l:alias, l:prog, l:default_alias[l:prog])
  endfor
  return l:alias
endfunction

" variables
let g:easy_terminal_rows   = get(g:, 'easy_terminal_rows', '15,18%')
let g:easy_terminal_cols   = get(g:, 'easy_terminal_cols','150,40%')
let g:easy_terminal_winfix = get(g:, 'easy_terminal_winfix', 1)
let g:easy_terminal_alias  = s:SetAlias()

" commands
command! -bang -nargs=? -complete=custom,easy_terminal#Complete Term call easy_terminal#Open("<mods>", <bang>0, <q-args>)

" key maps
nnoremap <silent> <Plug>(EasyTermSendText) :call easy_terminal#SendText()<CR>
xnoremap <silent> <Plug>(EasyTermSendText) :<C-u>call easy_terminal#SendText('v')<CR>
nnoremap <silent> <Plug>(EasyTermPutLast) :call easy_terminal#PutLastOutput()<CR>
tnoremap <silent> <Plug>(EasyTermYankLast) <C-w>:call easy_terminal#YankLastOutput()<CR>
nnoremap <silent> <Plug>(EasyTermCdVim) :call easy_terminal#CdVim()<CR>
tnoremap <silent> <Plug>(EasyTermCdTerm) <C-w>:call easy_terminal#CdTerm()<CR>
