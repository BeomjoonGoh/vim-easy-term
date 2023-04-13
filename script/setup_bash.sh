#!/usr/bin/env bash
# setup_bash
#
# Maintainer:   Beomjoon Goh
# Last Change:  13 Apr 2023 16:29:34 +0900

[ -f $HOME/.bash_profile ] && source $HOME/.bash_profile

dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
export PATH=$dir:$PATH
for comp in "${dir}/completion.d/"*; do
  source "${comp}"
done
unset comp dir
