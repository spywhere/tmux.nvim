# tmux.nvim

_This plugin still under development_

This plugin provides a framework to turns
[Neovim](https://github.com/neovim/neovim) into terminal multiplexer
(heavily based on [tmux](https://github.com/tmux/tmux))

The intention of this plugin is to eliminate the need of tmux for a basic
terminal multiplexing feature by leveraging Neovim split and tab features

For those who's on Windows, this could be a workaround for lack of tmux but
only for terminal multiplexing

## Table Of Contents

* [Installation](#installation)
* [Integration](#integration)
* [Configuration](#configuration)
* [Contributes](#contributes)
* [License](#license)

## Installation

It is highly recommended to clone the repository (or download a zip file) and
place it somewhere (`~/.tmux.nvim` would work too)

```sh
git clone https://github.com/spywhere/tmux.nvim ~/.tmux.nvim
```

or install using a plugin manager of your choice, for example:

```viml
" neovim 0.5 or later that supports lua
Plug 'spywhere/tmux.nvim'
```

## Integration

Create a file named `init.lua` and place it somewhere
(in this example, `~/.tmux.nvim/init.lua` will be used)

```lua
local tmux = require('tmux')

-- some configurations go here

tmux.start() -- this will start a terminal session

```

then, when you're ready to use Neovim as terminal multiplexer, just run

```sh
nvim -u ~/.tmux.nvim/init.lua
```

## Configuration

As the plugin still under development, please find the default configurations
from following locations...

- Neovim configurations: `lua/tmux/config.lua`
- Key bindings: `lua/tmux/bindings.lua`
- Available commands: `lua/tmux/commands.lua`

Please note that some options are opinionated and will be updated to match
tmux's defaults later on

## Contributes

During the development, you can use the following command to automatically setup
a working configurations to test the plugin...

```
make testrun
```

or

```
nvim -u tests/init.lua
```

## License

Released under the [MIT License](LICENSE)
