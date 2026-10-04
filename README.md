# zsh-ls-branch-label

A zsh plugin that shows the current git branch next to repository directories when you run a plain `ls`.

```console
$ ls
api (main)              docs                    notes.md
archive.zip             mobile (feature/login)  web (develop)
```

Useful when a folder like `~/workspace` holds many repositories and you want to see at a glance which branch each one is on.

## Features

- Adds `(branch)` to every subdirectory that has `.git` at its root.
- Shows the short commit hash (e.g. `(59a9b5b)`) when HEAD is detached.
- Supports worktrees and submodules (repositories whose `.git` is a file).
- Fast: reads `.git/HEAD` directly instead of running `git` for each directory.
- Keeps `ls`'s colors and sort order, and lays entries out in columns that fit the terminal width.
- Changes nothing else. The labels appear only for a plain `ls` or `ls <dir>` printed to a terminal. With any option (`ls -a`, `ls -l`, …), or when the output is piped or redirected, the real `ls` runs unchanged, so scripts and pipelines are unaffected.

## Requirements

- zsh 5.0 or later
- macOS (BSD `ls`). See [Limitations](#limitations) for other platforms.
- No other dependencies. `git` itself is not required.

## Installation

See [INSTALL.md](INSTALL.md) for instructions for each plugin manager, and how to update.

Quick start with [zgen](https://github.com/tarjoilija/zgen): add this line inside your `if ! zgen saved; then … fi` block in `~/.zshrc`:

```zsh
zgen load freddi-kit/zsh-ls-branch-label zsh-ls-branch-label.plugin.zsh main
```

zgen uses the `master` branch by default, so the `main` branch must be given explicitly. Then run `zgen reset` and open a new shell.

## Usage

Just run `ls`:

| Command | Branch labels shown? |
|---|---|
| `ls` | Yes |
| `ls ~/workspace` | Yes |
| `ls -a`, `ls -l`, `ls -la ~/workspace`, … | No (real `ls`) |
| `ls a b` (two or more paths) | No (real `ls`) |
| `ls \| grep foo`, `ls > files.txt` | No (real `ls`) |

To bypass the plugin for a single call, use `command ls`.

## Configuration

| Variable | Default | Description |
|---|---|---|
| `LS_BRANCH_LABEL_COLOR` | `35` (magenta) | [SGR](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR) color code for the label. Set it to an empty string for no color. |

The variable is read every time `ls` runs, so you can set it before or after loading the plugin:

```zsh
LS_BRANCH_LABEL_COLOR='1;33'  # bold yellow
LS_BRANCH_LABEL_COLOR='2'     # dim
LS_BRANCH_LABEL_COLOR=''      # no color
```

## How it works

The plugin defines an `ls` shell function. If the call qualifies (a terminal, no options, at most one directory argument), the function:

1. Looks at each subdirectory for `.git` and reads its `HEAD` to get the branch name.
2. Runs the real `ls -1` with colors forced, so the order and colors match what `ls` would show.
3. Adds the labels and prints the entries in columns sized to `$COLUMNS`.

If no subdirectory is a git repository, it just runs the real `ls`.

## Limitations

- **macOS-oriented.** The plugin is written for BSD `ls` and its `CLICOLOR` / `-G` color handling. On Linux, a common alias such as `alias ls='ls --color=auto'` counts as an option, so the plugin just runs the real `ls`. Without such an alias, labels work but GNU `ls`'s own colors are not shown.
- **Aliases to other tools.** If `ls` is an alias for `eza`, `lsd`, etc., the alias wins and this plugin is never called.
- **Column layout is approximate.** The columns are similar to, but not exactly the same as, native `ls`.
- **Filenames containing newlines** break the layout.
- **Repositories using the reftable backend** (`git init --ref-format=reftable`) may not show the correct branch.

## License

[MIT](LICENSE)
