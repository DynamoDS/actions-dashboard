#!/bin/env bash

# This script generates the README.md file.
# it requires gh to be installed. https://cli.github.com/
#
# Usage: ./generate_readme.sh

org="DynamoDS"
output_file="README.md"

if ! which gh &> /dev/null; then
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

echo "# Workflows" > ${output_file}
echo "" >> ${output_file}

for repo in $(get_repos $org); do
    echo "\n🔍 Parsing repository: $repo"
    workflows=$(gh api /repos/$repo/contents/.github/workflows -q '.[] | select(.type == "file") | .name')
    if [ $? -ne 0 ]; then
        continue
    fi

    echo "## [$repo](https://github.com/$repo)" >> ${output_file}
    echo "" >> ${output_file}
    echo "Workflow | Status" >> ${output_file}
    echo "---------|--------" >> ${output_file}
    for workflow in $workflows; do
        echo "ℹ️  Parsing workflow: $workflow"
        path="https://github.com/$repo/actions/workflows/$workflow"
        badge="https://github.com/$repo/actions/workflows/$workflow/badge.svg"
        echo "[$workflow]($path) | [![$workflow]($badge)]($path)" >> ${output_file}
    done
    echo "" >> ${output_file}
done

echo "\n✅ Readme generated: $output_file"
