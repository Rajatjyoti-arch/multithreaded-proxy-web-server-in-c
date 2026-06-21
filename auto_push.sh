#!/bin/bash

REPO_DIR="/home/rajat/languages/C/Multithreaded Proxy Web Server in C"
cd "$REPO_DIR" || exit

echo "Starting auto-push script for $REPO_DIR..."
echo "Logging to auto_push.log"

while true; do
    git add .
    
    # Check if there's anything to commit
    if ! git diff --quiet --cached; then
        # Get list of changed files
        CHANGED_FILES=$(git diff --cached --name-only | head -n 5 | paste -sd ", " -)
        FILE_COUNT=$(git diff --cached --name-only | wc -l)
        if [ "$FILE_COUNT" -gt 5 ]; then
            CHANGED_FILES="$CHANGED_FILES, and $(($FILE_COUNT - 5)) more"
        fi
        
        # Analyze the diff to generate a creative/meaningful message
        C_CHANGES=$(git diff --cached --name-only | grep -E '\.(c|h)$')
        
        SUMMARY=""
        if [ -n "$C_CHANGES" ]; then
            # Extract added functions (e.g. "void* handle_client(void* arg)")
            # Matches function definitions in C: returnType funcName(args) {
            FUNCS=$(git diff --cached | grep -E '^\+[a-zA-Z_][a-zA-Z0-9_* ]+[[:space:]]+[a-zA-Z0-9_*]+[[:space:]]*\([^)]*\)[[:space:]]*\{?' | sed -E 's/^\+//' | sed -E 's/\{//g' | sed -E 's/^[[:space:]]*//' | cut -d '(' -f 1 | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
            if [ -n "$FUNCS" ]; then
                SUMMARY="Added/Modified functions: $FUNCS"
            fi
            
            # Check for specific network/socket patterns
            if git diff --cached | grep -q -i -E 'socket|bind|listen|accept|connect'; then
                SUMMARY="${SUMMARY:+$SUMMARY; }Updated socket connections/network layer"
            fi
            # Check for multithreading patterns
            if git diff --cached | grep -q -i -E 'pthread_create|pthread_join|mutex|sem_'; then
                SUMMARY="${SUMMARY:+$SUMMARY; }Updated thread management/synchronization"
            fi
            # Check for HTTP parsing logic
            if git diff --cached | grep -q -i -E 'http|request|header|response|parse'; then
                SUMMARY="${SUMMARY:+$SUMMARY; }Updated HTTP parsing/proxy flow"
            fi
        fi
        
        # Check if README.md changed
        if git diff --cached --name-only | grep -q 'README.md'; then
            HEADERS=$(git diff --cached README.md | grep -E '^\+ *#+ ' | sed -E 's/^\+ *#+ //g' | tr '\n' ';' | sed 's/;$/ /' | sed 's/;/; /g')
            if [ -n "$HEADERS" ]; then
                SUMMARY="${SUMMARY:+$SUMMARY; }Updated documentation: $HEADERS"
            else
                SUMMARY="${SUMMARY:+$SUMMARY; }Refined README documentation"
            fi
        fi
        
        # Choose a creative prefix verb based on type of change
        VERB="Update"
        if git diff --cached | grep -q -E '^[+][[:space:]]*//'; then
            VERB="Document"
        elif git diff --cached | grep -q -E '#include'; then
            VERB="Integrate"
        elif git diff --cached --name-status | grep -q '^A'; then
            VERB="Introduce"
        elif git diff --cached | grep -q -E 'pthread_create|socket'; then
            VERB="Implement"
        else
            VERBS=("Polish" "Refine" "Tweak" "Optimize" "Streamline" "Adjust")
            VERB=${VERBS[$RANDOM % ${#VERBS[@]}]}
        fi
        
        # Assemble message
        if [ -n "$SUMMARY" ]; then
            COMMIT_MSG="$VERB: $SUMMARY"
        else
            COMMIT_MSG="$VERB $CHANGED_FILES"
        fi
        
        # Trim message length if too long
        COMMIT_MSG=$(echo "$COMMIT_MSG" | cut -c 1-100)
        
        git commit -m "$COMMIT_MSG"
        git push origin main
        
        echo "[$(date)] Pushed: $COMMIT_MSG" >> auto_push.log
    fi
    
    # Sleep for 10 minutes (600 seconds)
    sleep 600
done
