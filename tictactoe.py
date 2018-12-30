"""

"""

import os
import sys
from subprocess import Popen, PIPE
from Tkinter import Tk, Button
from tkMessageBox import showinfo
from tkFont import Font


PROLOG = os.path.join(os.path.dirname(__file__), 'tic.pl')

MODEL_ORBACH = 'x'
MODEL_GITLITZ = 'o'
MODEL_UNKNOWN = '~'


def GameModel(n):
    matrix = {}
    for i in xrange(n):
        for j in xrange(n):
            matrix[i, j] = MODEL_UNKNOWN
    return matrix


class GameWindow(object):
    ROOT = Tk()
    ROOT.title('Tic-Tac-Toe (NxN)')
    ROOT.resizable(width=False, height=False)
    FONT = Font(family="Ariel", size=18)

    def __init__(self, n, level):
        self.model = GameModel(int(n))
        args = [r"C:\Program Files\swipl\bin\swipl.exe", PROLOG, level, n]
        print args
        self.prolog = Popen(args, stdin=PIPE, stdout=PIPE)
        self._buttons = {}
        for x, y in self.model:
            button = Button(self.ROOT, command=lambda x=x, y=y: self._button_click(x, y), font=self.FONT)
            button.grid(row=x, column=y, sticky="WE")
            self._buttons[x, y] = button
        self.update()

    def play(self):
        self.ROOT.mainloop()

    def _button_click(self, x, y):
        self._button_play(x, y, MODEL_ORBACH)
        self.prolog.stdin.write('{}{}'.format(x, y))
        self.prolog.stdin.flush()
        print self.prolog.poll()
        print self.prolog.stdout.read(1)
        x, y = int(self.prolog.stdout.read(1)), int(self.prolog.stdout.read(1))
        self._button_play(x, y, MODEL_GITLITZ)
        self.update()

    def _button_play(self, x, y, v):
        self.model[x, y] = v
        if self._gameover():
            showinfo("Game Over", "test")
            exit()
        self.update()

    VISUALIZE = {
        MODEL_ORBACH: ('X', 'disabled'),
        MODEL_GITLITZ: ('O', 'disabled'),
        MODEL_UNKNOWN: ('    ', 'normal'),
    }

    def update(self):
        for x, y in self.model:
            button = self._buttons[x, y]
            text, state = self.VISUALIZE[self.model[x, y]]
            button.configure(text=text, state=state)

    def _gameover(self):
        for (x, y), player in self.model.iteritems():
            if player != MODEL_UNKNOWN and self._match(x, y, player):
                return True

    def _match(self, x, y, player):
        return self._match_row(x, y, player) or self._match_col(x, y, player)\
               or self._match_ldiag(x, y, player) or self._match_rdiag(x, y, player)

    def _match_row(self, x, y, player):
        try:
            return player == self.model[x, y+1] == self.model[x, y+2] == self.model[x, y+3]
        except KeyError:
            return False

    def _match_col(self, x, y, player):
        try:
            return player == self.model[x+1, y] == self.model[x+2, y] == self.model[x+3, y]
        except KeyError:
            return False

    def _match_ldiag(self, x, y, player):
        try:
            return player == self.model[x+1, y+1] == self.model[x+2, y+2] == self.model[x+3, y+3]
        except KeyError:
            return False

    def _match_rdiag(self, x, y, player):
        try:
            return player == self.model[x+1, y-1] == self.model[x+2, y-2] == self.model[x+3, y-3]
        except KeyError:
            return False


def main():
    n = sys.argv[1] if len(sys.argv) > 1 else '5'
    level = sys.argv[2] if len(sys.argv) > 2 else '0'
    game = GameWindow(n, level)
    game.play()


if __name__ == '__main__':
    main()
