# Building Your Persona

This tutorial continues Amira's story as BRadvoc8. Now that she has a basic XID from Tutorial 01, she needs to enrich it with professional information that demonstrates her capabilities. You'll learn how to build a rich persona with structured metadata and SSH signing keys.

**Time to complete: 20 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [Progressive Trust](../concepts/progressive-trust.md) to understand how personas support trust-building over time.

## Prerequisites

- Completed Tutorial 01: Creating Your First XID
- The artifacts from Tutorial 01 (or run `bash tests/01-your-first-xid-TEST.sh` to generate them)
- Basic understanding of public-key cryptography

## What You'll Learn

- How to load and work with an existing XID
- How to add structured metadata using proper data types (dates, URIs)
- How to create nested envelope structures for complex data
- How to generate and add SSH signing keys for Git commit signing
- How to prove control of keys using challenge-response patterns
- How to understand key separation (XID keys vs SSH keys)
- How to create public versions of your XID using elision
- How to selectively reveal elided data when needed

## Building on Tutorial 01

| Tutorial 01                     | Tutorial 02                       |
|---------------------------------|-----------------------------------|
| Created basic XID with nickname | Add rich professional information |
| Generated keypairs              | Add SSH signing key for commits   |
| Encrypted private keys          | Create public version for sharing |

**The Bridge**: Your XID exists and is signed, but it's bare-bones. Now you'll add the professional details that make BRadvoc8 a credible contributor.

---

## Amira's Challenge: Building Credibility

After creating her basic BRadvoc8 XID in Tutorial 01, Amira realizes it says almost nothing about her. Her XID has:
- ✅ A nickname ("BRadvoc8")
- ✅ Cryptographic keys
- ✅ A signature proving authenticity

But it's missing:
- ❌ Professional presence (GitHub account)
- ❌ Code signing capability (SSH key for commits)
- ❌ Evidence of her technical work

**The problem**: Amira wants to contribute to social impact projects through RISK (the network Charlene told her about). But her bare-bones XID doesn't demonstrate any capabilities. Project managers like Ben need to see:
1. Her professional presence (where does she code?)
2. Her commit signing key (how can they verify her work?)
3. Proof she controls these keys (is this really her?)

**The solution**: Amira needs to build a **rich persona** that:
1. Links to her GitHub account
2. Includes an SSH signing key for Git commits
3. Proves she controls that key

This tutorial teaches **persona building** - enriching your identity with structured, verifiable professional information.

> **What comes next**: After building her persona in this tutorial, Amira still won't be findable - her XID exists but isn't published anywhere. Tutorial 03 will show how to make her discoverable.

---

## Part I: Building Your Persona

In this section, you'll load your existing XID and enrich it with professional information that establishes your public participation profile.

### Step 1: Load Your Basic XID

First, let's load the XID you created in Tutorial 01 using the password permit workflow.

> **Building on Tutorial 01**: In Tutorial 01, you created a signed XID with encrypted private keys. Now you'll load it and add assertions to build your persona.

Find and load your Tutorial 01 artifacts:

```
# Find the most recent Tutorial 01 output directory
TUTORIAL_01_DIR=$(find output/xid-2* -type d 2>/dev/null | sort -r | head -1)

if [ -z "$TUTORIAL_01_DIR" ]; then
    echo "No Tutorial 01 output found. Run tests/01-your-first-xid-TEST.sh first."
    exit 1
fi

# Load the XID file
XID=$(cat "$TUTORIAL_01_DIR/BRadvoc8-xid.envelope")
PASSWORD="Amira's strong password"
XID_NAME=BRadvoc8

echo "Loaded XID from: $TUTORIAL_01_DIR"
envelope format "$XID"

│ {
│     XID(c7e764b7) [
│         'key': PublicKeys(88d90933) [
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
│         'provenance': ProvenanceMark(632330b4) [...]
│     ]
│ } [
│     'verifiedBy': Signature
│ ]
```

Your basic XID is loaded. Now let's enrich it with professional information.

### Step 2: Add GitHub Account Information

Amira wants to share her GitHub presence - this is key to her **public participation profile**. Her signed Git commits will prove her technical capabilities.

First, unwrap the XID to access its assertions:

