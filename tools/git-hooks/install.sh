#!/bin/sh

set -eu

cd "$(dirname "$0")/../.."

for hook in pre-commit prepare-commit-msg commit-msg post-commit; do
  {
    echo "#!/bin/sh"
    echo
    echo "set -eu"
    echo
    echo "cd \"\$(dirname \"\$0\")/../..\""
    echo
    echo "hook=\"\$(basename \"\$0\")\""
    echo "hook_dir=\"tools/git-hooks/\$hook.d\""
    echo
    echo "if [ -d \"\$hook_dir\" ]; then"
    echo "  for script in \"\$hook_dir\"/*.sh; do"
    echo "    if [ -f \"\$script\" ] && [ -x \"\$script\" ]; then"
    echo "      echo \"Running \$hook hook \$(basename \"\$script\")\""
    echo "      \"./\$script\" \"\$@\""
    echo "    fi"
    echo "  done"
    echo "fi"
  } >".git/hooks/$hook"
  chmod a+x ".git/hooks/$hook"
done
