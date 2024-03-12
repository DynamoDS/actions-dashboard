#!/bin/env sh

# This script generates the README.md file.
# it requires gh to be installed. https://cli.github.com/
#
# Usage: ./generate_readme.sh

org="DynamoDS"
input_file="repos.txt"
output_file="README.md"

if ! command -v gh &> /dev/null; then
  echo "❕gh is not installed.\nPlease install it first. https://cli.github.com/"
  exit 1
fi

get_repos() {
    local org=$1
    gh repo list $1 \
        --visibility public \
        --no-archived \
        --limit 100 \
        --json nameWithOwner \
        --template '{{range .}}{{.nameWithOwner}}{{"\n"}}{{end}}'
}

parse_repo() {
    local repo=$1
    workflows=$(gh api /repos/$repo/contents/.github/workflows -q '.[] | select(.type == "file") | .name')
    [[ $? -ne 0 ]] && continue

    echo "## $(basename $repo)" >> ${output_file}
    echo "Workflow | Status" >> ${output_file}
    echo "-------- | ------" >> ${output_file}
    for workflow in $workflows; do
        echo "ℹ️  Parsing workflow: $workflow"
        path="[$workflow](https://github.com/$repo/actions/workflows/$workflow)"
        status="[![$workflow](https://github.com/$repo/actions/workflows/$workflow/badge.svg)](https://github.com/$repo/actions/workflows/$workflow)"
        echo "$path | $status" >> ${output_file}
    done
}

echo "# Workflows" > ${output_file}
for repo in $(get_repos $org); do
    echo "\n🔍 Parsing repository: $repo"
    parse_repo $repo
done

echo "\n✅ Readme generated: $output_file"