```
# Unwrap the signed XID to work with its assertions
UNWRAPPED_XID=$(envelope extract wrapped "$XID")
```

Now create GitHub account information with proper data types:

```
# Create account information envelope with proper types
GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "created_at" date "2025-05-10T00:55:11Z" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "updated_at" date "2025-05-10T00:55:28Z" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "evidence" uri "https://api.github.com/users/$XID_NAME" "$GITHUB_ACCOUNT")

echo "GitHub account information:"
envelope format "$GITHUB_ACCOUNT"

│ "BRadvoc8" [
│     "created_at": 2025-05-10T00:55:11Z
│     "evidence": URI(https://api.github.com/users/BRadvoc8)
│     "updated_at": 2025-05-10T00:55:28Z
│ ]
```

Notice how dates appear without quotes (proper date type) and the URL has `URI()` wrapper (proper URI type). This makes the data machine-readable.

> **Why Proper Types Matter**:
> - **Date types** enable chronological operations and validation
> - **URI types** allow systems to recognize and validate web resources
> - **Structured data** enables machine readability and automated verification

Now wrap this in a service envelope:

```
# Create service envelope containing account information
GITHUB_SERVICE=$(envelope subject type string "GitHub")
GITHUB_SERVICE=$(envelope assertion add pred-obj known isA string "SourceCodeRepository" "$GITHUB_SERVICE")
GITHUB_SERVICE=$(envelope assertion add pred-obj string "account" envelope "$GITHUB_ACCOUNT" "$GITHUB_SERVICE")

echo "GitHub service:"
envelope format "$GITHUB_SERVICE"

│ "GitHub" [
│     'isA': "SourceCodeRepository"
│     "account": "BRadvoc8" [
│         "created_at": 2025-05-10T00:55:11Z
│         "evidence": URI(https://api.github.com/users/BRadvoc8)
│         "updated_at": 2025-05-10T00:55:28Z
│     ]
│ ]
```

Note the nested structure: the GitHub service contains account information with a logical hierarchy. The `'isA': "SourceCodeRepository"` uses a known predicate (single quotes) for standardized type indication.

Add the service to your XID:

```
# Add GitHub service to XID
UNWRAPPED_XID=$(envelope assertion add pred-obj string "service" envelope "$GITHUB_SERVICE" "$UNWRAPPED_XID")

echo "XID with GitHub service added:"
envelope format "$UNWRAPPED_XID"
```

### Step 3: Add Your SSH Signing Key

Now Amira adds an SSH signing key to her XID. This key is crucial for her **public participation profile** - it signs her Git commits on GitHub, proving her work is authentic.

> **Why SSH Signing Keys Matter**: For pseudonymous contributors like Amira, signed Git commits ARE their reputation. Each commit signed with her SSH key proves it came from BRadvoc8, building verifiable evidence of technical capabilities over time.

#### Step 3a: Generate SSH Signing Key

Generate an SSH Ed25519 signing key for Git commits:

```
# Generate SSH Ed25519 signing key
SSH_PRVKEYS=$(envelope generate prvkeys --signing ssh-ed25519)
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")

echo "✓ Generated SSH signing keypair"

# Export SSH public key to standard format
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")

echo "Your SSH public key (standard format):"
echo "$SSH_EXPORT"

│ ✓ Generated SSH signing keypair
│ Your SSH public key (standard format):
│ ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMx...
```

This is the standard SSH public key format that GitHub recognizes. You can add this to your GitHub account's SSH signing keys.

#### Step 3b: Prove SSH Key Control

Now prove you control this key using a **proof-of-control** pattern:

```
# Create a proof-of-control statement with today's date
CURRENT_DATE=$(date -u +"%Y-%m-%d")
PROOF_STATEMENT=$(envelope subject type string "$XID_NAME controls this SSH key on $CURRENT_DATE")

# Sign the statement with SSH private key
PROOF=$(envelope sign --signer "$SSH_PRVKEYS" "$PROOF_STATEMENT")

echo "Proof of SSH key control:"
envelope format "$PROOF"

│ Proof of SSH key control:
│ "BRadvoc8 controls this SSH key on 2025-11-27" [
│     'signed': Signature(SshEd25519)
│ ]
```

The `Signature(SshEd25519)` proves this was signed with an SSH Ed25519 key.

