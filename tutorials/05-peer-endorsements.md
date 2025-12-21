# Tutorial 05: Peer Endorsements & Web of Trust

Transform "I say I'm good" into "others agree I'm good" through peer endorsements. Learn to request, collect, and verify endorsements that create a web of trust around your pseudonymous identity.

**Time to complete**: ~55-60 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-04

> **Related Concepts**: After completing this tutorial, explore [Public Participation Profiles](../concepts/public-participation-profiles.md) and [Web of Trust](../concepts/web-of-trust.md) to deepen your understanding.

## Prerequisites

- Completed Tutorial 01 (Creating Your First XID)
- Completed Tutorial 02 (Building Your Persona)
- Completed Tutorial 03 (Publishing for Discovery)
- Completed Tutorial 04 (Self-Attestations & Selective Sharing)
- The `envelope` CLI tool installed
- Your XID artifacts from Tutorial 04
- Basic understanding of cryptographic signatures

## What You'll Learn

- The difference between attestations (your claims) and endorsements (others' validation)
- How to request endorsements from collaborators
- How to verify endorsements cryptographically
- How to build a **web of trust** through multiple independent endorsers
- How **relationship transparency** makes endorsements more valuable
- How to establish pseudonymous reputation without revealing legal identity

## Building on Tutorial 04

| Tutorial 04 | Tutorial 05 |
|-------------|-------------|
| Claims YOU make about yourself | Claims OTHERS make about you |
| Self-attestations | Peer endorsements |
| "I say I have 8 years experience" | "Others confirm my skills" |
| Foundation for trust | Validation of trust |

**The Bridge**: Your self-attestations establish what you claim. Peer endorsements validate those claims through independent third parties who have worked with you.

---

## Amira's Challenge: Getting Validated

In Tutorial 04, Amira (as BRadvoc8) created self-attestations about her skills and protected sensitive credentials with encryption. But there's a fundamental problem:

**Self-attestations only prove you MADE the claim - not that it's true.**

Anyone can claim "8 years of security experience." Project managers evaluating contributors need more than claims - they need validation from people who have actually worked with BRadvoc8.

**The solution**: Peer endorsements. When Charlene (who knows Amira's values) and code reviewers (who've seen her work) vouch for her, it transforms unverified claims into validated reputation.

**The key distinction**:
- **Attestations** = signed with YOUR keys (you made the claim)
- **Endorsements** = signed with THEIR keys (they stake their reputation on you)

This tutorial teaches how to request, collect, and verify peer endorsements that build a credible public participation profile.

---

## Part I: Personal Endorsement from Charlene

Self-attestations establish your claims, but peer endorsements add independent validation. When someone else vouches for you, it transforms "I say I'm good" into "others agree I'm good."

Amira's friend Charlene, who introduced her to the RISK network concept in Tutorial 01, can provide a personal endorsement of Amira's character and commitment to social impact work. This isn't a technical endorsement (Charlene isn't a developer), but a character reference from someone who knows Amira's values and motivations.

**Key distinction**: Endorsements come from others, signed with their keys, not yours. This makes them independent third-party validation.

### Step 1: Load Your Tutorial 04 Artifacts

First, load the XID with attestations from Tutorial 04:

👉
```sh
# Create output directory
mkdir -p output

# Find the most recent Tutorial 04 output directory
TUTORIAL_04_DIR=$(find output/xid-tutorial04* -type d 2>/dev/null | sort -r | head -1)

if [ -z "$TUTORIAL_04_DIR" ]; then
    echo "No Tutorial 04 output found. Run tests/04-self-attestations-TEST.sh first."
    exit 1
fi

# Load the XID with attestations from Tutorial 04
UNWRAPPED_XID=$(cat "$TUTORIAL_04_DIR/BRadvoc8-xid-with-attestations.envelope")
PASSWORD="Amira's strong password"
XID_NAME=BRadvoc8

# Extract XID identifier
XID_ID=$(envelope xid id "$UNWRAPPED_XID" 2>/dev/null || echo "ur:xid/placeholder")

echo "Loaded XID with attestations from: $TUTORIAL_04_DIR"
echo "XID: $XID_ID"
```

