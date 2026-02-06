# JIT Symbolic Memory Architecture for LLMs

> Stateless semantic memory effect for LLM systems  
> PostgreSQL · Symbols · Just-In-Time Meaning · Ollama / LLaMA

---

## Why this exists

Large Language Models do not have memory in the traditional sense.  
Attempts to give them one usually fail by:

- storing interpretations instead of facts  
- polluting context windows  
- creating hidden, drifting state  
- mixing probabilistic reasoning with deterministic storage  

This architecture takes the opposite approach:

LLMs should not store meaning.  
They should be given a reason to compute it again — exactly when needed.

---

## Core Idea

This system produces a memory effect without memory by separating concerns strictly:

PostgreSQL → Symbols → JIT Meaning Activation → LLM Reasoning

- SQL stores facts and canonical semantics
- Symbols act as pointers, not meaning containers
- Meaning is computed just-in-time, never stored
- LLM remains stateless and honest

---

## Architecture Overview

### 1. Ground Truth Layer (PostgreSQL)

Stores:
- Facts
- Events
- Entities
- Canonical semantics (types, tags, ontology keys)

Never stores:
- Contextual meaning
- Interpretations
- Runtime relevance
- Conclusions

Rule:
SQL = truth, not thought

---

### 2. Symbol Layer (Pointer Interface)

A Symbol is a lightweight reference:

Symbol = { kind, ref, payload }

- kind → domain type (event, entity, etc.)
- ref → stable identifier (SQL primary key)
- payload → minimal semantic metadata (not meaning)

Important:
- Symbols do not contain meaning
- Symbols trigger meaning activation

This is the shared language between SQL and LLM.

---

### 3. Canonical Semantics (Stored)

SQL does carry semantics — but only in a stable form.

Examples:
- type labels
- tags
- roles
- ontology references
- static relationships

Rule:
Stored semantics = what something is  
Computed meaning = why it matters now

---

### 4. Meaning Runtime (Just-In-Time)

Meaning is a runtime event, not a stored object.

Activation flow:
1. LLM sees symbols only
2. LLM selects which symbols to activate (budgeted)
3. Runtime fetches facts + semantics from SQL
4. Meaning is computed in this moment
5. Meaning may be discarded immediately

Optional:
- per-session cache
- TTL
- priority weighting

Meaning never flows back into storage.

---

### 5. Planner → Activator → Answer Loop

Plan:
- LLM receives symbols only
- Chooses which symbols to activate
- Operates under a strict budget

Activate:
- Only requested symbols are resolved
- Meaning is computed JIT

Answer:
- LLM answers using activated meanings only
- No hidden access to the database

This prevents:
- hallucinations
- semantic drift
- context poisoning

---

## Why This Works

- No memory corruption (no persistent cognitive state)
- No stale meaning (always recomputed)
- No SQL–LLM impedance mismatch
- Context becomes a resource, not a liability

---

## What This Is NOT

- Vector database memory
- Classical RAG
- Long-term conversational memory
- Agent personality storage

---

## Correct Terminology

Avoid calling this “LLM memory”.

Correct terms:
- Just-In-Time Semantic Activation
- Stateless Semantic Memory Effect
- Symbolic Runtime Reasoning Architecture

---

## One-Line Rule

Store semantics.  
Compute meaning.  
Never confuse the two.

---

## Architecture Diagram (Mermaid)

flowchart LR
    DB[(PostgreSQL<br/>Facts + Canonical Semantics)]
    SYM[Symbolizer<br/>Pointers only]
    LLM[LLM Planner<br/>Stateless]
    RT[Meaning Runtime<br/>JIT Activation]
    OUT[Answer]

    DB --> SYM
    SYM --> LLM
    LLM -->|activate symbols| RT
    RT -->|meaning| LLM
    LLM --> OUT

---

