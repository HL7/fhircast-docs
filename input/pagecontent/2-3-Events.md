FHIRcast describes a workflow event subscription and notification scheme with the goal of improving a clinician's workflow across multiple disparate applications. The set of events defined in this specification is not a closed set; anyone is able to define new events to fit specific use cases and are encouraged to propose those events to the community for standardization.

New events are proposed in a prescribed format using the [documentation template](3-1-template.html) by submitting a [pull request](https://github.com/fhircast/docs/tree/master). FHIRcast events are versioned, and mature according to the [Event Maturity Model](3-0-EventMaturityModel.html).

FHIRcast events do not communicate previous state. For a given event, opens and closes are complete replacements of previous communicated events, not "deltas". Understanding an event SHALL not require receiving a previous or future event.

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

Most FHIRcast events conform to an extensible syntax based upon FHIR resources. In the case where the FHIR data model doesn't describe context changes in the session, FHIRcast events MAY be named differently. For example, FHIR doesn't cleanly contain the concept of a user or user's session.  

FHIRcast events that describe context changes SHOULD conform to the following extensible syntax.

Patterned after the SMART on FHIR scope syntax and expressed in EBNF notation, the FHIRcast syntax for context change related events is:

`hub.events ::= ( fhir-resource | '*' ) '-' ( 'open' | 'close' | '*' )`

{% include img.html img="events-railroad.png" caption="Figure: Syntax for FHIRcast events" %}

Event names are unique and case-insensitive. Implementers may define their own events. Such proprietary events SHALL be named with reverse domain notation (e.g. `org.example.patient_transmogrify`). Reverse domain notation SHALL NOT be used by a standard event catalog. Proprietary events SHALL NOT contain a dash ("-").

### Context

Describes the set of contextual data associated with this event. Only data logically and necessarily associated with the purpose of this workflow related event should be represented in context. An event SHALL contain all required data fields, MAY contain optional data fields and SHALL NOT contain any additional fields.

All fields available within an event's context SHALL be defined in a table where each field is described by the following attributes:

- **Key**: The name of the field in the context JSON object. Event authors SHOULD name their context fields to be consistent with other existing events when referring to the same context field.
- **Optionality**: A string value of either `Required`, `Optional` or `Conditional`
- **FHIR operation to generate context**: A FHIR read or search string illustrating the intended content of the event.
- **Description**: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

A Hub SHALL at least send the required elements; a subscriber SHALL gracefully handle receiving a full FHIR resource in the context of a notification.

Context change events will include the resource the context change relates to. Common FHIR resources are: Patient, Encounter, and ImagingStudy.

For example, when the [`ImagingStudy-open`](3-6-imagingstudy-open.html) event occurs, the notification sent to a subscriber includes an ImagingStudy FHIR resource, which includes at least the elements defined in the *_elements* query parameter, as indicated in the event's definition. For ImagingStudy, this is defined as: `ImagingStudy/{id}?_elements=identifier`. (The *_elements* query parameter is defined in the [FHIR specification](https://www.hl7.org/fhir/search.html#elements)).

The key used for indicating a context change event's FHIR resource SHALL be the lower-case resourceType of the resource. In the case the resource refers to other FHIR resources that represent their own context, these can be included as well. The resources to include are defined in the corresponding event definition in the [event catalog](3_Events.html).

The Hub SHALL only return FHIR resources that the subscriber is authorized to receive with the existing OAuth 2.0 access_token's granted `fhircast/` scopes.
