#!/bin/sh

is_valid_file_path() {
    if echo "$1" | grep -qE "^(/[[:alnum:]_./ -]+)+$"; then
        return 0  # Valid
    else
        return 1  # Not valid
    fi
}

input_file=""
output_file=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    -i|--in-file)
      input_file="$2"
      shift 2
      ;;
    -o|--out-file)
      output_file="$2"
      shift 2
      ;;
    *)
      unknown_option=1
      if [ ! -f "$input_file" ]; then
        if [ -f "$1" ]; then
          unknown_option=0
          input_file="$1"
        fi
      elif ! is_valid_file_path "$output_file"; then
        unknown_option=0
        output_file="$1"
      fi
      if [ "$unknown_option" -eq 1 ]; then
        echo "Unknown option: $1"
        exit 1
      else
        shift 1
      fi
      ;;
  esac
done

if [ ! -f "$input_file" ]; then
  input_file="/dev/stdin"
fi
if ! is_valid_file_path "$output_file"; then
  output_file="/dev/stdout"
fi

sed_script=$(mktemp) || exit 1

trap 'rm -f "$sed_script"' EXIT

escape_regex_metachars() {
  echo "$1" | sed 's/[]\/$*.^|[]/\\&/g'
}

# build temporary sed script
env | while IFS= read -r line; do
  key=$(echo "$line" | cut -d= -f1)
  value=$(echo "$line" | cut -d= -f2-)
  escaped_value=$(escape_regex_metachars "$value")
  echo "s/\\\$${key}/${escaped_value}/g" >> "$sed_script"
  echo "s/\\\${${key}}/${escaped_value}/g" >> "$sed_script"
done

sedsubst() {
  sed --file "$sed_script"
}

sedsubst < "$input_file" > "$output_file"
