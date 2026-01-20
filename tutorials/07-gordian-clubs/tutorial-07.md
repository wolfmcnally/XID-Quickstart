# Secure Group Communications with Gordian Clubs

This tutorial introduces Gordian Clubs, a system for publishing verified content to a controlled audience. Building on concepts from the previous tutorials, you'll learn how to create a "club" where a publisher can send cryptographically verified updates to members using permits and provenance chains.

**Time to complete: 45-60 minutes**

> **Related Concepts**: This tutorial builds on [Tutorial 01 (XIDs)](../01-your-first-xid/tutorial-01.md), [Tutorial 02 (Building Your Persona)](../03-building-persona/tutorial-03.md), [Tutorial 03 (Publishing for Discovery)](../04-publishing-discovery/tutorial-04.md), [Tutorial 04 (Self-Attestations)](../06-self-attestations/tutorial-06.md), and [Tutorial 05 (Peer Endorsements)](../05-peer-endorsements/tutorial-05.md). Familiarity with XIDs, permits, envelope encryption, and attestations is recommended.

## Prerequisites

- Basic terminal/command line familiarity
- Completion of Tutorials 01-05 (understanding of XIDs, persona building, publishing, self-attestations, and peer endorsements)
- Tutorial 06 (Key Management) recommended but not required - coming soon
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 0.23.0 or later)
- The [Provenance Mark CLI](https://github.com/BlockchainCommons/bc-provenance-mark-cli-rust) tool installed
- The [Gordian Clubs CLI](https://github.com/BlockchainCommons/clubs-cli-rust) tool installed

> **Note on SSKR**: This tutorial introduces SSKR (Sharded Secret Key Recovery) for club content recovery. Tutorial 06 (Key Management) will cover personal SSKR key backup in detail. For now, we'll explain SSKR concepts as needed.

## What You'll Learn

- How to create a secure "club" for group communications
- How to publish content with cryptographic provenance
- How to create permits for specific recipients (public-key encryption)
- How to use SSKR (Sharded Secret Key Recovery) for disaster recovery
- How to maintain cryptographic chains across multiple editions
- How to verify edition authenticity and sequence continuity

## Amira's Story Continues: Joining RISK Communications

After successfully creating her pseudonymous identity (Tutorial 01), building her persona (Tutorial 02), publishing for discovery (Tutorial 03), making credible claims through self-attestations (Tutorial 04), and building a web of trust through peer endorsements (Tutorial 05), Amira has officially joined RISK, the network connecting developers with social impact projects.

Now as a RISK member, Amira will receive updates through the network's **secure internal communications** system. Charlene, RISK's coordinator, has explained why they don't use traditional platforms like Slack or Discord—they need communications that won't disappear if a platform changes its terms of service or a government pressures the hosting company. RISK sends updates to its member network about new projects, security guidelines, and coordination details. These updates must be:

1. **Authentically from RISK** - Members need to verify updates are genuinely from the coordinators
2. **Private to members only** - Non-members shouldn't be able to read the content
3. **Individually addressable** - Each member should have their own access permit
4. **Recoverable** - If permits are lost, there should be a recovery mechanism
5. **Historically verifiable** - Members should be able to verify the sequence and continuity of updates

This is where **Gordian Clubs** come in - a cryptographic system designed exactly for this use case.

## The Platform Problem: When Infrastructure Fails You

Amira remembers a story that Charlene shared about her graduate program at Bainbridge. The school had developed sophisticated knowledge management using del.icio.us for collaborative bookmarking and Google Reader for information discovery. Students used these tools to collectively manage the massive information flows of their sustainable business program—not because the school forced them, but because it worked remarkably well.

Then the cascade began. In 2011, Yahoo sold del.icio.us, and the new owners removed the collaborative features that made it powerful. In 2013, Google abruptly shut down Reader. An entire learning community's coordination infrastructure collapsed overnight. Not because of malice. Not because users did anything wrong. Because platforms made business decisions that destroyed what communities had built together.

This is the pattern RISK wants to avoid. If they use Slack, Discord, or email lists for their sensitive coordination work:
- **Platform control**: Access can be revoked, features removed, terms changed
- **Company survival**: If the company fails or sells, the infrastructure disappears
- **Political pressure**: Platforms can be forced to comply with government requests, hand over data, or restrict access
- **Network location**: Servers in one country can be raided; hosting can be blocked
- **Vendor lock-in**: Years of history and coordination trapped in proprietary formats

**What RISK needs is infrastructure that can't fail them**—no servers that can be shut down, no company whose survival matters, no administrators who can be pressured, no platform that can change its mind about serving their use case.

This is what **autonomous infrastructure** means: group communication as a mathematical right, not a corporate privilege.

Fifteen years ago, Bitcoin proved this pattern works for value transfer. You can verify transactions, prove ownership, and transfer value without depending on any bank, payment processor, or company. The network persists even when governments try to ban it. Self-custody protects funds even when exchanges are hacked.

Gordian Clubs apply the same architectural principles to group coordination. Just as Bitcoin gave us autonomous value transfer, Gordian Clubs provide **autonomous group communication**—infrastructure that works with or without internet access, survives across decades, and can't be taken away through platform decisions or political pressure.

**This is what sovereignty looks like: the power to coordinate can't be revoked.**

## Why Gordian Clubs Matter

Gordian Clubs provide a publisher-subscriber model with cryptographic guarantees that go beyond traditional mailing lists or group chat systems:

1. **Cryptographic Provenance** - Every edition is cryptographically linked to previous editions through a provenance chain, creating a tamper-evident record of all publications.

2. **Publisher Verification** - Members can verify that editions genuinely come from the publisher using cryptographic signatures, not just trust in a platform.

3. **Permit-Based Access** - Each member receives a unique permit encrypted with their public key. Only they can decrypt their permit—not the platform, not other members, only the intended recipient.

4. **Social Recovery (SSKR)** - Content can be recovered using a quorum of shares (e.g., 2-of-3), even without individual permits. This provides disaster recovery without central key management.

5. **Sequence Validation** - Members can cryptographically verify that editions form a continuous, unbroken chain, preventing attackers from injecting fake editions or reordering messages.

6. **Auditability** - The provenance chain provides a tamper-evident record that can be verified by anyone, proving the sequence and integrity of publications without revealing content.

7. **Forward Compatibility** - Publishers can evolve their audience and content while maintaining chain integrity. Add new members, change content, grow the community—the cryptographic foundation holds.

When del.icio.us sold and Google shut down Reader, entire communities lost their coordination infrastructure overnight—not due to user error, but platform business decisions. Traditional systems (email lists, Slack, Discord) rely on central servers that can be shut down, companies that can be pressured, and platforms that can change their minds.

Gordian Clubs ensure that what you build together can't be pulled out from under you by someone else's business pivot or policy change. **Autonomous infrastructure means your coordination survives platform failures, company pivots, and political pressure.** Just as Bitcoin works without banks, Gordian Clubs work without platforms.

## Understanding Key Concepts

Before we begin, let's understand the main components:

### Publisher
The entity creating and signing editions. In our case, RISK itself will be the publisher, represented by its XID.

### Members
Recipients who receive permits to access content. In this tutorial, Amira (BRadvoc8) and Bob are RISK members.

### Editions
Sealed content packages that include:
- The actual content (encrypted)
- A provenance mark (linking to the chain)
- Permits for each member (public-key encrypted keys)
- SSKR shares (for social recovery)
- Publisher's signature

### Permits
Public-key encrypted access credentials. Each member's permit is encrypted with their public key, so only they can decrypt it. The permit contains the key needed to decrypt the edition's content.

### Provenance Marks
Cryptographic links in a chain. Each mark contains:
- A sequence number
- Reference to the previous mark
- Info field (typically the content digest)
- Date and comment
- Publisher's signature

The chain proves that all editions come from the same publisher and follow a verifiable sequence.

### SSKR (Sharded Secret Key Recovery)
A social recovery mechanism that splits the decryption key into shares (e.g., 2-of-3). Any quorum of shares can recover the content without needing individual permits. This provides disaster recovery if permits are lost.

## Step 1: Creating the Publisher Identity

RISK needs a cryptographic identity to act as the publisher. This is just like creating a personal XID (Tutorial 01), but represents the organization rather than an individual.

👉
```sh
PUBLISHER_PRVKEYS=$(envelope generate prvkeys)
echo "Generated publisher private keys"
```

Now create the publisher's XID:

👉
```sh
PUBLISHER_XID=$(envelope xid new "$PUBLISHER_PRVKEYS")
echo "Created publisher XID"
```

View the publisher's XID structure:

👉
```sh
envelope format "$PUBLISHER_XID"
```

🔎
```
XID(a1b2c3d4) [
    'key': PublicKeys(...) [
        {
            'privateKey': PrivateKeys(...)
        } [
            'salt': Salt
        ]
        'allow': 'All'
    ]
]
```

This XID will sign every edition, allowing members to verify authenticity.

> **Best Practice**: In production, RISK would add assertions like `"organization": "RISK Network"` to make the publisher XID more identifiable. For this tutorial, we keep it simple.

## Step 2: Creating Member Identities

RISK has two members in this tutorial: Amira (BRadvoc8, whom you've followed through Tutorials 01-05) and Bob (a fellow developer). Each needs their own XID so RISK can create permits encrypted with their public keys.

> **Tutorial Note**: In production, Amira would use her actual XID from Tutorial 05 (with all her endorsements). Here we create fresh identities so the examples work independently. The mechanics are identical—you'd simply pass your real XID to the `--permit` flag.

Create Amira's identity (simulating her existing XID):

👉
```sh
AMIRA_PRVKEYS=$(envelope generate prvkeys)
AMIRA_PUBKEYS=$(envelope generate pubkeys "$AMIRA_PRVKEYS")
AMIRA_XID=$(envelope xid new "$AMIRA_PRVKEYS")
echo "Created Amira's identity"
```

Create Bob's identity:

👉
```sh
BOB_PRVKEYS=$(envelope generate prvkeys)
BOB_PUBKEYS=$(envelope generate pubkeys "$BOB_PRVKEYS")
BOB_XID=$(envelope xid new "$BOB_PRVKEYS")
echo "Created Bob's identity"
```

View Amira's XID to confirm:

👉
```sh
envelope format "$AMIRA_XID"
```

> **Note**: We're creating both private keys and public keys for each member. The public keys will be used to encrypt permits. The private keys will be used by members to decrypt their permits.

## Step 3: Preparing the First Update

RISK wants to send a welcome message to members. This becomes the content for the "genesis edition" (the first edition in the club).

Create the content:

👉
```sh
CONTENT_SUBJECT=$(envelope subject type string "Welcome to RISK! This is the genesis update for secure member communications.")
echo "Created content subject"
```

Add metadata (title) to the content:

👉
```sh
CONTENT_CLEAR=$(envelope assertion add pred-obj string "title" string "Genesis Edition" "$CONTENT_SUBJECT")
envelope format "$CONTENT_CLEAR"
```

🔎
```
"Welcome to RISK! ..." [
    "title": "Genesis Edition"
]
```

Wrap the content to stabilize its structure for signing:

👉
```sh
CONTENT_WRAPPED=$(envelope subject type wrapped "$CONTENT_CLEAR")
envelope format "$CONTENT_WRAPPED"
```

🔎
```
{
    "Welcome to RISK! ..." [
        "title": "Genesis Edition"
    ]
}
```

> **Why wrap?** Wrapping the content ensures its digest remains stable even when we add assertions or signatures later. The wrapped envelope's digest becomes our content identifier.

## Step 4: Starting the Provenance Chain

Provenance marks form a cryptographic chain that links all editions together. The first mark is called the "genesis mark" and starts the chain.

First, capture the content digest to embed in the provenance mark:

👉
```sh
CONTENT_DIGEST=$(envelope digest "$CONTENT_WRAPPED")
echo "Content digest: $CONTENT_DIGEST"
```

Create a directory for the provenance chain (it stores the chain state):

👉
```sh
PROV_DIR="output/clubs-provenance"
mkdir -p "$PROV_DIR"
```

Create the genesis mark:

👉
```sh
GENESIS_MARK=$(provenance new --comment "Genesis edition for RISK" --format ur --info "$CONTENT_DIGEST" --quiet "$PROV_DIR")
echo "Created genesis mark"
```

View the mark in human-readable format:

👉
```sh
provenance print --start 0 --end 0 --format markdown "$PROV_DIR"
```

🔎
```
## Provenance Mark #0

**Date**: 2025-10-19T18:00:00Z
**Comment**: Genesis edition for RISK
**Info**: ur:digest/hdcx...
**Previous**: (none - genesis)
```

The genesis mark contains:
- Sequence number (0)
- Our content digest in the info field
- A comment describing this mark
- No previous mark reference (it's the first!)

> **Key Insight**: The info field contains the content digest. This cryptographically binds the mark to the content. Anyone with the mark and content can verify they match.

## Step 5: Publishing the Genesis Edition

Now we create the actual edition - the sealed package that contains encrypted content, permits for members, and SSKR shares for recovery.

👉
```sh
EDITION_RAW=$(clubs init \
  --publisher "$PUBLISHER_XID" \
  --content "$CONTENT_WRAPPED" \
  --provenance "$GENESIS_MARK" \
  --permit "$AMIRA_XID" \
  --permit "$BOB_PUBKEYS" \
  --sskr 2of3)
echo "Created genesis edition"
```

This command:
- `--publisher`: RISK's XID (signs the edition)
- `--content`: The wrapped content to encrypt
- `--provenance`: The genesis mark linking to the chain
- `--permit`: Creates permits for Amira (using her XID) and Bob (using his public keys)
- `--sskr 2of3`: Generates 3 SSKR shares where any 2 can recover content

The output is multiple URs (one edition + three SSKR shares). Let's split them:

👉
```sh
EDITION_UR=$(echo "$EDITION_RAW" | head -1)
SSKR_SHARE_1=$(echo "$EDITION_RAW" | sed -n '2p')
SSKR_SHARE_2=$(echo "$EDITION_RAW" | sed -n '3p')
SSKR_SHARE_3=$(echo "$EDITION_RAW" | sed -n '4p')
echo "Extracted edition and SSKR shares"
```

View the edition structure:

👉
```sh
envelope format "$EDITION_UR"
```

🔎
```
{
    ENCRYPTED [
        'hasSecret': EncryptedKey
    ]
} [
    'permit': ENCRYPTED
    'permit': ENCRYPTED
    'provenance': {
        ProvenanceMark(#0) [
            'chainID': URI(...)
            'date': 2025-10-19T18:00:00Z
            'info': Digest(...)
        ]
    } [
        'signed': Signature
    ]
    'sskr': ENCRYPTED
    'sskr': ENCRYPTED
    'sskr': ENCRYPTED
    'signed': Signature
]
```

Notice:
- The content is `ENCRYPTED`
- There are two `'permit'` assertions (for Amira and Bob)
- The provenance mark is embedded and signed
- There are three `'sskr'` assertions (the shares)
- The whole edition is signed by the publisher

## Step 6: Verifying the Edition

Anyone who receives this edition can verify it came from RISK by checking the publisher's signature.

👉
```sh
clubs edition verify \
  --edition "$EDITION_UR" \
  --publisher "$PUBLISHER_XID"
echo "✅ Edition verified successfully"
```

No output means success! The verification confirms:
- The edition's signature is valid
- The signature was created by the publisher's private keys
- The provenance mark is properly embedded and signed
- The edition structure is intact

> **Security Note**: Verification doesn't require any secrets - only the edition and the publisher's XID (which includes public keys). Anyone can verify, but only permit holders can decrypt.

## Step 7: Extracting Permits

The edition contains permits for Amira and Bob. Let's extract them:

👉
```sh
PERMITS=$(clubs edition permits --edition "$EDITION_UR")
echo "$PERMITS"
```

This outputs the permit URs (one per line):

🔎
```
ur:envelope/lftpso...
ur:envelope/lftpso...
```

We don't know which permit is for which member yet - we'll find out by trying to decrypt.

## Step 8: Amira Decrypts Content

Amira tries to decrypt the content using her private keys. The clubs tool will try her permit and, if it matches, decrypt the content.

First, let's extract individual permits:

👉
```sh
PERMIT_1=$(echo "$PERMITS" | sed -n '1p')
PERMIT_2=$(echo "$PERMITS" | sed -n '2p')
```

Try decrypting with the first permit:

👉
```sh
AMIRA_CONTENT_1=$(clubs content decrypt \
  --edition "$EDITION_UR" \
  --publisher "$PUBLISHER_XID" \
  --permit "$PERMIT_1" \
  --identity "$AMIRA_PRVKEYS" \
  --emit-ur 2>/dev/null || echo "")
```

If that didn't work, try the second permit:

👉
```sh
if [ -z "$AMIRA_CONTENT_1" ]; then
  AMIRA_CONTENT=$(clubs content decrypt \
    --edition "$EDITION_UR" \
    --publisher "$PUBLISHER_XID" \
    --permit "$PERMIT_2" \
    --identity "$AMIRA_PRVKEYS" \
    --emit-ur)
else
  AMIRA_CONTENT="$AMIRA_CONTENT_1"
fi
echo "Amira decrypted content"
```

View the decrypted content:

👉
```sh
envelope format "$AMIRA_CONTENT"
```

🔎
```
{
    "Welcome to RISK! This is the genesis update for secure member communications." [
        "title": "Genesis Edition"
    ]
}
```

Success! Amira can read the welcome message using her permit.

> **Privacy Note**: Amira's permit is encrypted with her public key. Only someone with her private keys can decrypt it. Bob cannot use Amira's permit, and vice versa.

## Step 9: Bob Decrypts Content

Bob can do the same process with his private keys:

👉
```sh
BOB_CONTENT_1=$(clubs content decrypt \
  --edition "$EDITION_UR" \
  --publisher "$PUBLISHER_XID" \
  --permit "$PERMIT_1" \
  --identity "$BOB_PRVKEYS" \
  --emit-ur 2>/dev/null || echo "")

if [ -z "$BOB_CONTENT_1" ]; then
  BOB_CONTENT=$(clubs content decrypt \
    --edition "$EDITION_UR" \
    --publisher "$PUBLISHER_XID" \
    --permit "$PERMIT_2" \
    --identity "$BOB_PRVKEYS" \
    --emit-ur)
else
  BOB_CONTENT="$BOB_CONTENT_1"
fi

envelope format "$BOB_CONTENT"
```

Bob sees the same content, decrypted using his own permit.

## Step 10: Disaster Recovery via SSKR

What if both Amira and Bob lose their permits? This is where SSKR (Sharded Secret Key Recovery) saves the day.

The edition was created with `--sskr 2of3`, meaning:
- 3 shares were generated
- Any 2 shares can recover the content
- 1 share alone is useless

Let's use shares 1 and 2 to recover the content:

👉
```sh
SSKR_CONTENT=$(clubs content decrypt \
  --edition "$EDITION_UR" \
  --publisher "$PUBLISHER_XID" \
  --sskr "$SSKR_SHARE_1" \
  --sskr "$SSKR_SHARE_2" \
  --emit-ur)
echo "Recovered content via SSKR"
```

View the recovered content:

👉
```sh
envelope format "$SSKR_CONTENT"
```

🔎
```
{
    "Welcome to RISK! ..." [
        "title": "Genesis Edition"
    ]
}
```

The same content! SSKR shares provide a disaster recovery mechanism.

> **Distribution Strategy**: In practice, RISK might give:
> - Amira: Share 1
> - Bob: Share 2
> - Charlene (coordinator): Share 3
>
> Any two members can collaborate to recover content if permits are lost. No single person can decrypt alone.

## Step 11: Publishing a Follow-up Edition

Time passes, and RISK wants to send a second update to members. This becomes the second edition in the chain.

Create new content:

👉
```sh
UPDATE_SUBJECT=$(envelope subject type string "RISK Update: New projects available in Latin America and Southeast Asia. Check the project board for details.")
UPDATE_CLEAR=$(envelope assertion add pred-obj string "title" string "Second Edition - New Projects" "$UPDATE_SUBJECT")
UPDATE_WRAPPED=$(envelope subject type wrapped "$UPDATE_CLEAR")
UPDATE_DIGEST=$(envelope digest "$UPDATE_WRAPPED")
echo "Created update content"
```

Create the next provenance mark (this references the previous mark):

👉
```sh
SECOND_MARK=$(provenance next --comment "Second edition - new projects announcement" --format ur --info "$UPDATE_DIGEST" --quiet "$PROV_DIR")
echo "Created second provenance mark"
```

View the mark chain:

👉
```sh
provenance print --start 0 --end 1 --format markdown "$PROV_DIR"
```

🔎
```
## Provenance Mark #0
**Date**: 2025-10-19T18:00:00Z
**Comment**: Genesis edition for RISK
**Info**: ur:digest/hdcx... (genesis content)

## Provenance Mark #1
**Date**: 2025-10-19T18:15:00Z
**Comment**: Second edition - new projects announcement
**Info**: ur:digest/hdcx... (update content)
**Previous**: Mark #0
```

Notice mark #1 references mark #0, forming a chain.

Compose the second edition (note: we use `clubs edition compose`, not `init`):

👉
```sh
SECOND_EDITION_RAW=$(clubs edition compose \
  --publisher "$PUBLISHER_XID" \
  --content "$UPDATE_WRAPPED" \
  --provenance "$SECOND_MARK" \
  --permit "$AMIRA_XID" \
  --permit "$BOB_PUBKEYS" \
  --sskr 2of3)
echo "Created second edition"
```

Extract the edition and new SSKR shares:

👉
```sh
EDITION2_UR=$(echo "$SECOND_EDITION_RAW" | head -1)
SSKR2_SHARE_1=$(echo "$SECOND_EDITION_RAW" | sed -n '2p')
SSKR2_SHARE_2=$(echo "$SECOND_EDITION_RAW" | sed -n '3p')
SSKR2_SHARE_3=$(echo "$SECOND_EDITION_RAW" | sed -n '4p')
echo "Extracted second edition and shares"
```

## Step 12: Verifying the Edition Sequence

The power of Gordian Clubs is the ability to verify that editions form a continuous, unbroken chain from the same publisher.

Verify the second edition's signature:

👉
```sh
clubs edition verify \
  --edition "$EDITION2_UR" \
  --publisher "$PUBLISHER_XID"
echo "✅ Second edition verified"
```

Verify the sequence continuity:

👉
```sh
clubs edition sequence \
  --edition "$EDITION2_UR" \
  --edition "$EDITION_UR"
echo "✅ Edition sequence validated"
```

No output means success! This confirms:
- Both editions are from the same publisher
- Their provenance marks form a valid chain
- Mark #1 correctly references mark #0
- The chain has no gaps or forks

> **Security Guarantee**: Sequence validation proves that both editions come from the legitimate publisher and follow a continuous chain. An attacker cannot insert fake editions or reorder the sequence without detection.

## Proper File Organization

For real-world usage, you'll want to save these artifacts with clear naming conventions:

**Directory structure:**
```
output/clubs-TIMESTAMP/
├── provenance-chain/
│   ├── generator.json          # Provenance chain state
│   └── marks/
│       ├── mark-0.json         # Genesis mark
│       └── mark-1.json         # Second mark
├── RISK-edition-genesis.envelope
├── RISK-edition-genesis.format
├── RISK-sskr-share-1.envelope
├── RISK-sskr-share-2.envelope
├── RISK-sskr-share-3.envelope
├── RISK-edition-second.envelope
├── RISK-edition-second.format
├── RISK-sskr2-share-1.envelope
├── RISK-sskr2-share-2.envelope
└── RISK-sskr2-share-3.envelope
```

**File naming conventions:**
- `-genesis` = First edition
- `-second`, `-third`, etc. = Subsequent editions
- `sskr-share-N` = SSKR shares for recovery
- `.envelope` = Binary serialized format
- `.format` = Human-readable version

**Security levels:**
- 🔐 **Publisher keeps secret**: Publisher private keys
- 🔒 **Distribute to members**: Editions, permits
- 🔑 **Distribute SSKR shares**: Give different shares to different trusted members
- ✅ **Safe to share publicly**: Provenance chain (proves sequence, doesn't reveal content)

## Understanding What Happened

1. **Publisher-Subscriber Model**: RISK (publisher) sends updates to Amira and Bob (subscribers) without relying on any central server.

2. **Cryptographic Provenance**: The provenance chain creates an auditable, tamper-evident record of all publications. Anyone can verify the chain's integrity.

3. **Permit-Based Privacy**: Each member gets a unique permit encrypted with their public key. Only they can decrypt their permit and access the content.

4. **Social Recovery (SSKR)**: The 2-of-3 SSKR scheme allows any two members to recover content if individual permits are lost, without giving any single person unilateral access.

5. **Sequence Validation**: Members can verify that editions follow a continuous chain, preventing attackers from injecting fake editions or reordering messages.

6. **Autonomous Operation**: The entire system operates without central servers. Editions can be stored anywhere (IPFS, email, USB drives) and remain verifiable.

7. **Forward Evolution**: The publisher can add new members (issue new permits) or change content while maintaining chain integrity through provenance marks.

> **Real-World Analogy**: Think of Gordian Clubs like a cryptographically-secured newsletter where:
> - Each issue (edition) is cryptographically signed by the publisher
> - Each subscriber gets a unique, encrypted access key (permit)
> - A backup recovery mechanism (SSKR) exists if keys are lost
> - All issues are linked in a verifiable chain (provenance)
> - No central server is required - it's a pure cryptographic system

## What's Next

You've now mastered the basics of Gordian Clubs! In more advanced scenarios, you might explore:

- **Multi-publisher clubs**: Multiple coordinators co-signing editions
- **Provenance integration with git**: Linking code commits to club editions
- **Rich content structures**: Embedding XIDs, verifiable credentials, or complex data
- **Automated distribution**: Using IPFS or other decentralized storage
- **Member management**: Adding/removing permits over time
- **Audit trails**: Using the provenance chain for compliance or governance

The key insight: Gordian Clubs provide **cryptographically verifiable group communication** that's autonomous, privacy-preserving, and resistant to tampering or impersonation.

## Key Terminology

> **Gordian Clubs Terminology Reference**:
>
> - **Publisher** - The entity creating and signing editions (e.g., RISK)
>
> - **Member** - A recipient who receives permits to access content
>
> - **Edition** - A sealed content package including encrypted content, permits, provenance mark, and SSKR shares
>
> - **Permit** - Public-key encrypted credential that allows a specific member to decrypt content
>
> - **Provenance Mark** - A cryptographic link in a chain, containing sequence number, previous reference, content digest, and signature
>
> - **Provenance Chain** - The complete sequence of marks linking all editions together
>
> - **SSKR (Sharded Secret Key Recovery)** - A threshold scheme (e.g., 2-of-3) that splits the decryption key into shares for social recovery
>
> - **Genesis Edition** - The first edition in a club, starting the provenance chain
>
> - **Sequence Validation** - Verifying that editions form a continuous, unbroken chain from the same publisher
>
> - **Info Field** - The content digest stored in a provenance mark, cryptographically binding the mark to specific content

## Common Questions

**Q: Why create fresh identities instead of using Amira's XID from Tutorial 05?**

A: In a real deployment, Amira would use her existing XID with all her endorsements. For this tutorial, we create fresh identities to ensure the examples work independently and to focus on club mechanics rather than identity setup. In production, you'd pass your actual XID to the `--permit` flag.

**Q: How do members receive editions?**

A: Gordian Clubs are transport-agnostic. Editions can be distributed via email attachments, IPFS, USB drives, QR codes, or any file transfer method. The cryptographic guarantees (signatures, permits, provenance) work regardless of how the data travels.

**Q: What happens if a member loses their private keys?**

A: They can't decrypt their permit anymore. However, if SSKR shares were distributed, any quorum of shareholders (e.g., 2-of-3) can recover the content. For the member's ongoing access, the publisher would need to issue a new edition with a fresh permit for the member's new keys.

**Q: Can I add new members to an existing club?**

A: Yes! Each new edition can include different permits. The publisher simply adds `--permit` flags for new members when composing the next edition. New members can access new editions but not previous ones (unless they receive SSKR shares or someone shares decrypted content).

**Q: What's the difference between `clubs init` and `clubs edition compose`?**

A: `clubs init` creates the genesis edition (first in chain). `clubs edition compose` creates subsequent editions that link to the existing provenance chain. The underlying mechanics are similar, but `compose` ensures proper chain continuity.

**Q: How is this different from encrypted email or Signal groups?**

A: Three key differences: (1) **No server dependency** - editions work offline and survive platform shutdowns; (2) **Cryptographic provenance** - members can verify the complete publication history; (3) **Social recovery** - SSKR enables content recovery without central key escrow.

## Exercises

1. Create a club with 3 members (Amira, Bob, Charlie) using 3-of-5 SSKR
2. Experiment with trying to decrypt using insufficient SSKR shares (only 1 share)
3. Verify that you cannot decrypt Amira's permit using Bob's private keys
4. Create a third edition and verify the three-edition sequence
5. Try sequence validation with editions in different orders
6. Save all artifacts to files and reload them to verify persistence

## Example Script

A complete working script implementing this tutorial is available at `tests/07-gordian-clubs-TEST.sh`. Run it to see all steps in action:

```sh
bash tests/07-gordian-clubs-TEST.sh
```

This script will create all the files shown in the File Organization section with proper naming conventions and directory structure.

---

**Previous Tutorial**: [Peer Endorsements](../05-peer-endorsements/tutorial-05.md) | [Key Management](../06-key-management.md) (coming soon)

**Next**: This is the final tutorial in the series. Advanced topics include multi-publisher clubs and provenance integration.
