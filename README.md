<h1 align="center">μ (dotfiles)</h1>

> [!CAUTION]
> Currently in heavy development; not intended for public use.

## Architecture

### Chezmoi Dotfile Management

This repository uses [**chezmoi**](https://chezmoi.io/) for secure dotfile management across multiple machines.

**Setup:**

1. Install chezmoi: `curl -fsSL https://chezmoi.io/get | sh`
2. Initialize chezmoi: `chezmoi init --apply` (in this repo)
3. Apply configurations: `nu install.nu`

**Note:** Migration from symlinks.nu to chezmoi was completed on **Feb 15, 2026**. The old `symlinks.nu` script is preserved as `symlinks.nu.archive` for reference.

### Device-Specific Configurations

- To set up device-specific tweaks, add `.u` / `.u.*` files in the same directory.
- chezmoi templates can use `{{ .chezmoi.hostname }}`, `{{ .chezmoi.os }}`, etc. for dynamic configurations
- Execute `nu install.nu` to apply configurations to relevant config directories.

## Requirements

- [**Nushell**](https://github.com/nushell/nushell) 0.105.0+
- [**fzf**](https://github.com/junegunn/fzf) 0.64.0+

## License

This project is made available under [GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.html).

![GPLv3](https://www.gnu.org/graphics/gplv3-127x51.png)

<p align="center"><sub><strong>© 2025 MEDRIVIA ／ Umar Alfarouk</strong></sub></p>
