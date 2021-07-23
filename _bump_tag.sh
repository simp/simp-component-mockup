#!/bin/bash
set -euo pipefail
RPM_SPEC_FILE="build/simp-mockup-component.spec"
cur_ver="$(grep '^%global main_version' "$RPM_SPEC_FILE" | head -1 | awk '{print $3}')"
xyz=($(echo $cur_ver  | sed -e 's/\./ /g'))
y_mod=0; [[ $((1 + $RANDOM % 100)) == 1 ]] && y_mod=1

x="${xyz[0]}"
y=$(( ${xyz[1]} + $y_mod ))
z=$(( ${xyz[-1]} + 1 ))
bumped_ver="$x.$y.$z"
sub_ver=0.8.0

sed -e "s/%%MAIN_VER%%/${bumped_ver}/g" -e "s/%%SUB_VER%%/${sub_ver}/g" build/asset-with-multiple-packages.spec.template > "$RPM_SPEC_FILE"
git add -u
git commit -m "Test bump to ${bumped_ver}"
bundle exec rake pkg:create_tag_changelog | tee tag.txt
git tag "$bumped_ver" -F tag.txt
git push origin main
git push origin "$bumped_ver"
