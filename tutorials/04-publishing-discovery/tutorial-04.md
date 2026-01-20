# Publishing for Discovery

This tutorial continues Amira's story as BRadvoc8. In Tutorial 02, she built a rich persona with GitHub credentials and an SSH signing key. Now she faces a new challenge: **nobody can find her**. You'll learn how to make your XIDDoc discoverable through publication locations and repository authority.

**Time to complete: 25 minutes**

> **Related Concepts**
>
> Before or after completing this tutorial, you may want to read about [Open Integrity](https://github.com/OpenIntegrityProject/core) to understand how repository authority establishes trust without central authorities.

## Prerequisites

- Completed Tutorial 01: Creating Your First XIDDoc
- Completed Tutorial 02: <TBD>
- Completed Tutorial 03: Building Your Persona
- The artifacts from Tutorial 03 (or run `bash tests/03-building-persona-TEST.sh` to generate them)
- A GitHub account (for publication workflow)

## What You'll Learn

- How to add **dereferenceVia** assertions declaring where your XIDDoc can be fetched
- How to establish **repository authority** using Open Integrity inception commits
- How to publish your public XIDDoc to GitHub
- How to enable **update verification** so others can check for newer versions
- How to advance provenance to mark identity evolution

## Building on Tutorial 03

| Tutorial 03                         | Tutorial 04                             |
| ----------------------------------- | --------------------------------------- |
| Built rich persona with credentials | Declare WHERE to find that persona      |
| Created public version with elision | Publish public version to repository    |
| Generated SSH signing key           | Use SSH key to prove repository control |

**The Bridge**: Your persona exists and is credible, but it's invisible. Now you'll make it findable and establish authoritative publication.

---

## Amira's Challenge: Becoming Discoverable

After building her rich BRadvoc8 persona in Tutorial 03, Amira faces a critical problem: **nobody can find her**. Her XIDDoc exists on her computer, but without a publication location, it's like having a phone number that's not in any directory.

**The problem**: Amira wants to contribute to social impact projects through RISK (the network Charlene told her about). But project managers like Ben can't verify her identity because they have no way to:
1. **Discover** her XIDDoc (where is it published?)
2. **Verify** it's authentic (is this really BRadvoc8?)
3. **Trust** it's current (is this the latest version?)

**The solution**: Amira needs to:
1. Declare publication locations (dereferenceVia assertions)
2. Establish repository authority (inception commit with her SSH key)
3. Publish her public XIDDoc where others can fetch it
4. Enable update verification (provenance tracking)

This tutorial teaches the **XIDDoc discovery and publication pattern** - making your identity findable while maintaining control over what's shared.

---

## Part I: Making Yourself Discoverable

In this section, you'll declare WHERE your XIDDoc can be fetched and prove you control the publication repository.

### Step 1: Load Your Tutorial 03 Artifacts

First, load the XIDDoc you created in Tutorial 03:
```
# Find the most recent Tutorial 03 output directory
TUTORIAL_03_DIR=$(find ../03-building-persona/output/xid-tutorial03-* -type d 2>/dev/null | sort -r | head -1)

if [ -z "$TUTORIAL_03_DIR" ]; then
    echo "No Tutorial 03 output found. Run Tutorial 03 first:"
    echo "  cd ../03-building-persona && bash tutorial_output.sh"
    exit 1
fi

# Load the XIDDoc from Tutorial 03
XID=$(cat "$TUTORIAL_03_DIR/BRadvoc8-private.xid")
PASSWORD="Amira's strong password"
XID_NAME=BRadvoc8

# Load SSH keys from Tutorial 03 (for inception authority)
SSH_PRVKEYS=$(cat "$TUTORIAL_03_DIR/BRadvoc8-ssh-prvkeys.ur")
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
SSH_EXPORT=$(cat "$TUTORIAL_03_DIR/BRadvoc8-ssh.pub")

echo "Loaded artifacts from: $TUTORIAL_03_DIR"
echo "✓ XIDDoc loaded"
echo "✓ SSH signing keys loaded"
envelope format "$XIDDoc"

│ Loaded artifacts from: ../03-building-persona/output/xid-tutorial03-20260120032656
│ ✓ XIDDoc loaded
│ ✓ SSH signing keys loaded
│ {
│     XID(988f199d) [
│         'attachment': {
│             "BRadvoc8" [
│                 'isA': "GitHubAccount"
│                 "commitKey": PublicKeys(cb5282f7, SigningPublicKey(04be206a, SSHPublicKey(87d73f2a)), EncapsulationPublicKey(634ea581, X25519PublicKey(634ea581)))
│                 "commitKeyProof": {
│                     "BRadvoc8 controls this SSH key on 2026-01-20" [
│                         'signed': Signature(SshEd25519)
│                     ]
│                 }
│                 "commitKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4rApizfLvILdCyb9a6m/ZKAVi5bPA32baEOgL/rDmg"
│                 "createdAt": 2025-05-10T00:55:11Z
│                 "updatedAt": 2025-05-10T00:55:28Z
│                 'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│             ]
│         } [
│             'vendor': "self"
│         ]
│         'key': PublicKeys(08eaa8cb, SigningPublicKey(988f199d, Ed25519PublicKey(23d9e2c3)), EncapsulationPublicKey(4eed116c, X25519PublicKey(4eed116c))) [
│             {
│                 'privateKey': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│         ]
│         'provenance': ProvenanceMark(34ed69b2) [
│             {
│                 'provenanceGenerator': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

> **Building on Tutorial 03**
>
> Your XIDDoc already has GitHub account information, SSH signing key, and proof-of-control. Now you'll add publication locations that tell others WHERE to find it. We also load the SSH private keys for creating the inception authority.

### Step 2: Add dereferenceVia Assertions

The **dereferenceVia** assertion tells the world WHERE to fetch your canonical XIDDoc. Without this, your identity exists but is unfindable.

> **The Discovery Problem**
>
> Having an XIDDoc without publication locations is like having a phone number that's not in any directory. dereferenceVia solves this by declaring authoritative fetch locations.

Add dereferenceVia assertions pointing to your GitHub repository:

```
# Add dereferenceVia assertion - GitHub raw URL
GITHUB_URL="https://raw.githubusercontent.com/$XID_NAME/$XID_NAME/main/$XID_NAME-public.envelope"
XID_WITH_RESOLUTION=$(envelope xid resolution add \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$GITHUB_URL" \
    "$XID" \
)
XID="$XID_WITH_RESOLUTION"

echo "✓ Added dereferenceVia assertion"
envelope format "$XID"

│ ✓ Added dereferenceVia assertion
│ {
│     XID(988f199d) [
│         'attachment': {
│             "BRadvoc8" [
│                 'isA': "GitHubAccount"
│                 "commitKey": PublicKeys(cb5282f7, SigningPublicKey(04be206a, SSHPublicKey(87d73f2a)), EncapsulationPublicKey(634ea581, X25519PublicKey(634ea581)))
│                 "commitKeyProof": {
│                     "BRadvoc8 controls this SSH key on 2026-01-20" [
│                         'signed': Signature(SshEd25519)
│                     ]
│                 }
│                 "commitKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4rApizfLvILdCyb9a6m/ZKAVi5bPA32baEOgL/rDmg"
│                 "createdAt": 2025-05-10T00:55:11Z
│                 "updatedAt": 2025-05-10T00:55:28Z
│                 'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│             ]
│         } [
│             'vendor': "self"
│         ]
│         'dereferenceVia': URI(https://raw.githubusercontent.com/BRadvoc8/BRadvoc8/main/BRadvoc8-public.envelope)
│         'key': PublicKeys(08eaa8cb, SigningPublicKey(988f199d, Ed25519PublicKey(23d9e2c3)), EncapsulationPublicKey(4eed116c, X25519PublicKey(4eed116c))) [
│             {
│                 'privateKey': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│         ]
│         'provenance': ProvenanceMark(34ed69b2) [
│             {
│                 'provenanceGenerator': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

You can add multiple dereferenceVia endpoints for redundancy:

```
# Add alternative endpoint (GitHub blob URL as backup)
GITHUB_BLOB_URL="https://github.com/$XID_NAME/$XID_NAME/blob/main/$XID_NAME-public.envelope"
XID_WITH_RESOLUTION=$(envelope xid resolution add \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$GITHUB_BLOB_URL" \
    "$XID" \
)
XID="$XID_WITH_RESOLUTION"

echo "✓ Added second dereferenceVia for redundancy"
envelope format "$XID"

│ ✓ Added second dereferenceVia for redundancy
│ {
│     XID(988f199d) [
│         'attachment': {
│             "BRadvoc8" [
│                 'isA': "GitHubAccount"
│                 "commitKey": PublicKeys(cb5282f7, SigningPublicKey(04be206a, SSHPublicKey(87d73f2a)), EncapsulationPublicKey(634ea581, X25519PublicKey(634ea581)))
│                 "commitKeyProof": {
│                     "BRadvoc8 controls this SSH key on 2026-01-20" [
│                         'signed': Signature(SshEd25519)
│                     ]
│                 }
│                 "commitKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4rApizfLvILdCyb9a6m/ZKAVi5bPA32baEOgL/rDmg"
│                 "createdAt": 2025-05-10T00:55:11Z
│                 "updatedAt": 2025-05-10T00:55:28Z
│                 'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│             ]
│         } [
│             'vendor': "self"
│         ]
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/blob/main/BRadvoc8-public.envelope)
│         'dereferenceVia': URI(https://raw.githubusercontent.com/BRadvoc8/BRadvoc8/main/BRadvoc8-public.envelope)
│         'key': PublicKeys(08eaa8cb, SigningPublicKey(988f199d, Ed25519PublicKey(23d9e2c3)), EncapsulationPublicKey(4eed116c, X25519PublicKey(4eed116c))) [
│             {
│                 'privateKey': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│         ]
│         'provenance': ProvenanceMark(34ed69b2) [
│             {
│                 'provenanceGenerator': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

> **Known Predicate**
>
> Notice `'dereferenceVia'` uses single quotes - it's a known value predicate defined in the Gordian Envelope extension specifications. This ensures interoperability with other tools that understand XIDs.

### Step 3: Establish Repository Authority (Open Integrity)

Now comes a critical step: proving you control the repository where your XIDDoc will be published. This uses the **Open Integrity** inception pattern.

> **Why Repository Authority Matters**
>
> Anyone could create a GitHub account called "BRadvoc8" and publish a fake XIDDoc. The inception commit pattern proves that the **same key** that's in your XIDDoc also controls the repository - linking your cryptographic identity to the publication location.

#### Step 3a: Understanding Inception Authority

The Open Integrity pattern works like this:

1. Your XIDDoc contains SSH signing key: `ssh-ed25519 AAAAC3Nza...`
2. You create a GitHub repo with an inception commit
3. That inception commit is signed with the SAME SSH key
4. Anyone verifying your XIDDoc can:
   - Check the SSH key in your XIDDoc
   - Fetch the inception commit from GitHub
   - Verify the commit signature matches the XIDDoc's SSH key
   - Confirms: same entity controls both XIDDoc and repo

#### Step 3b: Create Inception Commit (Conceptual)

In practice, you would:

1. Create GitHub repository: `BRadvoc8/BRadvoc8`
2. Configure git to use your SSH signing key:

```
git config user.signingkey "$(cat ~/.ssh/id_ed25519.pub)"
git config commit.gpgsign true
git config gpg.format ssh
```

3. Create inception commit:

```
git commit --allow-empty -S -m "Inception: BRadvoc8 XID repository"
```

4. Push to GitHub:

```
git push origin main
```

> **For This Tutorial**
>
> We'll simulate the inception process. In a real workflow, you'd follow the [Open Integrity Script Snippets](https://github.com/OpenIntegrityProject/core/blob/main/docs/Open_Integrity_Script_Snippets.md) to create an actual inception commit.

#### Step 3c: Create the Inception Record

Create a signed inception record using the SSH keys loaded from Tutorial 03. The inception record uses the repository URI as its subject:

```
# Create inception authority record with repo URI as subject
INCEPTION_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
REPO_URL="https://github.com/$XID_NAME/$XID_NAME"

INCEPTION_RECORD=$(envelope subject type uri "$REPO_URL")
INCEPTION_RECORD=$(envelope assertion add pred-obj string "date" date "$INCEPTION_DATE" "$INCEPTION_RECORD")
INCEPTION_RECORD=$(envelope assertion add pred-obj string "sshKey" string "$SSH_EXPORT" "$INCEPTION_RECORD")

# Sign the inception record with the SSH key (same key as in XIDDoc)
INCEPTION_SIGNED=$(envelope sign --signer "$SSH_PRVKEYS" "$INCEPTION_RECORD")

echo "Inception authority record:"
envelope format "$INCEPTION_SIGNED"

│ URI(https://github.com/BRadvoc8/BRadvoc8) [
│     "date": 2026-01-20T22:58:22Z
│     "sshKey": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
│     'signed': Signature(SshEd25519)
│ ]
```

> **Key Point**
>
> We use the SAME SSH keys that are already in your XIDDoc (loaded from Tutorial 03). This is critical - the inception authority only works because the key in the inception record matches the key in your XIDDoc.

#### Step 3d: Add Inception to the GitHub Attachment

We'll augment the existing GitHub account attachment with the inception record. This keeps all GitHub-related information together.

First, extract the existing GitHub attachment and its payload:

```
# Find the existing GitHub attachment
GITHUB_ATTACHMENT=$(envelope xid attachment find --vendor "self" "$XID")

# Extract the payload (the inner envelope with GitHub account info)
ATTACHMENT_OBJECT=$(envelope extract object "$GITHUB_ATTACHMENT")
PAYLOAD=$(envelope extract wrapped "$ATTACHMENT_OBJECT")

echo "Current GitHub account payload:"
envelope format "$PAYLOAD"

│ "BRadvoc8" [
│     'isA': "GitHubAccount"
│     "commitKey": PublicKeys(cb5282f7, ...)
│     "commitKeyProof": {...}
│     "commitKeyText": "ssh-ed25519 AAAAC3Nza..."
│     "createdAt": 2025-05-10T00:55:11Z
│     "updatedAt": 2025-05-10T00:55:28Z
│     'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│ ]
```

Add the inception record as an assertion to the payload:

```
# Add inception as assertion to the GitHub account payload
UPDATED_PAYLOAD=$(envelope assertion add pred-obj string "inception" envelope "$INCEPTION_SIGNED" "$PAYLOAD")

echo "Updated payload with inception:"
envelope format "$UPDATED_PAYLOAD"

│ "BRadvoc8" [
│     'isA': "GitHubAccount"
│     "commitKey": PublicKeys(cb5282f7, ...)
│     "commitKeyProof": {...}
│     "commitKeyText": "ssh-ed25519 AAAAC3Nza..."
│     "createdAt": 2025-05-10T00:55:11Z
│     "inception": URI(https://github.com/BRadvoc8/BRadvoc8) [
│         "date": 2026-01-20T22:58:22Z
│         "sshKey": "ssh-ed25519 AAAAC3Nza..."
│         'signed': Signature(SshEd25519)
│     ]
│     "updatedAt": 2025-05-10T00:55:28Z
│     'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│ ]
```

Now replace the old attachment with the updated one:

```
# Remove old attachment and add updated one
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
envelope format "$XID"

│ {
│     XID(988f199d) [
│         'attachment': {
│             "BRadvoc8" [
│                 'isA': "GitHubAccount"
│                 "commitKey": PublicKeys(cb5282f7, ...)
│                 "commitKeyProof": {...}
│                 "commitKeyText": "ssh-ed25519 AAAAC3Nza..."
│                 "createdAt": 2025-05-10T00:55:11Z
│                 "inception": URI(https://github.com/BRadvoc8/BRadvoc8) [
│                     "date": 2026-01-20T22:58:22Z
│                     "sshKey": "ssh-ed25519 AAAAC3Nza..."
│                     'signed': Signature(SshEd25519)
│                 ]
│                 "updatedAt": 2025-05-10T00:55:28Z
│                 'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│             ]
│         } [
│             'vendor': "self"
│         ]
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/blob/main/BRadvoc8-public.envelope)
│         'dereferenceVia': URI(https://raw.githubusercontent.com/BRadvoc8/BRadvoc8/main/BRadvoc8-public.envelope)
│         'key': PublicKeys(08eaa8cb, ...) [...]
│         'provenance': ProvenanceMark(34ed69b2) [...]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

> **The Key Insight**
>
> The SSH key in the `"inception"` assertion matches the key used to sign Git commits. Anyone can verify the commit signature against this key, confirming the same entity controls both the XID and the repository. By embedding it in the GitHub attachment rather than as a separate attachment, all GitHub-related identity information stays together.

---

## Part II: Create Public Version and Verify

Your XID now has dereferenceVia assertions and inception authority. Since each modification was automatically verified and re-signed using the `--verify inception` and `--sign inception` flags, your XID is already properly signed. Now you'll create the public version for publication.

### Step 4: Create Public XID

Create a publicly distributable version by eliding private material:

```
# Export public version with elided secrets (preserves signature)
PUBLIC_XID=$(envelope xid export \
    --private elide \
    --generator elide \
    --password "$PASSWORD" \
    "$XID" \
)

echo "Public XID (ready for publication):"
envelope format "$PUBLIC_XID"

│ {
│     XID(988f199d) [
│         'attachment': {
│             "BRadvoc8" [
│                 'isA': "GitHubAccount"
│                 "commitKey": PublicKeys(cb5282f7, ...)
│                 "commitKeyProof": {...}
│                 "commitKeyText": "ssh-ed25519 AAAAC3Nza..."
│                 "createdAt": 2025-05-10T00:55:11Z
│                 "inception": URI(https://github.com/BRadvoc8/BRadvoc8) [
│                     "date": 2026-01-20T22:58:22Z
│                     "sshKey": "ssh-ed25519 AAAAC3Nza..."
│                     'signed': Signature(SshEd25519)
│                 ]
│                 "updatedAt": 2025-05-10T00:55:28Z
│                 'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│             ]
│         } [
│             'vendor': "self"
│         ]
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/blob/main/BRadvoc8-public.envelope)
│         'dereferenceVia': URI(https://raw.githubusercontent.com/BRadvoc8/BRadvoc8/main/BRadvoc8-public.envelope)
│         'key': PublicKeys(08eaa8cb, ...) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(34ed69b2) [
│             ELIDED
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

> **Why Elide Instead of Omit?**
>
> Elision replaces secret data with `ELIDED` placeholders while preserving the digest tree. This means:
> - The signature remains valid on the public version
> - Anyone can verify the public XID against the original signature
> - The private version can be used to "fill in" the elided parts later

### Step 5: Verify Signature on Public XID

Verify the signature is valid on the elided public version:

```
# Get public keys from the XID and verify signature
PUBKEYS=$(envelope xid key all "$PUBLIC_XID")
envelope verify --silent --verifier "$PUBKEYS" "$PUBLIC_XID"
echo "✅ Signature verified on public XID"

│ ✅ Signature verified on public XID
```

### Step 6: Save Your Files

Save your files:

```
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
```

> **To Actually Publish**
>
> Copy `BRadvoc8-public.xid` to your GitHub repository at the path declared in your dereferenceVia assertions. Then commit and push.

### Step 7: Update Verification Pattern

When someone fetches your XID, they need to verify it's authentic and current. Here's the verification pattern:

#### Verification Steps

Anyone fetching your XID should:

1. **Fetch** from dereferenceVia URL
2. **Check provenance** sequence (higher = more recent)
3. **Verify signature** with public keys from XID
4. **Verify inception** authority matches repository

```
echo "=== Update Verification Pattern ==="

# 1. Fetch XID (simulated - in practice, use curl)
FETCHED_XID="$PUBLIC_XID"
echo "1. Fetched XID from dereferenceVia URL"

# 2. Get public keys and verify signature
FETCHED_PUBKEYS=$(envelope xid key all "$FETCHED_XID")
envelope verify --silent --verifier "$FETCHED_PUBKEYS" "$FETCHED_XID"
echo "2. ✓ Signature verified"

# 3. Check provenance sequence
PROV_MARK=$(envelope xid provenance get "$FETCHED_XID")
echo "3. Provenance mark: $PROV_MARK"

# 4. Examine inception authority attachment
echo "4. ✓ Inception authority found in attachments - verify SSH key matches repository's inception commit"

echo ""
echo "=== Verification Complete ==="
```

> **Trust Chain**
>
> The verification pattern establishes a trust chain:
>
> - Signature proves XID authenticity
> - Provenance tracks identity evolution
> - Inception authority links XID to publication repository
> - Together, these provide strong guarantees without central authority

### Step 8: Advance Provenance

Before sharing your updated XID, advance the provenance to mark this version:

```
# Advance provenance from sequence 0 to sequence 1
# This requires the password to unlock the provenance generator
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
echo "New provenance mark:"
echo "$NEW_PROV"
```

> **Why Advance Provenance?**
>
> - Marks identity evolution (sequence 0 → 1 → 2...)
> - Enables update verification (higher sequence = more recent)
> - Creates audit trail of changes
> - Required before publishing significant updates

Save the provenanced version:

```
# Save the provenanced version
echo "$XID_V1" > "$OUTPUT_DIR/$XID_NAME-private-v1.xid"
envelope format "$XID_V1" > "$OUTPUT_DIR/$XID_NAME-private-v1.format"

echo "✓ Saved XID with advanced provenance"
```

---

## Part III: Wrap-Up

### Understanding What Happened

You've completed the XID publication workflow:

**1. Discovery Locations (dereferenceVia)**

You declared WHERE your XID can be fetched:
- Multiple endpoints for redundancy
- Known predicate for interoperability
- Canonical URLs for authoritative versions

**2. Repository Authority (Inception)**

You linked your XID to your GitHub repository:
- Same SSH key in XID and inception commit
- Cryptographic proof of unified control
- No central authority required

**3. Update Verification Pattern**

You learned how verifiers check:
- Signature (authenticity)
- Provenance (recency)
- Inception (repository control)

**4. Provenance Advancement**

You advanced the sequence number:
- Marks identity evolution
- Enables update detection
- Creates audit trail

---

## Key Terminology

> **dereferenceVia** - Known predicate declaring WHERE your XID can be fetched (publication URLs).
>
> **Inception Authority** - Cryptographic proof linking your XID to a repository via the same SSH key in both.
>
> **Open Integrity** - The inception commit pattern that establishes repository authority without central trust.
>
> **Provenance Advancement** - Incrementing the sequence number to mark identity evolution.
>
> **Update Verification** - The pattern for verifying fetched XIDs: signature + provenance + inception.

---

## Common Questions

### Q: Why use dereferenceVia instead of just sharing URLs?

**A:** The `'dereferenceVia'` known predicate is part of the Gordian Envelope standard. It declares authoritative fetch locations that verification tools can automatically use. Ad-hoc URLs wouldn't be recognized by standardized tooling.

### Q: Can I change my dereferenceVia URLs after publication?

**A:** Yes, but you should advance provenance when you do. Anyone with an older version will see different URLs. The provenance sequence helps them know to fetch the latest version.

### Q: Why not just share everything publicly?

**A:** Privacy through selective disclosure. Your full XID might contain sensitive information (contact details, work history, credentials). Elision lets you share minimal public information while revealing specific details to specific parties when needed. (See Tutorial 03 for the selective revelation pattern.)

### Q: What if someone publishes a fake XID at my dereferenceVia URL?

**A:** The inception authority protects against this. Even if someone compromises your GitHub account, they can't forge the SSH signature linking the repository to your XID. The SSH private key is the security anchor.

---

## What's Next

Amira now has a discoverable, verifiable identity. Her BRadvoc8 XID is ready for publication with:
- ✅ Publication locations (dereferenceVia assertions)
- ✅ Repository authority (inception commit)
- ✅ Update verification support (provenance)

**Coming Next: Making Claims**

In Tutorial 05, you'll learn how to:

**Build Trust Through Self-Attestations:**
- Create self-attestations about your skills and experience using **fair witness methodology**
- Handle sensitive attestations that require encryption
- Use **public-key permits** to share credentials selectively with specific people

**Privacy Through Selective Sharing:**
- When to use elision vs encryption
- The identity revelation problem and how to avoid it
- Creating protected attestations for trusted recipients

> **The Key Insight**
>
> Tutorial 04 made you **findable**. Tutorial 05 teaches you to make **credible claims**. Tutorial 06 then shows how others **validate those claims** through peer endorsements.

---

## Tutorial 04 Files Summary

Your Tutorial 04 output directory contains:

```
output/xid-tutorial04-TIMESTAMP/
├── BRadvoc8-public.xid          # ✅ Public XID (publish this)
├── BRadvoc8-public.format       #    Human-readable version
├── BRadvoc8-private.xid         # 🔒 Private XID (keep secure)
├── BRadvoc8-private.format      #    Human-readable version
├── BRadvoc8-private-v1.xid      # 🔒 Private XID with provenance v1
├── BRadvoc8-private-v1.format   #    Human-readable version
├── BRadvoc8-ssh-prvkeys.ur      # 🔒 SSH private keys (keep secure)
└── BRadvoc8-ssh.pub             # SSH public key (for git config)
```

---

## Exercises

1. **dereferenceVia Practice**: Add a third dereferenceVia endpoint pointing to a hypothetical IPFS location
2. **Inception Understanding**: Explain why the same SSH key must appear in both XID and inception commit
3. **Verification Practice**: Write a script that performs full update verification on a fetched XID
4. **Provenance Practice**: Advance provenance multiple times and observe how the sequence number changes
5. **Advanced - Real Publication**: Create an actual GitHub repository and publish your XID following the Open Integrity pattern

## Example Script

A complete working script implementing this tutorial is available at `tests/04-publishing-discovery-TEST.sh`. Run it to see all steps in action:

```
bash tests/04-publishing-discovery-TEST.sh
```

This script will create all the XID versions and demonstrate the complete publishing and discovery workflow.

---

**Next Tutorial**: [Self-Attestations & Selective Sharing](../06-self-attestations/tutorial-06.md) - Make credible claims about yourself using fair witness methodology and protect sensitive credentials with public-key permits.
