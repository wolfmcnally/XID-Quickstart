# Building Your Persona

This tutorial continues Amira's story as BRadvoc8. Now that she has a basic XID from Tutorial 01, she needs to enrich it with professional information that demonstrates her capabilities. You'll learn how to build a rich persona with structured metadata and SSH signing keys.

**Time to complete: 20 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [Progressive Trust](../../concepts/progressive-trust.md) to understand how personas support trust-building over time.

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
| ------------------------------- | --------------------------------- |
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
TUTORIAL_01_DIR=$(find ../01-your-first-xid/output/xid-2* -type d 2>/dev/null | sort -r | head -1)
if [ -z "$TUTORIAL_01_DIR" ]; then
    echo "No Tutorial 01 output found. Run Tutorial 01 first:"
    echo "  cd ../01-your-first-xid && bash tutorial_output.sh"
    exit 1
fi
# Load the XID file
XID=$(cat "$TUTORIAL_01_DIR/BRadvoc8-private.xid")
PASSWORD="Amira's strong password"
XID_NAME=BRadvoc8
envelope format "$XID"

│ {
│     XID(6103b546) [
│         'key': PublicKeys(2e94f423, SigningPublicKey(6103b546, Ed25519PublicKey(5d8b7d16)), EncapsulationPublicKey(33cee049, X25519PublicKey(33cee049))) [
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
│         'provenance': ProvenanceMark(80492376) [
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

Your basic XID is loaded. Now let's enrich it with professional information.

### Step 2: Add GitHub Account Information

Amira wants to share her GitHub presence - this is key to her **public participation profile**. Her signed Git commits will prove her technical capabilities.

First, she generates the SSH keys she will use to sign commits:

```
read -r SSH_PRVKEYS SSH_PUBKEYS <<< $(envelope generate keypairs --signing ssh-ed25519)
```

She adds her SSH public key to her GitHub account's SSH signing keys. To do that, she needs to export the public key in the standard SSH format that GitHub recognizes:

```
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")
echo "$SSH_EXPORT"

│ ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXFsZIZWX4Hnfopn/ZTwhx8THWhYxamq7mTGLRW5jsX
```

> **Why SSH Signing Keys Matter**: For pseudonymous contributors like Amira, signed Git commits ARE their reputation. Each commit signed with her SSH key proves it came from BRadvoc8, building verifiable evidence of technical capabilities over time.

Now she signs a dated statement with her private key. This is called a **proof-of-control** pattern:

```
CURRENT_DATE=$(date -u +"%Y-%m-%d")
PROOF_STATEMENT=$(envelope subject type string "$XID_NAME controls this SSH key on $CURRENT_DATE")
PROOF=$(envelope sign --signer "$SSH_PRVKEYS" "$PROOF_STATEMENT")
envelope format "$PROOF"

│ "BRadvoc8 controls this SSH key on 2026-01-12" [
│     'signed': Signature(SshEd25519)
│ ]
```

The `Signature(SshEd25519)` proves this was signed with an SSH Ed25519 key.

Anyone with the public key can verify:

```
# Verify the signature
envelope verify --silent --verifier "$SSH_PUBKEYS" "$PROOF"
echo "✓ Signature verified - proof of key control confirmed"

│ ✓ Signature verified - proof of key control confirmed
```

> **Why This Matters**: This self-signed attestation pattern proves Amira possesses the private key without revealing it. Anyone can verify the signature, confirming she controls the key that will sign her Git commits. An even stronger pattern would be *challenge-response* where the verifier issues a random challenge that the prover must sign, but that requires direct interaction. This dated statement is a simpler alternative that still proves control.

Next, she assembles her GitHub account information with proper data types:

```
GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known isA string "GitHubAccount" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known dereferenceVia uri "https://api.github.com/users/$XID_NAME" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "commitKey" ur $SSH_PUBKEYS "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "commitKeyText" string $SSH_EXPORT "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "commitKeyProof" ur $PROOF "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "createdAt" date "2025-05-10T00:55:11Z" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "updatedAt" date "2025-05-10T00:55:28Z" "$GITHUB_ACCOUNT")
envelope format "$GITHUB_ACCOUNT"

│ "BRadvoc8" [
│     'isA': "GitHubAccount"
│     "commitKey": PublicKeys(9839828c, SigningPublicKey(69d10561, SSHPublicKey(ac00a520)), EncapsulationPublicKey(02d6f5a1, X25519PublicKey(02d6f5a1)))
│     "commitKeyProof": {
│         "BRadvoc8 controls this SSH key on 2026-01-12" [
│             'signed': Signature(SshEd25519)
│         ]
│     }
│     "commitKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXFsZIZWX4Hnfopn/ZTwhx8THWhYxamq7mTGLRW5jsX"
│     "createdAt": 2025-05-10T00:55:11Z
│     "updatedAt": 2025-05-10T00:55:28Z
│     'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│ ]
```

Notice:

- Dates appear without quotes (proper date type).
- The URL has `URI()` wrapper (proper URI type).
- The `'isA' and 'dereferenceVia'` predicates are known values (single quotes) indicating standardized semantics.

> **Why Proper Types Matter**:
> - **Date types** enable chronological operations and validation
> - **URI types** allow systems to recognize and validate web resources
> - **Structured data** enables machine readability and automated verification
> - **Known values** provide semantic clarity and interoperability encoded as simple integers

Finally, she adds this envelope as an attachment to her XIDDoc:

```
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
    "$XID" \
)
envelope format "$XID_WITH_GITHUB_ATTACHMENT"

│ {
│     XID(6103b546) [
│         'attachment': {
│             "BRadvoc8" [
│                 'isA': "GitHubAccount"
│                 "commitKey": PublicKeys(9839828c, SigningPublicKey(69d10561, SSHPublicKey(ac00a520)), EncapsulationPublicKey(02d6f5a1, X25519PublicKey(02d6f5a1)))
│                 "commitKeyProof": {
│                     "BRadvoc8 controls this SSH key on 2026-01-12" [
│                         'signed': Signature(SshEd25519)
│                     ]
│                 }
│                 "commitKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXFsZIZWX4Hnfopn/ZTwhx8THWhYxamq7mTGLRW5jsX"
│                 "createdAt": 2025-05-10T00:55:11Z
│                 "updatedAt": 2025-05-10T00:55:28Z
│                 'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│             ]
│         } [
│             'vendor': "self"
│         ]
│         'key': PublicKeys(2e94f423, SigningPublicKey(6103b546, Ed25519PublicKey(5d8b7d16)), EncapsulationPublicKey(33cee049, X25519PublicKey(33cee049))) [
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
│         'provenance': ProvenanceMark(80492376) [
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

As you can see, the attachment has been added to the XIDDoc, the entire XIDDoc has been re-signed (because changing it invalidated the previous signature), and its private keys and provenance mark generator have been encrypted using the same password.

Let's break down each part of the command:

|                                  |                                                                                                                                                            |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `envelope xid attachment add`    | Command to add an attachment to a XIDDoc.                                                                                                                  |
| `--vendor "self"`                | The vendor identifier. Required for attachments. "self" is a common choice when the attachment is created by the XID owner.                                |
| `--payload "$GITHUB_ACCOUNT"`    | The payload to attach, in this case the GitHub account information.                                                                                        |
| `--verify inception`             | Verify the existing XID's signature using the inception key before adding the attachment. Ensures you have the correct password and that the XID is valid. |
| `--password "$PASSWORD"`         | The password to decrypt the existing XID's private keys for signing the new version.                                                                       |
| `--sign inception`               | Sign the new XIDDoc with the inception key (the original key). Creates a new signature that covers the new content including the attachment.               |
| `--private encrypt`              | Encrypt the private keys in the new XIDDoc.                                                                                                                |
| `--generator encrypt`            | Encrypt the provenance mark generator in the new XIDDoc.                                                                                                   |
| `--encrypt-password "$PASSWORD"` | The password to use for encrypting the new XIDDoc's private keys and provenance generator.                                                                 |
| `"$XID"`                         | The existing XIDDoc to which the attachment will be added.                                                                                                 |

> **Note**: Attachments support `vendor` and `conformsTo` fields. `vendor` is always required, so the source of the attachment can be identified. `conformsTo` can be used to specify a schema or standard the attachment adheres to, enabling better interoperability and understanding of the data structure. Presumably Amira would use a standard schema for GitHub account information in a real implementation, but for this tutorial we are just building the structure without a formal schema.

> **Key Separation**: You now have three keys in play:
> - **XID signing and encryption keys**: Proves this XID came from you (in `'key'` assertion), also allows decrypting messages sent to you (not covered in this tutorial)
> - **SSH signing key**: Signs Git commits
>
> **Why separate?** Compromise containment. If your SSH private key is compromised, your XID identity remains safe. Each key serves one specific purpose.

### Step 3: Elide Private Information

Now create a public version by eliding (leaving out) the private key and provenance mar generator. In your private version of the document, they are present but encrypted. In the public version, they are removed entirely, while the signature remains intact and valid.

```
PUBLIC_XID_WITH_GITHUB_ATTACHMENT=$( \
    envelope xid export \
    --private elide \
    --generator elide \
    "$XID_WITH_GITHUB_ATTACHMENT" \
)
envelope format "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT"

│ {
│     XID(6103b546) [
│         'attachment': {
│             "BRadvoc8" [
│                 'isA': "GitHubAccount"
│                 "commitKey": PublicKeys(9839828c, SigningPublicKey(69d10561, SSHPublicKey(ac00a520)), EncapsulationPublicKey(02d6f5a1, X25519PublicKey(02d6f5a1)))
│                 "commitKeyProof": {
│                     "BRadvoc8 controls this SSH key on 2026-01-12" [
│                         'signed': Signature(SshEd25519)
│                     ]
│                 }
│                 "commitKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXFsZIZWX4Hnfopn/ZTwhx8THWhYxamq7mTGLRW5jsX"
│                 "createdAt": 2025-05-10T00:55:11Z
│                 "updatedAt": 2025-05-10T00:55:28Z
│                 'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│             ]
│         } [
│             'vendor': "self"
│         ]
│         'key': PublicKeys(2e94f423, SigningPublicKey(6103b546, Ed25519PublicKey(5d8b7d16)), EncapsulationPublicKey(33cee049, X25519PublicKey(33cee049))) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(80492376) [
│             ELIDED
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

The `ELIDED` markers show private data has been removed, but the signature is still present and unchanged.

### Step 4: Verify Elision Preserved the Hash

Let's explicitly verify that elision preserved the root hash (just like in Tutorial 01):

```
# Compare digests of signed XID vs public (elided) XID
PRIVATE_DIGEST=$(envelope digest "$XID_WITH_GITHUB_ATTACHMENT")
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")

echo "Signed XID digest: $PRIVATE_DIGEST"
echo "Public XID digest: $PUBLIC_DIGEST"

if [ "$PRIVATE_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo '✅ VERIFIED: Digests identical - elision preserved the root hash!'
else
    echo '❌ ERROR: Digests differ'
fi

# Verify signature on the PUBLIC version (KEY_OBJECT was set in Step 4)
PUBKEYS=$(envelope xid key at 0 "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")
envelope verify --silent -v "$PUBKEYS" "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT" && echo '✅ Signature verified on public XID!'

│ Signed XID digest: ur:digest/hdcxswfrplwltibatbinvygegmnnhtflfmztndlkdrtnzspsnlbywewstngdnsurjyfhjnfzdtfy
│ Public XID digest: ur:digest/hdcxswfrplwltibatbinvygegmnnhtflfmztndlkdrtnzspsnlbywewstngdnsurjyfhjnfzdtfy
│ ✅ VERIFIED: Digests identical - elision preserved the root hash!
│ ✅ Signature verified on public XID!
```

**This is the power of Gordian Envelopes**: You signed once (over the complete XID with encrypted private keys), then created a public view by elision. The signature verifies on BOTH versions because elision preserves the Merkle tree root hash.

### Step 5: Selective Disclosure with Inclusion Proofs

You've learned to **elide** (remove) data while preserving the hash. But what if someone needs to verify that specific data exists in your elided XID? This is where **inclusion proofs** come in.

> **The Scenario**: You've shared your public XID with a collaborator. They need to verify you have a GitHub service without seeing all the details. You can prove the assertion exists without revealing everything.

#### Step 5a: Create an Extra-Elided Version

First, let's create a version with even more elision - hiding the service information. We start by finding the specific assertion within the envelope that we want to hide (the GitHub account attachment). To do that, we use an Envelope pattern expression (a topic for a different tutorial) to search for the assertion with the known predicate 'attachment' and capture it. This allows us to get the unique digest of that assertion, which we can then use to elide it specifically in the next step.

```
# We use HEREDOC assignment so we can write a pattern expression using quotes and newlines for clarity.
PATEX=$(cat <<'EOF'
    search(
        assertpred(
            'attachment'
        )
    )
EOF
)
ATTACHMENT_ENVELOPE=$(envelope match --envelopes --last-only $PATEX $PUBLIC_XID_WITH_GITHUB_ATTACHMENT)
envelope format $ATTACHMENT_ENVELOPE

│ 'attachment': {
│     "BRadvoc8" [
│         'isA': "GitHubAccount"
│         "commitKey": PublicKeys(9839828c, SigningPublicKey(69d10561, SSHPublicKey(ac00a520)), EncapsulationPublicKey(02d6f5a1, X25519PublicKey(02d6f5a1)))
│         "commitKeyProof": {
│             "BRadvoc8 controls this SSH key on 2026-01-12" [
│                 'signed': Signature(SshEd25519)
│             ]
│         }
│         "commitKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXFsZIZWX4Hnfopn/ZTwhx8THWhYxamq7mTGLRW5jsX"
│         "createdAt": 2025-05-10T00:55:11Z
│         "updatedAt": 2025-05-10T00:55:28Z
│         'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│     ]
│ } [
│     'vendor': "self"
│ ]
```

We then get the unique digest of that assertion, which allows us to elide it specifically:

```
ATTACHMENT_DIGEST=$(envelope digest "$ATTACHMENT_ENVELOPE")
```

Finally we create a new version of the XID with that specific assertion elided:

```
EXTRA_ELIDED_XIDDOC=$(envelope elide removing "$ATTACHMENT_DIGEST" "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")
envelope format "$EXTRA_ELIDED_XIDDOC"

│ {
│     XID(6103b546) [
│         'key': PublicKeys(2e94f423, SigningPublicKey(6103b546, Ed25519PublicKey(5d8b7d16)), EncapsulationPublicKey(33cee049, X25519PublicKey(33cee049))) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(80492376) [
│             ELIDED
│         ]
│         ELIDED
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

Notice that the only assertions in the public XID document are now the public key, the provenance mark, and an `ELIDED` marker representing where the attachment assertion was.

#### Step 5b: Create an Inclusion Proof

Create a proof that the service assertion exists in your full XID:

```
# Create an inclusion proof for the service assertion
INCLUSION_PROOF=$(envelope proof create "$ATTACHMENT_DIGEST" "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")

# The digest of the proof is the same as the digest of the elided envelope, confirming they are cryptographically linked
envelope digest $INCLUSION_PROOF
envelope digest $EXTRA_ELIDED_XIDDOC

│ ur:digest/hdcxswfrplwltibatbinvygegmnnhtflfmztndlkdrtnzspsnlbywewstngdnsurjyfhjnfzdtfy
│ ur:digest/hdcxswfrplwltibatbinvygegmnnhtflfmztndlkdrtnzspsnlbywewstngdnsurjyfhjnfzdtfy
```

#### Step 5c: Verify the Inclusion Proof

The recipient can verify the elided envelope contains the asserted data:

```
# Verify the proof confirms the assertion exists in the elided envelope
if envelope proof confirm --silent $INCLUSION_PROOF $ATTACHMENT_DIGEST $EXTRA_ELIDED_XIDDOC; then
    echo "✅ Proof confirmed - service assertion is in the original XID"
else
    echo "⚠ Proof failed"
fi

# Also verify both envelopes have the same root hash
ORIGINAL_DIGEST=$(envelope digest "$PUBLIC_XID_WITH_GITHUB_ATTACHMENT")
ELIDED_DIGEST=$(envelope digest "$EXTRA_ELIDED_XIDDOC")

if [ "$ORIGINAL_DIGEST" = "$ELIDED_DIGEST" ]; then
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

### Step 6: Save Your Files

Save both the private (complete) and public versions:

```
# Create output directory with timestamp
OUTPUT_DIR="output/xid-tutorial02-$(date +%Y%m%d%H%M%S)"
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

│ Saved files to output/xid-tutorial02-20260112002916:
│ total 48
│ drwxr-xr-x  8 wolf  staff   256 Jan 12 00:29 .
│ drwxr-xr-x  5 wolf  staff   160 Jan 12 00:29 ..
│ -rw-r--r--  1 wolf  staff  1550 Jan 12 00:29 BRadvoc8-private.format
│ -rw-r--r--  1 wolf  staff  3642 Jan 12 00:29 BRadvoc8-private.xid
│ -rw-r--r--  1 wolf  staff  1201 Jan 12 00:29 BRadvoc8-public.format
│ -rw-r--r--  1 wolf  staff  2366 Jan 12 00:29 BRadvoc8-public.xid
│ -rw-r--r--  1 wolf  staff   895 Jan 12 00:29 BRadvoc8-ssh-prvkeys.ur
│ -rw-r--r--  1 wolf  staff    81 Jan 12 00:29 BRadvoc8-ssh.pub
```

Your Tutorial 02 output directory contains:

```
output/xid-tutorial02-TIMESTAMP/
├── BRadvoc8-private.xid        # 🔒 Signed XID (complete, keep secure)
├── BRadvoc8-private.format     #    Human-readable version
├── BRadvoc8-public.xid         # ✅ Public XID (safe to share)
├── BRadvoc8-public.format      #    Human-readable version
├── BRadvoc8-ssh-prvkeys.ur     # 🔒 SSH private keys (keep secure!)
└── BRadvoc8-ssh.pub            # ✅ SSH public key (for GitHub)
```

---

## Part III: Wrap-Up

### Understanding What Happened

You've transformed a bare-bones XID into a rich professional persona with proper signing and verification:

**1. Structured Metadata with Proper Types**

You added GitHub account information using:
- **Date types**: `2025-05-10T00:55:11Z` (machine-parseable timestamps)
- **URI types**: `URI(https://api.github.com/users/BRadvoc8)` (validated web resources)
- **Nested envelopes**: Attachment → Account → Properties (logical hierarchy)

**Why nested structures matter**: When Ben fetches your XID in Tutorial 03, he can navigate to `attachment` → `GitHub` → `account` → `evidence` to find the API endpoint that proves your GitHub presence. Structured data enables automated verification.

**2. SSH Signing Key for Git Commits**

You generated an SSH Ed25519 key that:
- Signs Git commits (proving authorship)
- Uses standard SSH format (GitHub-compatible)
- Is separate from your XID keys (compromise containment)

**3. Proof-of-Control Pattern**

You proved you control the SSH key by:
- Creating a dated statement ("BRadvoc8 controls this SSH key on 2025-11-28")
- Signing it with the SSH private key
- Including the signed proof in your XIDDoc

Anyone can verify this proof without you revealing the private key. This establishes trust that the SSH key is legitimately associated with your identity.

**4. Re-Signing After Modification**

When you added assertions to your XID, you:
- Modified the envelope content (adding attachment, SSH key, proof)
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

| Key            | Purpose          | Location          | Algorithm   |
| -------------- | ---------------- | ----------------- | ----------- |
| XID Signing    | Sign XID updates | `'key'` assertion | Ed25519     |
| XID Encryption | Decrypt messages | `'key'` assertion | X25519      |
| SSH Signing    | Sign Git commits | `"sshSigningKey"` | SSH-Ed25519 |

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

**Next Tutorial**: [Publishing for Discovery](../04-publishing-discovery/tutorial-04.md) - Make your XID findable by declaring publication locations and establishing repository authority.
