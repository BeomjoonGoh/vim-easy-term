# Easy Term

The Easy Term makes using vim's `:terminal` feature easier to use.


## Installation

Use your favorite plugin manager.  For example using
[vim-plug](https://github.com/junegunn/vim-plug),
 * Add `Plug 'BeomjoonGoh/vim-easy-term'` in your vimrc, and
 * Run `:PlugInstall`.


## Features

* Make aliases for opening the vim terminal emulator.  For example, when
  opening a bash shell, you would want it to be a login shell so that bashrc
  is sourced.  And if you also want the terminal buffer to go away after
  exiting bash, we have to type
  ```vim
  :terminal ++close bash --login
  ```
  and it quickly becomes unwieldy.  Using `:Term`, alias can be set (such as
  an empty string, see `easy_term_alias`), 
  ```vim
  let g:easy_term_alias[''] = 'bash --login'
  ```
  then just `:Term` will do that for you.

  Furthermore tab-completion is supported using the aliases, 
  ```vim
  :Term <Tab>
  bash    ex    py3   zsh   ...
  ```
  Of course any lengthy command without defining alias can be directly passed
  to `:Term` as well:
  ```vim
  :Term whatever --with --option
  ```

* `:Term` sets a few options for `term_start()`.  Options such as
  `term_finish`, `term_cols`, are set.

* `tovim` utility for Bash and Python, if you choose to use, can do a few
  useful things.  For example, if you open a buffer inside the terminal using
  ```bash
  $ vim file.txt
  ```
  that instance of vim is inside of terminal and not so useful.  In such case,
  ```bash
  $ tovim vs file.txt
  ```
  will vertically split open 'file.txt' in the parent vim.

* Send texts from an open buffer to the terminal with a mapping.  When working
  with a scripting language, often it is useful to test sections of the script.
  For example if you open an interactive Python in a terminal and in a python
  file, using `<Plug>(EasyTermSendText)` mapping on the lines
  ```python
  a = 3
  print(1 + a)
  ```
  will send the lines to the terminal.  The terminal would look something like
  ```python
  >>> a = 3
  >>> print(1 + a)
  4
  ```
* Paste/Yank the last output of the terminal to an open buffer with a
  mapping using `<Plug>(EasyTermPutLast)`, `<Plug>(EasyTermYankLast)`.


## Commands and Mappings

### Commands

```vim
:Term[!] [{cmd}]
```
Split opens a vim terminal emulator window running `{cmd}`.  The `{cmd}` is
tested whether it is an alias defined in `easy_term_alias`.

When `[!]` is added, opens the terminal window using the current window

Any `<mods>` for spliting window can be used such as `:vertical`.

Usage Examples:

    :Term
    :Term bash
    :vertical Term python3 -i myprogram.py

If you want to define additional commands with completion, for example `Tterm`
that opens a terminal window in a new tab, put this in your vimrc:
```vim
command! -nargs=? -complete=custom,easy_term#Complete Tterm tab Term <args>
```


### Mappings

|`{mod}`| `{rhs}`                  | Description
|:-----:|:-------------------------|:-----------------------------------------
| n, x  |`<Plug>(EasyTermSendText)`| Send a line or selected text to terminal
| n     |`<Plug>(EasyTermPutLast)` | Paste last output of terminal to buffer
| t     |`<Plug>(EasyTermYankLast)`| Yank last output of terminal
| n     |`<Plug>(EasyTermCdVim)`   | Change cwd of vim & shell to buffer's dir
| t     |`<Plug>(EasyTermCdTerm)`  | Change cwd of shell to vim's cwd
| t     |`<Plug>(EasyTermCdSet)`   | Make the current terminal primary

To use any of the <Plug> mapping, add the following in your vimrc: `{mod}map
{lhs} {rhs}`.  For Example,
```vim
:nmap <Leader>p <Plug>(EasyTermPutLast)
```
See `:help easy_term_usage` for more information.


## Communication Between Vim and Terminal

### Vim to terminal

Currently, there are three mappings for vim to terminal communication:
 * `<Plug>(EasyTermSendText)`
 * `<Plug>(EasyTermCdVim)`
 * `<Plug>(EasyTermCdTerm)`


### Terminal to vim

To use this functionality, use `:Term` with

    bash --rcfile {where_plugin_is}/scripts/setup_bash.sh
    python3 -i {where_plugin_is}/scripts/setup_python.py

which is the default value of `easy_term_alias`.

For **Bash**, see
```bash
$ tovim help
```
For **Python**, see
```python
>>> help(tovim)
```
See `:help easy_term_communication` for more information.


## Settings

Available settings with its default values:
```vim
let g:easy_term_rows   = "50%"
let g:easy_term_cols   = "50%"
let g:easy_term_winfix = 1
let g:easy_term_alias  = {
    \ ''     : 'bash --rcfile scripts/setup_bash.sh',
    \ 'bash' : 'bash --rcfile scripts/setup_bash.sh',
    \ 'py3'  : 'python3 -i scripts/setup_python.py',
    \ 'ex'   : 'vim -e'
    \}
```
To overwrite an alias or add a new one, use any `Dictionary` modification
method. Example:
```vim
let g:easy_term_alias = {}
let g:easy_term_alias['zsh'] = 'zsh -i'
```
See `:help easy_term_settings` for more information.


## License

Under the MIT License. (c) Copyright 2020 Beomjoon Goh.
