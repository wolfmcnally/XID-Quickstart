# Tutorial 04: Self-Attestations & Selective Sharing

Build your reputation foundation through self-attestations using fair witness methodology, and learn to protect sensitive information with public-key permits for selective sharing.

**Time to complete**: ~45-50 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-03

> **Related Concepts**: After completing this tutorial, explore [Attestation & Endorsement Model](../concepts/attestation-endorsement-model.md) and [Pseudonymous Trust Building](../concepts/pseudonymous-trust-building.md) to deepen your understanding.

## Prerequisites

- Completed Tutorial 01 (Creating Your First XID)
- Completed Tutorial 02 (Building Your Persona)
- Completed Tutorial 03 (Publishing for Discovery)
- The `envelope` CLI tool installed
- Your XID artifacts from Tutorial 03
- Basic understanding of cryptographic signatures

## What You'll Learn

- How to create self-attestations about your skills and experience
- How to verify self-attestations cryptographically
- How to build progressive trust through layered attestations
- The **fair witness methodology** for making credible claims
- **Why some attestations need encryption** (the identity revelation problem)
- **How to use public-key permits** to share sensitive attestations selectively

## Building on Tutorial 03

| Tutorial 03 | Tutorial 04 |
|-------------|-------------|
| Made your XID discoverable | Make claims about your capabilities |
| Established repository authority | Establish credible self-attestations |
| Publication locations | Evidence and credentials |

**The Bridge**: Your XID is now findable and verifiable. But what does it actually say about your capabilities? This tutorial teaches you to make credible claims.

---

## Amira's Challenge: Making Credible Claims

Amira (as BRadvoc8) has created her pseudonymous identity and made it discoverable. But she faces a fundamental challenge: **how can she demonstrate her capabilities when nobody knows who she is?**

Open source maintainers are cautious about unknown contributors. They need to trust that:
- Contributors have relevant technical skills
- They'll deliver quality work
- They understand project values and norms
- They won't introduce security vulnerabilities

Without demonstrated capabilities, Amira is limited to trivial contributions. The meaningful work she wants to do - security enhancements, privacy-preserving features - requires showing she has relevant skills.

**The tension**: Traditional credentials rely on real-world identity - degrees, employment history, references. But Amira needs to maintain pseudonymity for her safety. How can she establish credibility without compromising privacy?

**The solution**: Self-attestations using **fair witness methodology**. Through specific, verifiable claims about her skills and experience, BRadvoc8 can establish a foundation for trust that's:
- **Cryptographically signed** - proves she made the claim
- **Specific and verifiable** - claims that can be tested through work
- **Progressively disclosed** - sensitive credentials shared only with those who need them

In this tutorial, you'll learn how Amira makes credible claims about herself and protects sensitive information using public-key permits.

---

## The Fair Witness Principle: Attestation Methodology

Before creating attestations, you need to understand what makes them trustworthy. The **fair witness principle** is a methodology for making claims that others can believe - especially important for pseudonymous contributors like BRadvoc8 who can't rely on traditional credentials.

Amira faces a unique challenge: without showing a resume, degree, or employment history, her attestations ARE her credentials. Using fair witness methodology makes those attestations trustworthy.

### What Fair Witness Means

A "fair witness" makes only factual claims they can personally verify, avoiding opinions or inferences. This methodology comes from professional attestation practices and creates more credible claims.

**The five fair witness practices**:

1. **Make factual claims** - state what you directly know or experienced
   - "I have 8 years of experience in distributed systems security"
   - "I am one of the best security experts"

2. **Be specific about scope** - state clearly what you're claiming (and what you're not)
   - "I design privacy-preserving authentication systems"
   - "I know everything about security"

3. **Avoid opinions and inferences** - stick to what you can verify
   - "I contributed security enhancements to Project X from 2023-2025"
   - "I probably know more than most developers about cryptography"