> **Building on Tutorial 04**: Your XID now has self-attestations about your skills. Now you'll add endorsements from others who can validate those claims.

### Step 2: Create Charlene's Identity

Before Charlene can endorse BRadvoc8, she needs her own XID. Let's create it:

👉
```sh
# Generate Charlene's key pair
envelope generate prvkeys > output/charlene.prvkeys
CHARLENE_PRVKEYS=$(cat output/charlene.prvkeys)
CHARLENE_PUBKEYS=$(envelope generate pubkeys "$CHARLENE_PRVKEYS")
echo "$CHARLENE_PUBKEYS" > output/charlene.pubkeys

# Create Charlene's XID
CHARLENE_XID=$(envelope xid new --nickname "Charlene" "$CHARLENE_PUBKEYS")
CHARLENE_XID=$(envelope assertion add pred-obj string "role" string "Community organizer and RISK network advocate" "$CHARLENE_XID")
CHARLENE_XID=$(envelope assertion add pred-obj string "focus" string "Connecting developers with social impact projects" "$CHARLENE_XID")

echo "$CHARLENE_XID" > output/charlene-xid.envelope
CHARLENE_XID_ID=$(envelope xid id "$CHARLENE_XID")

echo "Charlene's XID:"
envelope format "$CHARLENE_XID"
```

🔎
```console
XID(a1b2c3d4) [
    "focus": "Connecting developers with social impact projects"
    "role": "Community organizer and RISK network advocate"
    'key': PublicKeys(...) [
        'allow': 'All'
        'nickname': "Charlene"
    ]
]
```

### Step 3: Request an Endorsement

Before someone can endorse you, you typically need to request it. Let's model this exchange.

👉
```sh
# Create the request
REQUEST=$(envelope subject type string "Endorsement request from BRadvoc8")
REQUEST=$(envelope assertion add pred-obj known isA string "EndorsementRequest" "$REQUEST")
REQUEST=$(envelope assertion add pred-obj string "requestedFrom" string "Charlene" "$REQUEST")
REQUEST=$(envelope assertion add pred-obj string "requestedBy" string "$XID_ID" "$REQUEST")
REQUEST=$(envelope assertion add pred-obj string "context" string "Character reference for open source participation" "$REQUEST")
REQUEST=$(envelope assertion add pred-obj string "relationship" string "Friend who introduced me to RISK network concept" "$REQUEST")

echo "$REQUEST" > output/endorsement-request-to-charlene.envelope
envelope format "$REQUEST"
```

🔎
```console
"Endorsement request from BRadvoc8" [
    isA: "EndorsementRequest"
    "context": "Character reference for open source participation"
    "relationship": "Friend who introduced me to RISK network concept"
    "requestedBy": "ur:xid/hdcx..."
    "requestedFrom": "Charlene"
]
```

### Understanding Endorsement Requests

An endorsement request is optional but good practice. It:
- **Provides context** - explains why you're asking for endorsement
- **Clarifies relationship** - establishes basis for endorsement
- **Sets scope** - indicates what kind of endorsement is appropriate
- **Shows respect** - acknowledges endorser's time and reputation stake

In real-world use, you'd share this request with the potential endorser. They'd review it, decide whether to endorse, and create their endorsement based on what they can honestly attest to.

### Step 4: Charlene Creates Her Endorsement

Charlene reviews Amira's request and decides to provide a character endorsement based on their friendship and Amira's expressed commitment to social impact work.

