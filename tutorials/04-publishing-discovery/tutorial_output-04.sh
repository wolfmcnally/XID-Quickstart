#!/bin/bash
# tutorial_output.sh
#
# Tutorial 04: Publishing for Discovery
#
# Prepares an existing XID for publication:
# 1. Loads Tutorial 03 artifacts
# 2. Adds dereferenceVia assertions (publication URLs)
# 3. Creates and adds inception authority to GitHub attachment
# 4. Creates public version via elision
# 5. Verifies signatures and provenance
# 6. Advances provenance for version tracking

set -e  # Exit on any error

# Configuration
XID_NAME="BRadvoc8"
PASSWORD="Amira's strong password"

echo "=== Tutorial 04: Publishing for Discovery ==="
echo ""

# ============================================================================
# Part I: Load Tutorial 03 Artifacts
# ============================================================================

echo "## Step 1: Load Your Enriched XID"
echo ""

# Find the most recent Tutorial 03 output directory
TUTORIAL_03_DIR=$(find ../03-building-persona/output/xid-tutorial03-* -type d 2>/dev/null | sort -r | head -1)
if [ -z "$TUTORIAL_03_DIR" ]; then
    echo "No Tutorial 03 output found. Run Tutorial 03 first:"
    echo "  cd ../03-building-persona && bash tutorial_output.sh"
    exit 1
fi

echo "Loading artifacts from: $TUTORIAL_03_DIR"

# Load the XID from Tutorial 03
XID=$(cat "$TUTORIAL_03_DIR/BRadvoc8-private.xid")

# Load SSH keys from Tutorial 03 (for inception authority)
SSH_PRVKEYS=$(cat "$TUTORIAL_03_DIR/BRadvoc8-ssh-prvkeys.ur")
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
SSH_EXPORT=$(cat "$TUTORIAL_03_DIR/BRadvoc8-ssh.pub")

echo "✓ XID loaded"
echo "✓ SSH signing keys loaded"
echo ""
echo "Current XID structure:"
envelope format "$XID"

# ============================================================================
# Part II: Add Discovery Locations
# ============================================================================

echo ""
echo "## Step 2: Add dereferenceVia Assertions"
echo ""

