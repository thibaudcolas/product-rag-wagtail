#!/bin/bash

set -e

REPO="wagtail/roadmap"
OUTPUT_DIR="items"
JSON_FILE="roadmap-issues.json"
PROJECT_FILE="roadmap-project.json"
PROJECT_NUMBER=16
PROJECT_OWNER="wagtail"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Download all issues as JSON
echo "Downloading issues from $REPO..."
# gh issue list --repo "$REPO" --limit 1000 --state all --json number,title,labels,milestone,body,state,closedAt > "$JSON_FILE"

# Download project data
echo "Downloading project data from project $PROJECT_NUMBER..."
gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --format json --limit 1000 > "$PROJECT_FILE"

echo "Processing issues..."

# Process each issue and create markdown files
jq -c '.[]' "$JSON_FILE" | while read -r issue; do
    number=$(echo "$issue" | jq -r '.number')
    title=$(echo "$issue" | jq -r '.title')
    body=$(echo "$issue" | jq -r '.body // ""')
    milestone=$(echo "$issue" | jq -r '.milestone.title // "No Milestone"')
    labels=$(echo "$issue" | jq -r '[.labels[].name] | join(", ")')
    state=$(echo "$issue" | jq -r '.state | ascii_downcase')
    closedAt=$(echo "$issue" | jq -r '.closedAt // ""')

    # Fetch project metadata for this issue
    size=$(jq -r --arg num "$number" '.items[] | select(.content.number == ($num | tonumber)) | .size // ""' "$PROJECT_FILE")
    release=$(jq -r --arg num "$number" '.items[] | select(.content.number == ($num | tonumber)) | .status // ""' "$PROJECT_FILE")

    # Create filename: {{milestone}} - {{title}} #{{number}}.md
    # Sanitize filename by replacing problematic characters
    filename="${release} - ${title} #${number}.md"
    filename=$(echo "$filename" | sed 's/[\/\\:*?"<>|]/-/g')
    filepath="$OUTPUT_DIR/$filename"

    # Create markdown file with frontmatter
    if [ -n "$closedAt" ]; then
        cat > "$filepath" << EOF
---
number: $number
labels: $labels
size: $size
milestone: $milestone
release: $release
status: $state
closedAt: $closedAt
url: https://github.com/$REPO/issues/$number
---

# $title

$body
EOF
    else
        cat > "$filepath" << EOF
---
number: $number
labels: $labels
milestone: $milestone
size: $size
release: $project_status
status: $state
---

# $title

$body
EOF
    fi

    echo "Created: $filename"
done

echo "Done! Created $(jq length "$JSON_FILE") markdown files in $OUTPUT_DIR/"
