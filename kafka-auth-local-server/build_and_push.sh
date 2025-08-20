#!/bin/bash
set -e

# Configuration
# PROJECT_ID will be set based on the environment (prod/dev)
# IMAGE_NAME is the name of the Docker image
IMAGE_NAME="gcp-kafka-auth-server"
# REGION is the Google Cloud region where the Artifact Registry is located
REGION="us-east1"
# REGISTRY is the base domain for the Artifact Registry
REGISTRY="${REGION}-docker.pkg.dev"
# Project IDs
PROD_PROJECT_ID="serene-essence-442702-v4"
DEV_PROJECT_ID="cascade-meme-dev"


# --- Script Start ---

# Check if TAG argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <TAG>"
  echo "Example: $0 v1.0.0"
  exit 1
fi

TAG="$1"

# Define Registry URLs
DEV_REGISTRY_URL="${REGISTRY}/${DEV_PROJECT_ID}/internal"
PROD_REGISTRY_URL="${REGISTRY}/${PROD_PROJECT_ID}/internal"

# Define Image URLs
DEV_IMAGE_URL="${DEV_REGISTRY_URL}/${IMAGE_NAME}:${TAG}"
PROD_IMAGE_URL="${PROD_REGISTRY_URL}/${IMAGE_NAME}:${TAG}"

echo "--- Configuration ---"
echo "Image Name:   ${IMAGE_NAME}"
echo "Region:       ${REGION}"
echo "Tag:          ${TAG}"
echo "Dev Project:  ${DEV_PROJECT_ID}"
echo "Prod Project: ${PROD_PROJECT_ID}"
echo "Dev Image URL:  ${DEV_IMAGE_URL}"
echo "Prod Image URL: ${PROD_IMAGE_URL}"
echo "---------------------"

# Authenticate Docker with Artifact Registry (if not already configured)
# This command configures Docker to use gcloud as a credential helper for Artifact Registry.
echo "Authenticating Docker with Artifact Registry for ${REGISTRY}..."
gcloud auth configure-docker ${REGISTRY} --quiet

# Build the Docker image locally
# -t tags the image with the specified local tag
# -f Dockerfile specifies the Dockerfile to use
# . sets the build context to the current directory
echo "Building ${IMAGE_NAME} image with tag ${TAG} locally..."
docker build --platform linux/amd64 -t "${IMAGE_NAME}:${TAG}" -f Dockerfile .

# Tag the image for the Dev environment
echo "Tagging image for Dev environment: ${DEV_IMAGE_URL}"
docker tag "${IMAGE_NAME}:${TAG}" "${DEV_IMAGE_URL}"

# Tag the image for the Prod environment
echo "Tagging image for Prod environment: ${PROD_IMAGE_URL}"
docker tag "${IMAGE_NAME}:${TAG}" "${PROD_IMAGE_URL}"

# Push the image to Dev Artifact Registry
echo "Pushing image to Dev Artifact Registry at ${DEV_IMAGE_URL}..."
docker push "${DEV_IMAGE_URL}"

# Push the image to Prod Artifact Registry
echo "Pushing image to Prod Artifact Registry at ${PROD_IMAGE_URL}..."
docker push "${PROD_IMAGE_URL}"


echo "Done! Image pushed to:"
echo "  Dev:  ${DEV_IMAGE_URL}"
echo "  Prod: ${PROD_IMAGE_URL}"


# Print verification commands
# These commands help you verify that the image was pushed successfully by listing its tags.
echo "To verify the push, you can list tags for the image in Artifact Registry:"
echo "  Dev:  gcloud container images list-tags ${DEV_REGISTRY_URL}/${IMAGE_NAME} --filter='tags:${TAG}' --format='get(tags)'"
echo "  Prod: gcloud container images list-tags ${PROD_REGISTRY_URL}/${IMAGE_NAME} --filter='tags:${TAG}' --format='get(tags)'" 