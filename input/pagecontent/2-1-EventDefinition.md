### <a name="events"></a> Events

FHIRcast describes a workflow event subscription and notification scheme with the goal of improving a clinician's workflow across multiple disparate applications. The set of events defined in this specification is not a closed set; anyone is able to define new events to fit specific use cases and are encouraged to propose those events to the community for standardization. 

New events are proposed in a prescribed format using the [documentation template](../../events/template) by submitting a [pull request](https://github.com/fhircast/docs/tree/master/docs/events). FHIRcast events are versioned, and mature according to the [Event Maturity Model](#event-maturity-model).

FHIRcast events do not communicate previous state. For a given event, opens and closes are complete replacements of previous communicated events, not "deltas". Understanding an event SHALL not require receiving a previous or future event.

#### Event Definition Format

Each event definition: specifies a single event name, a description of the workflow in which the event occurs, and contextual information associated with the event. FHIR is the interoperable data model used by FHIRcast. The context information associated with an event is communicated as subsets of FHIR resources. Event notifications SHALL include the elements of the FHIR resources defined in the context from the event definition. Event notifications MAY include other elements of these resources.

For example, when the [`ImagingStudy-open`](../../events/imagingstudy-open) event occurs, the notification sent to a subscriber SHALL include an ImagingStudy FHIR resource, which includes at least the elements defined in the *_elements* query parameter, as indicated in the event's definition. For ImagingStudy, this is defined as: `ImagingStudy/{id}?_elements=identifier,accession`. (The *_elements* query parameter is defined in the [FHIR specification](https://www.hl7.org/fhir/search.html#elements)). 

A Hub SHALL at least send the required elements; a subscriber SHALL gracefully handle receiving a full FHIR resource in the context of a notification.

Each defined event in the standard event catalog SHALL be defined in the following format.

##### Event Definition Format: hook-name

Most FHIRcast events conform to an extensible syntax based upon FHIR resources. In the rare case where the FHIR data model doesn't describe content in the session, FHIRcast events MAY be named differently. For example, FHIR doesn't cleanly contain the concept of a user or user's session.  

Patterned after the SMART on FHIR scope syntax and expressed in EBNF notation, the FHIRcast syntax for workflow related events is:

`hub.events ::= ( fhir-resource | '*' ) '-' ( 'open' | 'close' | '*' )`

{% include img.html img="events-railroad.png" caption="Figure: Syntax for new events" %}

FHIRcast events SHOULD conform to this extensible syntax.

Event names are unique and case-insensitive. Implementers may define their own events. Such proprietary events SHALL be named with reverse domain notation (e.g. `org.example.patient_transmogrify`). Reverse domain notation SHALL NOT be used by a standard event catalog. Proprietary events SHALL NOT contain a dash ("-").

##### Event Definition Format: Workflow

Describe the workflow in which the event occurs. Event creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementers.

##### Event Definition Format: Context

Describe the set of contextual data associated with this event. Only data logically and necessarily associated with the purpose of this workflow related event should be represented in context. An event SHALL contain all required data fields, MAY contain optional data fields and SHALL NOT contain any additional fields.
 
All fields available within an event's context SHALL be defined in a table where each field is described by the following attributes:

- **Key**: The name of the field in the context JSON object. Event authors SHOULD name their context fields to be consistent with other existing events when referring to the same context field.
- **Optionality**: A string value of either `Required`, `Optional` or `Conditional`
- **FHIR operation to generate context**: A FHIR read or search string illustrating the intended content of the event. 
- **Description**: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

### Session Discovery

A session is an abstract concept representing a shared workspace, such as user's login session over multiple applications or a shared view of one application distributed to multiple users. FHIRcast requires a session to have a unique, unguessable, and opaque identifier. This identifier is exchanged as the value of the `hub.topic` parameter. Before establishing a subscription, an app must not only know the `hub.topic`, but also the `hub.url` which contains the base URL of the Hub.

Systems SHOULD use SMART on FHIR to authorize, authenticate, and exchange initial shared context. If using SMART, following a [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch#ehr-launch-sequence) or [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence), the app SHALL request and, if authorized, SHALL be granted one or more FHIRcast OAuth 2.0 scopes. Accompanying this scope grant, the authorization server SHALL supply the `hub.url` and `hub.topic` SMART launch parameters alongside the access token and other parameters appropriate to establish initial shared context. Per SMART, when the `openid` scope is granted, the authorization server additionally sends the current user's identity in an `id_token`.

Although FHIRcast works best with the SMART on FHIR launch and authorization process, implementation-specific launch, authentication, and authorization protocols may be possible. If not using SMART on FHIR, the mechanism enabling the app to discover the `hub.url` and `hub.topic` is not defined in FHIRcast. See [other launch scenarios](/launch-scenarios) for guidance.

