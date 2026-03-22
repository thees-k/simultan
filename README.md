# simultan.sh

CLI tool for running any command in parallel for all files with a given suffix.

## Features

- Executes a command once per matching file.
- Parallel execution using available CPU processing units.
  - The maximal number of jobs can be configured using the `-j` option.
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
./simultan.sh [ -d <maxdepth> ] [ -j <jobs> ] <suffix> <command> [args...]"
```

- `-d <maxdepth>`: the number of subdirectory levels to search for files (default: 1 -> search for files in the current directory only)
- `-j <jobs>`: optional number of parallel jobs (default: number of CPU processing units)
- `<suffix>`: file suffix without or with dot (for example `wav` or `.wav` - note that `*.wav` will not work!)
- `<command>`: executable to run for each matching file
- `[args...]`: optional arguments passed to `<command>`

## Examples

Convert all `.wav` files to MP3 files in the current directory:

```bash
./simultan.sh .wav lame --silent --preset insane
```

`.wav` is the suffix, `lame` is the command and `--silent --preset insane` are lame's arguments.

Process up to 3 levels/subdirectories deep:

```bash
./simultan.sh -d 3 .wav lame --silent --preset insane
```

`TIP:` If you are unsure what files will be processed you can first run:

```bash
./simultan.sh -d 3 .wav file
```
This will just print out all found .wav files plus a file info.

Run with up to 4 parallel jobs:

```bash
./simultan.sh -j 4 .wav lame --silent --preset insane
```


## Exit behavior

The script exits with an error when:

- suffix or command is missing
- command is not available in `PATH`
- no matching files are found
- `-d` is provided without a value or is invalid
- `-j` is provided without a value or is invalid (can't be <1 or higher than number of CPU processing units)

## License

[MIT](LICENSE)
