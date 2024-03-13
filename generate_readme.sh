#!/usr/bin/env bash

# This script generates the README.md file.
# it requires gh to be installed. https://cli.github.com/
#
# Usage: ./generate_readme.sh

org="DynamoDS"
output_file="README.md"

if ! which gh &> /dev/null; then
    echo "❕gh is not installed."
    echo "Please install it first. https://cli.github.com/"
    exit 1
fi

list_repos() {
    local org=$1
    gh repo list $1 \
        --limit 100 \
        --no-archived \
        --visibility public \
        --json nameWithOwner \
        --template '{{range .}}{{.nameWithOwner}}{{"\n"}}{{end}}'
}

echo "# Workflows" > ${output_file}
echo "" >> ${output_file}

echo "🔍 Getting all repositories"
repos=$(list_repos $org)
for repo in $repos; do
    echo
    echo "ℹ️  Parsing repository: $repo"
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

echo
echo "✅ Readme generated: $output_file"