Anyone with the public key can verify:

```
# Verify the signature
envelope verify --verifier "$SSH_PUBKEYS" "$PROOF"
echo "✓ Signature verified - proof of key control confirmed"

│ ✓ Signature verified - proof of key control confirmed
```

> **Why This Matters**: This challenge-response pattern proves Amira possesses the private key without revealing it. Anyone can verify the signature, confirming she controls the key that will sign her Git commits.

#### Step 3c: Add SSH Key to XID

Add the SSH public key and proof to the XID:

```
# Add SSH public key to XID
UNWRAPPED_XID=$(envelope assertion add pred-obj string "sshSigningKey" string "$SSH_EXPORT" "$UNWRAPPED_XID")

# Add the proof-of-control
UNWRAPPED_XID=$(envelope assertion add pred-obj string "sshKeyProof" envelope "$PROOF" "$UNWRAPPED_XID")

echo "✓ Added SSH signing key and proof to XID"
envelope format "$UNWRAPPED_XID"
```

> **Key Separation**: You now have three keys in play:
> - **XID signing key**: Proves this XID came from you (in `'key'` assertion)
> - **XID encryption key**: Protects your data (also in `'key'` assertion)
> - **SSH signing key**: Signs Git commits (new `"sshSigningKey"` assertion)
>
> **Why separate?** Compromise containment. If your SSH key is compromised, your XID identity remains safe. Each key serves one specific purpose.

---

## Part II: Sign and Create Public Version

Now that you've built a rich persona, you need to re-sign your XID (since adding assertions changed it) and create a public version.

### Step 4: Re-Sign Your Modified XID

When you added assertions in Part I, you modified your XID's content. The original signature from Tutorial 01 no longer applies because it was over the original content. You need to re-sign.

```
# Use the XID key command to extract and decrypt private keys
PRVKEYS=$(envelope xid key all --private --password "$PASSWORD" "$XID")

# Also get the public keys for later verification
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")

# Wrap the modified XID (required for signing)
WRAPPED_XID=$(envelope subject type wrapped "$UNWRAPPED_XID")

# Sign with your XID's private keys
SIGNED_XID=$(envelope sign --signer "$PRVKEYS" "$WRAPPED_XID")

echo "Re-signed XID with new assertions:"
envelope format "$SIGNED_XID"

│ Re-signed XID with new assertions:
│ {
│     XID(c7e764b7) [
│         "service": "GitHub" [...]
│         "sshKeyProof": "BRadvoc8 controls this SSH key on 2025-11-28" [...]
│         "sshSigningKey": "ssh-ed25519 AAAAC3Nza..."
│         'key': PublicKeys(88d90933) [
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
│         'provenance': ProvenanceMark(632330b4) [...]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

Notice the `{ }` wrapper and `'signed': Signature(Ed25519)` - your enriched XID is now properly signed!

> **Why Re-Sign?** Adding assertions changes the envelope's content. The original signature was a cryptographic commitment to the *original* content. After modification, you need a new signature that commits to the *new* content. This is how XID updates work - each version is independently signed.

### Step 5: Elide Private Keys

Now create a public version by eliding (removing) the private key. This is where the Merkle tree magic from Tutorial 01 applies:

```
# Find the private key assertion digest
PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$KEY_OBJECT")
PRIVATE_KEY_DIGEST=$(envelope digest "$PRIVATE_KEY_ASSERTION")

# Also find the provenance generator digest (it's encrypted but still private)
PROV_ASSERTION=$(envelope assertion find predicate known provenance "$UNWRAPPED_XID")
PROV_OBJECT=$(envelope extract object "$PROV_ASSERTION")
PROV_GEN_ASSERTION=$(envelope assertion find predicate known provenanceGenerator "$PROV_OBJECT")
PROV_GEN_DIGEST=$(envelope digest "$PROV_GEN_ASSERTION")

# Create public version by eliding both from the SIGNED XID
PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_DIGEST" "$SIGNED_XID")
PUBLIC_XID=$(envelope elide removing "$PROV_GEN_DIGEST" "$PUBLIC_XID")

echo "Public XID (ready for sharing):"
envelope format "$PUBLIC_XID"

