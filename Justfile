# modified from urob's file
default:
    @just --list --unsorted

config := absolute_path('config')
build := absolute_path('.build')
out := absolute_path('firmware')
current := absolute_path('')

# parse build.yaml and filter targets by expression
_parse_targets $expr:
  #!/usr/bin/env bash
  attrs="[.board, .shield, .snippet, .\"artifact-name\"]"
  filter="(($attrs | map(. // [.]) | combinations), ((.include // {})[] | $attrs)) | join(\",\")"
  echo "$(yq -r "$filter" build.yaml | grep -v "^," | grep -i "${expr/#all/.*}")"

# build firmware for single board & shield combination
_build_single $board $shield *west_args:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "${board}"
  echo "${shield}"
  artifact="${shield:+${shield// /+}-}${board}"
  build_dir="{{ build / '$artifact' }}"
  modules=$(yq '.manifest.projects[].name' config/west.yml | tr -d '"' | grep -Ev '^(zmk|zephyr)$' | paste -sd ' ' -)
  modules=$(printf "{{ current }}/%s;" $modules)
  modules=${modules%;}
  echo "Building firmware for $artifact..."
  west build -s zmk/app -d "$build_dir" -b $board -- \
    -DSHIELD="${shield:+${shield// /;}}" \
    -DZMK_CONFIG="{{ config }}" \
    -DZMK_EXTRA_MODULES="${modules}"

  if [[ -f "$build_dir/zephyr/zmk.uf2" ]]; then
    mkdir -p "{{ out }}" && cp "$build_dir/zephyr/zmk.uf2" "{{ out }}/$artifact.uf2"
  else
    mkdir -p "{{ out }}" && cp "$build_dir/zephyr/zmk.bin" "{{ out }}/$artifact.bin"
  fi

# build firmware for matching targets
build *expr='all':
  #!/usr/bin/env bash
  set -euo pipefail
  targets=$(just _parse_targets {{ expr }})

  [[ -z $targets ]] && echo "No matching targets found. Aborting..." >&2 && exit 1
  targets=$(echo "$targets" | cut -d',' -f1-2)
  # Process each line
  while IFS=',' read -r board shield _; do
      # Output the first two targets, if available
      just _build_single "${board}" "${shield:+$shield}"
  done <<< "$targets"

# clear build cache and artifacts
clean:
  rm -rf {{ build }} {{ out }}

# clear all automatically generated files
clean-all: clean
  rm -rf .west zmk


# clear nix cache
clean-nix:
    nix-collect-garbage --delete-old

# initialize west
init:
  #!/usr/bin/env bash
  set -euo pipefail
  west init -l config
  west update
  west zephyr-export

  # add git repo to .gitignore
  while IFS= read -r proj; do
    grep -qxF "$proj" .gitignore || echo "$proj" >> .gitignore
  done < <(
    yq  '.manifest.projects[].name' config/west.yml \
    | tr -d '"'
  )

# list build targets
list:
    @just _parse_targets all | sed 's/,*$//' | sort | column

# update west
update:
    west update --fetch-opt=--filter=blob:none

# upgrade zephyr-sdk and python dependencies
upgrade-sdk:
    nix flake update --flake .
