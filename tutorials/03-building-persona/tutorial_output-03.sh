#!/bin/bash
# tutorial_output.sh
#
# Tutorial 03: Building Your Persona
#
# Enriches an existing XID with professional information:
# 1. Loads Tutorial 01 artifacts
# 2. Generates SSH signing keys for Git commits
# 3. Creates proof-of-control statement
# 4. Builds GitHub account attachment with proper types
# 5. Creates public version via elision
# 6. Demonstrates selective disclosure with inclusion proofs

set -e  # Exit on any error

# Configuration
XID_NAME="BRadvoc8"
PASSWORD="Amira's strong password"

echo "=== Tutorial 03: Building Your Persona ==="
echo ""

# ============================================================================
# Part I: Load Tutorial 01 Artifacts
# ============================================================================

echo "## Step 1: Load Your Basic XID"
echo ""

# Find the most recent Tutorial 01 output directory
TUTORIAL_01_DIR=$(find ../01-your-first-xid/output/xid-2* -type d 2>/dev/null | sort -r | head -1)
if [ -z "$TUTORIAL_01_DIR" ]; then
    echo "No Tutorial 01 output found. Run tutorial 01 first:"
    echo "  cd ../01-your-first-xid && bash tutorial_output.sh"
    exit 1
fi

echo "Loading XID from: $TUTORIAL_01_DIR"

# Load the XID file
XID=$(cat "$TUTORIAL_01_DIR/BRadvoc8-private.xid")

echo "Loaded XID. Structure:"
envelope format "$XID"

# ============================================================================
# Part II: Add GitHub Account Information
# ============================================================================

echo ""
echo "## Step 2: Add GitHub Account Information"
echo ""

# Generate SSH signing keys
echo "Generating SSH signing keys..."
read -r SSH_PRVKEYS SSH_PUBKEYS <<< $(envelope generate keypairs --signing ssh-ed25519)

# Export SSH public key in standard format for GitHub
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")
echo "SSH public key (for GitHub):"
echo "$SSH_EXPORT"

# Create proof-of-control statement
echo ""
echo "Creating proof-of-control statement..."
CURRENT_DATE=$(date -u +"%Y-%m-%d")
PROOF_STATEMENT=$(envelope subject type string "$XID_NAME controls this SSH key on $CURRENT_DATE")
PROOF=$(envelope sign --signer "$SSH_PRVKEYS" "$PROOF_STATEMENT")

echo "Proof-of-control statement:"
envelope format "$PROOF"

# Verify the proof can be validated
echo ""
envelope verify --silent --verifier "$SSH_PUBKEYS" "$PROOF"
echo "✓ Signature verified - proof of key control confirmed"

# Build GitHub account information with proper types
echo ""
echo "Building GitHub account attachment..."
GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known isA string "GitHubAccount" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known dereferenceVia uri "https://api.github.com/users/$XID_NAME" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "commitKey" ur "$SSH_PUBKEYS" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "commitKeyText" string "$SSH_EXPORT" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "commitKeyProof" ur "$PROOF" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "createdAt" date "2025-05-10T00:55:11Z" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "updatedAt" date "2025-05-10T00:55:28Z" "$GITHUB_ACCOUNT")

echo "GitHub account attachment structure:"
envelope format "$GITHUB_ACCOUNT"

# Add attachment to XID
echo ""
echo "Adding attachment to XID..."
XID_WITH_GITHUB_ATTACHMENT=$(
    envelope xid attachment add \
    --vendor "self" \
    --payload "$GITHUB_ACCOUNT" \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID"
)

echo "XID with GitHub attachment:"
envelope format "$XID_WITH_GITHUB_ATTACHMENT"

# ============================================================================
# Part III: Create Public Version via Elision
# ============================================================================

echo ""
echo "## Step 3: Elide Private Information"
echo ""

PUBLIC_XID_WITH_GITHUB_ATTACHMENT=$(
    envelope xid export \
    --private elide \
    --generator elide \
    "$XID_WITH_GITHUB_ATTACHMENT"
)

echo "Public XID (private keys and generator elided):"
envelope format "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT"

# ============================================================================
# Part IV: Verify Elision Preserved Hash
# ============================================================================

echo ""
echo "## Step 4: Verify Elision Preserved the Hash"
echo ""

PRIVATE_DIGEST=$(envelope digest "$XID_WITH_GITHUB_ATTACHMENT")
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")

echo "Signed XID digest: $PRIVATE_DIGEST"
echo "Public XID digest: $PUBLIC_DIGEST"

