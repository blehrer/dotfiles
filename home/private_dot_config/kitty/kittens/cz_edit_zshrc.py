import os


def main(args):
    os.system('/opt/homebrew/bin/chezmoi edit $HOME/.zshrc')


if __name__ == "__main__":
    main()
