import os
import itertools


def main(args):
    home = os.getenv('HOME')
    cz_lx1 = os.path.join(home, '.local', 'bin', 'chezmoi')
    cz_lx2 = os.path.join(home, '.bin', 'chezmoi')
    cz_brew = '/opt/homebrew/bin/chezmoi'
    paths = list(itertools.dropwhile(lambda p: not os.path.exists(p), [
        cz_brew, cz_lx1, cz_lx2]))
    if len(paths) > 0:
        os.system(f'{paths[0]} edit {args}')


if __name__ == "__main__":
    main()
