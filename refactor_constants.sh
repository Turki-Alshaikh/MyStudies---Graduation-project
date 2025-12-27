#!/bin/bash

# Script to help refactor hardcoded values to use constants
# Run this from the project root: bash refactor_constants.sh

echo "🔧 Starting constants refactoring..."

# Function to add imports if not present
add_imports() {
    file="$1"
    if ! grep -q "import.*app_spacing.dart" "$file" && ! grep -q "import.*app_sizes.dart" "$file"; then
        # Find the last import line
        last_import=$(grep -n "^import" "$file" | tail -1 | cut -d: -f1)
        if [ -n "$last_import" ]; then
            # Add imports after the last import
            sed -i.bak "${last_import}a\\
\\
import '../../../../core/constants/app_spacing.dart';\\
import '../../../../core/constants/app_sizes.dart';" "$file"
            echo "  ✅ Added imports to $file"
        fi
    fi
}

# Common replacements
replace_in_files() {
    echo "📝 Replacing common patterns..."
    
    find lib/features -name "*.dart" -type f | while read file; do
        echo "Processing: $file"
        
        # Backup
        cp "$file" "$file.backup"
        
        # EdgeInsets replacements
        sed -i '' 's/EdgeInsets\.all(4)/AppSpacing.paddingXS/g' "$file"
        sed -i '' 's/EdgeInsets\.all(8)/AppSpacing.paddingSM/g' "$file"
        sed -i '' 's/EdgeInsets\.all(12)/AppSpacing.paddingMD/g' "$file"
        sed -i '' 's/EdgeInsets\.all(16)/AppSpacing.paddingLG/g' "$file"
        sed -i '' 's/EdgeInsets\.all(20)/AppSpacing.paddingXL/g' "$file"
        sed -i '' 's/EdgeInsets\.all(24)/AppSpacing.paddingXXL/g' "$file"
        sed -i '' 's/EdgeInsets\.all(32)/AppSpacing.paddingXXXL/g' "$file"
        
        # SizedBox height replacements
        sed -i '' 's/SizedBox(height: 4)/AppSpacing.verticalSpaceXS/g' "$file"
        sed -i '' 's/SizedBox(height: 8)/AppSpacing.verticalSpaceSM/g' "$file"
        sed -i '' 's/SizedBox(height: 12)/AppSpacing.verticalSpaceMD/g' "$file"
        sed -i '' 's/SizedBox(height: 16)/AppSpacing.verticalSpaceLG/g' "$file"
        sed -i '' 's/SizedBox(height: 20)/AppSpacing.verticalSpaceXL/g' "$file"
        sed -i '' 's/SizedBox(height: 24)/AppSpacing.verticalSpaceXXL/g' "$file"
        sed -i '' 's/SizedBox(height: 32)/AppSpacing.verticalSpaceXXXL/g' "$file"
        
        # SizedBox width replacements
        sed -i '' 's/SizedBox(width: 4)/AppSpacing.horizontalSpaceXS/g' "$file"
        sed -i '' 's/SizedBox(width: 8)/AppSpacing.horizontalSpaceSM/g' "$file"
        sed -i '' 's/SizedBox(width: 12)/AppSpacing.horizontalSpaceMD/g' "$file"
        sed -i '' 's/SizedBox(width: 16)/AppSpacing.horizontalSpaceLG/g' "$file"
        sed -i '' 's/SizedBox(width: 20)/AppSpacing.horizontalSpaceXL/g' "$file"
        sed -i '' 's/SizedBox(width: 24)/AppSpacing.horizontalSpaceXXL/g' "$file"
        
        # BorderRadius replacements
        sed -i '' 's/BorderRadius\.circular(8)/AppSpacing.borderRadiusSM/g' "$file"
        sed -i '' 's/BorderRadius\.circular(12)/AppSpacing.borderRadiusMD/g' "$file"
        sed -i '' 's/BorderRadius\.circular(16)/AppSpacing.borderRadiusLG/g' "$file"
        sed -i '' 's/BorderRadius\.circular(20)/AppSpacing.borderRadiusXL/g' "$file"
        sed -i '' 's/BorderRadius\.circular(24)/AppSpacing.borderRadiusXXL/g' "$file"
        sed -i '' 's/BorderRadius\.circular(28)/AppSpacing.borderRadiusRound/g' "$file"
        
        # Check if file was modified
        if ! cmp -s "$file" "$file.backup"; then
            echo "  ✅ Modified $file"
            add_imports "$file"
        else
            rm "$file.backup"
        fi
    done
}

# Main execution
echo "⚠️  This will modify all Dart files in lib/features/"
echo "📦 Backups will be created with .backup extension"
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    replace_in_files
    echo "✨ Refactoring complete!"
    echo "💡 Review changes and run: flutter analyze"
    echo "🗑️  To remove backups: find lib/features -name '*.backup' -delete"
else
    echo "❌ Cancelled"
fi

