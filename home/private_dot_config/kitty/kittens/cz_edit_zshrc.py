import os

from pathlib import Path


def main(args):
    home = os.environ('HOME')
    cz_lx1 = os.path.join(home, '.local', 'bin', 'chezmoi')
    cz_lx2 = os.path.join(home, '.bin', 'chezmoi')
    cz_brew = Path.absolute('/opt/homebrew/bin/chezmoi')
    for path in [cz_brew, cz_lx1, cz_lx2]:
        if os.path.exists(path):
            os.system([path, 'edit', os.path.join(home, '.zshrc')])
            return


if __name__ == "__main__":
    main()
