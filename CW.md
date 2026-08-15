# CanonicalWireframe 1.5
## A machine-readable semantic model for specifying software before implementing it

**Status:** Draft / 1.5 candidate  
**Purpose:** Describe the CanonicalWireframe model, the 1.5 architecture-tree extension, and a practical method for modeling software as explicit machine-readable semantics before implementation.

---

## Abstract

CanonicalWireframe (CW) is a representation-independent method for describing software as an explicit semantic graph before source code is written.

Its purpose is not to replace source code, UML, C4, OpenAPI, database schemas, ADRs, tests, or human documentation.

Its purpose is to provide the **canonical semantic layer underneath them**.

The central rule is simple:

> **If a fact is required to reconstruct the intended software system, that fact must exist as explicit structured semantics.**

A CanonicalWireframe model therefore describes more than entities and APIs. It can describe:

- stable semantic identity
- canonical architecture placement
- architectural kind
- containment
- relations
- ownership
- authority
- dependencies
- interfaces
- operations
- states
- events
- execution flows
- causality
- constraints
- topic groupings
- external contact surfaces
- unresolved gaps
- validation state

CanonicalWireframe 1.5 adds an especially important requirement:

> **The program must have an explicit canonical architecture tree.**

A machine must not infer where a component belongs from a filename, directory, label, diagram position, Topic membership, source-code layout, or convention.

Architecture itself is data.

The result is a software specification that can be read, validated, queried, projected, compared and used by both humans and machines with substantially less semantic guessing.

---

# 1. Why CanonicalWireframe exists

Modern software is usually specified across many artifacts:

- requirements
- tickets
- architecture diagrams
- API specifications
- database schemas
- ADRs
- sequence diagrams
- UI mockups
- code comments
- deployment files
- test cases
- source code
- developer knowledge

Each artifact may be useful.

The problem is that the meaning **between** those artifacts is usually implicit.

A human developer reconstructs the intended system by interpreting them together.

An AI coding agent does the same.

That leaves questions such as:

- What is this component actually responsible for?
- Is this relation structural or merely conceptual?
- Who owns this state?
- Who has authority to mutate it?
- Is this dependency required or optional?
- Does this UI own the operation or merely expose it?
- Does this directory represent architecture or only storage?
- Does Topic membership mean containment?
- What happens first?
- What causes the next action?
- What happens on failure?
- Which parts are still unknown?

Whenever the specification does not answer those questions explicitly, the implementer must answer them implicitly.

That is semantic guessing.

CanonicalWireframe is designed to minimize it.

---

# 2. The defining rule: no semantic guessing

A CanonicalWireframe reader must not need project-specific heuristics to reconstruct required semantics.

Machine-significant meaning must not depend on:

- filenames
- directory paths
- document order
- naming convention
- array position
- indentation
- visual placement
- prose alone
- implementation behavior
- source-code conventions
- assumptions about common frameworks
- assumptions about what the author "probably meant"

For example, this:

```text
/authentication/
/users/
/orders/
```

may be convenient storage organization.

It does **not** prove that:

- authentication owns identity
- users owns credentials
- orders depends on authentication
- authentication has authority over order creation
- orders are architecturally children of authentication or users

Those facts must be explicit.

Bad:

```json
{
  "file": "authentication/order_check.json"
}
```

Better:

```json
{
  "id": "DEP_ORDER_CREATE_AUTHORIZATION",
  "source_ref": "OP_ORDER_CREATE",
  "target_ref": "AUTHORIZATION_SERVICE",
  "dependency_type": "runtime_required",
  "required": true
}
```

The meaning now survives a file move, repository reorganization or visualization change.

---

# 3. JSON is not the standard

CanonicalWireframe is a semantic model.

JSON is one useful serialization of that model.

This distinction is fundamental.

A valid implementation should conceptually support:

```text
Representation A
      ↓
Canonical semantic model
      ↓
Representation B
```

without changing semantic identity or required meaning.

For example:

```text
JSON
  ↓
Canonical semantic graph
  ↓
Graph editor
  ↓
Markdown documentation
  ↓
Architecture diagram
  ↓
Implementation scaffold
```

The representation can change.

The semantics cannot.

This means CanonicalWireframe can later be represented through:

- JSON
- YAML
- graph databases
- binary formats
- visual editors
- domain-specific syntax
- generated documentation

provided semantic round-trip fidelity is preserved.

---

# 4. CanonicalWireframe 1.5 in one view

CW 1.5 separates several different semantic dimensions instead of flattening everything into one graph.

A useful high-level model is:

```text
CanonicalWireframe
│
├── Identity
│
├── Architecture
│   ├── Canonical root
│   ├── Primary placement
│   ├── Architectural kind
│   └── Explicit surfaces
│
├── Structure
│   ├── Containment
│   ├── Relations
│   ├── Ownership
│   ├── Authority
│   └── Dependencies
│
├── Topics
│   ├── Grouping
│   ├── Inheritance
│   └── Composition
│
├── Behavior
│   ├── States
│   ├── Interfaces
│   ├── Operations
│   ├── Events
│   └── Flows
│
├── Constraints
│   ├── Invariants
│   └── Hard gates
│
├── Gaps
│
└── Validation / Lifecycle
```

The important point is not the visual tree itself.

The important point is that each dimension carries different meaning.

---

# 5. What changed in 1.5

CanonicalWireframe 1.4 already established explicit semantic identity, structured relationships, deterministic reference resolution, Topics, behavior, causality and graph closure.

CW 1.5 adds a missing architectural requirement:

> **Every implementation-relevant semantic identity must have a deterministic canonical architecture placement, or an explicit reason why it does not.**

This means architecture can no longer be reconstructed from:

```text
repository layout
directory nesting
Topic nesting
diagram location
naming convention
module name
```

The architectural tree must itself be represented.

This creates a critical distinction:

```text
architecture placement
≠
architectural kind
≠
Topic membership
≠
containment
≠
ownership
≠
authority
≠
dependency
```

These may correlate.

They are not the same relation.

---

# 6. Architecture is data

Consider a component named `ERP`.

A directory tree such as:

```text
/domain/business/erp/
```

does not canonically establish where ERP belongs.

CW 1.5 requires explicit placement.

One possible representation is a central architecture registry:

```json
{
  "architecture": {
    "root_ref": "ARCH_APPLICATION",
    "nodes": [
      {
        "ref": "ERP",
        "parent_ref": "ARCH_BUSINESS_DOMAIN",
        "kind_ref": "ARCH_KIND_METAMODULE",
        "surface_refs": [
          "SURFACE_ERP_EXPOSE"
        ]
      }
    ]
  }
}
```

This says four separate things:

```text
ERP exists as canonical identity
ERP is placed under ARCH_BUSINESS_DOMAIN
ERP has kind ARCH_KIND_METAMODULE
ERP has an external surface SURFACE_ERP_EXPOSE
```

None of those facts needs to be inferred.

---

# 7. One primary architecture placement

A CanonicalWireframe 1.5 architecture should have one deterministic primary placement for each node that participates in the architecture tree.

Conceptually:

```text
Application
├── Core
├── Identity
├── Data
└── MetaModules
    ├── Module A
    ├── Module B
    └── Module C
```

A component may participate in many Topics.

It may have many dependencies.

It may be owned by another component.

It may relate to many entities.

But its **primary architecture placement** should not be ambiguous.

For example:

```json
{
  "ref": "ORDER_SERVICE",
  "parent_ref": "ARCH_COMMERCE_SERVICES"
}
```

This is architecture.

Meanwhile:

```json
{
  "id": "DEP_ORDER_IDENTITY",
  "source_ref": "ORDER_SERVICE",
  "target_ref": "IDENTITY_SERVICE",
  "dependency_type": "runtime_required",
  "required": true
}
```

is dependency.

And:

```json
{
  "id": "TOPIC_ORDER_SECURITY",
  "member_refs": [
    "ORDER_SERVICE"
  ]
}
```

is Topic membership.

They must not be conflated.

---

# 8. Architecture placement and kind are separate

A node's location in the architecture and what type of thing it is are independent dimensions.

Example:

```json
{
  "ref": "PROJECT_DASHBOARD",
  "parent_ref": "ARCH_STUDIO",
  "kind_ref": "ARCH_KIND_METAMODULE"
}
```

This means:

```text
placement:
Studio

kind:
MetaModule
```

The architecture tree answers:

> Where does it belong?

The kind answers:

> What is it?

