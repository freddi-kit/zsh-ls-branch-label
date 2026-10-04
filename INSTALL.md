# Installation Guide

## Overview

`zsh-ls-branch-label` adds the current git branch next to every repository directory when you run a plain `ls`.

Before:

```console
$ ls ~/workspace
api          archive.zip  docs         mobile       notes.md     web
```

After:

```console
$ ls ~/workspace
api (main)              docs                    notes.md
archive.zip             mobile (feature/login)  web (develop)
```

`ls` with any option (`ls -a`, `ls -l`, …), or with its output piped or redirected, behaves exactly as before.

The plugin is a single `zsh-ls-branch-label.plugin.zsh` file at the repository root, which is the standard zsh plugin layout. Any plugin manager that loads `*.plugin.zsh` files can use it.

## Contents

- [zgen](#zgen)
- [zgenom](#zgenom)
- [zinit](#zinit)
- [antidote](#antidote)
- [antigen](#antigen)
- [sheldon](#sheldon)
- [zplug](#zplug)
- [Oh My Zsh](#oh-my-zsh)
- [Manual](#manual)
- [Updating](#updating)

After installing, open a new terminal (or run `exec zsh`) and run `ls` in a directory that contains git repositories.

## zgen

Add the `load` line inside the `if ! zgen saved` block in `~/.zshrc`:

```zsh
source "$HOME/.zgen/zgen.zsh"

if ! zgen saved; then
  zgen oh-my-zsh
  # ...your other plugins...
  zgen load freddi-kit/zsh-ls-branch-label zsh-ls-branch-label.plugin.zsh main

  zgen save
fi
```

zgen clones the `master` branch unless told otherwise, so the line above names the file and the `main` branch explicitly.

zgen caches its init script, so regenerate it:

```sh
zgen reset
exec zsh
```

## zgenom

```zsh
zgenom load freddi-kit/zsh-ls-branch-label
```

Then run `zgenom reset` and `exec zsh`.

## zinit

```zsh
zinit light freddi-kit/zsh-ls-branch-label
```

## antidote

Add this line to `~/.zsh_plugins.txt`:

```text
freddi-kit/zsh-ls-branch-label
```

## antigen

```zsh
antigen bundle freddi-kit/zsh-ls-branch-label
antigen apply
```

## sheldon

```sh
sheldon add zsh-ls-branch-label --github freddi-kit/zsh-ls-branch-label
```

## zplug

```zsh
zplug "freddi-kit/zsh-ls-branch-label"
```

## Oh My Zsh

Clone the repository into your custom plugins directory:

```sh
git clone https://github.com/freddi-kit/zsh-ls-branch-label \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-ls-branch-label
```

Add it to the `plugins` array in `~/.zshrc`:

```zsh
plugins=(... zsh-ls-branch-label)
```

## Manual

Clone the repository anywhere and source the plugin from `~/.zshrc`:

```sh
git clone https://github.com/freddi-kit/zsh-ls-branch-label ~/.zsh/zsh-ls-branch-label
echo 'source ~/.zsh/zsh-ls-branch-label/zsh-ls-branch-label.plugin.zsh' >> ~/.zshrc
```

## Updating

| Method | Command |
|---|---|
| zgen | `zgen update` |
| zgenom | `zgenom update` |
| zinit | `zinit update freddi-kit/zsh-ls-branch-label` |
| antidote | `antidote update` |
| antigen | `antigen update` |
| sheldon | `sheldon lock --update` |
| zplug | `zplug update` |
| Oh My Zsh | `git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-ls-branch-label pull` |
| Manual | `git -C ~/.zsh/zsh-ls-branch-label pull` |
