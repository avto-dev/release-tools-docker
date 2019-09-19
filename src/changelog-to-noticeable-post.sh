#!/usr/bin/env sh
set -e

# Define script version
readonly SCRIPT_VERSION='1.0.0';

# Define GraphQL endpoint URI
readonly ENDPOINT_URI='https://api.noticeable.io/graphql';

# Show script usage help
showUsage() {
  self="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")";

  printf "Make post on noticeable.io with content entry from CHANGELOG.md file (v%s).\n\n" "${SCRIPT_VERSION}";
  printf "Usage:   \033[33m%s\033[0m \033[32m%s\033[0m\n" \
    "${self}" \
    "%path_to_changelog.md% %version_header% %author_name% %title% %featured_image_uri% %note_label% %project_id% %api_key%";
  printf "Example: \033[33m%s\033[0m \033[32m\\
           \"%s\" \\
           \"%s\" \\
           \"%s\" \\
           \"%s\" \\
           \"%s\" \\
           \"%s\" \\
           \"%s\" \\
           \"%s\"\033[0m\n\n" \
    "${self}" \
    "./CHANGELOG.md" \
    "v1.0.0" \
    "John Doe" \
    "Application FooBar v1.0.0 Released" \
    "https://hsto.org/webt/hn/5c/6g/hn5c6geloex3u6rzdphnguheckk.jpeg" \
    "New feature" \
    "XXXXXXXXXXXXXXXXXXXXX" \
    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  echo "Help: Graphql schema <https://graphdoc.noticeable.io/>";
  echo "      Graphql Playground <https://api.noticeable.io/graphql>";
  echo "      API Tokens <https://noticeable.io/api/tokens>";
}

# Make check - all arguments was passed?
if [ $# -ge 7 ]; then
  # Declare variables based on passed arguments
  CHANGELOG_PATH="$1";
  VERSION="$2";
  AUTHOR_NAME="${3:-Developers}";
  NOTE_TITLE="$4";
  FEATURED_IMAGE="$5";
  NOTE_LABEL="${6:-Announcement}";
  PROJECT_ID="$7";
  API_KEY="$8";

  # Make minimal chacking for passed variables
  if [ ! -f "$CHANGELOG_PATH" ]; then
    (>&2 echo "[ERROR] File '${CHANGELOG_PATH}' was not found.") && showUsage && exit 1;
  elif [ -z "${VERSION}" ]; then
    (>&2 echo "[ERROR] Version is not provided.") && showUsage && exit 1;
  elif [ -z "${NOTE_TITLE}" ]; then
    (>&2 echo "[ERROR] Note title is not provided.") && showUsage && exit 1;
  elif [ -z "${PROJECT_ID}" ]; then
    (>&2 echo "[ERROR] Project ID is not provided.") && showUsage && exit 1;
  elif [ -z "${API_KEY}" ]; then
    (>&2 echo "[ERROR] API key is not provided.") && showUsage && exit 1;
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
    --arg project_id "${PROJECT_ID}" \
    --arg author_name "${AUTHOR_NAME}" \
    --arg content "${RELEASE_NOTES}" \
    --arg title "${NOTE_TITLE}" \
    --arg featured_image "${FEATURED_IMAGE}" \
    --arg note_label_name "${NOTE_LABEL}" \
    --arg timestamp "$(date +%s)000" \
      '{query:"mutation ($post: CreatePostInput!) { createPost(input: $post) { post { id permalink }}}",
        variables: {
          post: {
            projectId:$project_id,
            author:{ fullName:$author_name },
            content:$content,
            isDraft:false,
            forwardToWebhooks:true,
            labels:[{name:$note_label_name}],
            publicationTime:$timestamp | tonumber,
            featuredImage:$featured_image,
            title:$title
          }
        }
      }' 1> "$request_body_file";

  printf "Send to the '%s':\n  " "${ENDPOINT_URI}" && jq -Cc < "$request_body_file" && echo;

  # Send request to the GitLab API
  curl -f -X POST \
    --header 'Content-Type:application/json' \
    --header 'Accept:application/json' \
    --header "Authorization: Apikey ${API_KEY}" \
    --data-binary "@${request_body_file}" \
      "${ENDPOINT_URI}" || (>&2 echo "[ERROR] Cannot complete request.") && exit 10;

  rm -f "$request_body_file";
else
  showUsage && exit 0;
fi;