# Add dereferenceVia assertion - GitHub raw URL
GITHUB_URL="https://raw.githubusercontent.com/$XID_NAME/$XID_NAME/main/$XID_NAME-public.envelope"
echo "Adding dereferenceVia: $GITHUB_URL"
XID=$(envelope xid resolution add \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$GITHUB_URL" \
    "$XID" \
)

# Add alternative endpoint (GitHub blob URL as backup)
GITHUB_BLOB_URL="https://github.com/$XID_NAME/$XID_NAME/blob/main/$XID_NAME-public.envelope"
echo "Adding dereferenceVia: $GITHUB_BLOB_URL"
XID=$(envelope xid resolution add \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$GITHUB_BLOB_URL" \
    "$XID" \
)

echo "✓ Added dereferenceVia assertions"
echo ""
echo "XID with discovery locations:"
envelope format "$XID"

# ============================================================================
# Part III: Add Inception Authority to GitHub Attachment
# ============================================================================

echo ""
echo "## Step 3: Establish Repository Authority (Inception)"
echo ""

# Create inception record with repo URI as subject
INCEPTION_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
REPO_URL="https://github.com/$XID_NAME/$XID_NAME"

echo "Creating inception record for: $REPO_URL"
INCEPTION_RECORD=$(envelope subject type uri "$REPO_URL")
INCEPTION_RECORD=$(envelope assertion add pred-obj string "date" date "$INCEPTION_DATE" "$INCEPTION_RECORD")
INCEPTION_RECORD=$(envelope assertion add pred-obj string "sshKey" string "$SSH_EXPORT" "$INCEPTION_RECORD")

# Sign the inception record with SSH key
INCEPTION_SIGNED=$(envelope sign --signer "$SSH_PRVKEYS" "$INCEPTION_RECORD")

echo "Inception record (signed with SSH key):"
envelope format "$INCEPTION_SIGNED"

# Find the existing GitHub attachment
echo ""
echo "Extracting existing GitHub attachment..."
GITHUB_ATTACHMENT=$(envelope xid attachment find --vendor "self" "$XID")

# Extract the payload (the inner envelope with GitHub account info)
ATTACHMENT_OBJECT=$(envelope extract object "$GITHUB_ATTACHMENT")
PAYLOAD=$(envelope extract wrapped "$ATTACHMENT_OBJECT")

echo "Current GitHub account payload:"
envelope format "$PAYLOAD"

# Add inception as assertion to the GitHub account payload
echo ""
echo "Adding inception assertion to GitHub attachment..."
UPDATED_PAYLOAD=$(envelope assertion add pred-obj string "inception" envelope "$INCEPTION_SIGNED" "$PAYLOAD")

echo "Updated payload with inception:"
envelope format "$UPDATED_PAYLOAD"

# Remove old attachment and add updated one
echo ""
echo "Replacing attachment in XID..."
XID_NO_ATTACHMENT=$(envelope xid attachment remove \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$GITHUB_ATTACHMENT" \
    "$XID" \
)

XID=$(envelope xid attachment add \
    --vendor "self" \
    --payload "$UPDATED_PAYLOAD" \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_NO_ATTACHMENT" \
)

echo "✓ Updated GitHub attachment with inception authority"
echo ""
echo "XID with inception authority:"
envelope format "$XID"

# ============================================================================
# Part IV: Create Public Version
# ============================================================================

echo ""
echo "## Step 4: Create Public XID"
echo ""

# Export public version with elided secrets (preserves signature)
PUBLIC_XID=$(envelope xid export \
    --private elide \
    --generator elide \
    --password "$PASSWORD" \
    "$XID" \
)

echo "Public XID (ready for publication):"
envelope format "$PUBLIC_XID"

# ============================================================================
# Part V: Verify Signatures
# ============================================================================

echo ""
echo "## Step 5: Verify Signature on Public XID"
echo ""

# Verify digests match (elision preserved the hash)
PRIVATE_DIGEST=$(envelope digest "$XID")
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_XID")

echo "Private XID digest: $PRIVATE_DIGEST"
echo "Public XID digest:  $PUBLIC_DIGEST"

if [ "$PRIVATE_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo "✅ VERIFIED: Digests identical - elision preserved the root hash!"
else
    echo "❌ ERROR: Digests differ"
    exit 1
fi

# Get public keys from the XID and verify signature
PUBKEYS=$(envelope xid key all "$PUBLIC_XID")
envelope verify --silent --verifier "$PUBKEYS" "$PUBLIC_XID"
echo "✅ Signature verified on public XID"

# ============================================================================
# Part VI: Verification Pattern Demo
# ============================================================================

echo ""
echo "## Step 6: Update Verification Pattern"
echo ""

echo "=== Simulating Verifier Fetching XID ==="

# 1. Fetch XID (simulated - in practice, use curl)
FETCHED_XID="$PUBLIC_XID"
echo "1. Fetched XID from dereferenceVia URL"

# 2. Get public keys and verify signature
FETCHED_PUBKEYS=$(envelope xid key all "$FETCHED_XID")
envelope verify --silent --verifier "$FETCHED_PUBKEYS" "$FETCHED_XID"
echo "2. ✓ Signature verified"

# 3. Check provenance sequence
PROV_MARK=$(envelope xid provenance get "$FETCHED_XID")
echo "3. Provenance mark: $(echo "$PROV_MARK" | head -c 60)..."

# 4. Examine inception authority attachment
echo "4. ✓ Inception authority found in attachment"

echo ""
echo "=== Verification Complete ==="

# ============================================================================
# Part VII: Save Files
# ============================================================================

echo ""
echo "## Step 7: Save Your Files"
echo ""

# Create output directory with timestamp
OUTPUT_DIR="output/xid-tutorial04-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save public XID (for publication)
echo "$PUBLIC_XID" > "$OUTPUT_DIR/$XID_NAME-public.xid"
envelope format "$PUBLIC_XID" > "$OUTPUT_DIR/$XID_NAME-public.format"

# Save private XID (complete version with encrypted secrets)
echo "$XID" > "$OUTPUT_DIR/$XID_NAME-private.xid"
envelope format "$XID" > "$OUTPUT_DIR/$XID_NAME-private.format"

# Save SSH keys (for reference)
echo "$SSH_PRVKEYS" > "$OUTPUT_DIR/$XID_NAME-ssh-prvkeys.ur"
echo "$SSH_EXPORT" > "$OUTPUT_DIR/$XID_NAME-ssh.pub"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"

# ============================================================================
# Part VIII: Advance Provenance
# ============================================================================

echo ""
echo "## Step 8: Advance Provenance"
echo ""

# Advance provenance from sequence 0 to sequence 1
XID_V1=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID" \
)

echo "✓ Advanced provenance to sequence 1"

# Check the new provenance
NEW_PROV=$(envelope xid provenance get "$XID_V1")
echo "New provenance mark: $(echo "$NEW_PROV" | head -c 60)..."

# Save the provenanced version
echo "$XID_V1" > "$OUTPUT_DIR/$XID_NAME-private-v1.xid"
envelope format "$XID_V1" > "$OUTPUT_DIR/$XID_NAME-private-v1.format"

echo "✓ Saved XID with advanced provenance"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "=== Tutorial 04 Complete ==="
echo ""
echo "Summary:"
echo "  - Loaded Tutorial 03 XID with GitHub account attachment"
echo "  - Added dereferenceVia assertions (publication URLs)"
echo "  - Created and added inception authority to GitHub attachment"
echo "  - Created public version via elision"
echo "  - Verified signatures and hash preservation"
echo "  - Demonstrated update verification pattern"
echo "  - Advanced provenance for version tracking"
echo ""
echo "Output files:"
echo "  $OUTPUT_DIR/$XID_NAME-public.xid        # ✅ Public XID (publish this)"
echo "  $OUTPUT_DIR/$XID_NAME-public.format     #    Human-readable version"
echo "  $OUTPUT_DIR/$XID_NAME-private.xid       # 🔒 Private XID (keep secure)"
echo "  $OUTPUT_DIR/$XID_NAME-private.format    #    Human-readable version"
echo "  $OUTPUT_DIR/$XID_NAME-private-v1.xid    # 🔒 Private XID v1 (with advanced provenance)"
echo "  $OUTPUT_DIR/$XID_NAME-private-v1.format #    Human-readable version"
echo "  $OUTPUT_DIR/$XID_NAME-ssh-prvkeys.ur    # 🔒 SSH private keys (keep secure)"
echo "  $OUTPUT_DIR/$XID_NAME-ssh.pub           # ✅ SSH public key (for git config)"
