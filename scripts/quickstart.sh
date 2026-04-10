#!/bin/bash

# Claude How To - Quick Start Script
# ===================================
# Idempotent setup for Claude Code best practices
# Copies essential templates to ~/.claude/ directory
#
# Usage:
#   ./scripts/quickstart.sh
#
# This script is safe to run multiple times.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${HOME}/.claude"
PROJECT_SLUG="claude-howto"

# ============================================================================
# Helper Functions
# ============================================================================

log_header() {
  echo -e "\n${BLUE}▶ $1${NC}"
}

log_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

die() {
  echo -e "${RED}✗ $1${NC}"
  exit 1
}

log_error() {
  echo -e "${RED}✗ $1${NC}"
}

copy_if_missing() {
  local src="$1"
  local dst="$2"
  local description="$3"

  if [[ ! -f "$dst" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    log_success "Installed: $description"
  else
    log_warning "Already exists: $description (skipped)"
  fi
}

# ============================================================================
# Validation
# ============================================================================

log_header "Validating setup..."

# Check if running from correct directory
if [[ ! -f "$REPO_ROOT/CLAUDE.md" ]]; then
  die "Cannot find CLAUDE.md in $REPO_ROOT. Are you running this from the correct directory?"
fi

# Check if ~/.claude exists
if [[ ! -d "$CLAUDE_DIR" ]]; then
  log_warning "Creating $CLAUDE_DIR (Claude Code profile directory)"
  mkdir -p "$CLAUDE_DIR"
fi

log_success "Validation passed"

# ============================================================================
# Step 1: Copy CLAUDE.md (Project Guidelines)
# ============================================================================

log_header "Step 1/3: Installing project guidelines..."

copy_if_missing \
  "$REPO_ROOT/CLAUDE.md" \
  "$CLAUDE_DIR/projects/$PROJECT_SLUG/CLAUDE.md" \
  "Project guidelines (CLAUDE.md)"

# ============================================================================
# Step 2: Copy Starter Slash Command
# ============================================================================

log_header "Step 2/3: Installing starter slash command..."

# Create skills directory if needed
SKILLS_DIR="$CLAUDE_DIR/skills"
if [[ ! -d "$SKILLS_DIR" ]]; then
  mkdir -p "$SKILLS_DIR"
  log_success "Created skills directory"
else
  log_warning "Skills directory already exists (skipped)"
fi

# Install commit command as starter
if [[ -f "$REPO_ROOT/01-slash-commands/commit.md" ]]; then
  copy_if_missing \
    "$REPO_ROOT/01-slash-commands/commit.md" \
    "$SKILLS_DIR/quickstart-commit.md" \
    "Starter skill: commit command"
else
  log_warning "Source not found: 01-slash-commands/commit.md (skipped)"
fi

# ============================================================================
# Step 3: Copy Starter Skill (CLAUDE.md preferences)
# ============================================================================

log_header "Step 3/3: Setting up preferences..."

PREFS_FILE="$CLAUDE_DIR/CLAUDE.md"

if [[ ! -f "$PREFS_FILE" ]]; then
  cat > "$PREFS_FILE" << 'EOF'
# My Development Preferences

## Quick Start
- **Language**: Python (primary)
- **Editor**: VS Code + Claude Code
- **Workflow**: TDD-first, incremental commits

## Key Principles
1. **Test First**: Write tests before code
2. **Immutability**: Create new objects, never mutate
3. **Small Functions**: Prefer <50 lines
4. **Clear Errors**: Always handle errors explicitly

## Next Steps
1. Read CLAUDE.md in your project directory
2. Run: `pre-commit install` (installs code quality hooks)
3. Try: `/commit` slash command (Claude will help write commit messages)

For full preferences, see ~/.claude/projects/claude-howto/CLAUDE.md.
EOF
  log_success "Created global preferences file"
else
  log_warning "Global preferences already exist (skipped)"
fi

# ============================================================================
# Verification
# ============================================================================

log_header "Verifying installation..."

INSTALLED_COUNT=0
EXPECTED_COUNT=3

[[ -f "$CLAUDE_DIR/projects/$PROJECT_SLUG/CLAUDE.md" ]] && INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
[[ -f "$CLAUDE_DIR/CLAUDE.md" ]] && INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
[[ -d "$SKILLS_DIR" ]] && INSTALLED_COUNT=$((INSTALLED_COUNT + 1))

if [[ $INSTALLED_COUNT -eq $EXPECTED_COUNT ]]; then
  log_success "$INSTALLED_COUNT/$EXPECTED_COUNT components verified"
else
  log_warning "$INSTALLED_COUNT/$EXPECTED_COUNT components verified (some were skipped)"
fi

# ============================================================================
# Success Message
# ============================================================================

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Quick Start Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo "What you just installed:"
echo "  • Project guidelines (CLAUDE.md)"
echo "  • Global preferences (~/.claude/CLAUDE.md)"
echo "  • Starter slash command template"
echo ""

echo "Next steps:"
echo "  1. Open your project in Claude Code"
echo "  2. Run: ${BLUE}pre-commit install${NC} (one-time setup for code checks)"
echo "  3. Try: ${BLUE}/commit${NC} command in Claude Code to test"
echo ""

echo "Learn more:"
echo "  • Project CLAUDE.md: $CLAUDE_DIR/projects/$PROJECT_SLUG/CLAUDE.md"
echo "  • Global preferences: $CLAUDE_DIR/CLAUDE.md"
echo "  • Tutorial modules: $REPO_ROOT/01-slash-commands (and 02-10)"
echo ""

log_success "Happy coding! 🚀"
