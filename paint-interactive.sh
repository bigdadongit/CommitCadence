#!/bin/bash

# Enhanced paint script with better user control
# This version creates commits but lets the user decide when to push

echo "Starting to create commits from your design..."
echo ""

# Get the configured email from git config
CONFIGURED_EMAIL=$(git config user.email)
CONFIGURED_NAME=$(git config user.name)

if [ -z "$CONFIGURED_EMAIL" ]; then
    echo "⚠️  Warning: No email configured!"
    read -p "Enter your GitHub email: " CONFIGURED_EMAIL
    git config user.email "$CONFIGURED_EMAIL"
    CONFIGURED_NAME="${CONFIGURED_EMAIL%%@*}"
    git config user.name "$CONFIGURED_NAME"
fi

echo "Using email: $CONFIGURED_EMAIL"
echo "Using name: $CONFIGURED_NAME"
echo ""

# Export these so they're used for ALL commits
export GIT_AUTHOR_EMAIL="$CONFIGURED_EMAIL"
export GIT_AUTHOR_NAME="$CONFIGURED_NAME"
export GIT_COMMITTER_EMAIL="$CONFIGURED_EMAIL"
export GIT_COMMITTER_NAME="$CONFIGURED_NAME"

COMMIT_COUNT=0

while read line	 
do		
	IFS='/' read -ra PARAMS <<< "$line"
	D=${PARAMS[0]}
	M=${PARAMS[1]}
	Y=${PARAMS[2]}
	I=${PARAMS[3]}
	
	if [ ! -d "$Y" ]; then
    	mkdir $Y
	fi	
		cd $Y
		if [ ! -d "$M" ]; then
			mkdir $M
		fi
			cd $M
			if [ ! -d "$D" ]; then
				mkdir $D
			fi
				cd $D
				for i in $( eval echo {1..$I} )
      			do
      				echo "$i on $D/$M/$Y" > commit.md
        			# Set both date AND email/name for this commit
        			export GIT_COMMITTER_DATE="$Y-$M-$D 12:$i:00"
        			export GIT_AUTHOR_DATE="$Y-$M-$D 12:$i:00"
        			export GIT_COMMITTER_EMAIL="$CONFIGURED_EMAIL"
        			export GIT_COMMITTER_NAME="$CONFIGURED_NAME"
        			export GIT_AUTHOR_EMAIL="$CONFIGURED_EMAIL"
        			export GIT_AUTHOR_NAME="$CONFIGURED_NAME"
        			git add commit.md -f
        			git commit --date="$Y-$M-$D 12:0$i:00" -m "$i on $M $D $Y"
        			COMMIT_COUNT=$((COMMIT_COUNT + 1))
        		done
        	cd ../
        cd ../
    cd ../	
done < dates.txt

echo ""
echo "Created $COMMIT_COUNT commits based on your design!"
echo ""

# Ask user if they want to push
read -p "Do you want to push to GitHub now? (y/n): " PUSH_CHOICE

if [ "$PUSH_CHOICE" == "y" ] || [ "$PUSH_CHOICE" == "Y" ]; then
    echo "Pushing to remote repository..."
    
    # Detect default branch name
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [ -z "$DEFAULT_BRANCH" ]; then
        DEFAULT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    fi
    
    echo "Pushing to branch: $DEFAULT_BRANCH"
    
    # Attempt to push
    if git push origin "$DEFAULT_BRANCH" 2>&1; then
        echo ""
        echo "✅ Successfully pushed to GitHub!"
        echo ""
        
        read -p "Do you want to clean up the temporary commit files? (y/n): " CLEANUP_CHOICE
        
        if [ "$CLEANUP_CHOICE" == "y" ] || [ "$CLEANUP_CHOICE" == "Y" ]; then
            echo "Cleaning up temporary files..."
            git rm -rf 20* 2>/dev/null
            git commit -am "cleanup" 2>/dev/null
            git push origin "$DEFAULT_BRANCH" 2>/dev/null
            echo "Cleanup complete!"
        fi
    else
        echo ""
        echo "❌ Push failed! Common issues:"
        echo ""
        echo "1. Authentication Error (403):"
        echo "   - For HTTPS: You need a Personal Access Token"
        echo "   - Create one at: https://github.com/settings/tokens"
        echo "   - Use: https://YOUR_TOKEN@github.com/username/repo.git"
        echo ""
        echo "2. Permission Denied:"
        echo "   - Make sure you own the repository"
        echo "   - Or use SSH: git@github.com:username/repo.git"
        echo ""
        echo "3. Wrong Credentials:"
        echo "   - Check your GitHub username in the URL"
        echo "   - Verify repository name is correct"
        echo ""
        echo "Your commits are saved locally. To push manually:"
        echo "  cd $(pwd)"
        echo "  git push origin $DEFAULT_BRANCH"
        echo ""
    fi
else
    echo "Commits created locally. You can push later with: git push origin <branch-name>"
    echo "Don't forget to clean up temporary folders (20**) after pushing!"
fi

echo ""
echo "Done!"
