#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# This script demonstrates how to verify and fix translation issues in Docker

set -e

echo "=========================================="
echo "Translation Verification Script"
echo "=========================================="
echo ""

# Function to check if translations are compiled
check_translations() {
    local lang=$1
    local has_mo=false
    local has_json=false
    
    if [ -f "superset/translations/$lang/LC_MESSAGES/messages.mo" ]; then
        has_mo=true
        echo "✓ Backend translations (.mo) found for $lang"
    else
        echo "✗ Backend translations (.mo) MISSING for $lang"
    fi
    
    if [ -f "superset/translations/$lang/LC_MESSAGES/messages.json" ]; then
        has_json=true
        echo "✓ Frontend translations (.json) found for $lang"
    else
        echo "✗ Frontend translations (.json) MISSING for $lang"
    fi
    
    if [ "$has_mo" = true ] && [ "$has_json" = true ]; then
        echo "→ Result: Translations are COMPLETE for $lang"
        return 0
    else
        echo "→ Result: Translations are INCOMPLETE for $lang"
        return 1
    fi
}

echo "Checking Russian (ru) translations..."
echo ""

if check_translations "ru"; then
    echo ""
    echo "All translations are compiled and ready!"
else
    echo ""
    echo "=========================================="
    echo "ISSUE DETECTED: Translations not compiled"
    echo "=========================================="
    echo ""
    echo "This is the root cause of incomplete UI translations in Docker."
    echo ""
    echo "To fix this issue, you have two options:"
    echo ""
    echo "Option 1: Build Docker with translations enabled"
    echo "  BUILD_TRANSLATIONS=true docker-compose build"
    echo ""
    echo "Option 2: Compile translations in running container"
    echo "  # Backend translations:"
    echo "  flask fab babel-compile --target superset/translations"
    echo ""
    echo "  # Frontend translations:"
    echo "  cd superset-frontend && npm run build-translation"
    echo ""
    echo "For more information, see:"
    echo "  docs/docs/contributing/translations.mdx"
    echo ""
fi

echo ""
echo "=========================================="
echo "Available translation files (.po):"
echo "=========================================="
for dir in superset/translations/*/; do
    lang=$(basename "$dir")
    if [ -f "$dir/LC_MESSAGES/messages.po" ]; then
        line_count=$(wc -l < "$dir/LC_MESSAGES/messages.po")
        echo "  $lang: $line_count lines"
    fi
done