4. **Include context** - explain the basis for your claim
   - "I have professional experience implementing cryptographic protocols in production systems"
   - "I'm a crypto expert" (no context given)

5. **Acknowledge limitations** - be honest about what you don't know
   - "I specialize in web security but have limited blockchain experience"
   - "I can do any security work" (claims everything)

### Why This Matters for BRadvoc8

Amira's pseudonymous identity means she can't show a resume, degree, or employment history. Her attestations ARE her credentials. Fair witness methodology makes those attestations trustworthy:

- **Specific claims are verifiable** - "8 years of experience" can be validated through demonstrated work
- **Honest limitations build trust** - admitting gaps shows self-awareness, not weakness
- **Factual claims invite validation** - people can test claims through collaboration
- **Scope clarity helps endorsers** - they know exactly what to vouch for

**The pattern**: Start with honest, specific, verifiable claims -> demonstrate through actual work -> gather endorsements from people who've seen you work -> build reputation on facts, not hype.

### Examples in Practice

**Strong fair witness attestations**:
- "I design privacy-preserving systems that protect vulnerable populations" (specific domain, factual)
- "I contribute to open source security tools" (verifiable through GitHub)
- "I have professional experience with cryptographic protocol implementation" (specific, factual)

**Weak attestations** (avoid these):
- "I am an expert" (opinion, not factual)
- "I probably know..." (uncertain, not factual)
- "I can do anything security-related" (too broad, claims everything)
- "I'm better than most developers" (comparative opinion)

**Why specificity matters**:

Compare these two attestations:
- "I'm good at security" - Vague, subjective, can't be verified
- "I have 8 years of experience implementing cryptographic authentication in distributed systems" - Specific domain, factual claim, can be validated through work

The second attestation gives collaborators clear expectations and provides something concrete to validate through actual work.

### The Trust Building Pattern

Fair witness attestations work because they're designed to be tested:

1. **Amira makes specific claims** - "I design privacy-preserving authentication systems"
2. **Someone gives her a relevant task** - "Help us with our authentication system"
3. **Her work validates (or contradicts) the claim** - Quality of work shows if claim was accurate
4. **Endorsers can honestly vouch** - They've seen evidence, not just claims

This creates a feedback loop: honest claims -> demonstrated work -> meaningful endorsements -> stronger reputation.

With this methodology in mind, let's create BRadvoc8's first self-attestation...

## Part I: Self-Attestation

Self-attestations are signed statements you make about yourself - your skills, experience, and values. While anyone can claim anything about themselves, cryptographic signatures prove that:
1. The claim came from you (not forged by someone else)
2. The claim hasn't been modified since you signed it
3. The claim is bound to your persistent XID

Think of self-attestations as the foundation of your public participation profile. They're baseline claims that set expectations and can later be validated through your actual contributions and peer endorsements.

### Step 1: Create Your First Self-Attestation

Let's start by setting up the working environment and loading Amira's XID from Tutorial 03.

**Create output directory:**

👉
```sh
mkdir -p output
```

**Load your XID from Tutorial 03:**

👉
```sh
# Find the most recent Tutorial 03 output directory
TUTORIAL_03_DIR=$(find output/xid-tutorial03* -type d 2>/dev/null | sort -r | head -1)

if [ -z "$TUTORIAL_03_DIR" ]; then
    echo "No Tutorial 03 output found. Run tests/03-publishing-discovery-TEST.sh first."
    exit 1
fi

# Load the XID you created in Tutorial 03
XID=$(cat "$TUTORIAL_03_DIR/BRadvoc8-xid.envelope")
PASSWORD="Amira's strong password"
XID_NAME=BRadvoc8

# Unwrap the signed XID to work with assertions
UNWRAPPED_XID=$(envelope extract wrapped "$XID")

# Extract public keys for verification
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
XID_PUBKEYS=$(envelope extract ur "$KEY_OBJECT")

# Generate attestation signing keys (separate from XID keys for this tutorial)
# In practice, you'd use the same keys or a dedicated attestation key
ATTESTATION_PRVKEYS=$(envelope generate prvkeys)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

# Extract your XID identifier for reference
XID_ID=$(envelope xid id "$XID")
echo "Loaded XID: $XID_ID"
echo "From: $TUTORIAL_03_DIR"
```

