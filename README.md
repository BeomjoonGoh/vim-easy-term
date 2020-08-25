# Easy Terminal

User defined commands that open `bash` in terminal emulator:

* `Bterm` : `botright call term_start()`
* `Vterm` : `vertical call term_start()`
* `Tterm` : `tab call term_start()`
* `Nterm` : `call term_start()`

Bash is invoked by `bash --rcfile ~/.vim/bin/setup_bash.sh`, which adds
`~/.vim/bin` in `$PATH` environment.  When terminal is opened, window height
(`min(18%, 15)` if `botright`) and width (`min(40%, 150)` if `vertical`) are
fixed. The terminal window is closed once the job is finished.

#### Terminal - Vim communication

`~/.vim/bin/2vim`

#### Vim -Terminal communication