👉
```sh
# Create the endorsement subject
ENDORSEMENT=$(envelope subject type string "BRadvoc8 is a thoughtful and committed contributor to privacy and security work that protects vulnerable communities")

# Mark it as a peer endorsement
ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$ENDORSEMENT")

# Add endorsement metadata
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "Charlene" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2025-11-20T00:00:00Z" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$ENDORSEMENT")

# Add context about the endorsement basis
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Personal friend, observed values and commitment over 2+ years" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Character and values alignment, not technical skills" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Friend who introduced BRadvoc8 to RISK network concept" "$ENDORSEMENT")

# Charlene signs the endorsement with her private key
ENDORSEMENT_SIGNED=$(envelope sign --signer "$CHARLENE_PRVKEYS" "$ENDORSEMENT")

# Add Charlene's XID to the signed endorsement for verifiability
ENDORSEMENT_SIGNED=$(envelope assertion add pred-obj string "endorserXID" string "$CHARLENE_XID_ID" "$ENDORSEMENT_SIGNED")

echo "$ENDORSEMENT_SIGNED" > output/endorsement-from-charlene.envelope
echo "Charlene's endorsement:"
envelope format "$ENDORSEMENT_SIGNED"
```

🔎
```console
{
    "BRadvoc8 is a thoughtful and committed contributor to privacy and security work that protects vulnerable communities" [
        isA: "PeerEndorsement"
        "endorsedBy": "Charlene"
        "endorsedOn": 2025-11-20T00:00:00Z"
        "endorsementContext": "Personal friend, observed values and commitment over 2+ years"
        "endorsementScope": "Character and values alignment, not technical skills"
        "endorsementTarget": "ur:xid/hdcx..."
        "relationshipBasis": "Friend who introduced BRadvoc8 to RISK network concept"
    ]
} [
    "endorserXID": "ur:xid/hdcxa1b2c3d4..."
    'signed': Signature
]
```

### Why Relationship Transparency Matters

The `"relationshipBasis"` assertion is one of the most valuable parts of this endorsement. Here's why:

**From the evaluator's perspective** (Ben, RISK members, other projects):

When someone reads "Charlene endorses BRadvoc8," they immediately wonder:
- How well does Charlene actually know BRadvoc8?
- What's her basis for making this judgment?
- Is there potential bias in this relationship?

**Relationship context answers these questions**:
- `"Friend who introduced BRadvoc8 to RISK network"` - specific relationship with clear context
- `"Personal friend, observed values and commitment over 2+ years"` - substantial time to observe consistency
- `"Character and values, not technical"` - honest about what's being endorsed

**Compare weak vs strong relationship disclosure**:

**Weak**: "I endorse BRadvoc8" (no relationship context)
- Evaluator doesn't know: How do they know each other? Why is this endorser qualified to judge?
- The endorsement has little value because its basis is unclear

**Strong**: "I endorse BRadvoc8's character and values. Relationship: friend for 2+ years, observed commitment to privacy work, introduced her to RISK network"
- Evaluator knows: Length of relationship (2+ years), what was observed (commitment to privacy), specific interactions (RISK introduction)
- The endorsement is meaningful because the basis is clear

**The principle**: Endorsement value comes from context. Without relationship transparency, even strong endorsements lose credibility because evaluators can't assess the endorser's basis for judgment.