🔎
```console
Loaded XID: ur:xid/hdcx...
```

Now Amira will create her first self-attestation - a claim about her technical expertise in distributed systems security.

**Create a self-attestation about technical skills:**

👉
```sh
# Create the claim (what you're attesting to)
CLAIM=$(envelope subject type string "I have 8 years of experience in distributed systems security")

# Wrap it as a self-attestation
ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$CLAIM")
ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "BRadvoc8" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2025-11-20T00:00:00Z" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$ATTESTATION")

# Sign the attestation with your attestation key
ATTESTATION_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$ATTESTATION")

echo "$ATTESTATION_SIGNED" > output/attestation-01-security-experience.envelope
envelope format "$ATTESTATION_SIGNED"
```

🔎
```console
{
    "I have 8 years of experience in distributed systems security" [
        isA: "SelfAttestation"
        "attestedBy": "BRadvoc8"
        "attestedOn": 2025-11-20T00:00:00Z
        "domain": "Distributed Systems & Security"
    ]
} [
    'signed': Signature
]
```

### Understanding Self-Attestations

A self-attestation has four key components:

1. **Subject** (`"I have 8 years..."`) - The actual claim being made
2. **Type marker** (`isA: "SelfAttestation"`) - Identifies this as a self-attestation
3. **Metadata** (`attestedBy`, `attestedOn`, `domain`) - Context about the attestation
4. **Signature** (`'signed': Signature`) - Cryptographic proof it came from you

The signature is critical: it proves this claim came from the controller of BRadvoc8's private key. Anyone can verify the signature using your public key, but they can't forge attestations without access to your private key.

**Important distinction**: A self-attestation proves **you made the claim**, not that the claim is true. It's the starting point for building trust - later you'll validate these claims through demonstrated work and peer endorsements.

Now let's add this attestation to your XID so others can discover your claims.

**Add the attestation to your XID:**

👉
```sh
UNWRAPPED_XID=$(envelope assertion add pred-obj string "attestation" envelope "$ATTESTATION_SIGNED" "$UNWRAPPED_XID")
echo "$UNWRAPPED_XID" > output/amira-xid-with-attestation-01.envelope

echo "XID with attestation:"
envelope format "$UNWRAPPED_XID"
```

🔎
```console
XID(e94de728) [
    "attestation": {
        "I have 8 years of experience in distributed systems security" [
            isA: "SelfAttestation"
            "attestedBy": "BRadvoc8"
            "attestedOn": 2025-11-20T00:00:00Z
            "domain": "Distributed Systems & Security"
        ]
    } [
        'signed': Signature
    ]
    'key': PublicKeys(...) [
        ...
    ]
]
```

Your XID now carries a self-attestation about your security experience. This attestation is:
- **Signed** - cryptographically bound to your XID
- **Timestamped** - shows when the claim was made
- **Verifiable** - anyone can check the signature

But how trustworthy is this claim? That's what verification helps establish.

### Step 2: Verify Your Self-Attestation

Verification proves that an attestation was actually signed by the claimed attestor and hasn't been tampered with. Let's verify the attestation we just created.

**Extract and verify the attestation:**

👉
```sh
# Find the attestation assertion in the XID
ATTESTATION_ASSERTION=$(envelope assertion find predicate string "attestation" "$UNWRAPPED_XID")

# Extract the signed attestation envelope
ATTESTATION_ENVELOPE=$(envelope extract object "$ATTESTATION_ASSERTION")

# Verify the signature using your attestation public keys
envelope verify --verifier "$ATTESTATION_PUBKEYS" "$ATTESTATION_ENVELOPE"
```

