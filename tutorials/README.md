# XID Tutorials

Welcome to the eXtensible IDentifiers (XIDs) tutorial series. These
tutorials will guide you through creating, understanding, and working
with XIDs, which are a powerful identity framework built on Gordian
Envelope technology.

## Getting Started

To complete these tutorials, you'll need:

1. The `envelope` CLI tool installed
2. Basic familiarity with the command line
3. No prior knowledge of XIDs or Gordian Envelope is required

## Tutorial Structure

The tutorials are designed to be completed in order:

1. [Your First XID](01-your-first-xid/tutorial-01.md) - Create a basic XID and understand its components
2. *(Coming soon)*
3. [Building Your Persona](03-building-persona/tutorial-03.md) - Enrich your XID with professional information and SSH signing keys
4. [Publishing for Discovery](04-publishing-discovery/tutorial-04.md) - Add discovery locations and inception authority for publication
5. [Peer Endorsements](05-peer-endorsements/tutorial-05.md) - Build a network of trust through independent verification
6. [Self-Attestations](06-self-attestations/tutorial-06.md) - Create structured self-claims with verifiable evidence
7. [Gordian Clubs](07-gordian-clubs/tutorial-07.md) - Work with group identities and collaborative structures

Each tutorial builds on skills from previous sections. Each tutorial directory contains:
- `tutorial-NN.md` - The tutorial content
- `tutorial_output-NN.sh` - A script that implements all tutorial steps
- `output/` - Generated artifacts from running the script

## Key Concepts

XIDs (eXtensible IDentifiers) provide:

- **Stable Identity**: Your identifier remains stable even as keys change
- **Self-Sovereign Control**: You control your identity, not a third party
- **Cryptographic Verification**: Digitally sign and verify information
- **Privacy Features**: Selectively share aspects of your identity

## Running the Examples

Each tutorial directory contains a `tutorial_output-NN.sh` script that implements all the steps from the tutorial.

To run an example:

```sh
cd tutorials/01-your-first-xid
bash tutorial_output-01.sh
```

## Next Steps

After completing these tutorials, you'll be able to:

- Create and manage XIDs
- Understand the relationship between XIDs and cryptographic keys
- Build rich, structured identity profiles
- Sign and verify data using your XID

Advanced tutorials on secure messaging, selective disclosure, and
integration with other systems will be coming soon.