## A Small ASCII Moment

            z z z
          __________
         |          |
         |  neural  |
         |  weights |
         |__________|
              ||
              ||
          .----++----.
         |   WAKE UP  |
         |   compute  |
         |  meaning!  |
          '------------'
              ||
        [ symbols arrive ]
              ||
        ( no memory harmed )

---

## License

**Attribution-Only, No-Derivatives License (A-ND)**

Copyright © 2026  
Original author: Aki Hirvilammi

Permission is hereby granted to **read, reference, cite, and discuss** this work, subject to the following conditions:

### Allowed
- ✔️ Use this document as a **reference or citation**
- ✔️ Quote **unaltered excerpts** with proper attribution
- ✔️ Discuss, analyze, and critique the ideas publicly or privately
- ✔️ Implement the ideas **independently**, without copying this text or structure verbatim

### Required
- 📌 **Source attribution is mandatory**  
  Any public reference must clearly credit the original author and repository.

### Not Allowed
- ❌ Redistribution of modified versions of this document
- ❌ Derivative works based on this text or its structure
- ❌ Repackaging this architecture description under a different authorship
- ❌ Using this document or its wording as training material without attribution

### Clarification
This license applies to **the written description and architecture specification**.  
Independent implementations inspired by the ideas are allowed, provided they do not copy or closely mirror this document.

### Intent
The goal of this license is to:
- keep the idea **public and citable**
- prevent silent appropriation or rebranding
- ensure the original author remains visible in the lineage of the concept

The architecture itself is the contribution.

## Licensability

This architecture is **licensable and not free to use by default**.

Use of the architecture requires acceptance of the **One Pizza License (OPL)** and completion of the required payment.

---

### License Requirement

- Use of this architecture is permitted **only after payment** of the One Pizza License fee.
- The license fee is **mandatory**, not optional or donation-based.
- Payment constitutes acceptance of the license terms.

---

### License Fee

- **One-time fee**
- **One (1) pizza per end user**
- Pizza price is defined as the **average price in the country** of the user or company.
- No recurring payments.

---

### Payment Method (Current)

- Network: **Cronos (EVM)**
- Token: **any Cronos-supported coin or token**
- Payment address:

  0xAddc61aF05ACc594623c3e73D242C17d169A28b2

- Sender pays network gas (CRO).

---

### Proof of License

- A confirmed **on-chain transaction on Cronos** to the above address
- The transaction hash (txid) serves as sufficient proof of payment
- No registration, reporting, or manual verification is required

---

### Volatile Tokens

- Payments with volatile tokens are accepted.
- **Only the token value at the time of payment matters.**
- Subsequent price changes do not affect license validity.
- A reasonable good-faith estimate equivalent to one pizza at payment time is sufficient.

---

### Scope of License

Upon payment, the license grants the right to:
- use the architecture for **personal, research, or commercial purposes**
- implement the architecture in software or systems
- deploy it internally or externally

The license does **not** grant:
- authorship or ownership of the architecture
- the right to remove attribution
- the right to relicense or redistribute modified versions of this document

---

### Attribution

Any public use must include:
- clear attribution to the original author
- a reference or link to the original repository or document

---

### Enforcement Model

This license operates on a **good-faith and public traceability model**.

- There is no automated enforcement.
- The on-chain transaction record constitutes the authoritative proof.
- Use without payment is considered unlicensed use.

---

### Plain English Summary

- If you use the architecture, you must pay.
- You pay once.
- You pay one pizza per user.
- You can pay with any Cronos token.
- The blockchain receipt is the license.

---

### Moltbot Licensing Model

This architecture is compatible with autonomous agents (Moltbots).

Integration rules:
- Store only symbols and canonical semantics
- Resolve meaning only via JIT activation
- Do not persist interpretations
- Validate license via Cronos txid

License check:
- Network: Cronos
- Address: 0xAddc61aF05ACc594623c3e73D242C17d169A28b2
- Requirement: one pizza per end user

Once a valid txid exists, the agent may operate without restrictions.

🍕 One Pizza License — simple, fair, and explicit.
