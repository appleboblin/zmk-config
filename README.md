# appleboblin's zmk-config

My personal [ZMK firmware](https://github.com/zmkfirmware/zmk/)
configuration, currently only consists of Choc spacing corne from [Typeractive](https://typeractive.xyz/)

## Setup

The local build process is streamlined using modified version of urob's local build process, using `nix`, `direnv` and `just`. It automatically sets up a virtual development environment required to compile ZMK firmware.

### Pre-requisits

(Read urob's [readme](https://github.com/urob/zmk-config/blob/main/readme.md#setup) for more information)

- nix packange manager with flake support
- direnv

### Set up workspace

1. Clone the repository you forked.

```bash
# Replace `appleboblin` with your username
git clone https://github.com/appleboblin/zmk-config
```

2. Enter the folder and set up the environment.

```bash
cd zmk-config

# Allow direnv
direnv allow

# Initialize the Zephyr environment and downlond ZMK dependencies
just init
```

## Usage

Your zmk-config folder should look somethig like this after following the steps above:

```
zmk-workspace
├── config
├── firmware (created after building)
├── modules
├── zephyr
├── zmk
└── shields and other repos you added to your config/west.yml
```

### Building the firmware

To build the firmware, type `just build` from anywhere in the folder. It defaults to buiding all boards and shield combinations listed in `build.yml`.

Use `just build <target>` to build the firmware that matches tha target. `just list` shows all valid build targets. I can type `just build corne` to builds both `corne_left` and `corne_right`. Generated firmware will be in the `firmware` folder.

To clear build cache, type `just clear`. To clear generated environment, type `just clear-all`.

#### Updating the build environment

(This section is directly from urob's readme)
To update the ZMK dependencies, use `just update`. This will pull in the latest
version of ZMK and all modules specified in `config/west.yml`. Make sure to
commit and push all local changes you have made to ZMK and the modules before
running this command, as this will overwrite them.

To upgrade the Zephyr SDK and Python build dependencies, use `just upgrade-sdk`. (Use with care --
Running this will upgrade all Nix packages and may end up breaking the build environment. When in
doubt, I recommend keeping the environment pinned to `flake.lock`, which is [continuously
tested](https://github.com/urob/zmk-config/actions/workflows/test-build-env.yml) on all systems.)

## Inspiration

My configuration is heavily intpired and use code from [urob](https://github.com/urob/zmk-config)
