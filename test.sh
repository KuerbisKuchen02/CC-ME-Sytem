 TARGET_DIR=${1:-./test}

# Test if the target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: Directory $TARGET_DIR not found."
  exit 1
fi

# Find all lua files and run them
find "$TARGET_DIR" -type f -name "*.lua" | while read -r lua_file; do
  # echo "Run tests inside: $lua_file"
  lua "$lua_file" || {
    echo "Error during execution $lua_file"
    exit 1
  }
done

echo "All tests executed successfully."