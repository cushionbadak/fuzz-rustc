#!/bin/bash
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="fuzz_results_${TIMESTAMP}"

echo "=== Archiving fuzz-rustc results ==="

# Check if there's anything to archive
if [ ! -d "artifacts" ] && [ ! -d "corpus" ]; then
    echo "Nothing to archive: artifacts/ and corpus/ not found."
    exit 1
fi

# Create a wrapper directory so tar extracts into a single folder
mkdir -p "$ARCHIVE_NAME"
[ -d "artifacts" ] && cp -r artifacts "$ARCHIVE_NAME/"
[ -d "corpus" ] && cp -r corpus "$ARCHIVE_NAME/"

# Summary
echo "  artifacts: $(ls "$ARCHIVE_NAME/artifacts" 2>/dev/null | wc -l) files"
echo "  corpus: $(ls "$ARCHIVE_NAME/corpus" 2>/dev/null | wc -l) files"

# Archive
tar -czf "${ARCHIVE_NAME}.tar.gz" "$ARCHIVE_NAME"
rm -rf "$ARCHIVE_NAME"

echo "Created: ${ARCHIVE_NAME}.tar.gz ($(du -h "${ARCHIVE_NAME}.tar.gz" | cut -f1))"
echo "Download with: scp <server>:$(pwd)/${ARCHIVE_NAME}.tar.gz ."
