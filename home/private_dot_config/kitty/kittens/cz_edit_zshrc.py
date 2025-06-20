import os


def main(args):
    home = os.getenv('HOME')
    cz_lx1 = os.path.join(home, '.local', 'bin', 'chezmoi')
    cz_lx2 = os.path.join(home, '.bin', 'chezmoi')
    cz_brew = '/opt/homebrew/bin/chezmoi'
    for path in [cz_brew, cz_lx1, cz_lx2]:
        if os.path.exists(path):
            os.system([path, 'edit', os.path.join(home, '.zshrc')])
        else:
            os.system(
                f'echo {path} doesnt exist >> /Users/nobut/scratch/log.py.log')


if __name__ == "__main__":
    main()
