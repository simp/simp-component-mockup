#!/bin/bash

set -euo pipefail
RPM_SPEC_FILE="build/simp-mockup-component.spec"

TAG_RELEASE_WORKFLOW_SOURCE_FILE="${1:-${TAG_RELEASE_WORKFLOW_SOURCE_FILE:-workflows/tag_deploy_github-only.yml}}"
RPM_SPEC_TEMPLATE="${2:-${RPM_SPEC_TEMPLATE:-build/asset-with-multiple-packages.spec.template}}"

print_run_settings()
{
  echo
  echo '================================================================================'
  echo 'Testing using the following sources'
  echo
  echo "  tag_release file:  ${TAG_RELEASE_WORKFLOW_SOURCE_FILE}"
  echo "  rpm spec template: ${RPM_SPEC_TEMPLATE}"
  echo
  echo '================================================================================'
  echo
}


validate_files_exist()
{
  for i in "$RPM_SPEC_FILE" "$RPM_SPEC_TEMPLATE" "$TAG_RELEASE_WORKFLOW_SOURCE_FILE"; do
    [ -f "$i" ] || { echo "ERROR: File not found: '$i'"; exit 99; }
  done
}

# bump to next x.y.z version (z=always y=1% chance)
next_rpm_version()
{
  local RPM_SPEC_FILE="$1"
  local cur_ver="$(grep '^%global main_version' "$RPM_SPEC_FILE" | head -1 | awk '{print $3}')"
  local xyz=($(echo $cur_ver  | sed -e 's/\./ /g'))
  local y_mod=0; [[ $((1 + $RANDOM % 100)) == 1 ]] && y_mod=1
  local x="${xyz[0]}"
  local y=$(( ${xyz[1]} + $y_mod ))
  local z=$(( ${xyz[-1]} + 1 ))
  >&2 printf "\n-- bumping from '%s' to '%s'\n" "$cur_ver" "$x.$y.$z"
  echo "$x.$y.$z"
}

write_rpm_spec_file_from_template()
{
  local RPM_SPEC_TEMPLATE="$1"
  local RPM_SPEC_FILE="$2"
  local bumped_ver="$3"
  local sub_ver="${4:-0.8.0}"
  sed -e "s/%%MAIN_VER%%/${bumped_ver}/g" -e "s/%%SUB_VER%%/${sub_ver}/g" "$RPM_SPEC_TEMPLATE" > "$RPM_SPEC_FILE"
}

copy_tag_release_workflow_to_test()
{
  local TAG_RELEASE_WORKFLOW_SOURCE_FILE="$1"
  rm -vf ".github/workflows/tag_deploy*.yml"
  cp -v "$TAG_RELEASE_WORKFLOW_SOURCE_FILE" ".github/workflows/"
}

git_commit_tag_and_push_to_trigger_workflow()
{
  git add -u
  git add .github/workflows/tag_deploy*.yml || :
  git commit -m "Test bump to ${bumped_ver}"
  bundle exec rake pkg:create_tag_changelog | tee tag.txt
  git tag "$bumped_ver" -F tag.txt
  git push origin main
  git push origin "$bumped_ver"
}

# --------------------------------------
# main
# --------------------------------------
validate_files_exist
print_run_settings

bumped_ver="$(next_rpm_version "$RPM_SPEC_FILE")"
write_rpm_spec_file_from_template "$RPM_SPEC_TEMPLATE" "$RPM_SPEC_FILE" "$bumped_ver"

copy_tag_release_workflow_to_test "$TAG_RELEASE_WORKFLOW_SOURCE_FILE"

git_commit_tag_and_push_to_trigger_workflow "$bumped_ver"
