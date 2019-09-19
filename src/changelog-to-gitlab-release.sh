#!/usr/bin/env sh
set -e

# Define script version
readonly SCRIPT_VERSION='1.0.0';

# Show script usage help
showUsage() {
  self="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")";

  printf "Make release on gitlab.com based on entry in CHANGELOG.md file (v%s).\n\n" "${SCRIPT_VERSION}";
  printf "Usage:   \033[33m%s\033[0m \033[32m%s\033[0m\n" \
    "${self}" \
    "%path_to_changelog.md% %version_header% %git_tag_name% %gitlab_api_endpoint% %api_token%";
  printf "Example: \033[33m%s\033[0m \033[32m\"%s\" \"%s\" \"%s\" \"%s\" \"%s\"\033[0m\n\n" \
    "${self}" \
    "./CHANGELOG.md" \
    "v1.0.0" \
    "v1.0.0" \
    "https://gitlab.com/api/v4/projects/666/releases" \
    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  echo "Help: Releases API <https://docs.gitlab.com/ee/api/releases/>";
}

# Make check - all arguments was passed?
if [ $# -ge 4 ]; then
  # Declare variables based on passed arguments
  CHANGELOG_PATH="$1";
  VERSION="$2";
  TAG_NAME="$3";
  API_ENDPOINT="$4";
  API_TOKEN="$5";

  # Make minimal chacking for passed variables
  if [ ! -f "$CHANGELOG_PATH" ]; then
    (>&2 echo "[ERROR] File '${CHANGELOG_PATH}' was not found.") && showUsage && exit 1;
  elif [ -z "${VERSION}" ]; then
    (>&2 echo "[ERROR] Version is not provided.") && showUsage && exit 1;
  elif [ -z "${TAG_NAME}" ]; then
    (>&2 echo "[ERROR] Git tag name is not provided.") && showUsage && exit 1;
  elif [ -z "${API_ENDPOINT}" ]; then
    (>&2 echo "[ERROR] API endpoint path is not provided.") && showUsage && exit 1;
  elif [ -z "${API_TOKEN}" ]; then
    (>&2 echo "[ERROR] API auth token is not provided.") && showUsage && exit 1;
  fi;

  # Extract release notes
  RELEASE_NOTES=$(sed "1,/## [vV]\?${VERSION}/d;/## [vV]/Q" ./CHANGELOG.md 2>/dev/null);

  # Make release notes check
  if [ -z "$RELEASE_NOTES" ]; then
    (>&2 echo "[ERROR] Release notes for '${VERSION}' was not found in '${CHANGELOG_PATH}' file.") && exit 1;
  fi;

  # Create temporary file for request body
  request_body_file=$(mktemp) && touch "$request_body_file";

  # Write request body into temporary file
  jq -n -M \
    --arg name "Release ${VERSION}" \
    --arg tag_name "${TAG_NAME}" \
    --arg release_notes "${RELEASE_NOTES}" \
    '{name:$name, tag_name:$tag_name, description:$release_notes }' 1> "$request_body_file";

  printf "Send to the '%s':\n  " "$API_ENDPOINT" && jq -Cc < "$request_body_file" && echo;

  # Send request to the GitLab API
  curl -f -X POST \
    --header 'Content-Type:application/json' \
    --header "PRIVATE-TOKEN:${API_TOKEN}" \
    --data "@${request_body_file}" \
      "${API_ENDPOINT}" || (>&2 echo "[ERROR] Cannot complete request.") && exit 10;

  rm -f "$request_body_file";
else
  showUsage && exit 0;
fi;
