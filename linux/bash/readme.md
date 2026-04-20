# Bash "enough" configuration

## Installing the configuration

> Warning: `$HOME`-level config files will be overriden by the ones in 
> this directory if configured by the `apply.sh` script.

1. Run `bash setup.sh` (just once)
1. Run `bash apply.sh` (after `git pull`)
1. Restart your shell.

## Editing the config

1. All new config files in `.config/enough` must start with '`.`' to be loaded
1. `$HOME`-level config files like `.vimrc` or `.inputrc` should be explicitly loaded with a `cp` statement in `apply.sh`