🔎
```console
Signature valid
```

The signature verification confirms that:
1. This attestation was signed by the controller of BRadvoc8's private key
2. The attestation content hasn't been modified since signing
3. The signature is cryptographically valid

But notice what verification **doesn't** tell us:
- Whether the claim is actually true
- Whether BRadvoc8 has the claimed experience
- Whether others trust this claim

**This is the key limitation of self-attestations**: cryptographic validity != trustworthiness of the claim.

### Understanding Trust Levels

Self-attestations have inherent trust limitations:

**What self-attestations prove:**
- You made the claim (signature verification)
- The claim hasn't been altered (cryptographic integrity)
- The claim is bound to your XID (persistent identity)

**What self-attestations don't prove:**
- The claim is actually true (anyone can claim anything)
- Others should trust the claim (no third-party validation)
- You have evidence to support the claim (assertion != proof)

Self-attestations are like introductions at a networking event: "Hi, I'm BRadvoc8, I work in security." Useful for setting context, but trust comes from what you do next.

To build real trust, you need:
1. **Multiple attestations** - consistent claims over time
2. **Demonstrated work** - contributions that validate your claims
3. **Peer endorsements** - others vouch for your abilities (covered in Tutorial 05)

Let's start building that trust foundation.

### Step 3: Build Progressive Trust with Multiple Attestations

Trust builds through consistency. Let's create additional self-attestations that demonstrate Amira's expertise in different aspects of security and privacy work.

**Create an attestation about privacy-preserving design:**

👉
```sh
CLAIM2=$(envelope subject type string "I design privacy-preserving systems that protect vulnerable populations")

ATTESTATION2=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$CLAIM2")
ATTESTATION2=$(envelope assertion add pred-obj string "attestedBy" string "BRadvoc8" "$ATTESTATION2")
ATTESTATION2=$(envelope assertion add pred-obj string "attestedOn" date "2025-11-20T00:00:00Z" "$ATTESTATION2")
ATTESTATION2=$(envelope assertion add pred-obj string "domain" string "Privacy Engineering" "$ATTESTATION2")

ATTESTATION2_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$ATTESTATION2")
echo "$ATTESTATION2_SIGNED" > output/attestation-02-privacy-design.envelope

UNWRAPPED_XID=$(envelope assertion add pred-obj string "attestation" envelope "$ATTESTATION2_SIGNED" "$UNWRAPPED_XID")
```

**Create an attestation about open source contribution:**

👉
```sh
CLAIM3=$(envelope subject type string "I contribute to open source security tools and privacy-focused projects")

ATTESTATION3=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$CLAIM3")
ATTESTATION3=$(envelope assertion add pred-obj string "attestedBy" string "BRadvoc8" "$ATTESTATION3")
ATTESTATION3=$(envelope assertion add pred-obj string "attestedOn" date "2025-11-20T00:00:00Z" "$ATTESTATION3")
ATTESTATION3=$(envelope assertion add pred-obj string "domain" string "Open Source Contribution" "$ATTESTATION3")
ATTESTATION3=$(envelope assertion add pred-obj string "evidence" string "GitHub activity under BRadvoc8 pseudonym" "$ATTESTATION3")

ATTESTATION3_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$ATTESTATION3")
echo "$ATTESTATION3_SIGNED" > output/attestation-03-opensource.envelope

UNWRAPPED_XID=$(envelope assertion add pred-obj string "attestation" envelope "$ATTESTATION3_SIGNED" "$UNWRAPPED_XID")

# Save the updated XID
echo "$UNWRAPPED_XID" > output/amira-xid-with-attestations.envelope
```

**View all attestations in your XID:**

👉
```sh
echo "BRadvoc8's attestations:"
envelope assertion find predicate string "attestation" "$UNWRAPPED_XID" | \
  while read attestation_assertion; do
    attestation=$(envelope extract object <<< "$attestation_assertion")
    envelope extract wrapped <<< "$attestation" | envelope subject | envelope format
  done
```

