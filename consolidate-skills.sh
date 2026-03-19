#!/usr/bin/env bash

set -u

TARGET_SKILLS_DIR="${HOME}/.skills"

AGENT_NAMES=(
  "Claude Code"
  "Cline"
  "OpenCode"
  "Gemini CLI"
  "Codex (OpenAI)"
  "Windsurf"
  "Cursor"
  "Antigravity"
)

AGENT_SKILL_DIRS=(
  "${HOME}/.claude/skills"
  "${HOME}/.cline/skills"
  "${HOME}/.opencode/skills"
  "${HOME}/.gemini/skills"
  "${HOME}/.codex/skills"
  "${HOME}/.windsurf/skills"
  "${HOME}/.cursor/skills"
  "${HOME}/.antigravity/skills"
)

print_section() {
  printf "\n== %s ==\n" "$1"
}

prompt_yes_no() {
  local prompt="$1"
  local answer=""

  while true; do
    read -r -p "${prompt} [y/N]: " answer
    case "$answer" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo]|"") return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

prompt_overwrite_or_skip() {
  local prompt="$1"
  local answer=""

  while true; do
    read -r -p "${prompt} [o=overwrite/s=skip]: " answer
    case "$answer" in
      [Oo]|[Oo][Vv][Ee][Rr][Ww][Rr][Ii][Tt][Ee]) echo "overwrite"; return 0 ;;
      [Ss]|[Ss][Kk][Ii][Pp]|"") echo "skip"; return 0 ;;
      *) echo "Please answer o (overwrite) or s (skip)." ;;
    esac
  done
}

copy_directory() {
  local source_path="$1"
  local destination_path="$2"

  if cp -a "$source_path" "$destination_path" 2>/dev/null; then
    return 0
  fi

  cp -R "$source_path" "$destination_path"
}

is_same_directory() {
  local first_path="$1"
  local second_path="$2"
  local first_real=""
  local second_real=""

  [[ -d "$first_path" && -d "$second_path" ]] || return 1

  first_real="$(cd "$first_path" && pwd -P)"
  second_real="$(cd "$second_path" && pwd -P)"

  [[ "$first_real" == "$second_real" ]]
}

copy_skills_from_agent() {
  local agent_name="$1"
  local source_dir="$2"
  local found_any=0
  local action=""
  local skill_dir=""
  local skill_name=""
  local destination_dir=""
  local entries=()

  shopt -s nullglob dotglob
  entries=("${source_dir}"/*)
  shopt -u nullglob dotglob

  for skill_dir in "${entries[@]}"; do
    [[ -d "$skill_dir" ]] || continue

    found_any=1
    skill_name="$(basename "$skill_dir")"
    destination_dir="${TARGET_SKILLS_DIR}/${skill_name}"

    if [[ -e "$destination_dir" || -L "$destination_dir" ]]; then
      action="$(
        prompt_overwrite_or_skip \
          "Conflict for '${skill_name}' while importing from ${agent_name}. Overwrite or skip?"
      )"

      if [[ "$action" == "skip" ]]; then
        echo "Skipped '${skill_name}'."
        continue
      fi

      rm -rf "$destination_dir"
    fi

    copy_directory "$skill_dir" "$destination_dir"
    echo "Imported '${skill_name}' from ${agent_name}."
  done

  if [[ "$found_any" -eq 0 ]]; then
    echo "No skill directories found in ${source_dir}."
  fi
}

ensure_target_directory() {
  if [[ -e "$TARGET_SKILLS_DIR" && ! -d "$TARGET_SKILLS_DIR" ]]; then
    echo "Error: ${TARGET_SKILLS_DIR} exists but is not a directory."
    exit 1
  fi

  if [[ ! -d "$TARGET_SKILLS_DIR" ]]; then
    mkdir -p "$TARGET_SKILLS_DIR"
    echo "Created ${TARGET_SKILLS_DIR}."
  else
    echo "Using existing ${TARGET_SKILLS_DIR}."
  fi
}

main() {
  local i=0
  local agent_name=""
  local agent_skill_dir=""

  ensure_target_directory

  for i in "${!AGENT_NAMES[@]}"; do
    agent_name="${AGENT_NAMES[$i]}"
    agent_skill_dir="${AGENT_SKILL_DIRS[$i]}"

    print_section "${agent_name}"
    echo "Source: ${agent_skill_dir}"

    if [[ ! -e "$agent_skill_dir" && ! -L "$agent_skill_dir" ]]; then
      echo "Directory does not exist. Skipping."
      continue
    fi

    if ! [[ -d "$agent_skill_dir" || -L "$agent_skill_dir" ]]; then
      echo "Path exists but is not a directory. Skipping."
      continue
    fi

    if is_same_directory "$agent_skill_dir" "$TARGET_SKILLS_DIR"; then
      echo "Already points to ${TARGET_SKILLS_DIR}. Skipping."
      continue
    fi

    copy_skills_from_agent "$agent_name" "$agent_skill_dir"

    if prompt_yes_no "Delete ${agent_skill_dir} and replace it with a symlink to ${TARGET_SKILLS_DIR}?"; then
      rm -rf "$agent_skill_dir"
      mkdir -p "$(dirname "$agent_skill_dir")"
      ln -s "$TARGET_SKILLS_DIR" "$agent_skill_dir"
      echo "Created symlink: ${agent_skill_dir} -> ${TARGET_SKILLS_DIR}"
    else
      echo "Kept ${agent_skill_dir} unchanged."
    fi
  done

  print_section "Done"
  echo "Skill consolidation complete."
}

main "$@"