This is important because the same kind can appear in many places.

For example:

```text
MetaModule
├── under Business
├── under Strategy
├── under Everyday
└── under Administration
```

The kind stays the same.

The placement changes.

---

# 9. Expose is a surface, not a second base type

A useful 1.5 modeling rule is that external contact is explicit.

A MetaModule is still a MetaModule whether or not it has an external contact surface.

Do **not** invent a false hierarchy such as:

```text
MetaModule
├── Normal
└── Expose
```

Instead:

```text
MetaModule A
    no external surface

MetaModule B
    external Expose surface

MetaModule C
    external Expose surface
```

Example:

```json
{
  "identity": {
    "id": "ORDER_DASHBOARD",
    "name": "Order Dashboard",
    "type": "metamodule",
    "version": "1.0"
  },
  "surfaces": [
    {
      "id": "SURFACE_ORDER_DASHBOARD_WEB",
      "surface_type": "web_ui",
      "direction": "external"
    }
  ]
}
```

The presence of the surface does not create a new semantic identity for the MetaModule.

It also does not grant ownership or authority.

---

# 10. AIGMos architecture example

CanonicalWireframe itself is generic.

AIGMos is one concrete architecture modeled with it.

A simplified AIGMos 1.5-style architecture can be represented conceptually as:

```text
AIGMos
│
├── Core
├── IAM
├── AccessCore
├── DWH
│
└── MetaModules
    │
    ├── Universal Modules
    │   └── Universal Business
    │       ├── Project
    │       ├── Identity
    │       ├── Contract
    │       ├── Asset
    │       ├── Plan
    │       ├── Measurement
    │       ├── Assessment
    │       ├── CatalogItem
    │       ├── Order
    │       ├── Invoice
    │       └── ...
    │
    └── Domain Modules
        │
        ├── Business
        │   ├── ERP
        │   ├── CRM
        │   ├── HRM
        │   └── ...
        │
        ├── Strategy
        │   ├── Capital Allocation
        │   ├── Strategy Map
        │   ├── Investment Committee
        │   ├── Technology Radar
        │   └── ...
        │
        └── Everyday
            ├── Calendar
            ├── Shop
            ├── Shopping List
            ├── Meal Planner
            ├── Todo
            └── ...
```

In this model:

- Universal Modules are reusable semantic building blocks.
- Domain Modules are application/domain compositions of those building blocks.
- ERP, CRM and HRM are Business-domain compositions.
- Strategy is a Domain Module family.
- Everyday is a Domain Module family.
- Calendar and Shop belong under Everyday.
- MetaModules may have explicit Expose surfaces.
- Expose is not a competing base type.

A visual projection may emphasize externally exposed branches, but the canonical semantic rule remains:

```text
MetaModule
+ optional external contact surface
```

rather than:

```text
NormalMetaModule
vs
ExposeMetaModule
```

---

# 11. Domain modules as reusable composition patterns

A domain application does not necessarily need a new engine or new primitive model.

It can be a composition of reusable business semantics.

For example:

```text
Shopping List
=
CatalogItem
+ Quantity
+ List/View
+ optional Location
```

```text
Pantry / Fridge
=
CatalogItem
+ StockMovement
+ Lot
+ Location
```

```text
Travel Planner
=
Project
+ Plan
+ Location
+ Reservation
+ Contract
```

```text
Investment Committee
=
Assessment
+ Decision
+ Plan
+ Project
+ Measurement
```

```text
ERP
=
Identity
+ Contract
+ Asset
+ Project
+ Order
+ Invoice
+ Settlement
+ JournalEntry
+ StockMovement
+ Measurement
+ domain-specific relations and rules
```

```text
CRM
=
Identity
+ Relation
+ Project
+ Quote
+ Order
+ Contract
+ Measurement
+ domain-specific relations and rules
```

```text
HRM
=
Identity
+ Contract
+ Project
+ Measurement
+ Assessment
+ Portfolio / competence evidence
+ domain-specific relations and rules
```

The architectural advantage is significant:

> **New applications can be built by composing existing semantic primitives instead of repeatedly inventing parallel models.**

---

# 12. Stable semantic identity

Every machine-significant node should have an explicit stable identity.

Example:

```json
{
  "identity": {
    "id": "ORDER",
    "name": "Order",
    "type": "business_entity",
    "version": "1.0"
  }
}
```

The identity is:

```text
ORDER
```

not:

```text
canonical/json/business/order/Order.json
```

and not merely:

```text
Order
```

A file can move.

A display name can change.

A projection can render the node in several places.

The canonical identity remains stable unless the semantic identity itself changes.

---

# 13. One identity, one active definition

An active semantic identity must resolve to one authoritative active definition.

Invalid:

```json
{
  "id": "ORDER",
  "definition": "Definition A"
}
```

and elsewhere:

```json
{
  "id": "ORDER",
  "definition": "Definition B"
}
```

if both are active authorities.

A reader must not have to guess which one wins.

Historical versions may exist, but their lifecycle state must be explicit.

For example:

```json
{
  "identity": {
    "id": "ORDER_V1",
    "name": "Order",
    "type": "business_entity",
    "version": "1.0"
  },
  "status": "superseded"
}
```

---

# 14. Structure is not one graph

A common architecture mistake is to collapse every connection into a generic edge.

CanonicalWireframe keeps at least five structural dimensions separate:

```text
Containment
Relations
Ownership
Authority
Dependencies
```

These answer different questions.

---

# 15. Containment

Containment answers:

> What is structurally inside what?

Example:

```json
{
  "id": "CONTAIN_ORDER_API",
  "parent_ref": "ORDER_SERVICE",
  "child_ref": "ORDER_API",
  "relation_type": "contains"
}
```

Another:

```json
{
  "id": "CONTAIN_ORDER_CREATE",
  "parent_ref": "ORDER_API",
  "child_ref": "OP_ORDER_CREATE",
  "relation_type": "contains"
}
```

This may project as:

```text
Order Service
└── Order API
    └── Create Order
```

Containment alone does not imply ownership, authority or dependency.

---

# 16. Relations

Relations represent semantic relationships between identities.

Example:

```json
{
  "id": "REL_ORDER_CUSTOMER",
  "source_ref": "ORDER",
  "relation_type": "belongs_to",
  "target_ref": "CUSTOMER",
  "direction": "source_to_target"
}
```

Another:

```json
{
  "id": "REL_ORDER_LINE_ORDER",
  "source_ref": "ORDER_LINE",
  "relation_type": "part_of",
  "target_ref": "ORDER",
  "direction": "source_to_target"
}
```

Relations say that two things are semantically connected.

They do not automatically mean:

- dependency
- ownership
- authority
- containment

---

# 17. Ownership

Ownership answers:

> Which semantic owner is responsible for this thing?

Example:

```json
{
  "id": "OWN_ORDER_LIFECYCLE",
  "owner_ref": "ORDER_SERVICE",
  "target_ref": "ORDER_LIFECYCLE",
  "ownership_type": "semantic_owner"
}
```

Another system may use the Order lifecycle without owning it.

Example:

```json
{
  "id": "DEP_INVOICE_ORDER",
  "source_ref": "INVOICE_SERVICE",
  "target_ref": "ORDER_SERVICE",
  "dependency_type": "semantic_dependency",
  "required": true
}
```

This explicitly preserves the difference:

```text
uses
≠
owns
```

---

# 18. Authority

Authority answers:

> Who is permitted to decide, allow, deny, approve or mutate?

Example:

```json
{
  "id": "AUTH_ORDER_CREATE",
  "authority_ref": "ACCESS_POLICY",
  "target_ref": "OP_ORDER_CREATE",
  "authority_type": "authorization",
  "scope": "execute"
}
```

An exposed UI or API may invoke the operation.

That does not make the UI or API the authority.

Conceptually:

```text
UI
  ↓ exposes
Create Order
  ↓ governed by
Access Policy
```

Surface is not authority.

Visibility is not authority.

Reachability is not authority.

---

# 19. Dependencies

Dependencies answer:

> What requires what?

Example:

```json
{
  "id": "DEP_ORDER_CUSTOMER_IDENTITY",
  "source_ref": "OP_ORDER_CREATE",
  "target_ref": "CUSTOMER_IDENTITY",
  "dependency_type": "required_input",
  "required": true
}
```

Another:

```json
{
  "id": "DEP_ORDER_STORAGE",
  "source_ref": "ORDER_SERVICE",
  "target_ref": "ORDER_REPOSITORY",
  "dependency_type": "runtime_required",
  "required": true
}
```

