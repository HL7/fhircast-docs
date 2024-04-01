FHIRcast describes a workflow event subscription and notification scheme with the goal of improving a clinician's workflow across multiple disparate applications. The set of events defined in this specification is not a closed set; anyone is able to define new events to fit specific use cases and are encouraged to propose those events to the community for standardization.

New events are proposed in a prescribed format using the [event template](3-1-1-template.html) by submitting a [pull request](https://github.com/fhircast/docs/tree/master). FHIRcast events are versioned, and mature according to the [event maturity model](3-1-2-eventmaturitymodel.html).

FHIRcast context events do not communicate previous contexts. For a given event, open and close events are complete replacements of previous communicated context change events, not "deltas". Understanding a context change event SHALL NOT require receiving a previous or future event.

### Event Definition Format

Each event definition specifies a single event name, a description of the workflow in which the event occurs, and contextual information associated with the event. FHIR is the interoperable data model used by FHIRcast. The context information associated with an event is communicated as subsets of FHIR resources. Resources are formatted in [the fhir+json json representation as defined by the base FHIR specification](https://www.hl7.org/fhir/json.html). Event notifications SHALL include the elements of the FHIR resources defined in the context from the event definition. Event notifications MAY include other elements of these resources.

All events are documented in the [standard event catalog](3_Events.html) and SHALL be defined in the following format.

{:.grid}
Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The session topic given in the subscription request. MAY be a Universally Unique Identifier ([UUID](https://tools.ietf.org/html/rfc4122)).
`hub.event` | Required | string | The event that triggered this notification, taken from the list of events from the subscription request.
`context`   | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred.
`versionId`   | Conditional| string | A string displaying the context's version ID. `versionId` SHALL be present for *-update events.
`priorVersionId`   | Optional | string | A string displaying the context's previous version ID.

The notification's `hub.event` and `context` fields inform the Subscriber of the current state of the user's session. The `hub.event` is a user workflow event, from the [Event Catalog](3_Events.html) (or an organization-specific event in reverse-domain name notation). The `context` is an array of named FHIR resources (similar to [CDS Hooks's context](https://cds-hooks.hl7.org/1.0/#http-request_1) field) that describe the current content of the user's session. Each event in the [Event Catalog](3_Events.html) defines what context is included in the notification. The context contains zero, one, or more FHIR resources. Hubs SHOULD use the [FHIR _elements parameter](https://www.hl7.org/fhir/search.html#elements) to limit the size of the data being passed while also including additional, local identifiers that are likely already in use in production implementations. Subscribers SHALL accept a full FHIR resource or the [_elements](https://www.hl7.org/fhir/search.html#elements)-limited resource as defined in the Event Catalog.

The Subscriber requesting a context change SHALL ensure consistency of the FHIR resources in the `context` array.  For example, the Hub will not check that the Patient resource in an Encounter-open `context` array is in fact the patient associated with the encounter in the real world.

### Event name

The event name defines the event. Most FHIRcast events conform to an extensible syntax based upon FHIR resources.

Patterned after the SMART on FHIR scope syntax and expressed in EBNF notation, the FHIRcast syntax for context change related events is:

```ebnf
EventName ::= (FHIRresource | '*') ('-') ( 'open' | 'close' | 'update' | 'select' | '*' )
```

{% include img.html img="EventName.png" caption="Figure: Event-name specification" %}

The `FHIRresource` indicates the focus of the event; the `suffix` defines the type of event.

Event names are unique and case-insensitive. It is RECOMMENDED to use [Upper-Camel](https://en.wikipedia.org/wiki/Camel_case) case.

Implementers may define their own events. Such proprietary events SHALL be named with reverse domain notation (e.g. `org.example.patient_transmogrify`). Reverse domain notation SHALL NOT be used by a standard event catalog. Proprietary events SHALL NOT contain a dash ("-").

When subscribing to FHIRcast events a list of events is added. These events may contain wild cards. Wild cards are expressed as a `*` replacing either the `FHIRresource` or `suffix`  with `*` indicates any events that match the resulting definition are requested. The event `*` means the Subscriber subscribes to any event. The table below shows some typical examples.

{:.grid}
| **Event** | **Description** |
|=======|=============|
| `*`   | All events  |
| `*-*` | All events with a FHIRcast defined postfix |
| `Patient-*` | All events that use the `Patient` FHIR resource |
| `*-update` | All update events |
| `*-select` | All select events |

### Context

Describes the set of contextual data associated with this event. Only data logically and necessarily associated with the purpose of this workflow related event should be represented in context. An event SHALL contain all required data fields, MAY contain optional data fields and SHALL NOT contain any additional fields. Events defined in the standard event catalog or by implementers SHALL contain only valid JSON and MAY contain FHIR resources.

All fields available within an event's context SHALL be defined in a table where each field is described by the following attributes:

- **Key**: The name of the field in the context JSON object. Event authors SHOULD name their context fields to be consistent with other existing events when referring to the same context field. The key name SHALL be lower case and implementations SHALL treat them as case-sensitive.
- **Cardinality**: Indicates the optionality and maximum resources instances allowed in an event's context
- **FHIR operation to generate context**: A FHIR read or search string illustrating the intended content of the event.
- **Description**: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

A Hub SHALL at least send the elements indicated in *FHIR operation to generate context*; a Subscriber SHALL gracefully handle receiving a full FHIR resource in the context of a notification. For example, when the [`ImagingStudy-open`](3-5-1-ImagingStudy-open.html) event occurs, the notification sent to a Subscriber includes an ImagingStudy FHIR resource, which contains at least the elements defined in the *_elements* query parameter, as indicated in the event's definition. For ImagingStudy, this is defined as: `ImagingStudy/{id}?_elements=identifier`. (The *_elements* query parameter is defined in the [FHIR specification](https://www.hl7.org/fhir/search.html#elements)).

The key used for indicating an event's anchor FHIR resource SHALL be the lower-case resourceType of the resource. The resources to include is defined in the corresponding event definition in the [event catalog](3-Event.html).


References to resources other than anchor resources SHALL be named any string which is not a value from the resource type valueset.

In the case in which other events are deriveable from the event in question, additional non-anchor FHIR resources included in the event SHALL be named what they are named in the deriveable event.

The Hub SHALL only return FHIR resources that the Subscriber is authorized to receive with the existing OAuth 2.0 access_token's granted `fhircast/` scopes.

### Event types

The FHIRcast specification supports many different events. These events are defined in the [event catalog](3_Events.html). The events can be grouped in different types. The following sections define the characteristics of these different event-types.

#### Context-change events

FHIRcast context-change events that describe context changes SHALL conform to the following extensible syntax. Patterned after the SMART on FHIR scope syntax and expressed in EBNF notation, the FHIRcast syntax for context-change related event names is:

```ebnf
ContextChangeEventName ::= ( FHIRresource ) '-' ( 'open' | 'close' )
```

{% include img.html img="ContextEventName.png" caption="Figure: Context Event-name specification" %}

Context change events SHALL include the resource the context change relates to. Common FHIR resources are: Patient, Encounter, ImagingStudy, and DiagnosticReport.

In the case the resource refers to other FHIR resources that represent their own context, these can be included as well. For example, an [`Encounter-open`](3-4-1-Encounter-open.html) also refers to the patient that is the subject of the Encounter. What resources to include is defined in the corresponding event definition in the [event catalog](3_Events.html).

FHIRcast defines profiles for FHIR resources used in `*-open` and `*-close` events documented in the [`event catalog`](3_Events.html).  Each resource used to establish context has a profile for when that resource is used in an `*-open` event and a different profile for when that resource is used in a `*-close` event.  The profiles for *-`open` events mandate more attributes than those for `*-close` events since all Subscribers need enough information to identify the appropriate information associated with the context resource(s) in their application enabling them to participate in a common context.

FHIRcast does not mandate that contextual subjects have any FHIR persistance; sufficient information to establish a common context may simply be exchanged using FHIR resources as the structure to hold the necessary information without the resources ever existing in a FHIR server (in fact it may be that there is no FHIR server in the infrastructure associated with any Subscriber synchronizing in a FHIRcast topic).  As this is an FHIR R4 implementation guide, all profiles and examples conform to FHIR R4 resource specifications. Where relevant/required, notes have been added to the description of the resource profiles indicating how to use the resources in a FHIRcast session using FHIR R5-based resources.

__`*-open` Event Resource Profiles:__
* [`Patient`](StructureDefinition-fhircast-patient-open.html)
* [`Encounter`](StructureDefinition-fhircast-encounter-open.html)
* [`ImagingStudy`](StructureDefinition-fhircast-imaging-study-open.html)
* [`DiagnosticReport`](StructureDefinition-fhircast-diagnostic-report-open.html)

__`*-close` Event Resource Profiles:__
* [`Patient`](StructureDefinition-fhircast-patient-close.html)
* [`Encounter`](StructureDefinition-fhircast-encounter-close.html)
* [`ImagingStudy`](StructureDefinition-fhircast-imaging-study-close.html)
* [`DiagnosticReport`](StructureDefinition-fhircast-diagnostic-report-close.html)

FHIRcast supports all events that follow this format. The most common events definitions have been provided in the [event catalog](3_Events.html).

#### Infrastructure events

This event category contains events required to maintain a FHIRcast session. The main events in this category are:

| [`SyncError`](3-2-1-SyncError.html) | indicates refusal to follow context or inability to deliver an event
| [`Heartbeat.html`](3-2-2-Heartbeat.html) | for monitoring the connection to the hub

#### Content sharing events

Content sharing events use the suffix `update`. The format of selection event names is:

```ebnf
ContentSharingEventName ::= ( FHIRresource ) '-' ( 'update' )
```

{% include img.html img="ContentSharingEventName.png" caption="Figure: Content sharing event-name specification" %}

`*-update` events provide a mechanism to share content in the context of an `anchor context` (see [`anchor context`](5_glossary.html)). `*-update` events update the content within the specified anchor context; said another way, most `*-update` events are not changing the `anchor context` resource rather creating, modifying, or removing the content within the `anchor context`.  A Subscriber shares content related to the anchor context by providing FHIR resource(s) in a `Bundle` contained in the `updates` key of a `*-update` event. See [`Content Sharing`](2-10-ContentSharing.html) for a comprehensive description of `*-update` events. The FHIRresource indicates the anchor context in which content is being shared.

The `context` element in an update event SHALL contain at least two fields. One with the name of the `FHIRresource` which holds the anchor context and one named `updates` holding a single `Bundle` resource with entries holding the content being shared.  The `Bundle` resource SHALL conform to the [FHIRcast content update Bundle](StructureDefinition-fhircast-content-update-bundle.html) profile. 

FHIRcast supports all events that follow this format. The most common events definitions have been provided in the [event catalog](3_Events.html). For an example see [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html).

#### Selection events - Experimental


Selection events use the suffix `select`. The format of selection event names is:

```ebnf
SelectionEventName ::= ( FHIRresource  ) '-' ( 'select' )
```

{% include img.html img="SelectionEventName.png" caption="Figure: Selection Event-name specification" %}

`*-select` events provide a mechanism to select content in the context an `anchor context` (see [`anchor context`](5_glossary.html)).  `*-select` events select content resources within the `anchor context`, not the `anchor context` itself (making the `anchor context` the current context is performed by the corresponding `*-open` event).  The `context` array in a select event contains two attributes.  The FHIR resource which is the `anchor context`, and a select array indicating the content resource(s) that are selected.  If the Subscriber wants to indicate that no resource is selected, the select attribute is an empty array.

FHIRcast supports all events that follow this format. The most common events definitions have been provided in the [event catalog](3_Events.html). For an example see [`DiagnosticReport-select`](3-6-4-DiagnosticReport-select.html).