if exists("g:loaded_easy_terminal_plugin") || !has('terminal')
  finish
endif
let g:loaded_easy_terminal_plugin = 1

function! s:SetCommands() abort
  let l:script_dir = expand("<sfile>:p:h:h") . '/script'
  let l:default_commands = {
      \ 'bash' : 'bash --rcfile '.l:script_dir.'/setup_bash.sh',
      \ 'py3'  : 'python3 -i '.l:script_dir.'/setup_python.py',
      \ 'ex'   : 'vim -e',
      \}
  let l:commands = get(g:, 'easy_terminal_commands', l:default_commands)
  for l:prog in keys(l:default_commands)
    let l:commands[l:prog] = get(l:commands, l:prog, l:default_commands[l:prog])
  endfor
  return l:commands
endfunction

function! s:OpenComplete(A,L,P) abort
  return join(keys(g:easy_terminal_commands),"\n")
endfunction

" variables
let g:easy_terminal_rows     = get(g:, 'easy_terminal_rows', '15,18%')
let g:easy_terminal_cols     = get(g:, 'easy_terminal_cols','150,40%')
let g:easy_terminal_winfix   = get(g:, 'easy_terminal_winfix', 1)
let g:easy_terminal_commands = s:SetCommands()

" commands
if has("user_commands")
  command -nargs=? -complete=custom,s:OpenComplete Bterm call easy_terminal#Open("botright", <q-args>)
  command -nargs=? -complete=custom,s:OpenComplete Vterm call easy_terminal#Open("vertical", <q-args>)
  command -nargs=? -complete=custom,s:OpenComplete Nterm call easy_terminal#Open("new", <q-args>)
  command -nargs=? -complete=custom,s:OpenComplete Tterm call easy_terminal#Open("tab", <q-args>)
endif

" key maps
nnoremap <silent> <Plug>EasyTermCdVim :call easy_terminal#CdVim()<CR>
tnoremap <silent> <Plug>EasyTermCdTerm <C-w>:call easy_terminal#CdTerm()<CR>
nnoremap <silent> <Plug>EasyTermSendText :call easy_terminal#SendText('n')<CR>
vnoremap <silent> <Plug>EasyTermSendText :<C-u>call easy_terminal#SendText('v')<CR>
tnoremap <silent> <Plug>EasyTermYankLast <C-w>:call easy_terminal#YankLastOutput()<CR>
nnoremap <silent> <Plug>EasyTermPutLast :call easy_terminal#PutLastOutput()<CR>