**Examples of relationship contexts**:
- "Colleague for 3 years, worked together on 12 security audits"
- "Code reviewer for 8 pull requests over 6 months"
- "Friend for 2+ years, observed values alignment" (Charlene's case)
- "Client who hired for privacy consultation in 2024"

Each gives evaluators different information about how the endorser knows the person and why their endorsement matters.

### Understanding Peer Endorsements

Notice the key differences between self-attestations and peer endorsements:

**Peer Endorsement Characteristics:**
1. **Third-party signature** - signed with Charlene's key, not Amira's
2. **Endorser identity** - includes Charlene's XID for verification
3. **Relationship context** - explains basis for endorsement
4. **Scope limitations** - clarifies what is/isn't being endorsed
5. **Independent validation** - Charlene stakes her reputation

**Why this matters**: When someone else signs an endorsement, they're putting their own reputation at stake. If Charlene endorses someone dishonest, it damages her credibility too. This mutual accountability creates real trust.

**Endorsement scope**: Charlene explicitly limits her endorsement to character and values, not technical skills. This honesty about limitations actually increases trust - it shows thoughtful assessment, not blanket approval.

### Step 5: Verify Charlene's Endorsement

Now Amira (or anyone else) can verify that this endorsement actually came from Charlene and hasn't been tampered with.

👉
```sh
# Verify using Charlene's public keys
envelope verify --verifier "$CHARLENE_PUBKEYS" "$ENDORSEMENT_SIGNED"
```

🔎
```console
Signature valid
```

The verified signature proves:
- This endorsement was signed by Charlene (controller of her private key)
- The endorsement content hasn't been modified
- Charlene actually made this statement about BRadvoc8

This is significantly more trustworthy than a self-attestation because:
1. **Independent party** - Charlene isn't Amira
2. **Reputation stake** - Charlene risks her credibility
3. **Verifiable** - anyone can check Charlene's signature
4. **Context provided** - relationship and scope are clear

Now let's add this endorsement to Amira's XID.

👉
```sh
UNWRAPPED_XID=$(envelope assertion add pred-obj string "endorsement" envelope "$ENDORSEMENT_SIGNED" "$UNWRAPPED_XID")
echo "$UNWRAPPED_XID" > output/amira-xid-with-charlene-endorsement.envelope

echo "XID with Charlene's endorsement added"
```

### Understanding Endorsement Value

Charlene's endorsement adds significant value to BRadvoc8's profile:

**Trust elevation**:
- Before: "I claim to care about social impact work" (self-attestation)
- After: "Charlene confirms I care about social impact work" (peer endorsement)

**Verifiable relationship**:
- Endorsement establishes Charlene knows BRadvoc8 over 2+ years
- Relationship context (friend, RISK introduction) provides basis
- Scope limitations (character, not technical) show honest assessment

**Progressive trust path**:
- Self-attestations: "Here's what I claim about myself"
- Personal endorsement: "Here's what a friend who knows me confirms"
- Next step: Technical endorsements from collaborators

**Network effects**:
- If others trust Charlene, they can extend some trust to BRadvoc8
- Charlene's credibility partially transfers through the endorsement
- Web of trust begins to form around BRadvoc8's identity

But one endorsement isn't enough. To build robust reputation, BRadvoc8 needs multiple independent endorsements from different contexts. That's where technical peer endorsements come in - validation from people who've actually worked with her code.

---

## Part II: Technical Peer Endorsements

Character endorsements establish values alignment, but technical endorsements validate actual skills. As BRadvoc8 contributes to open source projects, collaborators who review her code can endorse her technical abilities.

This creates a **web of trust**: multiple independent endorsers, each validating different aspects of BRadvoc8's capabilities. The more diverse the endorsers and contexts, the stronger the reputation.

### Step 6: Collect Endorsement from Code Reviewer

Let's simulate BRadvoc8 receiving an endorsement from a code reviewer who examined her security contributions to an open source project.

👉
```sh
# Generate reviewer's key pair
envelope generate prvkeys > output/reviewer.prvkeys
REVIEWER_PRVKEYS=$(cat output/reviewer.prvkeys)
REVIEWER_PUBKEYS=$(envelope generate pubkeys "$REVIEWER_PRVKEYS")

# Create reviewer's XID
REVIEWER_XID=$(envelope xid new --nickname "DevReviewer" "$REVIEWER_PUBKEYS")
REVIEWER_XID=$(envelope assertion add pred-obj string "role" string "Open source code reviewer and security consultant" "$REVIEWER_XID")
REVIEWER_XID=$(envelope assertion add pred-obj string "focus" string "Security code reviews for privacy-focused projects" "$REVIEWER_XID")

echo "$REVIEWER_XID" > output/reviewer-xid.envelope
REVIEWER_XID_ID=$(envelope xid id "$REVIEWER_XID")
```

👉
```sh
# Create endorsement about BRadvoc8's code quality
TECH_ENDORSEMENT=$(envelope subject type string "BRadvoc8 writes secure, well-tested code with clear attention to privacy-preserving patterns")

TECH_ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "DevReviewer" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2025-11-20T00:00:00Z" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$TECH_ENDORSEMENT")

# Technical context
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Reviewed 8 pull requests for privacy-focused authentication system" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Code quality, security practices, privacy patterns" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Code reviewer for open source project contributions" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "specificSkills" string "Cryptographic implementations, secure data handling, comprehensive testing" "$TECH_ENDORSEMENT")

# Sign with reviewer's key
TECH_ENDORSEMENT_SIGNED=$(envelope sign --signer "$REVIEWER_PRVKEYS" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT_SIGNED=$(envelope assertion add pred-obj string "endorserXID" string "$REVIEWER_XID_ID" "$TECH_ENDORSEMENT_SIGNED")

echo "$TECH_ENDORSEMENT_SIGNED" > output/endorsement-from-reviewer.envelope
envelope format "$TECH_ENDORSEMENT_SIGNED"
```

🔎
```console
{
    "BRadvoc8 writes secure, well-tested code with clear attention to privacy-preserving patterns" [
        isA: "PeerEndorsement"
        "endorsedBy": "DevReviewer"
        "endorsedOn": 2025-11-20T00:00:00Z
        "endorsementContext": "Reviewed 8 pull requests for privacy-focused authentication system"
        "endorsementScope": "Code quality, security practices, privacy patterns"
        "endorsementTarget": "ur:xid/hdcx..."
        "relationshipBasis": "Code reviewer for open source project contributions"
        "specificSkills": "Cryptographic implementations, secure data handling, comprehensive testing"
    ]
} [
    "endorserXID": "ur:xid/..."
    'signed': Signature
]
```

This endorsement is more valuable than Charlene's because:
- **Technical validation** - assesses actual code, not just character
- **Specific skills** - identifies concrete technical capabilities
- **Work evidence** - based on reviewing actual pull requests
- **Domain expertise** - endorser has technical credibility to assess code

### Step 7: Collect Additional Endorsements

Robust reputation requires multiple independent endorsers. Let's add another technical endorsement from a different context.

👉
```sh
# Generate maintainer's key pair
envelope generate prvkeys > output/maintainer.prvkeys
MAINTAINER_PRVKEYS=$(cat output/maintainer.prvkeys)
MAINTAINER_PUBKEYS=$(envelope generate pubkeys "$MAINTAINER_PRVKEYS")

# Create maintainer's XID
MAINTAINER_XID=$(envelope xid new --nickname "SecurityMaintainer" "$MAINTAINER_PUBKEYS")
MAINTAINER_XID=$(envelope assertion add pred-obj string "role" string "Maintainer of open source security tools" "$MAINTAINER_XID")
MAINTAINER_XID=$(envelope assertion add pred-obj string "focus" string "Privacy-preserving cryptographic libraries" "$MAINTAINER_XID")

echo "$MAINTAINER_XID" > output/maintainer-xid.envelope
MAINTAINER_XID_ID=$(envelope xid id "$MAINTAINER_XID")
```

👉
```sh
# Create endorsement about collaboration
COLLAB_ENDORSEMENT=$(envelope subject type string "BRadvoc8 is a reliable contributor who delivers high-quality security enhancements and responds constructively to feedback")

COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "SecurityMaintainer" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2025-11-20T00:00:00Z" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$COLLAB_ENDORSEMENT")

# Collaboration context
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Collaborated on 3 security features over 6 months" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Technical skills, collaboration quality, communication" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Project maintainer who merged BRadvoc8's contributions" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "specificStrengths" string "Security-first design thinking, thorough documentation, patient collaboration" "$COLLAB_ENDORSEMENT")

# Sign with maintainer's key
COLLAB_ENDORSEMENT_SIGNED=$(envelope sign --signer "$MAINTAINER_PRVKEYS" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT_SIGNED=$(envelope assertion add pred-obj string "endorserXID" string "$MAINTAINER_XID_ID" "$COLLAB_ENDORSEMENT_SIGNED")

echo "$COLLAB_ENDORSEMENT_SIGNED" > output/endorsement-from-maintainer.envelope
```

👉
```sh
# Add both technical endorsements to XID
UNWRAPPED_XID=$(envelope assertion add pred-obj string "endorsement" envelope "$TECH_ENDORSEMENT_SIGNED" "$UNWRAPPED_XID")
UNWRAPPED_XID=$(envelope assertion add pred-obj string "endorsement" envelope "$COLLAB_ENDORSEMENT_SIGNED" "$UNWRAPPED_XID")

echo "$UNWRAPPED_XID" > output/amira-xid-with-all-endorsements.envelope
```

### Step 8: Verify the Endorsement Chain

With multiple endorsements, BRadvoc8 now has a **web of trust**. Let's verify all endorsements to demonstrate the complete trust chain.

👉
```sh
echo "Verifying BRadvoc8's endorsement chain:"
echo "=========================================="

# Count endorsements
ENDORSEMENT_COUNT=$(envelope assertion find predicate string "endorsement" "$UNWRAPPED_XID" | wc -l | tr -d ' ')
echo "Found $ENDORSEMENT_COUNT endorsements"
echo ""

# Verify Charlene's endorsement
echo "1. Charlene's endorsement:"
envelope verify --verifier "$CHARLENE_PUBKEYS" "$ENDORSEMENT_SIGNED"
echo "   Context: Character and values (friend)"
echo ""

# Verify DevReviewer's endorsement
echo "2. DevReviewer's endorsement:"
envelope verify --verifier "$REVIEWER_PUBKEYS" "$TECH_ENDORSEMENT_SIGNED"
echo "   Context: Technical skills (code reviewer)"
echo ""

# Verify SecurityMaintainer's endorsement
echo "3. SecurityMaintainer's endorsement:"
envelope verify --verifier "$MAINTAINER_PUBKEYS" "$COLLAB_ENDORSEMENT_SIGNED"
echo "   Context: Collaboration quality (project maintainer)"
echo ""

echo "=========================================="
echo "All endorsements verified"
```

🔎
```console
Verifying BRadvoc8's endorsement chain:
==========================================
Found 3 endorsements

1. Charlene's endorsement:
Signature valid
   Context: Character and values (friend)

2. DevReviewer's endorsement:
Signature valid
   Context: Technical skills (code reviewer)

3. SecurityMaintainer's endorsement:
Signature valid
   Context: Collaboration quality (project maintainer)

==========================================
All endorsements verified
```

### Understanding the Web of Trust

BRadvoc8 now has a robust **public participation profile** with multiple independent validators:

**Endorsement diversity**:
1. **Charlene** - personal friend, validates character and values
2. **DevReviewer** - code reviewer, validates technical quality
3. **SecurityMaintainer** - project maintainer, validates collaboration

**Trust multiplication**:
- One endorsement: "Maybe trustworthy"
- Three independent endorsements: "Likely trustworthy"
- Three endorsements from different contexts: "Highly trustworthy"

**Verification chain**:
- Each endorsement is cryptographically signed (can't be forged)
- Each endorser has their own XID (identity persistence)
- Each endorsement includes context (relationship transparency)
- All signatures can be independently verified (public accountability)

**Network effects**:
- If you trust any of the endorsers, you can extend partial trust to BRadvoc8
- If you trust multiple endorsers, confidence compounds
- If endorsers themselves have endorsements, trust propagates through the network

**Progressive reputation**:
- Started with zero reputation (unknown pseudonym)
- Added self-attestations (claims about skills)
- Gathered personal endorsement (character validation)
- Collected technical endorsements (skill validation)
- **Result**: Established reputation for meaningful contribution

This is how pseudonymous trust works: cryptographically verifiable endorsements from multiple independent parties create a reputation that's both trustworthy and privacy-preserving.

### Evaluating Endorser Credibility

When assessing endorsements, evaluators consider:

1. **Endorser identity**: Who are they? What's their expertise?
2. **Relationship context**: How do they know the endorsed person?
3. **Endorsement scope**: What specifically are they endorsing?
4. **Endorser limitations**: What are they NOT endorsing?
5. **Endorser reputation**: Do others trust this endorser?

**Critical thinking required**:
- Three endorsements from unknown people != strong reputation
- Three endorsements from established community members = strong signal
- Endorsement without context ("BRadvoc8 is great!") = low value
- Endorsement with specific evidence ("reviewed 8 PRs, all high quality") = high value

**Reputation is recursive**:
- Endorsements are only as valuable as the endorsers' own reputations
- Endorsers stake their credibility when they endorse
- This creates mutual accountability throughout the web of trust

---

## Part III: Understanding Public Participation Profiles

Now that you've built a complete trust profile, let's understand how it all fits together and how to use it effectively.

### The Attestation vs Endorsement Model

**Attestations** and **endorsements** serve different purposes in trust building:

| Aspect | Self-Attestation | Peer Endorsement |
|--------|------------------|------------------|
| **Signer** | You (your private key) | Others (their private keys) |
| **Content** | Claims about yourself | Claims others make about you |
| **Trust level** | Baseline (anyone can claim anything) | Higher (third-party validation) |
| **Purpose** | Set expectations, establish claims | Validate claims, transfer trust |
| **Verification** | Proves you made the claim | Proves they endorse you |
| **Value** | Foundation for trust | Amplification of trust |

**When to use each**:
- **Self-attestations**: Skills, experience, values, availability, interests
- **Peer endorsements**: Work quality, collaboration, character, technical abilities

**Best practice**: Start with self-attestations (what you claim), then gather endorsements (what others confirm).

### Progressive Trust in Pseudonymous Contexts

Trust doesn't happen instantly - it builds through stages:

**Stage 1: Initial Claims (Self-Attestation)**
- Make specific, verifiable claims about your skills
- Provide context (domains, experience level, focus areas)
- Commit to evidence you can reveal later
- Set baseline expectations

**Stage 2: Demonstrated Work (Evidence)**
- Contribute to projects (code, documentation, reviews)
- Build public track record (GitHub activity, commits, PRs)
- Show consistency over time
- Let work speak for itself

**Stage 3: Peer Validation (Endorsements)**
- Request endorsements from collaborators
- Gather endorsements from different contexts
- Build diverse endorsement network
- Create web of trust

**Stage 4: Reputation Establishment**
- Multiple independent endorsers
- Endorsements across different skill areas
- Long-term track record
- Community recognition

**The key insight**: Each stage builds on the previous. Self-attestations alone aren't enough, but they're the necessary starting point. Endorsements without demonstrated work lack credibility. Trust is progressive, not instant.

### Building Reputation Without Legal Identity

Pseudonymous reputation is possible because:

1. **Cryptographic Identity** - Your XID provides persistent identity through public key cryptography
2. **Verifiable Claims** - Digital signatures prove who made what claims
3. **Independent Validation** - Multiple endorsers provide triangulated trust
4. **Work Evidence** - Public contributions validate claimed skills
5. **Relationship Transparency** - Endorsement context shows basis for trust
6. **Network Effects** - Trust propagates through endorsement chains

**What you don't need**:
- Legal name or real identity
- Institutional credentials (degrees, certifications)
- Employment history or CV
- Government-issued ID
- Email addresses tied to legal identity

**What you do need**:
- Consistent pseudonymous identity (XID)
- Demonstrable skills through actual work
- Honest claims about capabilities and limitations
- Relationships with other community members
- Patience to build trust progressively

### Privacy Considerations

**What to share**:
- Technical skills and domains
- General experience level (years, not dates/places)
- Values and motivations for contribution
- Examples of work (code samples, contributions)
- Relationship contexts (how you know endorsers)

**What to protect**:
- Legal name or real-world identity
- Specific employment history or employers
- Geographic location or timezone
- Unique identifying characteristics
- Connections between pseudonym and real identity

**Balance**:
- Share enough to build trust
- Protect what needs to remain private
- Use progressive disclosure (reveal more as trust grows)
- Maintain context separation (different pseudonyms for different domains if needed)

---

## Part IV: Wrap-Up

### Save Your Work

👉
```sh
# Create output directory with timestamp
OUTPUT_DIR="output/xid-tutorial05-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save XID with all endorsements
echo "$UNWRAPPED_XID" > "$OUTPUT_DIR/$XID_NAME-xid-with-endorsements.envelope"
envelope format "$UNWRAPPED_XID" > "$OUTPUT_DIR/$XID_NAME-xid-with-endorsements.format"

# Save individual endorsements
echo "$ENDORSEMENT_SIGNED" > "$OUTPUT_DIR/endorsement-charlene.envelope"
echo "$TECH_ENDORSEMENT_SIGNED" > "$OUTPUT_DIR/endorsement-devreviewer.envelope"
echo "$COLLAB_ENDORSEMENT_SIGNED" > "$OUTPUT_DIR/endorsement-securitymaintainer.envelope"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
```

### Next Steps for BRadvoc8

With an established public participation profile, Amira (as BRadvoc8) can now:

1. **Contribute meaningfully** - Apply to projects requiring trust
2. **Build on reputation** - Use endorsements to access higher-trust work
3. **Expand network** - Connect with new collaborators and communities
4. **Participate in RISK** - Join communities like RISK that align with her values
5. **Long-term impact** - Contribute to important work while maintaining safety

The reputation she's built is:
- **Portable** - follows her XID across projects
- **Verifiable** - anyone can check endorsements
- **Privacy-preserving** - no connection to legal identity
- **Resilient** - multiple independent validators
- **Growing** - can continue building over time

---

## What's Next

Amira now has a robust public participation profile with multiple endorsements validating her capabilities.

**In Future Tutorials:**
- **Tutorial 06**: Key Management - managing identity lifecycle (key rotation, profile updates, long-term maintenance)
- **Tutorial 07**: Gordian Clubs - joining collaborative communities using established reputation

**Advanced Topics to Explore:**
- Creating verifiable credentials on top of XIDs
- Building trust frameworks for specific domains
- Integrating XIDs with decentralized platforms
- Using provenance chains for identity evolution

---

## Key Terminology

> **Peer Endorsement** - A signed statement someone else makes about you, providing independent validation
>
> **Web of Trust** - Network of interconnected endorsements where trust propagates through relationships
>
> **Endorsement Chain** - Multiple independent endorsements that collectively establish reputation
>
> **Endorsement Scope** - Explicit limitations on what an endorsement does/doesn't cover
>
> **Relationship Transparency** - Explanation of how endorser knows the endorsed person, making endorsements more valuable
>
> **Public Participation Profile** - Collection of self-attestations, peer endorsements, and demonstrated work that establishes pseudonymous reputation
>
> **Reputation Portability** - Ability to carry reputation across projects through persistent XID

---

## Common Questions

### Q: How many endorsements do I need?

**A:** Quality matters more than quantity. Three strong endorsements from established community members with clear relationship context are worth more than ten vague endorsements from unknown people. Aim for diversity (different contexts) over volume.

### Q: What if an endorser later becomes disreputable?

**A:** Endorsements are point-in-time statements. If an endorser's reputation declines, you may want to gather new endorsements from other sources. The web of trust model means no single endorser is critical - diversify your endorsements.

### Q: Can I endorse others?

**A:** Yes! Endorsing others is valuable network behavior. Be thoughtful - only endorse what you can honestly attest to, include relationship context, and limit scope appropriately. Your endorsements affect your reputation too.

### Q: What if someone requests an endorsement I can't honestly give?

**A:** Decline gracefully. You can explain you don't have sufficient basis for endorsement, or offer to endorse a limited scope you can honestly support. Honest endorsements maintain network integrity.

---

## Exercises

1. **Design Endorsement Request**: Write a request for endorsement from a real collaborator
2. **Evaluate Trust**: Given multiple endorsements, practice assessing credibility based on context and scope
3. **Plan Your Profile**: Identify who could provide endorsements for different aspects of your work
4. **Analyze Real Profiles**: Look at GitHub profiles and identify implicit endorsements (PRs merged, code reviews approved)
5. **Create Endorsement**: Write an endorsement for a fictional collaborator using fair witness methodology

## Example Script

A complete working script implementing this tutorial is available at `tests/05-peer-endorsements-TEST.sh`. Run it to see all steps in action:

```sh
bash tests/05-peer-endorsements-TEST.sh
```

This script creates endorsement requests, simulates peer endorsements from multiple contexts, verifies signatures, and builds a complete web of trust.

---

**Next Tutorial**: [Key Management](06-key-management.md) - Manage your identity lifecycle (coming soon). Or skip to [Gordian Clubs](07-gordian-clubs.md) for group communications.