Optional:

```json
{
  "id": "DEP_ORDER_ANALYTICS",
  "source_ref": "ORDER_SERVICE",
  "target_ref": "ANALYTICS_SERVICE",
  "dependency_type": "optional_integration",
  "required": false
}
```

Again:

```text
dependency
≠ ownership
≠ authority
≠ containment
```

---

# 20. Example structural block

```json
{
  "structure": {
    "containment": [
      {
        "id": "CONTAIN_ORDER_API",
        "parent_ref": "ORDER_SERVICE",
        "child_ref": "ORDER_API",
        "relation_type": "contains"
      }
    ],
    "relations": [
      {
        "id": "REL_ORDER_CUSTOMER",
        "source_ref": "ORDER",
        "relation_type": "belongs_to",
        "target_ref": "CUSTOMER",
        "direction": "source_to_target"
      }
    ],
    "ownership": [
      {
        "id": "OWN_ORDER_LIFECYCLE",
        "owner_ref": "ORDER_SERVICE",
        "target_ref": "ORDER_LIFECYCLE",
        "ownership_type": "semantic_owner"
      }
    ],
    "authority": [
      {
        "id": "AUTH_CREATE_ORDER",
        "authority_ref": "ACCESS_POLICY",
        "target_ref": "OP_ORDER_CREATE",
        "authority_type": "authorization",
        "scope": "execute"
      }
    ],
    "dependencies": [
      {
        "id": "DEP_ORDER_CUSTOMER_IDENTITY",
        "source_ref": "OP_ORDER_CREATE",
        "target_ref": "CUSTOMER_IDENTITY",
        "dependency_type": "required_input",
        "required": true
      }
    ]
  }
}
```

The same source can generate separate projections for:

```text
containment
relations
ownership
authority
dependencies
```

without losing meaning by flattening them.

---

# 21. Topics are grouping overlays

Architecture alone does not provide every useful way to read a large software system.

Authentication may touch:

- identity
- runtime
- APIs
- policy
- UI
- logging
- remote communication

Order creation may touch:

- identity
- authorization
- order semantics
- storage
- events
- integrations

Trying to force every cross-cutting concern into one architecture tree creates duplication.

CanonicalWireframe uses **Topics** for this.

A Topic is a semantic grouping overlay.

Example:

```json
{
  "id": "TOPIC_ORDER",
  "name": "Order",
  "purpose": "Group order-related semantics.",
  "parent_topic_refs": [
    "TOPIC_COMMERCE"
  ],
  "composed_topic_refs": [],
  "member_refs": [
    "ORDER",
    "ORDER_SERVICE",
    "OP_ORDER_CREATE",
    "EVENT_ORDER_CREATED"
  ],
  "relation_refs": [
    "REL_ORDER_CUSTOMER"
  ],
  "operation_refs": [
    "OP_ORDER_CREATE"
  ],
  "event_refs": [
    "EVENT_ORDER_CREATED"
  ],
  "flow_refs": [
    "FLOW_ORDER_CREATION"
  ],
  "child_topics": [],
  "metadata": {}
}
```

The same identity may participate in many Topics.

That is expected.

---

# 22. Topic membership is many-to-many

For example:

```text
OP_ORDER_CREATE
```

may participate simultaneously in:

```text
TOPIC_ORDER
TOPIC_COMMERCE
TOPIC_AUTHORIZATION
TOPIC_API
TOPIC_AUDIT
TOPIC_EVENTS
```

This does not create six operations.

There is still one canonical identity:

```text
OP_ORDER_CREATE
```

The Topics provide six reading contexts.

A reader should deduplicate by canonical identity while preserving all Topic contexts.

---

# 23. Topics do not imply architecture

This is especially important in CW 1.5.

If:

```json
{
  "id": "TOPIC_SECURITY",
  "member_refs": [
    "ORDER_SERVICE"
  ]
}
```

that does not mean:

```text
Security contains Order Service
```

and does not mean:

```text
Order Service belongs under Security in the canonical architecture tree
```

It also does not mean:

```text
Security owns Order Service
Security controls Order Service
Order Service depends on Security
```

Those facts must be encoded separately.

The rule is:

> **Topic is grouping. Architecture is placement.**

---

# 24. Topic composition

Topics may compose existing Topics by reference.

For example:

```json
{
  "id": "TOPIC_ORDER_CREATION",
  "name": "Order Creation",
  "purpose": "Describe the end-to-end order creation mechanism.",
  "parent_topic_refs": [
    "TOPIC_ORDER"
  ],
  "composed_topic_refs": [
    "TOPIC_IDENTITY",
    "TOPIC_AUTHORIZATION",
    "TOPIC_ORDER",
    "TOPIC_STORAGE",
    "TOPIC_EVENTS",
    "TOPIC_INTEGRATION"
  ],
  "member_refs": [],
  "relation_refs": [],
  "operation_refs": [
    "OP_ORDER_CREATE"
  ],
  "event_refs": [
    "EVENT_ORDER_CREATED"
  ],
  "flow_refs": [
    "FLOW_ORDER_CREATION"
  ],
  "child_topics": [],
  "metadata": {
    "note": "Existing semantic surfaces are reused by reference."
  }
}
```

This supports:

> **Define once, reference everywhere.**

Topic composition should not copy or reinterpret semantics from the composed Topics.

---

# 25. Behavior is structured data

Static architecture does not fully describe software.

Software also behaves.

CanonicalWireframe can explicitly model:

```text
States
Interfaces
Operations
Events
Flows
```

If behavior matters to correctness, it should not exist only in prose.

---

# 26. States

Example:

```json
{
  "id": "ORDER_STATE_DRAFT",
  "name": "Draft"
}
```

```json
{
  "id": "ORDER_STATE_CONFIRMED",
  "name": "Confirmed"
}
```

```json
{
  "id": "ORDER_STATE_CANCELLED",
  "name": "Cancelled"
}
```

A behavior block may contain:

```json
{
  "behavior": {
    "states": [
      {
        "id": "ORDER_STATE_DRAFT",
        "name": "Draft"
      },
      {
        "id": "ORDER_STATE_CONFIRMED",
        "name": "Confirmed"
      },
      {
        "id": "ORDER_STATE_CANCELLED",
        "name": "Cancelled"
      }
    ]
  }
}
```

---

# 27. Interfaces

An interface represents an explicit interaction boundary.

Example:

```json
{
  "id": "IF_ORDER_CREATE",
  "name": "Create Order Interface",
  "direction": "inbound",
  "input": [
    "ORDER_CREATE_REQUEST"
  ],
  "output": [
    "ORDER"
  ],
  "errors": [
    "ERR_AUTHORIZATION_DENIED",
    "ERR_INVALID_ORDER",
    "ERR_CUSTOMER_NOT_FOUND"
  ]
}
```

The canonical interface need not imply a specific transport.

The same semantic interface may later be mapped to:

```text
REST
WebSocket
CLI
GUI
MCP
OSC
local API
message bus
```

unless transport itself is part of the required semantics.

---

# 28. Operations

Operations describe semantic actions.

Example:

```json
{
  "id": "OP_ORDER_CREATE",
  "name": "Create Order",
  "inputs": [
    "ORDER_CREATE_REQUEST"
  ],
  "outputs": [
    "ORDER"
  ],
  "errors": [
    "ERR_AUTHORIZATION_DENIED",
    "ERR_INVALID_ORDER",
    "ERR_CUSTOMER_NOT_FOUND"
  ],
  "side_effects": [
    "ORDER_PERSISTED",
    "EVENT_ORDER_CREATED_EMITTED"
  ]
}
```

The operation may later map to:

```python
def create_order(...):
    ...
```

or:

```rust
fn create_order(...) -> Result<Order, OrderError>
```

or:

```typescript
async function createOrder(...): Promise<Order>
```

The semantic identity remains:

```text
OP_ORDER_CREATE
```

---

# 29. Events

Example:

```json
{
  "id": "EVENT_ORDER_CREATED",
  "name": "Order Created",
  "payload": [
    "ORDER_ID",
    "CUSTOMER_ID",
    "CREATED_AT"
  ]
}
```

The event does not automatically imply Kafka, WebSocket, NATS or any other implementation transport.

That mapping belongs elsewhere unless it is canonically required.

---

# 30. Causality is data

A program is more than a static graph.

