#!/bin/bash

echo "=== Fixing Git Conflicts ==="

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "File exists. Checking content..."
    head -5 ios/Runner/GoogleService-Info.plist
    echo "Removing sensitive Firebase config..."
    git rm ios/Runner/GoogleService-Info.plist
else
    echo "File doesn't exist. Marking as resolved..."
    git rm ios/Runner/GoogleService-Info.plist 2>/dev/null || true
fi

# Also fix other conflicts
git add .gitignore README.md
git add -u

echo "=== Done ==="
