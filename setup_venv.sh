#!/usr/bin/env bash
# Crea (si no existe) el .venv del repo, instala requirements.txt y te deja adentro.
#
# Uso:
#   source ./setup_venv.sh      # crea/instala y activa el .venv en TU shell actual
#   ./setup_venv.sh             # crea/instala y abre una shell nueva ya activada
#   ./setup_venv.sh --no-shell  # solo crea/instala (útil para CI)
#
# Después, para correr el notebook:
#   jupyter lab notebooks/vqe_h4.ipynb
# y elegí el kernel "Python (quantumjam2026)".

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$ROOT/.venv"
PYTHON="${PYTHON:-python3}"
KERNEL_NAME="quantumjam2026"
KERNEL_DISPLAY="Python (quantumjam2026)"

# ¿Nos están haciendo source? (si sí, no tocamos las opciones ni el cwd del usuario)
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  SOURCED=1
else
  SOURCED=0
fi

_setup() {
  set -euo pipefail

  if [[ ! -d "$VENV" ]]; then
    echo ">> Creando entorno virtual en $VENV con $PYTHON ..."
    "$PYTHON" -m venv "$VENV"
  else
    echo ">> Reutilizando entorno virtual existente en $VENV"
  fi

  # shellcheck disable=SC1091
  source "$VENV/bin/activate"

  python -m pip install --upgrade pip >/dev/null
  echo ">> Instalando dependencias de requirements.txt (puede tardar unos minutos) ..."
  python -m pip install -r "$ROOT/requirements.txt"

  # Registra el kernel para que Jupyter lo muestre con nombre propio.
  python -m ipykernel install --user \
    --name "$KERNEL_NAME" \
    --display-name "$KERNEL_DISPLAY" >/dev/null
  echo ">> Kernel de Jupyter registrado como \"$KERNEL_DISPLAY\""

  echo ""
  echo ">> Listo. Entorno: $VENV"
  echo "   Python: $(python --version)"
  echo "   Para correr el notebook:  jupyter lab notebooks/vqe_h4.ipynb"
}

if [[ "$SOURCED" -eq 1 ]]; then
  # Corremos la instalación en un subshell para no contaminar tu shell con set -e/-u.
  ( _setup )
  # shellcheck disable=SC1091
  source "$VENV/bin/activate"
  echo ">> .venv activado en esta shell (deactivate para salir)."
  return 0
fi

_setup

if [[ "${1:-}" == "--no-shell" ]]; then
  exit 0
fi

# Sin terminal interactiva (CI, GUI, pipe) no tiene sentido abrir una shell.
if [[ ! -t 0 || ! -t 1 ]]; then
  echo ">> No hay terminal interactiva. Para activar el entorno corré:"
  echo "   source \"$VENV/bin/activate\""
  exit 0
fi

# Ejecutado como script: abrimos una shell interactiva con el venv ya activado.
# Importante: cargamos primero el rc normal del usuario (que puede tocar PATH, p. ej.
# conda/pyenv) y recién después activamos el venv, para que el venv gane.
SHELL_BIN="${SHELL:-/bin/bash}"
case "$(basename "$SHELL_BIN")" in
  bash)
    RC="$VENV/activate-shell.bashrc"
    {
      [[ -f /etc/bash.bashrc ]] && printf 'source %q\n' /etc/bash.bashrc
      [[ -f "$HOME/.bashrc" ]] && printf 'source %q\n' "$HOME/.bashrc"
      printf 'source %q\n' "$VENV/bin/activate"
      printf 'hash -r\n'
    } > "$RC"
    echo ">> Abriendo bash con el entorno activado (exit para salir) ..."
    exec "$SHELL_BIN" --rcfile "$RC" -i
    ;;
  zsh)
    ZDOT="$VENV/zsh-rc"
    ORIG_ZDOT="${ZDOTDIR:-$HOME}"
    mkdir -p "$ZDOT"
    {
      [[ -f "$ORIG_ZDOT/.zshrc" ]] && printf 'source %q\n' "$ORIG_ZDOT/.zshrc"
      printf 'source %q\n' "$VENV/bin/activate"
      printf 'hash -r 2>/dev/null || true\n'
    } > "$ZDOT/.zshrc"
    echo ">> Abriendo zsh con el entorno activado (exit para salir) ..."
    ZDOTDIR="$ZDOT" exec "$SHELL_BIN" -i
    ;;
  *)
    echo ">> Shell $SHELL_BIN no soportada para auto-activar; abriendo igual."
    echo "   Si el entorno no queda activo, corré: source \"$VENV/bin/activate\""
    exec "$SHELL_BIN" -i
    ;;
esac