🔎
```console
BRadvoc8's attestations:
"I have 8 years of experience in distributed systems security"
"I design privacy-preserving systems that protect vulnerable populations"
"I contribute to open source security tools and privacy-focused projects"
```

### Understanding Progressive Trust

By creating multiple related attestations, Amira is building a **progressive trust profile**:

1. **Consistency across domains** - attestations cover related areas (security, privacy, open source)
2. **Specificity** - each attestation addresses a distinct aspect of expertise
3. **Evidence hints** - the GitHub mention provides a verification path
4. **Temporal consistency** - all dated to establish timeline

This pattern demonstrates:
- **Coherent identity** - attestations tell a consistent story
- **Breadth of expertise** - multiple relevant skills
- **Verifiability path** - evidence can be checked (GitHub activity)
- **Foundation for validation** - claims that can be tested through actual work

**The progressive trust model**: Start with self-attestations (claims) -> demonstrate through contributions (evidence) -> gather peer endorsements (validation). Each layer strengthens the trust foundation.

But not all attestations can be public. Some claims - like specific project work - could reveal your legal identity. That's where **public-key permits** come in.

---

## Part II: Sensitive Attestations & Permits

Some attestations are too risky to publish publicly. Amira's work on real projects could reveal her legal identity if she's not careful. This section teaches you when and how to encrypt attestations for specific recipients.

### The Identity Revelation Problem

Amira wants to share that she contributed to **Project CivilTrust** from 2023-2025. This is valuable evidence of her skills - but there's a problem:

> **The Risk**: CivilTrust's public contributor list includes legal names. If Amira publishes "I contributed to CivilTrust," anyone could cross-reference that claim with CivilTrust's contributor list and discover her real identity.

