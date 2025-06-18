#!/usr/bin/env bash
set -euo pipefail

versions=("3.10.17" "3.11.12" "3.12.10" "3.13.4")

for v in "${versions[@]}"; do
  echo "📦 Installing Python $v via uv..."
  uv python install "$v"

  py_bin=$(uv python find "$v")

  echo "🧪 Upgrading pip for Python $v..."
  "$py_bin" -m pip install --upgrade pip setuptools wheel --break-system-packages

  echo "📡 Installing numpy for Python $v..."
  "$py_bin" -m pip install numpy --break-system-packages
done