│ Public XID (ready for sharing):
│ {
│     XID(c7e764b7) [
│         "service": "GitHub" [...]
│         "sshKeyProof": "BRadvoc8 controls this SSH key on 2025-11-28" [...]
│         "sshSigningKey": "ssh-ed25519 AAAAC3Nza..."
│         'key': PublicKeys(88d90933) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(632330b4) [
│             ELIDED
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

The `ELIDED` markers show private data has been removed, but the signature wrapper is still present!

### Step 6: Verify Elision Preserved the Hash

Let's explicitly verify that elision preserved the root hash (just like in Tutorial 01):

```
# Compare digests of signed XID vs public (elided) XID
SIGNED_DIGEST=$(envelope digest "$SIGNED_XID")
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_XID")

echo "Signed XID digest: $SIGNED_DIGEST"
echo "Public XID digest: $PUBLIC_DIGEST"

if [ "$SIGNED_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo "✅ VERIFIED: Digests identical - elision preserved the root hash!"
else
    echo "❌ ERROR: Digests differ"
fi

# Verify signature on the PUBLIC version (KEY_OBJECT was set in Step 4)
PUBKEYS=$(envelope extract ur "$KEY_OBJECT")
envelope verify -v "$PUBKEYS" "$PUBLIC_XID" >/dev/null && echo "✅ Signature verified on public XID!"

│ Signed XID digest: ur:digest/hdcx...
│ Public XID digest: ur:digest/hdcx...
│ ✅ VERIFIED: Digests identical - elision preserved the root hash!
│ ✅ Signature verified on public XID!
```

**This is the power of Gordian Envelopes**: You signed once (over the complete XID with encrypted private keys), then created a public view by elision. The signature verifies on BOTH versions because elision preserves the Merkle tree root hash.

### Step 7: Selective Disclosure with Inclusion Proofs

You've learned to **elide** (remove) data while preserving the hash. But what if someone needs to verify that specific data exists in your elided XID? This is where **inclusion proofs** come in.

> **The Scenario**: You've shared your public XID with a collaborator. They need to verify you have a GitHub service without seeing all the details. You can prove the assertion exists without revealing everything.

#### Step 7a: Create an Extra-Elided Version

First, let's create a version with even more elision - hiding the service information:

```
# Find the service assertion to elide
SERVICE_ASSERTION=$(envelope assertion find predicate string "service" "$UNWRAPPED_XID")
SERVICE_DIGEST=$(envelope digest "$SERVICE_ASSERTION")

# Create a version with service elided (in addition to private keys)
EXTRA_ELIDED_XID=$(envelope elide removing "$SERVICE_DIGEST" "$PUBLIC_XID")

echo "Extra-elided XID (service hidden):"
envelope format "$EXTRA_ELIDED_XID"

│ Extra-elided XID (service hidden):
│ {
│     XID(c7e764b7) [
│         "sshKeyProof": "BRadvoc8 controls this SSH key on 2025-11-28" [...]
│         "sshSigningKey": "ssh-ed25519 AAAAC3Nza..."
│         'key': PublicKeys(88d90933) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(632330b4) [
│             ELIDED
│         ]
│         ELIDED                    ← Service assertion removed
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

Notice the `ELIDED` marker where the service assertion was.

#### Step 7b: Create an Inclusion Proof

Create a proof that the service assertion exists in your full XID:

```
# Create an inclusion proof for the service assertion
INCLUSION_PROOF=$(envelope proof create "$SERVICE_DIGEST" "$SIGNED_XID")

echo "Created inclusion proof for service assertion"
echo "Proof digest: $(envelope digest "$INCLUSION_PROOF")"

│ Created inclusion proof for service assertion
│ Proof digest: ur:digest/hdcx...
```

#### Step 7c: Verify the Inclusion Proof

The recipient can verify the elided envelope contains the asserted data:

```
# Verify the proof confirms the assertion exists in the elided envelope
if envelope proof confirm "$INCLUSION_PROOF" "$SERVICE_DIGEST" "$EXTRA_ELIDED_XID" 2>/dev/null; then
    echo "✅ Proof confirmed - service assertion is in the original XID"
else
    echo "⚠ Proof failed"
fi

# Also verify both envelopes have the same root hash
SIGNED_DIGEST=$(envelope digest "$SIGNED_XID")
ELIDED_DIGEST=$(envelope digest "$EXTRA_ELIDED_XID")

if [ "$SIGNED_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "✅ Root hash matches - envelopes are cryptographically equivalent"
fi

│ ✅ Proof confirmed - service assertion is in the original XID
│ ✅ Root hash matches - envelopes are cryptographically equivalent
```

> **Key Insight**: Inclusion proofs let you prove data exists without revealing everything:
> - The elided envelope has the same root hash as the full one
> - The proof confirms a specific assertion was part of the original
> - Recipients verify without you revealing the full contents

**Why Selective Disclosure Matters**:
- Share minimal information publicly (elided version)
- Prove specific claims when needed (inclusion proofs)
- All versions cryptographically prove they came from the same original
- Perfect for progressive trust: start minimal, prove more as trust grows

### Step 8: Save Your Files

Save both the private (complete) and public versions:

```
# Create output directory with timestamp
OUTPUT_DIR="output/xid-tutorial02-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save signed XID (complete version with encrypted keys)
echo "$SIGNED_XID" > "$OUTPUT_DIR/$XID_NAME-xid.envelope"
envelope format "$SIGNED_XID" > "$OUTPUT_DIR/$XID_NAME-xid.format"

# Save public XID (elided version)
echo "$PUBLIC_XID" > "$OUTPUT_DIR/$XID_NAME-public.envelope"
envelope format "$PUBLIC_XID" > "$OUTPUT_DIR/$XID_NAME-public.format"

# Save SSH private keys (for git configuration - keep secure!)
echo "$SSH_PRVKEYS" > "$OUTPUT_DIR/$XID_NAME-ssh-prvkeys.envelope"

# Save SSH public key (standard format for GitHub)
echo "$SSH_EXPORT" > "$OUTPUT_DIR/$XID_NAME-ssh.pub"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
```

Your Tutorial 02 output directory contains:

```
output/xid-tutorial02-TIMESTAMP/
├── BRadvoc8-xid.envelope         # 🔒 Signed XID (complete, keep secure)
├── BRadvoc8-xid.format           #    Human-readable version
├── BRadvoc8-public.envelope      # ✅ Public XID (safe to share)
├── BRadvoc8-public.format        #    Human-readable version
├── BRadvoc8-ssh-prvkeys.envelope # 🔒 SSH private keys (keep secure!)
└── BRadvoc8-ssh.pub              # ✅ SSH public key (for GitHub)
```

---

## Part III: Wrap-Up

### Understanding What Happened

You've transformed a bare-bones XID into a rich professional persona with proper signing and verification:

**1. Structured Metadata with Proper Types**

You added GitHub account information using:
- **Date types**: `2025-05-10T00:55:11Z` (machine-parseable timestamps)
- **URI types**: `URI(https://api.github.com/users/BRadvoc8)` (validated web resources)
- **Nested envelopes**: Service → Account → Properties (logical hierarchy)

**Why nested structures matter**: When Ben fetches your XID in Tutorial 03, he can navigate to `service` → `GitHub` → `account` → `evidence` to find the API endpoint that proves your GitHub presence. Structured data enables automated verification.

**2. SSH Signing Key for Git Commits**

You generated an SSH Ed25519 key that:
- Signs Git commits (proving authorship)
- Uses standard SSH format (GitHub-compatible)
- Is separate from your XID keys (compromise containment)

**3. Proof-of-Control Pattern**

You proved you control the SSH key by:
- Creating a dated statement ("BRadvoc8 controls this SSH key on 2025-11-28")
- Signing it with the SSH private key
- Including the signed proof in your XID

Anyone can verify this proof without you revealing the private key. The dated statement prevents replay attacks - you can't claim you had the key before that date.

**4. Re-Signing After Modification**

When you added assertions to your XID, you:
- Modified the envelope content (adding service, SSH key, proof)
- Invalidated the original Tutorial 01 signature
- Re-signed with your XID's private keys (decrypted with password)

This is the XID update pattern: modify → re-sign → share. Each signed version is a complete, verifiable snapshot of your identity at that moment.

**5. Elision with Hash Preservation**

You verified that:
- The signed XID and public XID have **identical digests**
- The signature verifies on **both versions**
- Elision removes data while preserving the Merkle tree root hash

This is what enables selective disclosure: sign once, create multiple views for different audiences, all cryptographically valid.

**6. Key Separation Model**

Your XID now has three distinct keys:

| Key | Purpose | Location | Algorithm |
|-----|---------|----------|-----------|
| XID Signing | Sign XID updates | `'key'` assertion | Ed25519 |
| XID Encryption | Decrypt messages | `'key'` assertion | X25519 |
| SSH Signing | Sign Git commits | `"sshSigningKey"` | SSH-Ed25519 |

Each key serves one specific purpose. If one is compromised, the others remain secure.

**7. Selective Disclosure**

You learned to use inclusion proofs:
- Create elided versions for public sharing
- Prove specific assertions exist without revealing everything
- Proofs confirm data was part of the original (same root hash)
- Perfect for progressive trust: start minimal, prove more as relationships develop

---

## Key Terminology

> **Nested Envelope** - An envelope contained within another envelope's assertion, creating hierarchical data structures.
>
> **Proper Data Types** - Using appropriate types (date, uri, string) instead of treating everything as strings, enabling machine processing.
>
> **Proof-of-Control** - A challenge-response pattern where you sign a statement to prove you possess a private key without revealing it.
>
> **Key Separation** - Using different keys for different purposes (identity, encryption, code signing) to contain potential compromises.
>
> **Public Participation Profile** - Verifiable evidence of capabilities through public activity like signed Git commits.
>
> **SSH Signing Key** - An SSH key used specifically for signing Git commits, proving code authorship.
>
> **Selective Disclosure** - Using inclusion proofs to verify that specific assertions exist in an elided envelope without revealing all the data.

---

## Common Questions

### Q: Why not use my XID signing key for Git commits?

**A:** Key separation provides compromise containment. Your XID signing key is your core identity - if compromised, your entire identity is at risk. The SSH key is used frequently for commits and is more exposed. If it's compromised, you can revoke it and add a new one without losing your XID identity.

### Q: Can I use an existing SSH key instead of generating a new one?

**A:** Yes, but you'll need to import it properly. The tutorial generates a new key to demonstrate the workflow. For existing keys, you can use `envelope import` to bring them into the envelope format.

### Q: Why include proof-of-control in the XID?

**A:** The proof establishes that you controlled the SSH key at a specific date. Without it, anyone could claim your SSH key is theirs. The dated, signed statement is verifiable evidence of control.

### Q: Is the SSH private key stored in my XID?

**A:** No! Only the SSH **public** key is in your XID. The private key should be stored separately (typically in `~/.ssh/`) and protected. The XID only contains what others need to verify your signatures.

---

## What's Next

Amira now has a rich BRadvoc8 persona with:
- ✅ GitHub account information
- ✅ SSH signing key for commits
- ✅ Proof of key control
- ✅ Public version ready to share

**But there's a problem**: Nobody can find her. Her XID exists on her computer, but it's not published anywhere. Project managers like Ben have no way to:
- **Discover** where her XID is published
- **Verify** the publication is authentic
- **Trust** they have the latest version

**Coming Next: Publishing for Discovery**

In Tutorial 03, you'll learn how to:
- Add **dereferenceVia** assertions (declaring where your XID can be fetched)
- Establish **repository authority** (proving you control the publication location)
- **Publish** your XID to GitHub
- Enable **update verification** (so others can check for newer versions)

> **The Key Insight**: Tutorial 02 made your identity **credible**. Tutorial 03 will make it **findable**.

---

## Exercises

1. Add a second service to your XID (e.g., a personal website or another code platform)
2. Generate a different type of SSH key (e.g., ECDSA) and compare the output format
3. Create multiple proof-of-control statements with different dates and verify each
4. Practice the elision workflow: elide different parts of your XID and verify the signature still works
5. Export your SSH public key and configure git to use it for signing commits

## Example Script

A complete working script implementing this tutorial is available at `tests/02-building-persona-TEST.sh`. Run it to see all steps in action:

```sh
bash tests/02-building-persona-TEST.sh
```

This script will create all the files shown in the tutorial with proper naming conventions and directory structure.

---

**Next Tutorial**: [Publishing for Discovery](03-publishing-discovery.md) - Make your XID findable by declaring publication locations and establishing repository authority.