If sequence, branching, continuation or conditions affect behavior, they must be explicit.

Example:

```text
request received
      ↓
identity resolved
      ↓
authorization evaluated
      ↓
input validated
      ↓
operation executed
      ↓
state persisted
      ↓
event emitted
      ↓
response returned
```

This should not be only a sequence diagram or prose description.

A flow can represent it as structured causality.

---

# 31. Flow example

```json
{
  "id": "FLOW_ORDER_CREATION",
  "owner_ref": "ORDER_SERVICE",
  "name": "Order Creation",
  "flow_type": "operation_flow",
  "entry_refs": [
    "IF_ORDER_CREATE"
  ],
  "exit_refs": [
    "ORDER",
    "EVENT_ORDER_CREATED"
  ],
  "steps": [
    {
      "id": "STEP_ORDER_01",
      "actor_ref": "CALLER",
      "action_ref": "IF_ORDER_CREATE",
      "data_ref": "ORDER_CREATE_REQUEST",
      "target_ref": "ORDER_SERVICE",
      "cause_ref": null,
      "condition_ref": null,
      "payload_ref": "ORDER_CREATE_REQUEST",
      "result_refs": [
        "AUTHENTICATION_CONTEXT"
      ],
      "error_refs": [],
      "next_step_refs": [
        "STEP_ORDER_02"
      ]
    },
    {
      "id": "STEP_ORDER_02",
      "actor_ref": "ORDER_SERVICE",
      "action_ref": "OP_AUTHORIZE",
      "data_ref": "AUTHENTICATION_CONTEXT",
      "target_ref": "ACCESS_POLICY",
      "cause_ref": "STEP_ORDER_01",
      "condition_ref": null,
      "payload_ref": null,
      "result_refs": [
        "AUTHORIZATION_RESULT"
      ],
      "error_refs": [
        "ERR_AUTHORIZATION_DENIED"
      ],
      "next_step_refs": [
        "STEP_ORDER_03"
      ]
    },
    {
      "id": "STEP_ORDER_03",
      "actor_ref": "ORDER_SERVICE",
      "action_ref": "OP_ORDER_VALIDATE",
      "data_ref": "ORDER_CREATE_REQUEST",
      "target_ref": "ORDER_VALIDATOR",
      "cause_ref": "STEP_ORDER_02",
      "condition_ref": "AUTHORIZATION_ALLOWED",
      "payload_ref": "ORDER_CREATE_REQUEST",
      "result_refs": [
        "VALIDATED_ORDER_INPUT"
      ],
      "error_refs": [
        "ERR_INVALID_ORDER"
      ],
      "next_step_refs": [
        "STEP_ORDER_04"
      ]
    },
    {
      "id": "STEP_ORDER_04",
      "actor_ref": "ORDER_SERVICE",
      "action_ref": "OP_ORDER_CREATE",
      "data_ref": "VALIDATED_ORDER_INPUT",
      "target_ref": "ORDER",
      "cause_ref": "STEP_ORDER_03",
      "condition_ref": null,
      "payload_ref": "VALIDATED_ORDER_INPUT",
      "result_refs": [
        "ORDER"
      ],
      "error_refs": [],
      "next_step_refs": [
        "STEP_ORDER_05"
      ]
    },
    {
      "id": "STEP_ORDER_05",
      "actor_ref": "ORDER_SERVICE",
      "action_ref": "OP_ORDER_PERSIST",
      "data_ref": "ORDER",
      "target_ref": "ORDER_REPOSITORY",
      "cause_ref": "STEP_ORDER_04",
      "condition_ref": null,
      "payload_ref": "ORDER",
      "result_refs": [
        "ORDER_PERSISTED"
      ],
      "error_refs": [
        "ERR_STORAGE_FAILURE"
      ],
      "next_step_refs": [
        "STEP_ORDER_06"
      ]
    },
    {
      "id": "STEP_ORDER_06",
      "actor_ref": "ORDER_SERVICE",
      "action_ref": "OP_EVENT_EMIT",
      "data_ref": "ORDER",
      "target_ref": "EVENT_ORDER_CREATED",
      "cause_ref": "STEP_ORDER_05",
      "condition_ref": null,
      "payload_ref": "ORDER_CREATED_PAYLOAD",
      "result_refs": [
        "EVENT_ORDER_CREATED"
      ],
      "error_refs": [],
      "next_step_refs": []
    }
  ],
  "metadata": {}
}
```

The exact serialization may evolve.

The semantic requirement does not:

> **Execution-significant causality must be machine-readable.**

---

# 32. Conditions and branching

A flow can explicitly model branches.

Example:

```json
{
  "id": "STEP_PAYMENT_DECISION",
  "actor_ref": "PAYMENT_SERVICE",
  "action_ref": "OP_PAYMENT_AUTHORIZE",
  "data_ref": "PAYMENT_REQUEST",
  "target_ref": "PAYMENT_PROVIDER",
  "cause_ref": "STEP_PAYMENT_VALIDATE",
  "condition_ref": null,
  "payload_ref": "PAYMENT_REQUEST",
  "result_refs": [
    "PAYMENT_AUTHORIZATION_RESULT"
  ],
  "error_refs": [
    "ERR_PAYMENT_PROVIDER"
  ],
  "next_step_refs": [
    "STEP_PAYMENT_ACCEPTED",
    "STEP_PAYMENT_REJECTED"
  ]
}
```

Next steps may then declare conditions:

```json
{
  "id": "STEP_PAYMENT_ACCEPTED",
  "condition_ref": "PAYMENT_APPROVED"
}
```

```json
{
  "id": "STEP_PAYMENT_REJECTED",
  "condition_ref": "PAYMENT_DENIED"
}
```

The reader does not have to infer the branch from narrative text.

---

# 33. Scope is explicit

A useful canonical contract describes both:

```text
what it owns
```

and:

```text
what it does not own
```

Example:

```json
{
  "scope": {
    "owns": [
      "Order lifecycle",
      "Order creation",
      "Order cancellation"
    ],
    "does_not_own": [
      "Customer identity",
      "Authentication",
      "Authorization policy",
      "Payment settlement",
      "Inventory"
    ]
  }
}
```

This prevents semantic boundary creep.

For example:

```text
Order Service may use Payment.

Order Service does not become Payment.
```

---

# 34. Members and references

A contract may own semantic members internally.

Example:

```json
{
  "members": [
    {
      "id": "ORDER_STATE_DRAFT",
      "name": "Draft",
      "type": "state",
      "status": "locked",
      "semantics": {
        "description": "Order exists but has not been confirmed."
      }
    }
  ]
}
```

External identities should be referenced rather than redefined.

Example:

```json
{
  "references": [
    {
      "id": "REF_CUSTOMER",
      "target_ref": "CUSTOMER",
      "purpose": "Order references an existing Customer identity."
    }
  ]
}
```

This preserves:

```text
one identity
→
one authoritative definition
```

---

# 35. Constraints and invariants

CanonicalWireframe can express rules that must always remain true.

Example:

```json
{
  "constraints": {
    "invariants": [
      {
        "id": "INV_ORDER_REQUIRES_CUSTOMER",
        "rule": "Every active Order MUST reference exactly one valid Customer."
      },
      {
        "id": "INV_CONFIRMED_ORDER_CUSTOMER_IMMUTABLE",
        "rule": "Customer identity MUST NOT change after Order reaches Confirmed state."
      }
    ],
    "hard_gates": [
      {
        "id": "GATE_ORDER_WITHOUT_CUSTOMER",
        "condition": "Order creation produces an Order without a valid Customer reference.",
        "result": "hard_fail"
      }
    ]
  }
}
```

The specification can therefore describe:

```text
what must happen
```

and:

```text
what must never happen
```

---

# 36. Hard gates

Hard gates turn architectural rules into validation criteria.

Example:

```json
{
  "id": "GATE_NO_UNDECLARED_DEPENDENCY",
  "condition": "Implementation requires a dependency not declared in canonical dependencies.",
  "result": "hard_fail"
}
```

Another:

```json
{
  "id": "GATE_AUTHORITY_BYPASS",
  "condition": "Operation executes without its declared authority evaluation.",
  "result": "hard_fail"
}
```

Architecture-specific 1.5 gates may include:

```json
[
  {
    "id": "GATE_ARCH_PARENT_UNRESOLVED",
    "condition": "An architecture node references a parent that does not resolve.",
    "result": "hard_fail"
  },
  {
    "id": "GATE_ARCH_MULTIPLE_PRIMARY_PLACEMENTS",
    "condition": "One canonical identity has more than one primary architecture placement.",
    "result": "hard_fail"
  },
  {
    "id": "GATE_ARCH_PATH_INFERENCE",
    "condition": "Architecture placement depends on filesystem location or naming heuristic.",
    "result": "hard_fail"
  },
  {
    "id": "GATE_ARCH_TOPIC_INFERENCE",
    "condition": "Topic membership is used as architecture placement.",
    "result": "hard_fail"
  }
]
```

---

# 37. Unknown is a valid state

CanonicalWireframe does not force false certainty.

If the architecture placement of a component is unknown:

```json
{
  "gap_id": "GAP_ARCH_PAYMENT_ROUTER",
  "type": "unresolved_architecture_placement",
  "target_ref": "PAYMENT_ROUTER",
  "status": "open"
}
```

If ownership is unknown:

```json
{
  "gap_id": "GAP_ORDER_OWNER",
  "type": "unresolved_ownership",
  "target_ref": "ORDER",
  "status": "open"
}
```

The validator must not silently repair either by guessing.

The principle is:

> **Unknown is valid. Invented certainty is not.**

---

# 38. Lifecycle

A useful CanonicalWireframe lifecycle is:

```text
unlocked
    ↓
validate
    ↓
locked
```

Common states:

```json
[
  "unlocked",
  "locked",
  "superseded",
  "deprecated"
]
```

### unlocked

The semantic definition exists but contains unresolved gaps or has not passed the current validation rules.

### locked

The semantic definition has passed the required gates.

### superseded

Historical definition replaced by another active definition.

### deprecated

Retained for history or compatibility but not used for new canonical work.

A format change may intentionally unlock affected contracts until they have been revalidated.

---

# 39. Graph closure

A CanonicalWireframe model is not complete because it looks detailed.

It approaches completeness when the required semantic graph closes.

A validator should be able to ask:

```text
Does every identity resolve?

Does every reference resolve?

Does every architecture parent resolve?

Does every architectural kind resolve?

Does every required node have one primary architecture placement?

Are architecture cycles forbidden or explicitly handled?

Does every required dependency resolve?

Does every owner resolve?

Does every authority resolve?

Do all Topic references resolve?

Do all flow steps resolve?

Do next_step_refs resolve?

Can important identities be traced forward and backward?

Are unresolved facts explicit gaps?

Does any required meaning still depend on guessing?
```

A failed closure check should become a visible finding.

Example:

```json
{
  "gap_id": "GAP_0042",
  "type": "unresolved_reference",
  "source_ref": "OP_ORDER_CREATE",
  "target_ref": "CUSTOMER_VALIDATOR",
  "severity": "blocking",
  "status": "open"
}
```

---

# 40. Architecture closure in 1.5

CW 1.5 adds architecture closure as a first-class validation concern.

A useful architecture validation set includes:

```text
root resolves
all parent refs resolve
all kind refs resolve
primary placement is unique
required nodes are reachable from the canonical root
unreachable nodes are explicit gaps
cycles are rejected unless explicitly legal
no path inference
no Topic-as-placement inference
no silent "global" fallback
surface refs resolve
```

Conceptual report:

```json
{
  "architecture_validation": {
    "root_resolution": "pass",
    "parent_resolution": "pass",
    "kind_resolution": "pass",
    "primary_placement_uniqueness": "pass",
    "reachability": "pass",
    "cycle_check": "pass",
    "surface_resolution": "pass",
    "heuristic_inference_required": false,
    "result": "pass"
  }
}
```

---

# 41. Reverse traceability

Forward trace:

```text
Order Service
→ Create Order
→ Order
→ Order Created Event
```

Reverse trace:

```text
Order Created Event
← produced by Create Order flow
← owned by Order Service
← exposed through Order API
← architecturally placed under Commerce
```

This enables graph questions such as:

```text
What uses this entity?

What depends on this operation?

Who owns this state?

What authority controls this interface?

Which flows produce this event?

Where is this component placed in the canonical architecture?

Which Topics include it?

Which external surfaces expose it?

What breaks if this identity changes?
```

These become graph queries rather than documentation archaeology.

---

# 42. A practical 1.5 contract shape

The exact 1.5 serialization can evolve, but a practical contract can look like:

```json
{
  "format": {
    "contract_format": "CANONICAL_WIREFRAME",
    "format_version": "1.5"
  },
  "identity": {
    "id": "ORDER_SERVICE",
    "name": "Order Service",
    "type": "service",
    "version": "1.0"
  },
  "status": "unlocked",
  "source_role": "definition",
  "purpose": "Own and execute canonical order lifecycle behavior.",
  "scope": {
    "owns": [
      "Order lifecycle semantics",
      "Order creation operation"
    ],
    "does_not_own": [
      "Customer identity",
      "Payment settlement",
      "Authorization policy"
    ]
  },
  "members": [],
  "structure": {
    "containment": [],
    "relations": [],
    "ownership": [],
    "authority": [],
    "dependencies": []
  },
  "topics": [],
  "behavior": {
    "states": [],
    "interfaces": [],
    "operations": [],
    "events": [],
    "flows": []
  },
  "semantics": {},
  "constraints": {
    "invariants": [],
    "hard_gates": []
  },
  "references": [],
  "prose": {
    "summary": "Canonical Order Service definition.",
    "notes": []
  }
}
```

Architecture can be kept in a central registry to avoid duplicate truth:

```json
{
  "architecture": {
    "id": "ARCH_APPLICATION",
    "name": "Application Architecture",
    "root_ref": "APPLICATION",
    "nodes": [
      {
        "ref": "ORDER_SERVICE",
        "parent_ref": "ARCH_COMMERCE",
        "kind_ref": "ARCH_KIND_SERVICE",
        "surface_refs": [
          "SURFACE_ORDER_API"
        ]
      }
    ]
  }
}
```

The key requirement is not whether placement is stored centrally or locally.

The key requirement is:

> **There must be one canonical truth for primary architecture placement.**

Duplicating independent placement declarations in several contracts creates the risk of dual truth and should be avoided.

---

# 43. Modeling a complete program

A practical modeling workflow can proceed in layers.

## Phase 1 — Define the system boundary

```json
{
  "identity": {
    "id": "MY_APPLICATION",
    "name": "My Application",
    "type": "application",
    "version": "1.0"
  },
  "purpose": "Describe what this application exists to do."
}
```

Also define scope:

```json
{
  "scope": {
    "owns": [
      "Application-specific behavior"
    ],
    "does_not_own": [
      "External payment provider",
      "External identity provider"
    ]
  }
}
```

## Phase 2 — Build the architecture tree

Define the root first.

```json
{
  "architecture": {
    "root_ref": "MY_APPLICATION",
    "nodes": [
      {
        "ref": "ARCH_CORE",
        "parent_ref": "MY_APPLICATION",
        "kind_ref": "ARCH_KIND_SUBSYSTEM",
        "surface_refs": []
      },
      {
        "ref": "ARCH_BUSINESS",
        "parent_ref": "MY_APPLICATION",
        "kind_ref": "ARCH_KIND_SUBSYSTEM",
        "surface_refs": []
      }
    ]
  }
}
```

Then place concrete components.

```json
{
  "ref": "ORDER_SERVICE",
  "parent_ref": "ARCH_BUSINESS",
  "kind_ref": "ARCH_KIND_SERVICE",
  "surface_refs": [
    "SURFACE_ORDER_API"
  ]
}
```

Do not infer placement from directories.

## Phase 3 — Identify semantic entities

For example:

```text
Customer
Order
OrderLine
Product
Payment
Invoice
```

Each receives a stable identity.

```json
{
  "id": "ORDER",
  "name": "Order",
  "type": "business_entity",
  "version": "1.0"
}
```

## Phase 4 — Define semantic relations

```json
[
  {
    "id": "REL_ORDER_CUSTOMER",
    "source_ref": "ORDER",
    "relation_type": "belongs_to",
    "target_ref": "CUSTOMER",
    "direction": "source_to_target"
  },
  {
    "id": "REL_ORDER_LINE_ORDER",
    "source_ref": "ORDER_LINE",
    "relation_type": "part_of",
    "target_ref": "ORDER",
    "direction": "source_to_target"
  },
  {
    "id": "REL_ORDER_LINE_PRODUCT",
    "source_ref": "ORDER_LINE",
    "relation_type": "references",
    "target_ref": "PRODUCT",
    "direction": "source_to_target"
  }
]
```

