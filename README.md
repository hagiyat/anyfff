# anyfff

fuzzy finder wrapper plugin for fish.

inspired from [mollifier/anyframe](https://github.com/mollifier/anyframe)

## Features

You can use your favorite fuzzy finder!

### Widget

*Main Command*: anyfff_widget

*Sub Commands*:

- put_history
  - Put the command selected from the command history on the commandline
- put_filename
  - Put the filename selected from some files on the commandline
  - The candidates are optimized according to the content of the command line
  - Currently it does not correspond to several git commands :cry:
- checkout_git_branch
  - Checkout to branch selected from branch including remote branch
- put_git_branch
  - Put the selected branch on the commandline
- kill_process
  - Kill 9 for the selected running process
  - Although it is a standard, I wonder if I will use it ...?
- cdr
  - Select from cd history and directories around the current directory and cd to that directory


## Install

With [*fundle*](https://github.com/tuvistavie/fundle)

1. add to your `config.fish`

```fish
fundle plugin hagiyat/anyfff
```

2. `$ fundle install`

## Requirements

- An interactive filter
  - [**sk**](https://github.com/lotabout/skim)
  - [**peco**](https://github.com/peco/peco)
  - [**fzf**](https://github.com/junegunn/fzf)
  - ...

Choose any one from among these.

## Usage

Please assign favorite key bind to widget, set alias and use it.

Example:

```fish
bind \cr 'anyfff_widget put_history'
bind \cx\cx 'anyfff_widget put_filename'
bind \cx\cg 'anyfff_widget checkout_git_branch'
bind \cx\cb 'anyfff_widget put_git_branch'

alias cd 'anyfff_widget cdr'
```

## Configurations

The default settings will be applied without setting anything :+1:

### finder application

```fish
if type -q sk
  set -x SKIM_DEFAULT_OPTIONS '--ansi'
  set -x ANYFFF__FINDER_APP sk
  set -x ANYFFF__FINDER_APP_OPTION_MULTIPLE '-m'
end
```

### cd history

```fish
# The contents of the peripheral directory to which you cd are cached.
set -x ANYFFF__CDR_CACHE_PATH ~/.local/share/fish/anyfff/cdr
# This is the retention period (days) setting.
set -x ANYFFF__CDR_CACHE_LIFETIME 3
set -x ANYFFF__FILESEARCH_MAXDEPTH 2
```

### for put_filename widget

```fish
# Setting scan range for file search
set -x ANYFFF__FILESEARCH_MAXDEPTH 2
```


## License

[MIT][license-link]
