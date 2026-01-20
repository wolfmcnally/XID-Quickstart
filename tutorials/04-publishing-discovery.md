# Publishing for Discovery

This tutorial continues Amira's story as BRadvoc8. In Tutorial 02, she built a rich persona with GitHub credentials and an SSH signing key. Now she faces a new challenge: **nobody can find her**. You'll learn how to make your XID discoverable through publication locations and repository authority.

**Time to complete: 25 minutes**

> **Related Concepts**
>
> Before or after completing this tutorial, you may want to read about [Open Integrity](https://github.com/OpenIntegrityProject/core) to understand how repository authority establishes trust without central authorities.

## Prerequisites

- Completed Tutorial 01: Creating Your First XID
- Completed Tutorial 02: Building Your Persona
- The artifacts from Tutorial 02 (or run `bash tests/02-building-persona-TEST.sh` to generate them)
- A GitHub account (for publication workflow)

## What You'll Learn

- How to add **dereferenceVia** assertions declaring where your XID can be fetched
- How to establish **repository authority** using Open Integrity inception commits
- How to publish your public XID to GitHub
- How to enable **update verification** so others can check for newer versions
- How to advance provenance to mark identity evolution

## Building on Tutorial 02

| Tutorial 02 | Tutorial 03 |
|-------------|-------------|
| Built rich persona with credentials | Declare WHERE to find that persona |
| Created public version with elision | Publish public version to repository |
| Generated SSH signing key | Use SSH key to prove repository control |

**The Bridge**: Your persona exists and is credible, but it's invisible. Now you'll make it findable and establish authoritative publication.

---

## Amira's Challenge: Becoming Discoverable

After building her rich BRadvoc8 persona in Tutorial 02, Amira faces a critical problem: **nobody can find her**. Her XID exists on her computer, but without a publication location, it's like having a phone number that's not in any directory.

**The problem**: Amira wants to contribute to social impact projects through RISK (the network Charlene told her about). But project managers like Ben can't verify her identity because they have no way to:
1. **Discover** her XID (where is it published?)
2. **Verify** it's authentic (is this really BRadvoc8?)
3. **Trust** it's current (is this the latest version?)

**The solution**: Amira needs to:
1. Declare publication locations (dereferenceVia assertions)
2. Establish repository authority (inception commit with her SSH key)
3. Publish her public XID where others can fetch it
4. Enable update verification (provenance tracking)

This tutorial teaches the **XID discovery and publication pattern** - making your identity findable while maintaining control over what's shared.

---

## Part I: Making Yourself Discoverable

In this section, you'll declare WHERE your XID can be fetched and prove you control the publication repository.

### Step 1: Load Your Tutorial 02 Artifacts

First, load the XID you created in Tutorial 02:

```
# Find the most recent Tutorial 02 output directory
TUTORIAL_02_DIR=$(find output/xid-tutorial02-* -type d 2>/dev/null | sort -r | head -1)

if [ -z "$TUTORIAL_02_DIR" ]; then
    echo "No Tutorial 02 output found. Run tests/02-building-persona-TEST.sh first."
    exit 1
fi

# Load the SIGNED XID from Tutorial 02
SIGNED_XID=$(cat "$TUTORIAL_02_DIR/BRadvoc8-xid.envelope")
PASSWORD="Amira's strong password"
XID_NAME=BRadvoc8

# Unwrap the signed XID to access its assertions
UNWRAPPED_XID=$(envelope extract wrapped "$SIGNED_XID")

# Load SSH keys from Tutorial 02 (for inception authority)
SSH_PRVKEYS=$(cat "$TUTORIAL_02_DIR/BRadvoc8-ssh-prvkeys.envelope")
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
SSH_EXPORT=$(cat "$TUTORIAL_02_DIR/BRadvoc8-ssh.pub")

echo "Loaded artifacts from: $TUTORIAL_02_DIR"
echo "✓ Signed XID loaded and unwrapped"
echo "✓ SSH signing keys loaded"
envelope format "$UNWRAPPED_XID"
```

> **Building on Tutorial 02**
>
> Your XID already has GitHub account information, SSH signing key, and proof-of-control. Now you'll add publication locations that tell others WHERE to find it. We also load the SSH private keys for creating the inception authority.

### Step 2: Add dereferenceVia Assertions

The **dereferenceVia** assertion tells the world WHERE to fetch your canonical XID. Without this, your identity exists but is unfindable.

> **The Discovery Problem**
>
> Having an XID without publication locations is like having a phone number that's not in any directory. dereferenceVia solves this by declaring authoritative fetch locations.

Add dereferenceVia assertions pointing to your GitHub repository:

```
# Add dereferenceVia assertion - GitHub raw URL
GITHUB_URL="https://raw.githubusercontent.com/$XID_NAME/$XID_NAME/main/$XID_NAME-public.envelope"
UNWRAPPED_XID=$(envelope assertion add pred-obj known dereferenceVia uri "$GITHUB_URL" "$UNWRAPPED_XID")

echo "Added dereferenceVia assertion"
envelope format "$UNWRAPPED_XID"
```

You can add multiple dereferenceVia endpoints for redundancy:

```
# Add alternative endpoint (GitHub blob URL as backup)
GITHUB_BLOB_URL="https://github.com/$XID_NAME/$XID_NAME/blob/main/$XID_NAME-public.envelope"
UNWRAPPED_XID=$(envelope assertion add pred-obj known dereferenceVia uri "$GITHUB_BLOB_URL" "$UNWRAPPED_XID")

echo "Added multiple dereferenceVia endpoints for redundancy"

│ XID(c7e764b7) [
│     "nickname": "BRadvoc8"
│     "sshSigningKey": "ssh-ed25519 AAAAC3Nza..."
│     "sshKeyProof": "BRadvoc8 controls this SSH key on 2025-11-27" [...]
│     "service": "GitHub" [...]
│     'dereferenceVia': URI(https://raw.githubusercontent.com/BRadvoc8/BRadvoc8/main/BRadvoc8-public.envelope)
│     'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/blob/main/BRadvoc8-public.envelope)
│     'key': PublicKeys(88d90933) [...]
│     'provenance': ProvenanceMark(632330b4) [...]
│ ]
```

> **Known Predicate**
>
> Notice `'dereferenceVia'` uses single quotes - it's a known predicate defined in the Gordian Envelope specification. This ensures interoperability with other tools that understand XIDs.

### Step 3: Establish Repository Authority (Open Integrity)

Now comes a critical step: proving you control the repository where your XID will be published. This uses the **Open Integrity** inception pattern.

> **Why Repository Authority Matters**
>
> Anyone could create a GitHub account called "BRadvoc8" and publish a fake XID. The inception commit pattern proves that the **same key** that's in your XID also controls the repository - linking your cryptographic identity to the publication location.

#### Step 3a: Understanding Inception Authority

The Open Integrity pattern works like this:

```
1. Your XID contains SSH signing key: ssh-ed25519 AAAAC3Nza...
2. You create a GitHub repo with an inception commit
3. That inception commit is signed with the SAME SSH key
4. Anyone verifying your XID can:
   - Check the SSH key in your XID
   - Fetch the inception commit from GitHub
   - Verify the commit signature matches the XID's SSH key
   - Confirms: same entity controls both XID and repo
```

#### Step 3b: Create Inception Commit (Conceptual)

In practice, you would:

```
# 1. Create GitHub repository: BRadvoc8/BRadvoc8
# 2. Configure git to use your SSH signing key:
#    git config user.signingkey "$(cat ~/.ssh/id_ed25519.pub)"
#    git config commit.gpgsign true
#    git config gpg.format ssh
#
# 3. Create inception commit:
#    git commit --allow-empty -S -m "Inception: BRadvoc8 XID repository"
#
# 4. Push to GitHub:
#    git push origin main
```

> **For This Tutorial**
>
> We'll simulate the inception process. In a real workflow, you'd follow the [Open Integrity Script Snippets](https://github.com/OpenIntegrityProject/core/blob/main/docs/Open_Integrity_Script_Snippets.md) to create an actual inception commit.

Create a mock inception record using the SSH keys loaded from Tutorial 02:

```
# Use SSH keys loaded in Step 1 (same keys that are in your XID)
# SSH_PRVKEYS and SSH_EXPORT were loaded from Tutorial 02 artifacts

# Create inception authority record (simulated)
INCEPTION_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
REPO_URL="https://github.com/$XID_NAME/$XID_NAME"

INCEPTION_RECORD=$(envelope subject type string "inception")
INCEPTION_RECORD=$(envelope assertion add pred-obj string "repository" uri "$REPO_URL" "$INCEPTION_RECORD")
INCEPTION_RECORD=$(envelope assertion add pred-obj string "date" date "$INCEPTION_DATE" "$INCEPTION_RECORD")
INCEPTION_RECORD=$(envelope assertion add pred-obj string "sshKey" string "$SSH_EXPORT" "$INCEPTION_RECORD")

# Sign the inception record with the SSH key (same key as in XID)
INCEPTION_SIGNED=$(envelope sign --signer "$SSH_PRVKEYS" "$INCEPTION_RECORD")

echo "Inception authority record:"
envelope format "$INCEPTION_SIGNED"

│ "inception" [
│     "date": 2025-11-27T12:00:00Z
│     "repository": URI(https://github.com/BRadvoc8/BRadvoc8)
│     "sshKey": "ssh-ed25519 AAAAC3Nza..."
│     'signed': Signature(SshEd25519)
│ ]
```

> **Key Point**
>
> We use the SAME SSH keys that are already in your XID (loaded from Tutorial 02). This is critical - the inception authority only works because the key in the inception record matches the key in your XID.

Add the inception record to your XID:

```
# Add inception authority to XID
UNWRAPPED_XID=$(envelope assertion add pred-obj string "inceptionAuthority" envelope "$INCEPTION_SIGNED" "$UNWRAPPED_XID")

echo "✓ Added inception authority to XID"
```

> **The Key Insight**
>
> The SSH key in `"sshKey"` matches the key used to sign Git commits. Anyone can verify the commit signature against this key, confirming the same entity controls both the XID and the repository.

---

## Part II: Sign, Publish and Verify

Now you'll re-sign your modified XID, create the public version, and learn the verification pattern others will use.

### Step 4: Re-Sign Your Modified XID

You've added new assertions (dereferenceVia, inceptionAuthority) to your XID. Just like in Tutorial 02, modifications require re-signing:

```
# Extract private keys for signing (same pattern as Tutorial 02)
PRVKEYS=$(envelope xid key all --private --password "$PASSWORD" "$SIGNED_XID")

# Get public keys for later verification
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBKEYS=$(envelope extract ur "$KEY_OBJECT")

# Wrap and sign the modified XID
WRAPPED_XID=$(envelope subject type wrapped "$UNWRAPPED_XID")
SIGNED_XID=$(envelope sign --signer "$PRVKEYS" "$WRAPPED_XID")

echo "✓ Re-signed XID with new assertions"
envelope format "$SIGNED_XID"

│ {
│     XID(c7e764b7) [
│         "inceptionAuthority": "inception" [...]
│         "service": "GitHub" [...]
│         "sshKeyProof": "BRadvoc8 controls this SSH key on 2025-11-28" [...]
│         "sshSigningKey": "ssh-ed25519 AAAAC3Nza..."
│         'dereferenceVia': URI(https://raw.githubusercontent.com/BRadvoc8/BRadvoc8/main/BRadvoc8-public.envelope)
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/blob/main/BRadvoc8-public.envelope)
│         'key': PublicKeys(88d90933) [...]
│         'provenance': ProvenanceMark(632330b4) [...]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

> **Why Re-Sign?**
>
> Adding assertions changes the envelope's content. The signature from Tutorial 02 was over the *old* content. After adding dereferenceVia and inceptionAuthority, you need a new signature that commits to the *new* content.

### Step 5: Elide Private Keys and Verify

Create a public version by eliding private keys, then verify the hash is preserved:

```
# Find and elide the private key
PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$KEY_OBJECT")
PRIVATE_KEY_DIGEST=$(envelope digest "$PRIVATE_KEY_ASSERTION")

# Also elide the provenance generator
PROV_ASSERTION=$(envelope assertion find predicate known provenance "$UNWRAPPED_XID")
PROV_OBJECT=$(envelope extract object "$PROV_ASSERTION")
PROV_GEN_ASSERTION=$(envelope assertion find predicate known provenanceGenerator "$PROV_OBJECT")
PROV_GEN_DIGEST=$(envelope digest "$PROV_GEN_ASSERTION")

# Create public version by eliding both from the SIGNED XID
PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_DIGEST" "$SIGNED_XID")
PUBLIC_XID=$(envelope elide removing "$PROV_GEN_DIGEST" "$PUBLIC_XID")

echo "Public XID (ready for publication):"
envelope format "$PUBLIC_XID"

│ {
│     XID(c7e764b7) [
│         "inceptionAuthority": "inception" [...]
│         "service": "GitHub" [...]
│         "sshKeyProof": "BRadvoc8 controls this SSH key on 2025-11-28" [...]
│         "sshSigningKey": "ssh-ed25519 AAAAC3Nza..."
│         'dereferenceVia': URI(https://raw.githubusercontent.com/BRadvoc8/BRadvoc8/main/BRadvoc8-public.envelope)
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/blob/main/BRadvoc8-public.envelope)
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

Now verify the hash is preserved and signature is valid:

```
# Verify digests match (elision preserved the hash)
SIGNED_DIGEST=$(envelope digest "$SIGNED_XID")
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_XID")

echo "Signed XID digest: $SIGNED_DIGEST"
echo "Public XID digest: $PUBLIC_DIGEST"

if [ "$SIGNED_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo "✅ VERIFIED: Digests identical - elision preserved the root hash!"
else
    echo "❌ ERROR: Digests differ"
fi

# Verify signature on the public version
envelope verify -v "$PUBKEYS" "$PUBLIC_XID" >/dev/null && echo "✅ Signature verified on public XID!"

│ Signed XID digest: ur:digest/hdcx...
│ Public XID digest: ur:digest/hdcx...
│ ✅ VERIFIED: Digests identical - elision preserved the root hash!
│ ✅ Signature verified on public XID!
```

### Step 6: Save Your Files

Save your files:

```
# Create output directory with timestamp
OUTPUT_DIR="output/xid-tutorial03-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save public XID (for publication)
echo "$PUBLIC_XID" > "$OUTPUT_DIR/$XID_NAME-public.envelope"
envelope format "$PUBLIC_XID" > "$OUTPUT_DIR/$XID_NAME-public.format"

# Save signed XID (complete version with signature)
echo "$SIGNED_XID" > "$OUTPUT_DIR/$XID_NAME-xid.envelope"
envelope format "$SIGNED_XID" > "$OUTPUT_DIR/$XID_NAME-xid.format"

# Save SSH public key
echo "$SSH_EXPORT" > "$OUTPUT_DIR/$XID_NAME-ssh.pub"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
```

> **To Actually Publish**
>
> Copy `BRadvoc8-public.envelope` to your GitHub repository at the path declared in your dereferenceVia assertions. Then commit and push.

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

# 2. Check provenance sequence
PROV_MARK=$(envelope xid provenance get "$FETCHED_XID")
echo "2. Provenance mark: $PROV_MARK"

# 3. Verify the XID structure
FETCHED_UNWRAPPED=$(envelope extract wrapped "$FETCHED_XID" 2>/dev/null || echo "$FETCHED_XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$FETCHED_UNWRAPPED")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
FETCHED_PUBKEYS=$(envelope extract ur "$KEY_OBJECT")
echo "3. ✓ Extracted public keys for verification"

# 4. Verify inception authority
INCEPTION=$(envelope assertion find predicate string "inceptionAuthority" "$FETCHED_UNWRAPPED")
INCEPTION_ENV=$(envelope extract object "$INCEPTION")
SSH_IN_INCEPTION=$(envelope assertion find predicate string "sshKey" "$INCEPTION_ENV")
SSH_KEY_VALUE=$(envelope extract object "$SSH_IN_INCEPTION")

echo "4. ✓ Inception authority found - SSH key for repository verification"

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
XID_V1=$(envelope xid provenance next --password "$PASSWORD" "$SIGNED_XID")

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
echo "$XID_V1" > "$OUTPUT_DIR/$XID_NAME-xid-v1.envelope"
envelope format "$XID_V1" > "$OUTPUT_DIR/$XID_NAME-xid-v1.format"

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

**A:** Privacy through selective disclosure. Your full XID might contain sensitive information (contact details, work history, credentials). Elision lets you share minimal public information while revealing specific details to specific parties when needed. (See Tutorial 02 for the selective revelation pattern.)

### Q: What if someone publishes a fake XID at my dereferenceVia URL?

**A:** The inception authority protects against this. Even if someone compromises your GitHub account, they can't forge the SSH signature linking the repository to your XID. The SSH private key is the security anchor.

---

## What's Next

Amira now has a discoverable, verifiable identity. Her BRadvoc8 XID is ready for publication with:
- ✅ Publication locations (dereferenceVia assertions)
- ✅ Repository authority (inception commit)
- ✅ Update verification support (provenance)

**Coming Next: Making Claims**

In Tutorial 04, you'll learn how to:

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
> Tutorial 03 made you **findable**. Tutorial 04 teaches you to make **credible claims**. Tutorial 05 then shows how others **validate those claims** through peer endorsements.

---

## Tutorial 03 Files Summary

Your Tutorial 03 output directory contains:

```
output/xid-tutorial03-TIMESTAMP/
├── BRadvoc8-public.envelope     # ✅ Public XID (publish this)
├── BRadvoc8-public.format       #    Human-readable version
├── BRadvoc8-xid.envelope        # 🔒 Private XID (keep secure)
├── BRadvoc8-xid.format          #    Human-readable version
├── BRadvoc8-xid-v1.envelope     # 🔒 Private XID with provenance v1
├── BRadvoc8-xid-v1.format       #    Human-readable version
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

A complete working script implementing this tutorial is available at `tests/03-publishing-discovery-TEST.sh`. Run it to see all steps in action:

```
bash tests/03-publishing-discovery-TEST.sh
```

This script will create all the XID versions and demonstrate the complete publishing and discovery workflow.

---

**Next Tutorial**: [Self-Attestations & Selective Sharing](06-self-attestations.md) - Make credible claims about yourself using fair witness methodology and protect sensitive credentials with public-key permits.
