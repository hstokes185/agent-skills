#!/bin/bash
#
# purge-old-kernels — keep only the N newest kernels (plus the running one).
#
# Intended to be installed to /usr/local/sbin/ and run by system-maintenance,
# or driven by its own systemd timer (see the "Recommended: scheduled system
# maintenance" section of SKILL.md). It is safe to run by hand at any time; it
# makes no changes when there is nothing to prune.
#
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

KEEP=2                       # how many of the newest kernels to retain
running="$(uname -r)"

# Installed kernel versions (e.g. 6.8.0-111-generic), sorted oldest -> newest.
mapfile -t versions < <(
    dpkg-query -W -f='${Package}\n' 'linux-image-*' 2>/dev/null \
    | sed -n 's/^linux-image-\([0-9].*\)/\1/p' \
    | sort -V
)

# Nothing to do if we already have KEEP or fewer kernels.
(( ${#versions[@]} <= KEEP )) && exit 0

# Versions to keep: the newest $KEEP, plus whatever is running right now.
declare -A keep=()
for v in "${versions[@]: -$KEEP}"; do keep["$v"]=1; done
keep["$running"]=1

# Collect every package belonging to the kernels we are dropping.
purge=()
for v in "${versions[@]}"; do
    [[ -n "${keep[$v]:-}" ]] && continue
    base="${v%-generic}"   # e.g. 6.8.0-90
    while read -r pkg; do
        [[ -n "$pkg" ]] && purge+=("$pkg")
    done < <(
        dpkg-query -W -f='${Package} ${Status}\n' \
            "linux-headers-${base}*" "linux-image-${v}*" \
            "linux-modules-${base}*" "linux-modules-extra-${base}*" \
            "linux-tools-${base}*" 2>/dev/null \
        | awk '/install ok installed/{print $1}'
    )
done

if (( ${#purge[@]} )); then
    logger -t purge-old-kernels "Purging old kernels: ${purge[*]}"
    apt-get -y purge "${purge[@]}"
    apt-get -y autoremove --purge
    logger -t purge-old-kernels "Done."
fi
