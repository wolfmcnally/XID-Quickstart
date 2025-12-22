#!/bin/bash
# create_basic_xid.sh
#
# Tutorial 01: Creating Your First XID
#
# Creates a pseudonymous XID identity with:
# 1. Encrypted private keys (password-protected)
# 2. Encrypted provenance generator
# 3. Cryptographic signature
# 4. Public version via elision

set -e  # Exit on any error

# Configuration
XID_NAME="BRadvoc8"
PASSWORD="Amira's strong password"

# Create output directory
OUTPUT_DIR="xid-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "## Step 1: Creating Private XID"
echo ""

# Create complete XID in one command (like ssh-keygen)
PRIVATE_XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$XID_NAME" \
    --generator encrypt \
    --sign inception)

echo "Created private XID: $XID_NAME"

# Display the private XID structure
echo ""
echo "Private XID structure:"
envelope format "$PRIVATE_XID"

# Save the private XID
echo "$PRIVATE_XID" > "$OUTPUT_DIR/${XID_NAME}-private.xid"
envelope format "$PRIVATE_XID" > "$OUTPUT_DIR/${XID_NAME}-private.format"

echo ""
echo "## Step 2: Creating Public Version by Elision"
echo ""

# Export with private keys and generator elided (preserves signature)
PUBLIC_XID=$(envelope xid export --private elide --generator elide "$PRIVATE_XID")

echo "Created public XID by eliding private key and generator"

# Display the public XID
echo ""
echo "Public XID structure:"
envelope format "$PUBLIC_XID"

# Save the public XID
echo "$PUBLIC_XID" > "$OUTPUT_DIR/${XID_NAME}-public.xid"
envelope format "$PUBLIC_XID" > "$OUTPUT_DIR/${XID_NAME}-public.format"

echo ""
echo "## Step 3: Verification"
echo ""

# Verify the signature using the XID's inception key
echo "Verifying signature on public XID..."
XID_ID=$(envelope xid id --verify inception "$PUBLIC_XID")
echo "Signature verified! XID: $XID_ID"

# Extract and verify provenance mark
echo ""
echo "Verifying provenance mark..."
PROVENANCE_MARK=$(envelope xid provenance get "$PUBLIC_XID")
provenance validate "$PROVENANCE_MARK" && echo "Provenance validated!"

# Show provenance details
echo ""
echo "Provenance mark details:"
provenance validate --format json-pretty "$PROVENANCE_MARK"

echo ""
echo "## Summary"
echo ""
echo "All files created in: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
echo ""
echo "XID creation completed successfully!"
echo ""
echo "Key points:"
echo "  - Private XID contains encrypted private keys and generator"
echo "  - Public XID has these elided (ELIDED markers in format)"
echo "  - Signature verifies on BOTH versions (elision preserves merkle tree)"
echo "  - Provenance mark establishes genesis timestamp"
