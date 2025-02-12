if exists("g:loaded_easy_term") || !has('terminal')
  finish
endif
let g:loaded_easy_term = 1

let s:cpo_save = &cpo
set cpo&vim

let s:term_bufnr = -1

function! easy_term#Open(mods, bang, prog) abort
  let l:term_options = {
      \ 'term_finish' : 'close',
      \ 'term_api' : 'easy_term#Tapi_',
      \ 'curwin' : a:bang,
      \}
  if a:mods =~ '\m\(botright\)\|\(topleft\)'
    call s:DefineWinfixAugroup(g:easy_term_winfix)
    if a:mods =~ 'vertical'
      let l:term_options['term_cols'] = s:CalculateMin(g:easy_term_cols, &columns)
    else
      let l:term_options['term_rows'] = s:CalculateMin(g:easy_term_rows, &lines)
    endif
  else
    call s:DeleteWinfixAugroup(g:easy_term_winfix)
  endif

  let l:cmd = get(g:easy_term_alias, a:prog, a:prog)
  let l:term_options['term_name'] = '[Term] '.l:cmd->split()[0]

  execute a:mods 'call term_start("'.l:cmd.'", l:term_options)'
  let s:term_bufnr = term_list()[0]

  augroup easy_term_close
    autocmd!
    autocmd BufWinLeave *
        \ if &buftype == 'terminal' |
        \   call s:UpdateTermBufnr() |
        \ endif
  augroup END
endfunction

function! easy_term#CdTerm() abort
  if getbufvar(s:term_bufnr, '&buftype') != 'terminal'
    return
  endif

  let l:cmd = "cd " . fnameescape(getcwd()) . "\<CR>"
  call term_sendkeys(s:term_bufnr, l:cmd)
endfunction

function! easy_term#CdVim() abort
  tcd %:p:h
  call easy_term#CdTerm()
endfunction

function! easy_term#SendText(...) abort
  if getbufvar(s:term_bufnr, '&buftype') != 'terminal'
    return
  endif

  let l:text = get(a:,1,'') == 'v' ? s:GetSelectedText() : getline(".")."\n"

  let l:ftype = getbufvar("%", '&filetype')
  if l:ftype == 'vim'
    let l:text = s:ProcessVimscript(l:text)
  elseif l:ftype == 'python'
    let l:text = s:ProcessPython(l:text)
  endif

  call term_sendkeys(s:term_bufnr, l:text)
endfunction

function! easy_term#YankLastOutput() abort
  if getbufvar(s:term_bufnr, '&buftype') != 'terminal'
    return
  endif
  " More sophisticated method for prompt?
  " !!Does not work well when PS2 exists (python, bash, ...)
  " $ ps -p $PID -o comm=  -> process name
  " $ pgrep -P $PID      -> child pid list
  " user_dictionary = { 'child_process_name': 'regex_prompt', ... }
  " let l:prompt = haskey() ? user_dictionary["child_process_name"] : term_getline(s:term_bufnr, '.')[-2:-1]
  call feedkeys("\<C-w>N", 'n')
  call cursor(line('$'), 1)
  let l:prompt = term_getline(s:term_bufnr, ".")[-2:-1]
  let l:start = search(l:prompt, 'bW') + 1
  let l:end = line('$') - 1
  call feedkeys("i", 'n')
  call setreg('"', getbufline(s:term_bufnr, l:start, l:end))
endfunction

function! easy_term#PutLastOutput() abort
  if getbufvar(s:term_bufnr, '&buftype') != 'terminal'
    return
  endif

  execute bufwinnr(s:term_bufnr).'wincmd w'
  call easy_term#YankLastOutput()
  wincmd p
  normal! p
endfunction

function! easy_term#GetBufnr() abort
  if index(term_list(), s:term_bufnr) == -1
    return -1
  endif
  return s:term_bufnr
endfunction

