# tmux.nvim

_This plugin still under development_

![tmux.nvim](https://user-images.githubusercontent.com/1087399/194050442-dedeea40-5c34-4a75-b292-d694a151385c.png)

This plugin provides a framework to turns
[Neovim](https://github.com/neovim/neovim) into terminal multiplexer
(heavily based on [tmux](https://github.com/tmux/tmux))

The intention of this plugin is to eliminate the need of tmux for a basic
terminal multiplexing feature by leveraging Neovim split and tab features

For those who's on Windows, this could be a workaround for lack of tmux but
only for terminal multiplexing

## Table Of Contents

* [Features](#features)
* [Getting Started](#getting-started)
* [Configurations](#configurations)
* [Installation](#installation)
* [Integration](#integration)
* [Supported Features](#supported-features)
* [Contributes](#contributes)
* [License](#license)

## Features

This are non exhaustive list of features available

- [x] Panes
- [x] Windows
- [x] Status bar<sup>1</sup>
- [x] Copy mode<sup>1</sup>
- [ ] (Detachable) Sessions<sup>2</sup>

1: Partially implemented  
2: This requires Neovim to implement a server / client architecture which
planned in [neovim#10071](https://github.com/neovim/neovim/pull/10071)

## Getting Started

To quickly setup and run the first session of tmux.nvim

```sh
curl -fLo ~/.tmux.nvim/init.lua --create-dirs https://raw.githubusercontent.com/spywhere/tmux.nvim/main/tests/git.lua
nvim -u ~/.tmux.nvim/init.lua
```

This will download a basic configuration to `~/.tmux.nvim/init.lua` and run it.
In which, it will automatically install and setup the plugin using vim-plug.

## Configurations

As the plugin still under development, please find the default configurations
from following locations...

- Neovim configurations: `lua/tmux/config.lua`
- Status bar (built using tabline): `lua/tmux/statusbar.lua`
- Key bindings: `lua/tmux/bindings.lua`
- Available commands: `lua/tmux/commands.lua`

Please note that some options are opinionated and will be updated to match
tmux's defaults later on

## Installation

Requires neovim v0.7.0 or later.

If you wish to use tmux.nvim with older neovim version (v0.5.0 up to v0.6.1),
check out [nvim-0.5.0](https://github.com/spywhere/tmux.nvim/tree/nvim-0.5.0)
branch. Do note that nvim-0.5.0 branch is for migration purpose only so the
code will not be maintained.

It is highly recommended to clone the repository (or download a zip file) and
place it somewhere (`~/.tmux.nvim` would work too)

```sh
git clone https://github.com/spywhere/tmux.nvim ~/.tmux.nvim
```

or install using a plugin manager of your choice, for example:

```viml
Plug 'spywhere/tmux.nvim'
```

## Integration

Create a file named `init.lua` and place it somewhere
(in this example, `~/.tmux.nvim/init.lua` will be used)

```lua
-- if you're cloning the repository, you will need to add the plugin directory
--   to the 'runtimepath'
vim.opt.rtp:append('~/.tmux.nvim')

local tmux = require('tmux')
local cmds = require('tmux.commands')

-- some configurations go here

-- may be changing the default prefix key?
--   tmux.prefix('<C-a>')

-- may be binding a new key?
--   tmux.bind('|', cmds.split_window { 'v' } )
--   tmux.bind('-', cmds.split_window { 'h' } )

tmux.start() -- this will start a terminal session

```

then, when you're ready to use Neovim as terminal multiplexer, just run

```sh
nvim -u ~/.tmux.nvim/init.lua
```

Check out [bindings.lua](/lua/tmux/bindings.lua) for how tmux.nvim set a default key bindings

## Supported Features

These are a list of features that required a certain version of Neovim

Neovim 0.8 or later is required for

- Cleaner status line (hide the command line)

Neovim 0.7 or later is required for

- Status line on the bottom (above command line)

Neovim 0.5 or later is required for

- Basic functionality

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

Alternatively, if you wish to test the plugin through direct cloning, use...

```
make testrun-from-git
```

or

```
nvim -u tests/git.lua
```

## License

Released under the [MIT License](LICENSE)
