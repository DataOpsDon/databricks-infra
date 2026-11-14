#!/bin/bash
set -e

# onCreateCommand installs uv into ~/.local/bin, but this script runs in its
# own shell that doesn't inherit remoteEnv (that only applies to VS Code's
# own terminals/processes) - so uv isn't on PATH yet without this.
export PATH="${HOME}/.local/bin:${PATH}"

echo "🔄 Updating development tools..."
echo ""

# Track failures
FAILURES=()

# Update Azure CLI
echo "📦 Checking Azure CLI..."
CURRENT_AZ=$(az version --query '"azure-cli"' -o tsv 2>/dev/null || echo "unknown")
echo "   ℹ️  Current version: $CURRENT_AZ (managed by devcontainer feature, auto-upgrade disabled)"


# Configure Git and directories
echo "🔐 Configuring Git & directories..."
mkdir -p "${HOME}/.cache" "${HOME}/.config/gh"
sudo chown -R vscode:vscode "${HOME}/.cache" 2>/dev/null || true
sudo chown -R vscode:vscode "${HOME}/.config/gh" 2>/dev/null || true
chmod 755 "${HOME}/.cache" 2>/dev/null || true
chmod 755 "${HOME}/.config/gh" 2>/dev/null || true
git config --global --add safe.directory "${PWD}"
git config --global core.autocrlf input
echo "   ✅ Git configured, cache dirs created"

# Install Telefónica Tech Ignition CLI
# 1. Local wheel committed to the repo (works offline / in client environments
#    with no access to the Telefónica Tech GitHub org):
#      .devcontainer/wheels/ign-*.whl  (bundled by `ign init`; override with --ign-wheel <path>)
#      ./ign-*.whl                     (repo root)
#    Newest version wins.
# 2. Only if no local wheel: download from the GitHub release (needs GH_TOKEN
#    with read access to IGN_REPO).
echo "📦 Installing Telefónica Tech Ignition CLI..."
IGN_VERSION="${IGN_VERSION:-1.0.22}"
IGN_REPO="telefonicatechuki/devops-cli"
WHEEL_DIR="$(mktemp -d)"

WHEEL=$(ls -1 .devcontainer/wheels/ign-*.whl ./ign-*.whl 2>/dev/null | sort -V | tail -n1)
if [ -n "$WHEEL" ]; then
  echo "   ℹ️  Using local wheel: $WHEEL"
elif gh auth status >/dev/null 2>&1 && \
     gh release download "v${IGN_VERSION}" --repo "$IGN_REPO" --pattern "*.whl" --dir "$WHEEL_DIR"; then
  WHEEL=$(ls -1 "$WHEEL_DIR"/ign-*.whl 2>/dev/null | sort -V | tail -n1)
  echo "   ✅ Downloaded ign v${IGN_VERSION} from GitHub release"
fi

if [ -n "$WHEEL" ] && uv tool install "$WHEEL" --force; then
  echo "   ✅ Installed $(basename "$WHEEL")"
else
  echo "   ❌ Ignition CLI install failed - no wheel found"
  echo "      Commit the wheel to .devcontainer/wheels/ (e.g. ign-${IGN_VERSION}-py3-none-any.whl),"
  echo "      or set GH_TOKEN with read access to ${IGN_REPO}, then run: bash .devcontainer/post-create.sh"
  FAILURES+=("ign")
fi
rm -rf "$WHEEL_DIR"

# Verify Infracost installation
infracost -v || FAILURES+=("infracost")

echo ""
if [ ${#FAILURES[@]} -eq 0 ]; then
  echo "✅ Dev container ready"
else
  # Don't fail container creation - the rest of the tooling is still usable.
  echo "⚠️  Dev container ready, but these steps failed: ${FAILURES[*]}"
fi