**This is why permits matter**: Some information is too sensitive to share publicly, even in elided form. Public-key permits let Amira prove her credentials to specific people (like Ben, who's evaluating her for a project) without publishing that connection for everyone to see.

### Step 4: Fetch Ben's XID

For public-key permits to work, Amira needs Ben's public encryption key. XIDs contain **X25519 encryption keys** specifically for receiving encrypted data.

Remember Ben from Tutorial 01? He's the project manager from SisterSpaces that Charlene mentioned when introducing Amira to RISK. Ben evaluates potential contributors for social impact projects, and Amira wants to share her CivilTrust credentials with him to demonstrate her experience.

> **Real-World XID Discovery**: XIDs are typically published to public repositories (GitHub, IPFS, personal websites) where they can be discovered and fetched. Each XID contains encryption keys for receiving encrypted data.

#### Step 4a: Ben Publishes His XID (Mock Setup)

For this tutorial, we'll simulate Ben publishing his XID:

👉
```sh
# Create Ben's complete XID (what Ben does on his own system)
BEN_PRVKEYS=$(envelope generate prvkeys)
BEN_PUBKEYS=$(envelope generate pubkeys "$BEN_PRVKEYS")
BEN_XID=$(envelope xid new "$BEN_PRVKEYS")
BEN_XID=$(envelope assertion add pred-obj string "nickname" string "Ben" "$BEN_XID")

echo "Created Ben's XID"

# Ben elides his private keys before publishing (critical!)
BEN_XID_UNWRAPPED=$(envelope extract wrapped "$BEN_XID" 2>/dev/null || echo "$BEN_XID")
BEN_KEY_ASSERTION=$(envelope assertion find predicate known key "$BEN_XID_UNWRAPPED")
BEN_KEY_OBJECT=$(envelope extract object "$BEN_KEY_ASSERTION")
BEN_PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$BEN_KEY_OBJECT")
BEN_PRIVATE_KEY_DIGEST=$(envelope digest "$BEN_PRIVATE_KEY_ASSERTION")
BEN_XID_PUBLIC=$(envelope elide removing "$BEN_PRIVATE_KEY_DIGEST" "$BEN_XID")

# Save to simulate GitHub publication
mkdir -p output/mock-published
echo "$BEN_XID_PUBLIC" > output/mock-published/ben-xid.envelope

echo "Ben's XID 'published' (mock setup complete)"
```

> **In Practice**: Ben would push his elided XID to GitHub. His **private keys never leave his system** - only the public XID is shared.

#### Step 4b: Amira Fetches Ben's XID

Now Amira discovers Ben's XID and fetches it:

👉
```sh
# Amira fetches Ben's published XID
BEN_XID_FETCHED=$(cat output/mock-published/ben-xid.envelope)

echo "Fetched Ben's XID"
envelope format "$BEN_XID_FETCHED"
```

🔎
```
XID(abc123) [
    "nickname": "Ben"
    'key': PublicKeys(def456) [
        'allow': 'All'
        ELIDED
    ]
]
```

### Step 5: Create Sensitive Attestation

Now Amira creates an attestation about her CivilTrust work - but this one is sensitive:

👉
```sh
# Create the sensitive claim
SENSITIVE_CLAIM=$(envelope subject type string "I contributed security enhancements to Project CivilTrust from 2023-2025")

# Wrap it as a sensitive attestation
SENSITIVE_ATTESTATION=$(envelope assertion add pred-obj known isA string "SensitiveAttestation" "$SENSITIVE_CLAIM")
SENSITIVE_ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "BRadvoc8" "$SENSITIVE_ATTESTATION")
SENSITIVE_ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2025-11-20T00:00:00Z" "$SENSITIVE_ATTESTATION")
SENSITIVE_ATTESTATION=$(envelope assertion add pred-obj string "domain" string "Security Engineering" "$SENSITIVE_ATTESTATION")
SENSITIVE_ATTESTATION=$(envelope assertion add pred-obj string "privacyNote" string "Reveals legal identity via CivilTrust contributor list" "$SENSITIVE_ATTESTATION")

echo "Sensitive attestation (before encryption):"
envelope format "$SENSITIVE_ATTESTATION"
```

🔎
```
"I contributed security enhancements to Project CivilTrust from 2023-2025" [
    isA: "SensitiveAttestation"
    "attestedBy": "BRadvoc8"
    "attestedOn": 2025-11-20T00:00:00Z
    "domain": "Security Engineering"
    "privacyNote": "Reveals legal identity via CivilTrust contributor list"
]
```

> **Key Insight**: This attestation is valuable evidence of Amira's skills, but publishing it publicly would link BRadvoc8 to her legal name. She needs to encrypt it for specific recipients only.

### Step 6: Encrypt Attestation for Ben (Public-Key Permit)

Now the key step: encrypt this attestation so only Ben can read it.

👉
```sh
# First, sign the attestation (proves it came from BRadvoc8)
# Extract Amira's private keys from her XID
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
XID_PUBKEYS=$(envelope extract ur "$KEY_OBJECT")

# Sign the sensitive attestation
SENSITIVE_ATTESTATION_SIGNED=$(envelope sign --signer "$XID_PUBKEYS" "$SENSITIVE_ATTESTATION" 2>/dev/null || echo "$SENSITIVE_ATTESTATION")

# Now encrypt for Ben using his public keys
SENSITIVE_ENCRYPTED=$(envelope encrypt --recipient "$BEN_PUBKEYS" "$SENSITIVE_ATTESTATION_SIGNED")

echo "Encrypted attestation (only Ben can read):"
envelope format "$SENSITIVE_ENCRYPTED"
```

🔎
```
ENCRYPTED [
    'hasRecipient': SealedMessage
]
```

Notice the `ENCRYPTED` marker and `'hasRecipient': SealedMessage`. The attestation content is now protected - only Ben can decrypt it with his private key.

> **Security Guarantee**: Even if this encrypted attestation is published publicly, only Ben can read its contents. No one else can discover Amira's connection to CivilTrust.

### Step 7: Ben Decrypts and Verifies

Ben receives the encrypted attestation. Let's see what he can do with it:

👉
```sh
# Ben decrypts with his private key
BEN_DECRYPTED=$(envelope decrypt --recipient "$BEN_PRVKEYS" "$SENSITIVE_ENCRYPTED")

echo "What Ben sees after decryption:"
envelope format "$BEN_DECRYPTED"
```

🔎
```
"I contributed security enhancements to Project CivilTrust from 2023-2025" [
    isA: "SensitiveAttestation"
    "attestedBy": "BRadvoc8"
    "attestedOn": 2025-11-20T00:00:00Z
    "domain": "Security Engineering"
    "privacyNote": "Reveals legal identity via CivilTrust contributor list"
]
```

Ben now knows:
- Amira contributed to CivilTrust (valuable credential)
- She worked on security enhancements (relevant to his project)
- The claim is signed by BRadvoc8 (can verify authenticity)
- This information is sensitive (she trusted him with it)

> **Trust Signal**: By sharing this sensitive information, Amira signals trust in Ben. This creates reciprocal trust - Ben knows she's sharing something valuable that could harm her if leaked.

### Step 8: Add Encrypted Attestation to Public XID

Amira can add the encrypted attestation to her public XID. Anyone can see she has a "sensitive attestation," but only Ben can read its contents:

👉
```sh
# Add encrypted attestation to XID
UNWRAPPED_XID=$(envelope assertion add pred-obj string "sensitiveAttestation" envelope "$SENSITIVE_ENCRYPTED" "$UNWRAPPED_XID")

echo "XID with encrypted attestation:"
envelope format "$UNWRAPPED_XID"
```

🔎
```
XID(e94de728) [
    "attestation": {...} [...]
    "sensitiveAttestation": ENCRYPTED [
        'hasRecipient': SealedMessage
    ]
    'key': PublicKeys(...) [...]
]
```

The public can see:
- BRadvoc8 has attestations (visible)
- BRadvoc8 has a sensitive attestation (visible but unreadable)
- The content is encrypted for someone (Ben, but they don't know who)

Only Ben can see:
- The actual CivilTrust connection
- The specific work Amira did
- Why this information is sensitive

### Understanding When to Use Permits

**Use Elision when**:
- Information is simply "not relevant" for an audience
- No harm if someone sees "ELIDED" placeholder
- Example: Eliding your private keys (everyone knows you have them)

**Use Encryption (Permits) when**:
- Information reveals identity or sensitive connections
- Even knowing "something is hidden" could be harmful
- You want specific people to access specific information
- Example: Project work that could expose legal identity

**The CivilTrust Pattern**:
1. Create attestation about sensitive work
2. Sign it (proves authenticity)
3. Encrypt for specific recipient (controls access)
4. Add to public XID (discoverable but protected)
5. Recipient decrypts (validates your credentials)

This pattern lets Amira prove her credentials to people who need to know, while protecting her identity from the general public.

---

## Part III: Wrap-Up

### Save Your Work

👉
```sh
# Create output directory with timestamp
OUTPUT_DIR="output/xid-tutorial04-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save XID with all attestations
echo "$UNWRAPPED_XID" > "$OUTPUT_DIR/$XID_NAME-xid-with-attestations.envelope"
envelope format "$UNWRAPPED_XID" > "$OUTPUT_DIR/$XID_NAME-xid-with-attestations.format"

# Save attestation keys for later use
echo "$ATTESTATION_PRVKEYS" > "$OUTPUT_DIR/$XID_NAME-attestation-prvkeys.envelope"
echo "$ATTESTATION_PUBKEYS" > "$OUTPUT_DIR/$XID_NAME-attestation-pubkeys.envelope"

# Save encrypted attestation separately
echo "$SENSITIVE_ENCRYPTED" > "$OUTPUT_DIR/sensitive-attestation-for-ben.envelope"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
```

### Understanding What Happened

You've learned to make credible claims about yourself and protect sensitive ones:

**1. Fair Witness Methodology**
- Make specific, factual claims (not opinions or vague assertions)
- Acknowledge limitations honestly
- Provide context that can be verified through work

**2. Self-Attestations**
- Signed statements proving YOU made the claim
- Foundation for trust (not proof of truth)
- Building blocks for progressive trust

**3. Sensitive Attestations with Permits**
- Some credentials would reveal your identity
- Public-key encryption protects sensitive information
- Selective sharing with specific recipients

**4. The Trust Foundation**
- Multiple consistent attestations show coherent identity
- Evidence hints provide verification paths
- Protected credentials can be revealed selectively

---

## What's Next

You've learned to make credible claims about yourself:
- Public self-attestations using fair witness methodology
- Sensitive attestations protected with public-key permits
- Selective sharing with specific recipients (Ben)

**But there's a gap**: Self-attestations prove you MADE the claim - not that it's TRUE. Anyone can claim "8 years of security experience." How do others know to believe you?

**Coming in Tutorial 05: Peer Endorsements**

The answer is external validation. When others vouch for you:
- Charlene can endorse your character and values
- Code reviewers can validate your technical skills
- Multiple endorsers create a **web of trust**

Self-attestation + Peer endorsement = Credible reputation

> **The Key Insight**: Tutorial 04 taught you to make claims. Tutorial 05 teaches you to get them validated.

---

## Key Terminology

> **Self-Attestation** - A signed statement you make about yourself, proving you made the claim but not that it's true
>
> **Fair Witness Methodology** - Making only factual, specific, verifiable claims rather than opinions or vague assertions
>
> **Progressive Trust** - Trust that builds gradually through consistent claims, demonstrated work, and accumulated endorsements
>
> **Public-Key Permit** - Encrypting data for a specific recipient using their public key
>
> **Sensitive Attestation** - An attestation that could reveal identity or other private information if published publicly
>
> **Identity Revelation Problem** - The risk that certain claims could be cross-referenced to reveal your legal identity

---

## Common Questions

### Q: Why separate attestation keys from XID keys?

**A:** Key separation provides flexibility and security. Your XID signing key is your core identity - using it for every attestation increases exposure. Dedicated attestation keys can be rotated or revoked without affecting your core identity.

### Q: Can I encrypt attestations for multiple recipients?

**A:** Yes! You can add multiple `--recipient` flags when encrypting. Each recipient can decrypt independently using their private key. Useful when sharing credentials with multiple evaluators.

### Q: What if Ben shares my decrypted attestation?

**A:** This is a trust decision. By encrypting for Ben, you're trusting him with that information. The encryption prevents public discovery, but once decrypted, Ben could share it. Choose recipients carefully based on trust level.

### Q: Should I include all my attestations in my public XID?

**A:** Include attestations appropriate for your public profile. Sensitive ones can be encrypted (as shown) or kept separate and shared only when needed. Progressive disclosure means revealing more as trust develops.

---

## Exercises

1. **Create Self-Attestations**: Make 3-5 self-attestations about your own skills using fair witness methodology
2. **Practice Encryption**: Create an encrypted attestation for a fictional recipient
3. **Analyze Your Claims**: Review your attestations - are they specific, factual, and verifiable?
4. **Plan Your Profile**: Identify which of your credentials would need protection vs public sharing

## Example Script

A complete working script implementing this tutorial is available at `tests/04-self-attestations-TEST.sh`. Run it to see all steps in action:

```sh
bash tests/04-self-attestations-TEST.sh
```

This script creates self-attestations, encrypts sensitive attestations, and builds the foundation for your public participation profile.

---

**Next Tutorial**: [Peer Endorsements & Web of Trust](05-peer-endorsements.md) - Get others to validate your claims and build a web of trust.