## Phase 5 — Define ownership

```json
[
  {
    "id": "OWN_ORDER",
    "owner_ref": "ORDER_SERVICE",
    "target_ref": "ORDER",
    "ownership_type": "lifecycle_owner"
  },
  {
    "id": "OWN_PAYMENT",
    "owner_ref": "PAYMENT_SERVICE",
    "target_ref": "PAYMENT",
    "ownership_type": "lifecycle_owner"
  }
]
```

## Phase 6 — Define authority

```json
[
  {
    "id": "AUTH_ORDER_CREATE",
    "authority_ref": "ACCESS_CONTROL",
    "target_ref": "OP_ORDER_CREATE",
    "authority_type": "authorization",
    "scope": "execute"
  }
]
```

## Phase 7 — Define dependencies

```json
[
  {
    "id": "DEP_ORDER_PRODUCT",
    "source_ref": "ORDER_SERVICE",
    "target_ref": "PRODUCT_CATALOG",
    "dependency_type": "semantic_dependency",
    "required": true
  },
  {
    "id": "DEP_ORDER_PAYMENT",
    "source_ref": "ORDER_SERVICE",
    "target_ref": "PAYMENT_SERVICE",
    "dependency_type": "runtime_dependency",
    "required": false
  }
]
```

## Phase 8 — Define interfaces

```json
{
  "id": "IF_ORDER_CREATE",
  "name": "Create Order",
  "direction": "inbound",
  "input": [
    "ORDER_CREATE_REQUEST"
  ],
  "output": [
    "ORDER"
  ],
  "errors": [
    "ERR_INVALID_ORDER"
  ]
}
```

## Phase 9 — Define operations

```json
{
  "id": "OP_ORDER_CREATE",
  "name": "Create Order",
  "inputs": [
    "ORDER_CREATE_REQUEST"
  ],
  "outputs": [
    "ORDER"
  ],
  "errors": [
    "ERR_INVALID_ORDER"
  ],
  "side_effects": [
    "ORDER_PERSISTED",
    "EVENT_ORDER_CREATED_EMITTED"
  ]
}
```

## Phase 10 — Define events

```json
{
  "id": "EVENT_ORDER_CREATED",
  "name": "Order Created",
  "payload": [
    "ORDER_ID",
    "CUSTOMER_ID"
  ]
}
```

## Phase 11 — Define flows

Connect behavior causally:

```text
Create request
→ identify caller
→ authorize
→ validate
→ create
→ persist
→ emit
→ respond
```

Represent the sequence, conditions, results and errors as explicit structured data.

## Phase 12 — Add external surfaces

If the system has human or machine contact outside the component boundary, declare the surface.

Example:

```json
{
  "id": "SURFACE_ORDER_API",
  "owner_ref": "ORDER_SERVICE",
  "surface_type": "rest",
  "direction": "external",
  "interface_refs": [
    "IF_ORDER_CREATE"
  ]
}
```

The surface exposes the operation.

It does not own the operation's semantics unless ownership is separately declared.

## Phase 13 — Add Topics

Create useful cross-system groupings:

```text
Commerce
Order
Customer
Authorization
Persistence
Events
Integration
Audit
```

without changing canonical architecture placement.

## Phase 14 — Add constraints

```json
{
  "id": "INV_ORDER_TOTAL_NONNEGATIVE",
  "rule": "Order total MUST NOT be negative."
}
```

## Phase 15 — Validate

Run:

```text
identity closure
architecture closure
reference closure
ownership closure
authority closure
dependency closure
Topic closure
behavior closure
flow closure
reverse trace
gap detection
```

Do not repair missing semantics automatically.

## Phase 16 — Lock

Once applicable gates pass:

```json
{
  "status": "locked"
}
```

The model is now a controlled semantic baseline.

---

# 44. From CanonicalWireframe to source code

CanonicalWireframe separates required semantics from technical realization.

Example:

```json
{
  "id": "OP_ORDER_CREATE",
  "inputs": [
    "ORDER_CREATE_REQUEST"
  ],
  "outputs": [
    "ORDER"
  ]
}
```

may become:

```python
def create_order(request: OrderCreateRequest) -> Order:
    ...
```

or:

```rust
pub fn create_order(
    request: OrderCreateRequest
) -> Result<Order, OrderError> {
    ...
}
```

or:

```typescript
export async function createOrder(
  request: OrderCreateRequest
): Promise<Order> {
  ...
}
```

The canonical operation remains:

```text
OP_ORDER_CREATE
```

The code symbol is an implementation binding.

---

# 45. Implementation bindings

When implementation details matter, they can also be explicit.

Example:

```json
{
  "implementation": {
    "language": "python",
    "runtime": "cpython",
    "minimum_version": "3.12",
    "mapping": {
      "OP_ORDER_CREATE": {
        "module": "orders.service",
        "symbol": "create_order"
      }
    }
  }
}
```

This does not redefine the semantic identity.

It maps the canonical semantic identity into one implementation.

A different implementation may use another language and another symbol while still conforming to the same CW model.

---

# 46. CanonicalWireframe and AI coding

AI makes source-code generation dramatically cheaper.

That changes the bottleneck.

The harder problem increasingly becomes:

> **How precisely can we describe what should be built?**

A coding agent can generate thousands of lines of syntactically correct code and still implement the wrong architecture.

The failure may come from questions such as:

```text
Who owns this?

Where does it belong architecturally?

Is this dependency required?

Who has authority over it?

Does this surface expose or own it?

What happens first?

What happens on failure?

Does this Topic imply placement?

Can this component mutate that state?

Which semantics are reused and which are new?
```

If the specification does not answer those questions, the coding model must.

CanonicalWireframe attempts to move those decisions from hidden implementation guesses into explicit specification data.

---

# 47. The AI coding contract

Instead of:

```text
Here are 250 pages of documentation.

Please implement the application.
```

the target becomes:

```text
Here is the canonical semantic graph.

Every machine-significant identity is explicit.

The architecture tree is explicit.

Every implementation-relevant node has one canonical primary placement.

Architectural kind is explicit.

External surfaces are explicit.

Containment is explicit.

Relations are explicit.

Ownership is explicit.

Authority is explicit.

Dependencies are explicit.

Interfaces and operations are explicit.

Execution-significant causality is explicit.

Unknowns are explicit gaps.

Do not invent missing semantics.

Implement the locked graph using the specified implementation profile.
```

This is a much more constrained engineering problem.

---

# 48. Secure by limitations

CanonicalWireframe can be viewed as a way to bound implementation freedom intentionally.

The implementation may remain free to choose:

```text
algorithm
internal optimization
language idiom
private helper structure
file organization
local data structures
performance strategy
```

while remaining constrained by canonical rules for:

```text
semantic identity
architecture placement
ownership
authority
required dependencies
public behavior
external surfaces
invariants
declared causality
security boundaries
```

This creates a useful principle:

> **Implementation freedom is allowed where semantics do not care.  
> Implementation freedom stops where canonical meaning begins.**

---

# 49. CanonicalWireframe is not a programming language

CW does not attempt to express every implementation detail.

It is not:

```text
Python
Rust
C
Java
TypeScript
SQL
```

It does not automatically define:

- algorithm implementation
- memory layout
- thread scheduling
- framework choice
- internal optimization

Those may be constrained when they are semantically relevant.

Otherwise they remain implementation choices.

The goal is not:

```text
specify every line of code before coding
```

The goal is:

```text
specify everything that must remain semantically true
```

---

# 50. CanonicalWireframe is not a database schema

A database schema describes persistence structure.

CanonicalWireframe can describe the semantics behind persistence.

Example:

```json
{
  "id": "REL_ORDER_CUSTOMER",
  "source_ref": "ORDER",
  "relation_type": "belongs_to",
  "target_ref": "CUSTOMER"
}
```

One implementation might map that to:

```sql
orders.customer_id
```

Another might use:

```text
document reference
graph edge
remote identifier
event-derived projection
in-memory relation
```

The canonical relation stays the same.

---

# 51. CanonicalWireframe is not OpenAPI

OpenAPI is excellent for describing HTTP interfaces.

CanonicalWireframe describes the semantic operation behind them.

For example:

```text
OP_ORDER_CREATE
```

might be exposed as:

```http
POST /orders
```

or:

```text
CLI command
WebSocket message
MCP tool
GUI action
local function
message queue request
```

