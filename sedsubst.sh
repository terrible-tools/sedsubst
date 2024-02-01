#!/bin/sh

sed_script=$(mktemp) || exit 1

trap 'rm -f "$sed_script"' EXIT

escape_regex_metachars() {
  echo "$1" | sed 's/[]\/$*.^|[]/\\&/g'
}

# build sed script
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

if [ -t 0 ]; then
  # when < is used to redirect input
  sedsubst < /dev/stdin
else
  # when | is used to direct input
  sedsubst
fi
