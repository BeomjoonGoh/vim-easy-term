import os
import sys
import inspect

if os.environ.get('VIM_TERMINAL') is None:
    sys.exit("You are not in vim.")

if os.environ.get('PYTHONSTARTUP') is not None:
    pythonrc = os.environ.get('PYTHONSTARTUP')
    with open(pythonrc, 'rb') as f:
        exec(compile(f.read(), pythonrc, 'exec'), globals())

class ToVim():
    """docstring for ToVim"""
    def help(self):
        print(inspect.cleandoc(self.__doc__))

    def set(self):
        print("Setting this terminal buffer as primary.")
        self._send("call", "set_term_bufnr")

    def _send(self, cmd, name, args = []):
        if cmd == "call":
            fullname = 'easy_term#Tapi_'+name
            arguments = '[' + ','.join(['"'+arg+'"' for arg in args]) + ']'
        elif cmd == "drop":
            fullname = os.path.abspath(name)
            arguments = '{' + ' '.join(args) +'}'
        print('\033]51;["{}", "{}", {}]\007'.format(cmd, fullname, arguments), end='')

tovim = ToVim()

print("Python", sys.version, "on", sys.platform)
print('Type "help", "copyright", "credits" or "license" for more information.')