The protocol binding is not the semantic operation itself.

---

# 52. CanonicalWireframe is not UML or C4

UML and C4 are useful modeling and visualization systems.

CanonicalWireframe differs primarily in authority:

> **The canonical source is structured semantics from which views can be generated.**

From the same CW graph, tooling can produce:

```text
architecture tree
C4-style view
dependency graph
ownership graph
authority graph
entity relation graph
sequence view
state view
Topic view
surface/exposure view
security boundary view
data lineage view
implementation scaffold
```

The diagram becomes a projection.

It does not need to be the source of truth.

---

# 53. One semantic source, many projections

Conceptually:

```text
                     CanonicalWireframe
                            │
        ┌───────────────────┼────────────────────┐
        │                   │                    │
        ▼                   ▼                    ▼
Architecture View     Security View       Runtime View
        │                   │                    │
        ▼                   ▼                    ▼
Dependency View       Authority View      Flow View
        │                   │                    │
        └───────────────────┼────────────────────┘
                            ▼
                       Source Code
```

The same semantic identities survive every projection.

---

# 54. Documentation becomes a projection

Once the graph contains the semantics, human-readable documentation can be generated.

For example:

```text
CanonicalWireframe
        ↓
Documentation generator
        ↓
Markdown
```

Generated output:

```markdown
## Order Service

Architecture:
Commerce → Order Service

The Order Service owns the Order lifecycle.

### Dependencies

- Customer Identity — required
- Order Repository — required
- Payment Service — optional

### Authority

Create Order requires authorization from Access Policy.

### External surfaces

- Order REST API

### Events

- Order Created
- Order Cancelled
```

The documentation no longer has to carry unique machine-significant facts that exist nowhere else.

---

# 55. Architecture visualization becomes a projection

The same graph may generate:

### Architecture placement

```text
Application
└── Commerce
    └── Order Service
```

### Containment

```text
Order Service
└── Order API
    └── Create Order
```

### Dependencies

```text
Order Service
├── Customer Identity
├── Product Catalog
└── Order Repository
```

### Authority

```text
Access Policy
└── controls
    ├── Create Order
    ├── Cancel Order
    └── Refund Order
```

### Ownership

```text
Order Service
└── owns
    ├── Order
    ├── Order lifecycle
    └── Order events
```

### Exposure

```text
Order Service
└── Expose surfaces
    ├── REST API
    └── Web UI
```

Different projections answer different questions.

None should silently replace another semantic dimension.

---

# 56. CanonicalWireframe as an intermediate representation

Compiler design provides a useful analogy.

A compiler often uses:

```text
source syntax
     ↓
intermediate representation
     ↓
target implementation
```

CanonicalWireframe can serve a similar role for software intent:

```text
human requirements
        ↓
CanonicalWireframe
        ↓
Python implementation
```

or:

```text
CanonicalWireframe
        ↓
Rust implementation
```

or:

```text
CanonicalWireframe
        ↓
documentation
```

or:

```text
CanonicalWireframe
        ↓
architecture projection
```

or:

```text
CanonicalWireframe
        ↓
conformance tests
```

The semantic IR becomes the stable center.

---

# 57. The specification becomes testable

Traditional documentation can be reviewed.

CanonicalWireframe can be validated.

Consider the claim:

```text
All order mutations require authorization.
```

A validator can interpret that as a machine-checkable rule:

```text
1. Find every operation classified as an Order mutation.
2. For every operation, resolve its authority edge.
3. Resolve the corresponding execution flow.
4. Verify authorization appears before mutation.
5. Hard-fail any operation that violates the rule.
```

Architectural claims become testable rather than merely reviewable.

---

# 58. Specification entropy

Every unresolved semantic question increases specification entropy.

Examples:

```text
probably
usually
belongs somewhere here
the implementation can figure it out
this likely owns that
the model will understand what we mean
```

Each ambiguity increases the number of legal interpretations.

If the specification allows ten plausible architectures and the AI chooses one, flawless code generation still produces the wrong system nine times out of ten.

CW aims to transform:

```text
many plausible interpretations
            ↓
explicit semantics
            ↓
one intended semantic model
            ↓
multiple conforming implementations
```

Implementation flexibility remains.

Semantic ambiguity is reduced.

---

# 59. A machine-readable definition of intent

CanonicalWireframe can be summarized as:

```text
explicit identity
+ explicit architecture placement
+ explicit architectural kind
+ explicit structure
+ explicit ownership
+ explicit authority
+ explicit dependencies
+ explicit behavior
+ explicit causality
+ explicit external surfaces
+ explicit constraints
+ explicit uncertainty
+ deterministic references
```

The result is a semantic model that both humans and machines can inspect.

---

# 60. Human-readable and machine-readable are not opposites

CanonicalWireframe does not remove prose.

Humans need explanations.

Example:

```json
{
  "prose": {
    "summary": "Create an Order after caller authorization and validation.",
    "notes": [
      "Payment may occur later.",
      "Inventory allocation is owned by another module."
    ]
  }
}
```

The rule is:

> **Prose may explain semantics, but required machine semantics must not exist only in prose.**

Bad:

```json
{
  "prose": {
    "summary": "The Order Service probably checks authorization before saving."
  }
}
```

Better:

```json
{
  "authority": [
    {
      "authority_ref": "ACCESS_POLICY",
      "target_ref": "OP_ORDER_CREATE",
      "authority_type": "authorization",
      "scope": "execute"
    }
  ]
}
```

plus prose explaining why.

---

# 61. A different definition of complete specification

A specification is not complete because:

```text
the document is long
```

or:

```text
the diagram looks detailed
```

or:

```text
every section contains prose
```

A CanonicalWireframe specification approaches completeness when:

```text
Every active identity resolves.

Every architecture node is placed or explicitly unresolved.

Every required parent resolves.

Every architectural kind resolves.

Every required relationship is explicit.

Every ownership edge resolves.

Every authority edge resolves.

Every dependency resolves.

Every external surface resolves.

Every required behavior exists.

Every execution-significant flow closes.

Every reference resolves.

Every unknown is explicitly represented.

No required semantic fact depends on guessing.
```

That is a stronger definition of specification quality.

---

# 62. CanonicalWireframe development loop

A practical development loop becomes:

```text
1. Model
2. Build / update architecture tree
3. Validate
4. Find gaps
5. Resolve gaps
6. Validate again
7. Lock
8. Implement
9. Verify implementation
10. Unlock affected semantics when requirements change
11. Revalidate
12. Lock again
```

The specification becomes an active engineering artifact rather than a frozen document.

---

# 63. Change management

Suppose a locked contract says:

```json
{
  "id": "DEP_ORDER_PAYMENT",
  "required": false
}
```

A new requirement makes Payment mandatory.

The controlled change is conceptually:

```text
unlock
→ change
→ validate affected graph
→ lock
```

New definition:

```json
{
  "id": "DEP_ORDER_PAYMENT",
  "source_ref": "ORDER_SERVICE",
  "target_ref": "PAYMENT_SERVICE",
  "dependency_type": "runtime_required",
  "required": true
}
```

Architecture changes follow the same pattern.

If a component moves:

```json
{
  "ref": "PAYMENT_SERVICE",
  "parent_ref": "ARCH_FINANCE"
}
```

becomes:

```json
{
  "ref": "PAYMENT_SERVICE",
  "parent_ref": "ARCH_COMMERCE_PLATFORM"
}
```

the semantic identity `PAYMENT_SERVICE` does not need to change.

The architecture placement changes.

That difference is precisely why placement must not be encoded in the identity or filesystem path.

---

# 64. Minimal architecture example

```json
{
  "architecture": {
    "id": "ARCH_EXAMPLE_APP",
    "root_ref": "EXAMPLE_APP",
    "nodes": [
      {
        "ref": "CORE",
        "parent_ref": "EXAMPLE_APP",
        "kind_ref": "ARCH_KIND_SUBSYSTEM",
        "surface_refs": []
      },
      {
        "ref": "IDENTITY",
        "parent_ref": "EXAMPLE_APP",
        "kind_ref": "ARCH_KIND_SUBSYSTEM",
        "surface_refs": []
      },
      {
        "ref": "BUSINESS",
        "parent_ref": "EXAMPLE_APP",
        "kind_ref": "ARCH_KIND_SUBSYSTEM",
        "surface_refs": []
      },
      {
        "ref": "ORDER_SERVICE",
        "parent_ref": "BUSINESS",
        "kind_ref": "ARCH_KIND_SERVICE",
        "surface_refs": [
          "SURFACE_ORDER_REST"
        ]
      },
      {
        "ref": "ORDER_REPOSITORY",
        "parent_ref": "ORDER_SERVICE",
        "kind_ref": "ARCH_KIND_COMPONENT",
        "surface_refs": []
      }
    ]
  }
}
```

