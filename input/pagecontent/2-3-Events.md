FHIRcast describes a workflow event subscription and notification scheme with the goal of improving a clinician's workflow across multiple disparate applications. The set of events defined in this specification is not a closed set; anyone is able to define new events to fit specific use cases and are encouraged to propose those events to the community for standardization.

New events are proposed in a prescribed format using the [event template](3-1-1-template.html) by submitting a [pull request](https://github.com/fhircast/docs/tree/master). FHIRcast events are versioned, and mature according to the [event maturity model](3-1-2-eventmaturitymodel.html).

FHIRcast context events do not communicate previous contexts. For a given event, open and close events are complete replacements of previous communicated context change events, not "deltas". Understanding a context change event SHALL not require receiving a previous or future event.

### Event Definition Format

Each event definition: specifies a single event name, a description of the workflow in which the event occurs, and contextual information associated with the event. FHIR is the interoperable data model used by FHIRcast. The context information associated with an event is communicated as subsets of FHIR resources. Event notifications SHALL include the elements of the FHIR resources defined in the context from the event definition. Event notifications MAY include other elements of these resources.

All events are documents in the [standard event catalog](3_Events.html) and SHALL be defined in the following format.

Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The session topic given in the subscription request. MAY be a UUID.
`hub.event` | Required | string | The event that triggered this notification, taken from the list of events from the subscription request.
`context`   | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred.

The notification's `hub.event` and `context` fields inform the subscriber of the current state of the user's session. The `hub.event` is a user workflow event, from the [Event Catalog](3_Events.html) (or an organization-specific event in reverse-domain name notation). The `context` is an array of named FHIR resources (similar to [CDS Hooks's context](https://cds-hooks.hl7.org/1.0/#http-request_1) field) that describe the current content of the user's session. Each event in the [Event Catalog](3_Events.html) defines what context is included in the notification. The context contains zero, one, or more FHIR resources. Hubs SHOULD use the [FHIR _elements parameter](https://www.hl7.org/fhir/search.html#elements) to limit the size of the data being passed while also including additional, local identifiers that are likely already in use in production implementations. Subscribers SHALL accept a full FHIR resource or the [_elements](https://www.hl7.org/fhir/search.html#elements)-limited resource as defined in the Event Catalog.

### Event name

The event name defines the event. Most FHIRcast events conform to an extensible syntax based upon FHIR resources. 


Patterned after the SMART on FHIR scope syntax and expressed in EBNF notation, the FHIRcast syntax for context change related events is:

The `fhir-resource` indicates the focus of the event; the `suffix` defines the type of event.

{% include img.html img="events-railroad.png" caption="Figure: Syntax for FHIRcast events" %}

Event names are unique and case-insensitive. Implementers may define their own events. Such proprietary events SHALL be named with reverse domain notation (e.g. `org.example.patient_transmogrify`). Reverse domain notation SHALL NOT be used by a standard event catalog. Proprietary events SHALL NOT contain a dash ("-").

When subscribing to FHIRcast events a list of events is added. These events may contain wild cards. Wild cards are expressed as a `*` replacing either the `fhir-resource` or `suffix`  with `*` indicates any events that match the resulting definition are requested. The event `*` means the subscriber subscribes to any event. The table below shows some typical examples.

| **Event** | **Description** |
|=======|=============|
| `*`   | All events  |
| `*-*` | All events  |
| `Patient-*` | All events that use the `Patient` fhir-resource |
| `*-select` | All select events |
| `*-update` | All events updating content in the specified context |

### Context

Describes the set of contextual data associated with this event. Only data logically and necessarily associated with the purpose of this workflow related event should be represented in context. An event SHALL contain all required data fields, MAY contain optional data fields and SHALL NOT contain any additional fields.

All fields available within an event's context SHALL be defined in a table where each field is described by the following attributes:

- **Key**: The name of the field in the context JSON object. Event authors SHOULD name their context fields to be consistent with other existing events when referring to the same context field.
- **Optionality**: A string value of either `Required`, `Optional` or `Conditional`
- **FHIR operation to generate context**: A FHIR read or search string illustrating the intended content of the event.
- **Description**: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

A Hub SHALL at least send the elements indicated in *FHIR operation to generate context*; a subscriber SHALL gracefully handle receiving a full FHIR resource in the context of a notification. For example, when the [`ImagingStudy-open`](3-5-1-imagingstudy-open.html) event occurs, the notification sent to a subscriber includes an ImagingStudy FHIR resource, which includes at least the elements defined in the *_elements* query parameter, as indicated in the event's definition. For ImagingStudy, this is defined as: `ImagingStudy/{id}?_elements=identifier`. (The *_elements* query parameter is defined in the [FHIR specification](https://www.hl7.org/fhir/search.html#elements)).

Many events refer to a resource the event relates to. Common FHIR resources are: Patient, Encounter, and ImagingStudy.

For example, when the [`ImagingStudy-open`](3-5-1-imagingstudy-open.html) event occurs, the notification sent to a subscriber includes an ImagingStudy FHIR resource, which includes at least the elements defined in the *_elements* query parameter, as indicated in the event's definition. For ImagingStudy, this is defined as: `ImagingStudy/{id}?_elements=identifier`. (The *_elements* query parameter is defined in the [FHIR specification](https://www.hl7.org/fhir/search.html#elements)).

The key used for indicating a context change event's FHIR resource SHALL be the lower-case resourceType of the resource. In the case the resource refers to other FHIR resources that represent their own context, these can be included as well. The resources to include are defined in the corresponding event definition in the [event catalog](3_Events.html).

The Hub SHALL only return FHIR resources that the subscriber is authorized to receive with the existing OAuth 2.0 access_token's granted `fhircast/` scopes.

### Event types

The FHIRcast specification supports many different events. These events are defined in the [event catalog](3_Events.html). The events can be grouped in different types. The following sections define the characteristics of these different event-types.

#### Context-change events

FHIRcast context-change events that describe context changes SHALL conform to the following extensible syntax. Patterned after the SMART on FHIR scope syntax and expressed in EBNF notation, the FHIRcast syntax for context-change related events is:

`hub.events ::= ( fhir-resource  ) '-' ( 'open' | 'close' )`

Context change events will include the resource the context change relates to. Common FHIR resources are: Patient, Encounter, ImagingStudy and DiagnosticReport.

In the case the resource refers to other FHIR resources that represent there own context, these can be included as well. For example, an [`Encounter-open`](3-4-1-encounter-open.html) also refers to the patient that is the subject of the Encounter. What resources to include is defined in the corresponding event definition in the [event catalog](3_Events.html).

FHIRcast supports all events that follow this format. The most common events definitions have been provided in the [event catalog](3_Events.html).


#### Infrastructure events

This event category contains events required to maintain a FHIRcast session. The main events in this category are:


| [`syncerror`](3-2-1-syncerror.html) | indicates refusal to follow context or inability to deliver an event
| [`heartbeat`](3-2-2-heartbeat.html) | for monitoring the connection to the hub

#### Selection events

Selection events use the suffix `select`. The format of selection events is:

`hub.events ::= ( fhir-resource  ) '-' ( select )`

The `fhir-resource` indicates the context of the selection. The `context` element in a select event typically contains two fields. One with the name of the `fhir-resource` holding a the anchor resource and one or more named `select` indicating the resources that is selected.


This allows of communication of different select sets for the different anchor-types.