function! easy_term#SetBufnr(bufnr) abort
  if index(term_list(), a:bufnr) == -1
    return -1
  endif
  let s:term_bufnr = a:bufnr
  echomsg "This terminal(" . s:term_bufnr . ") is now set to primary."
endfunction

function! easy_term#Complete(A,L,P) abort
  return join(sort(keys(g:easy_term_alias)),"\n")
endfunction

" terminal-api
function! easy_term#Tapi_set_term_bufnr(bufnr, arglist) abort
  let s:term_bufnr = a:bufnr
  echomsg "This terminal(" . s:term_bufnr . ") is now set to primary."
endfunction

function! easy_term#Tapi_change_directory(bufnr, arglist) abort
  let l:cwd = join(a:arglist[:-2], " ")
  let l:do_cd = a:arglist[-1]
  if getcwd() != l:cwd
    execute 'tcd' l:cwd
  endif
  if l:do_cd
    call easy_term#CdTerm()
  endif
endfunction

function! easy_term#Tapi_open(bufnr, arglist) abort
  if a:arglist[0] == 's'
    let l:mode = ''
  elseif a:arglist[0] == 'v'
    let l:mode = 'vertical'
  elseif a:arglist[0] == 't'
    let l:mode = 'tab'
  endif
  let l:file = a:arglist[1]
  let l:cmd = (l:file == 'new') ? '' : 'split'
  wincmd W
  execute l:mode l:cmd l:file
endfunction

function! easy_term#Tapi_make(bufnr, arglist) abort
  execute 'cgetfile' a:arglist[0]
  botright cwindow
  call delete(a:arglist[0])
endfunction

" local function
function! s:ProcessVimscript(code) abort
  " Remove line-continuation-comment ("\ ) then remove line-continuation (\)
  return split(a:code, '\m\n\+')->
      \filter({idx, val -> match(val, '\m^\s*"\\ ')})->
      \join("\n")->
      \substitute('\m\n\s*\\\s*', " ", 'g') . "\n"
endfunction

function! s:ProcessPython(code) abort
  let l:first_indent = match(a:code,'\m\w')
  let l:text = ""
  let l:previous_indent = 0
  for l:line in split(a:code, '\m\n\+')
    let l:line=l:line[l:first_indent:]
    let l:current_indent = match(l:line, '\m\w')
    if !l:current_indent && l:previous_indent && split(l:line)[0] !~ 'el\(se\|if\)'
      let l:text .= "\n"
    endif
    let l:text .= l:line."\n"
    let l:previous_indent = l:current_indent
  endfor
  return l:previous_indent ? l:text."\n" : l:text
endfunction

function! s:GetSelectedText() abort
  let l:old_reg = getreg('"')
  let l:old_regtype = getregtype('"')
  normal! gvy
  let l:ret = getreg('"')
  call setreg('"', l:old_reg, l:old_regtype)
  execute "normal! \<Esc>"
  return l:ret
endfunction

function! s:CalculateMin(expr, lim) abort
  let l:e = split(a:expr, ',')
  call map(l:e, { _, val -> (val =~ '%$') ? a:lim * str2nr(val[:-2]) / 100 : str2nr(val) })
  return min(l:e)
endfunction

function! s:DefineWinfixAugroup(do)
  if a:do
    augroup easy_term_open
      autocmd!
      autocmd TerminalOpen *
          \ if &buftype == 'terminal' |
          \   setlocal winfixheight winfixwidth |
          \   wincmd = |
          \ endif
    augroup END
  endif
endfunction

function! s:DeleteWinfixAugroup(do) abort
  if a:do
    augroup easy_term_open
      autocmd!
    augroup END
  endif
endfunction

function s:UpdateTermBufnr() abort
  if len(term_list()) > 1 && term_list()[0] == s:term_bufnr
    let s:term_bufnr = term_list()[1]
  else
    let s:term_bufnr = -1
  endif
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