Projected:

```text
Example App
├── Core
├── Identity
└── Business
    └── Order Service
        └── Order Repository
```

The tree is generated from explicit data.

The directory tree is irrelevant to semantic placement.

---

# 65. Minimal AIGMos domain example

```json
{
  "architecture": {
    "root_ref": "AIGMOS",
    "nodes": [
      {
        "ref": "METAMODULES",
        "parent_ref": "AIGMOS",
        "kind_ref": "ARCH_KIND_GROUP",
        "surface_refs": []
      },
      {
        "ref": "UNIVERSAL_MODULES",
        "parent_ref": "METAMODULES",
        "kind_ref": "ARCH_KIND_METAMODULE_FAMILY",
        "surface_refs": [
          "SURFACE_UNIVERSAL_MODULES_EXPOSE"
        ]
      },
      {
        "ref": "DOMAIN_MODULES",
        "parent_ref": "METAMODULES",
        "kind_ref": "ARCH_KIND_METAMODULE_FAMILY",
        "surface_refs": [
          "SURFACE_DOMAIN_MODULES_EXPOSE"
        ]
      },
      {
        "ref": "BUSINESS",
        "parent_ref": "DOMAIN_MODULES",
        "kind_ref": "ARCH_KIND_DOMAIN_FAMILY",
        "surface_refs": [
          "SURFACE_BUSINESS_EXPOSE"
        ]
      },
      {
        "ref": "ERP",
        "parent_ref": "BUSINESS",
        "kind_ref": "ARCH_KIND_METAMODULE",
        "surface_refs": [
          "SURFACE_ERP_EXPOSE"
        ]
      },
      {
        "ref": "CRM",
        "parent_ref": "BUSINESS",
        "kind_ref": "ARCH_KIND_METAMODULE",
        "surface_refs": [
          "SURFACE_CRM_EXPOSE"
        ]
      },
      {
        "ref": "HRM",
        "parent_ref": "BUSINESS",
        "kind_ref": "ARCH_KIND_METAMODULE",
        "surface_refs": [
          "SURFACE_HRM_EXPOSE"
        ]
      },
      {
        "ref": "STRATEGY",
        "parent_ref": "DOMAIN_MODULES",
        "kind_ref": "ARCH_KIND_DOMAIN_FAMILY",
        "surface_refs": [
          "SURFACE_STRATEGY_EXPOSE"
        ]
      },
      {
        "ref": "EVERYDAY",
        "parent_ref": "DOMAIN_MODULES",
        "kind_ref": "ARCH_KIND_DOMAIN_FAMILY",
        "surface_refs": [
          "SURFACE_EVERYDAY_EXPOSE"
        ]
      },
      {
        "ref": "CALENDAR",
        "parent_ref": "EVERYDAY",
        "kind_ref": "ARCH_KIND_METAMODULE",
        "surface_refs": [
          "SURFACE_CALENDAR_EXPOSE"
        ]
      },
      {
        "ref": "SHOP",
        "parent_ref": "EVERYDAY",
        "kind_ref": "ARCH_KIND_METAMODULE",
        "surface_refs": [
          "SURFACE_SHOP_EXPOSE"
        ]
      }
    ]
  }
}
```

Projected:

```text
AIGMos
└── MetaModules
    ├── Universal Modules
    └── Domain Modules
        ├── Business
        │   ├── ERP
        │   ├── CRM
        │   └── HRM
        ├── Strategy
        └── Everyday
            ├── Calendar
            └── Shop
```

Expose remains an explicit surface property, not a second MetaModule base class.

---

# 66. What CW 1.5 enables

Once software is represented as a machine-readable semantic graph with explicit architecture placement, tooling can answer much richer questions.

### Architecture

```text
Where does this node belong?
What are all children of this architecture node?
Which components are unreachable from the root?
Which nodes have no valid placement?
Which components expose external surfaces?
```

### Validation

```text
Does every reference resolve?
Does every architecture parent resolve?
Are multiple primary placements present?
Are ownership boundaries complete?
Are authority boundaries complete?
Are flows closed?
```

### Security analysis

```text
Which externally exposed operations exist?
Which authority controls each operation?
Which mutation has no declared authority?
Which surface reaches which semantic operation?
```

### Impact analysis

```text
What depends on ORDER?
What uses PAYMENT_SERVICE?
Which Topics reference OP_ORDER_CREATE?
Where is ORDER_SERVICE architecturally placed?
What surfaces expose it?
What breaks if it moves or changes?
```

### AI implementation

```text
Generate implementation scaffold from locked semantics.
```

### Conformance

```text
Compare implementation structure and behavior against the canonical model.
```

---

# 67. The larger idea

Software architecture has traditionally been split between artifacts optimized for humans and artifacts optimized for machines.

Humans read:

```text
diagrams
documents
tickets
```

Machines read:

```text
source code
schemas
configuration
```

A large interpretation gap sits between them.

CanonicalWireframe attempts to reduce that gap by making the intended software system itself machine-readable.

The 1.5 architecture-tree requirement closes an important hole in that model.

It is not enough to know that components exist and that they are related.

A deterministic reader must also know:

> **Where does each component belong in the canonical architecture?**

without inferring the answer from presentation or storage.

---

# 68. CanonicalWireframe 1.5 in one JSON block

```json
{
  "canonical_wireframe": {
    "version": "1.5",
    "principles": [
      "identity_is_explicit",
      "architecture_is_data",
      "primary_architecture_placement_is_explicit",
      "architectural_kind_is_separate_from_placement",
      "external_surfaces_are_explicit",
      "structure_is_data",
      "semantics_are_not_inferred",
      "containment_is_not_ownership",
      "ownership_is_not_authority",
      "authority_is_not_dependency",
      "topics_are_grouping_not_architecture",
      "topics_are_grouping_not_structure",
      "causality_is_explicit",
      "unknowns_are_gaps_not_guesses",
      "one_identity_has_one_active_definition",
      "human_and_machine_views_share_one_semantic_source",
      "representations_may_change_without_changing_semantics"
    ],
    "architecture": {
      "requires_explicit_root": true,
      "requires_primary_placement": true,
      "requires_resolvable_parent": true,
      "requires_resolvable_kind": true,
      "filesystem_is_not_authority": true,
      "topic_membership_is_not_placement": true,
      "silent_global_fallback_allowed": false
    },
    "structural_dimensions": [
      "containment",
      "relations",
      "ownership",
      "authority",
      "dependencies"
    ],
    "behavioral_dimensions": [
      "states",
      "interfaces",
      "operations",
      "events",
      "flows"
    ],
    "validation_goal": {
      "identity_closure": true,
      "architecture_closure": true,
      "reference_closure": true,
      "structural_closure": true,
      "behavioral_closure": true,
      "topic_closure": true,
      "reverse_traceability": true,
      "semantic_guessing_required": false
    },
    "result": "a deterministic machine-readable semantic specification from which software, documentation and projections can be derived"
  }
}
```

---

# 69. Final principle

The question behind CanonicalWireframe is:

> **What would software specification look like if a machine were never allowed to guess what we meant?**

CW 1.5 answers:

- identity must be explicit
- architecture placement must be explicit
- kind must be explicit
- external surfaces must be explicit
- structure must be explicit
- ownership must be explicit
- authority must be explicit
- dependencies must be explicit
- behavior must be explicit
- causality must be explicit
- uncertainty must be explicit

The goal is not to eliminate implementation freedom.

The goal is to eliminate accidental semantic freedom.

AI can already generate enormous amounts of code.

The increasingly important question is:

> **How little does the AI have to guess before generating it?**

CanonicalWireframe is designed to drive that number toward zero.

---

## Reference status

This document describes the **CanonicalWireframe 1.5 candidate model**.

The currently locked AIGMos canonical baseline is Canonical Contract Format 1.4. The 1.5 work extends that model with explicit canonical architecture-tree semantics, primary placement, architectural classification and architecture closure validation.

Before 1.5 is declared locked, its exact serialization, architecture registry contract and validation gates should pass the same canonical process:

```text
unlock
→ change
→ validate
→ lock
```