if [ "$PRIVATE_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo "✅ VERIFIED: Digests identical - elision preserved the root hash!"
else
    echo "❌ ERROR: Digests differ"
    exit 1
fi

# Verify signature on the public version
PUBKEYS=$(envelope xid key at 0 "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")
envelope verify --silent -v "$PUBKEYS" "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT" && echo "✅ Signature verified on public XID!"

# ============================================================================
# Part V: Selective Disclosure with Inclusion Proofs
# ============================================================================

echo ""
echo "## Step 5: Selective Disclosure with Inclusion Proofs"
echo ""

# Step 5a: Find the attachment assertion using a pattern expression
echo "Finding attachment assertion..."
PATEX=$(cat <<'EOF'
    search(
        assertpred(
            'attachment'
        )
    )
EOF
)
ATTACHMENT_ENVELOPE=$(envelope match --envelopes --last-only "$PATEX" "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")

echo "Found attachment envelope:"
envelope format "$ATTACHMENT_ENVELOPE"

# Get the digest of the attachment assertion
ATTACHMENT_DIGEST=$(envelope digest "$ATTACHMENT_ENVELOPE")

# Create extra-elided version (hiding the attachment)
echo ""
echo "Creating extra-elided version (hiding attachment)..."
EXTRA_ELIDED_XIDDOC=$(envelope elide removing "$ATTACHMENT_DIGEST" "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")

echo "Extra-elided XID (attachment hidden):"
envelope format "$EXTRA_ELIDED_XIDDOC"

# Step 5b: Create inclusion proof
echo ""
echo "Creating inclusion proof for attachment..."
INCLUSION_PROOF=$(envelope proof create "$ATTACHMENT_DIGEST" "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")

echo "Inclusion proof digest:     $(envelope digest "$INCLUSION_PROOF")"
echo "Extra-elided XID digest:    $(envelope digest "$EXTRA_ELIDED_XIDDOC")"

# Step 5c: Verify inclusion proof
echo ""
echo "Verifying inclusion proof..."
if envelope proof confirm --silent "$INCLUSION_PROOF" "$ATTACHMENT_DIGEST" "$EXTRA_ELIDED_XIDDOC"; then
    echo "✅ Proof confirmed - attachment assertion is in the original XID"
else
    echo "⚠ Proof failed"
fi

# Verify root hashes match
ORIGINAL_DIGEST=$(envelope digest "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")
ELIDED_DIGEST=$(envelope digest "$EXTRA_ELIDED_XIDDOC")

if [ "$ORIGINAL_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "✅ Root hash matches - envelopes are cryptographically equivalent"
fi

# ============================================================================
# Part VI: Save Files
# ============================================================================

echo ""
echo "## Step 6: Save Your Files"
echo ""

# Create output directory with timestamp
OUTPUT_DIR="output/xid-tutorial03-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save XIDDoc with attachment (complete version with encrypted keys)
echo "$XID_WITH_GITHUB_ATTACHMENT" > "$OUTPUT_DIR/$XID_NAME-private.xid"
envelope format "$XID_WITH_GITHUB_ATTACHMENT" > "$OUTPUT_DIR/$XID_NAME-private.format"

# Save public XID (elided version)
echo "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT" > "$OUTPUT_DIR/$XID_NAME-public.xid"
envelope format "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT" > "$OUTPUT_DIR/$XID_NAME-public.format"

# Save SSH private keys (for git configuration - keep secure!)
echo "$SSH_PRVKEYS" > "$OUTPUT_DIR/$XID_NAME-ssh-prvkeys.ur"

# Save SSH public key (standard format for GitHub)
echo "$SSH_EXPORT" > "$OUTPUT_DIR/$XID_NAME-ssh.pub"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"

echo ""
echo "=== Tutorial 03 Complete ==="
echo ""
echo "Summary:"
echo "  - Loaded Tutorial 01 XID and enriched it with professional information"
echo "  - Generated SSH signing keys for Git commits"
echo "  - Created proof-of-control statement"
echo "  - Added GitHub account attachment with proper types"
echo "  - Created public version via elision"
echo "  - Demonstrated selective disclosure with inclusion proofs"
echo ""
echo "Output files:"
echo "  $OUTPUT_DIR/$XID_NAME-private.xid     # 🔒 Complete XID (keep secure)"
echo "  $OUTPUT_DIR/$XID_NAME-private.format  #    Human-readable version"
echo "  $OUTPUT_DIR/$XID_NAME-public.xid      # ✅ Public XID (safe to share)"
echo "  $OUTPUT_DIR/$XID_NAME-public.format   #    Human-readable version"
echo "  $OUTPUT_DIR/$XID_NAME-ssh-prvkeys.ur  # 🔒 SSH private keys (keep secure!)"
echo "  $OUTPUT_DIR/$XID_NAME-ssh.pub         # ✅ SSH public key (for GitHub)"
