#!/bin/bash

# CommitCadence Automation Script
# This script automates the entire process of creating GitHub contribution art

# Store the script directory at the beginning
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESIGNER_DIR="$SCRIPT_DIR/dist"

echo "================================================"
echo "   CommitCadence - Automated Setup"
echo "================================================"
echo ""
echo "Create beautiful GitHub contribution art!"
echo ""

# Step 1: Get user email
echo "Step 1: GitHub Configuration"
read -p "Enter your GitHub email address: " GITHUB_EMAIL

if [ -z "$GITHUB_EMAIL" ]; then
    echo "Error: Email address is required!"
    exit 1
fi

echo "Email configured: $GITHUB_EMAIL"

# Step 2: Repository setup
echo ""
echo "Step 2: Repository Setup"

read -p "Enter your GitHub repository name (e.g., commit-art): " REPO_NAME

if [ -z "$REPO_NAME" ]; then
    echo "Error: Repository name is required!"
    exit 1
fi

read -p "Enter your GitHub repository URL: " REMOTE_URL

if [ -z "$REMOTE_URL" ]; then
    echo "Error: Repository URL is required!"
    exit 1
fi

# Validate URL format
if [[ ! "$REMOTE_URL" =~ ^(https://|git@) ]]; then
    echo "Error: URL must start with 'https://' or 'git@'"
    exit 1
fi

# Create repository in a temp directory
REPO_PATH="/tmp/commitcadence-$REPO_NAME-$$"

echo "Creating temporary repository at: $REPO_PATH"
mkdir -p "$REPO_PATH"
cd "$REPO_PATH"
git init
echo "# $REPO_NAME" > README.md
git add README.md
git commit -m "Initial commit"
git remote add origin "$REMOTE_URL"

echo "Repository initialized!"

# Step 3: Configure git email for the repository
echo ""
echo "Step 3: Configuring Git"
cd "$REPO_PATH"
git config --local user.email "$GITHUB_EMAIL"
echo "Git configured with email: $GITHUB_EMAIL"

# Step 4: Launch the designer
echo ""
echo "Step 4: Design Your Pattern"
echo "================================================"
echo ""
echo "Instructions:"
echo "  - LEFT CLICK on cells to cycle through colors"
echo "  - RIGHT CLICK anywhere when done to save your design"
echo "  - Enter the date when you want the pattern to appear"
echo "  - Close the window after saving"
echo ""
read -p "Press ENTER to launch the designer..."

# Check if JAR exists
if [ ! -f "$DESIGNER_DIR/Selectable_Grid.jar" ]; then
    echo "Error: Selectable_Grid.jar not found in $DESIGNER_DIR"
    exit 1
fi

cd "$DESIGNER_DIR"
java -jar Selectable_Grid.jar

# Step 5: Check if dates.txt was generated
echo ""
echo "Step 5: Applying Your Design"

if [ ! -f "$DESIGNER_DIR/dates.txt" ]; then
    echo "Error: dates.txt was not generated. Did you right-click to save your design?"
    exit 1
fi

echo "Design file found!"
echo ""

# Copy necessary files to repository
cp "$DESIGNER_DIR/dates.txt" "$REPO_PATH/"
cp "$SCRIPT_DIR/paint-interactive.sh" "$REPO_PATH/"

# Step 6: Execute the paint script
echo "Applying commits to create your design..."
cd "$REPO_PATH"

# Use the interactive paint script
bash paint-interactive.sh dates.txt

echo ""
echo "================================================"
echo "   Success! CommitCadence art is ready!"
echo "================================================"
echo ""
echo "✨ Your art has been created!"
echo ""
echo "Next steps:"
echo "1. Wait 5-10 minutes for GitHub to update"
echo "2. Visit your profile to see your contribution graph"
echo "3. Share your awesome creation!"
echo ""
echo "Repository location: $REPO_PATH"
echo "This temporary directory will be auto-cleaned from /tmp"
echo ""
read -p "Press ENTER to exit..."

# Note: /tmp directories are automatically cleaned up by the system
