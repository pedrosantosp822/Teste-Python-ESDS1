#!/usr/bin/env bash
set -e

# Caminhos possíveis onde as extensões remotas ficam armazenadas
EXT_PATHS=("$HOME/.vscode-server/extensions" "$HOME/.vscode-remote/extensions" "$HOME/.vscode/extensions")

# 1) Desinstalar Copilot (se estiver instalado)
echo ">> Removendo GitHub Copilot (se existir)..."
code --uninstall-extension GitHub.copilot || true
code --uninstall-extension GitHub.copilot-nightly || true

# 2) Limpar extensões que não sejam as autorizadas (ms-python.* e ms-python.vscode-pylance)
ALLOWED=("ms-python.python" "ms-python.vscode-pylance")

for p in "${EXT_PATHS[@]}"; do
  if [ -d "$p" ]; then
    echo ">> Processando extensões em $p"
    # Listar diretórios dentro de p
    for extdir in "$p"/*; do
      [ -e "$extdir" ] || continue
      extname=$(basename "$extdir")
      keep=false
      for a in "${ALLOWED[@]}"; do
        if [[ "$extname" == "$a"* ]]; then
          keep=true
          break
        fi
      done
      if [ "$keep" = false ]; then
        echo "   -> Removendo $extname"
        rm -rf "$extdir" || true
      else
        echo "   -> Mantendo $extname"
      fi
    done
  fi
done

# 3) Re-instalar explicitamente as extensões autorizadas (garantia)
echo ">> Instalando extensões autorizadas..."
for a in "${ALLOWED[@]}"; do
  code --install-extension "$a" --force || true
done

# 4) Tornar as pastas de extensões só-leitura para impedir novas instalações
echo ">> Tornando pastas de extensões somente-leitura para o utilizador"
for p in "${EXT_PATHS[@]}"; do
  if [ -d "$p" ]; then
    # Retira permissões de escrita para todos
    chmod -R a-w "$p" || true
    # Se quiser ser ainda mais restrito, mudar o dono para root (pode falhar se não houver permissões)
    # sudo chown -R root:root "$p" || true
  fi
done

# 5) Instalar dependências Python (requirements.txt se existir)
if [ -f "/workspaces/$(basename $(git rev-parse --show-toplevel))/requirements.txt" ]; then
  echo ">> Instalando requirements.txt (detetado na raiz do workspace)..."
  pip install -r "/workspaces/$(basename $(git rev-parse --show-toplevel))/requirements.txt" || true
else
  # fallback: procurar requirements.txt no workspace root
  if [ -f "/workspaces/$(ls /workspaces | head -n1)/requirements.txt" ]; then
    pip install -r "/workspaces/$(ls /workspaces | head -n1)/requirements.txt" || true
  else
    echo ">> requirements.txt não encontrado — nada a instalar."
  fi
fi

echo ">> Enforcement concluído."
