# simultan.sh

CLI tool for running any command in parallel for all files with a given suffix.

## Features

- Executes a command once per matching file.
- Parallel execution using available CPU processing units.
- Optional directory depth limit with `-d`.
- Safe filename handling via null-delimited `find`/`xargs`.

## Requirements

- Bash
- `find`
- `xargs`
- `wc`
- `nproc` or `getconf` (or `sysctl` on macOS)

## Installation

Clone or copy the script, then make it executable:

```bash
chmod +x simultan.sh
```

## Usage

```bash
./simultan.sh [ -d <maxdepth> ] <suffix> <command> [args...]
```

- `<suffix>`: file suffix without or with dot (for example `wav`, `.wav`, `*.wav`)
- `<command>`: executable to run for each matching file
- `[args...]`: optional arguments passed to `<command>`

## Examples

Convert all `.wav` files in the current directory:

```bash
./simultan.sh wav lame --silent --preset insane
```

`wav` is the suffix, `lame` is the command and `--silent --preset insane` are lame's arguments.


Search up to 3 levels deep:

```bash
./simultan.sh -d 3 wav lame --silent --preset insane
```

## Exit behavior

The script exits with an error when:

- suffix or command is missing
- command is not available in `PATH`
- no matching files are found
- `-d` is provided without a value or is invalid

## License

MIT. See `LICENSE`.
