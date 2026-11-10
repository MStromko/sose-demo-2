#!/usr/bin/env bash
# Vráti demo do bodu 0 (stav pred vložením kódu z dema).
# Pracuje len lokálne – nič nepushuje ani nemení na vzdialenom repozitári.
#
# Použitie:
#   ./reset-demo.sh          # interaktívne, s potvrdením
#   ./reset-demo.sh --yes    # bez potvrdenia

set -euo pipefail

BASE_TAG="demo-start"
MAIN_BRANCH="main"
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "Neznámy argument: $arg" >&2; exit 2 ;;
  esac
done

cd "$(dirname "$0")"

if ! git rev-parse -q --verify "refs/tags/$BASE_TAG" >/dev/null; then
  echo "Chyba: tag '$BASE_TAG' neexistuje." >&2
  echo "Vytvor ho na commite, ktorý je bodom 0 (už obsahuje README aj tento script):" >&2
  echo "  git tag $BASE_TAG" >&2
  exit 1
fi

# Pracovné vetvy = všetky lokálne vetvy okrem main.
# Bez mapfile a polí, aby script fungoval aj s bash 3.2 na macOS.
EXTRA_BRANCHES="$(git for-each-ref --format='%(refname:short)' refs/heads | grep -vx "$MAIN_BRANCH" || true)"

echo "Reset do bodu 0: $BASE_TAG ($(git rev-parse --short "$BASE_TAG"))"
echo
echo "--- Necommitnuté zmeny, ktoré sa zahodia ---"
git status --short || true
echo
echo "--- Commity po $BASE_TAG, ktoré sa zahodia (aktuálna vetva) ---"
git log --oneline "$BASE_TAG"..HEAD || true
echo
echo "--- Lokálne vetvy, ktoré sa zmažú ---"
if [ -n "$EXTRA_BRANCHES" ]; then echo "$EXTRA_BRANCHES"; else echo "(žiadne)"; fi
echo

if [ "$ASSUME_YES" -ne 1 ]; then
  read -r -p "Pokračovať a zahodiť všetko vyššie? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Zrušené."; exit 1 ;;
  esac
fi

git checkout -f "$MAIN_BRANCH"
git reset --hard "$BASE_TAG"
git clean -fd

# Názvy git vetiev nemôžu obsahovať medzery, takže delenie slov je bezpečné.
for branch in $EXTRA_BRANCHES; do
  git branch -D "$branch"
done

echo
echo "Hotovo. Demo je v bode 0 ($BASE_TAG)."
