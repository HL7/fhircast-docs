
{:.grid}
Term | Description
---- | ---
session | an abstract concept representing a shared workspace, such as a user's login session across multiple applications or a shared view of one application distributed to multiple users - a session results from a user logging into an application and can encompass one or more workflows
topic | an identifier of a session
Subscriber | an application which subscribes to and requests or receives session events
Hub | handles subscription requests, session change requests, and distributes events to Subscribers
context | a FHIR resource associated with a session which indicates a subject on which applications should synchronize as appropriate to their functionality
current context | the context associated with a session that is active at a given time
anchor resource | a context that is used as a container for shared content, typical anchor contexts are resources such as Patient, Encounter, ImagingStudy, and DiagnosticReport
content | resources created during a user's interaction with the anchor context - for example, if the anchor context is an imaging study the user may make a measurement resulting in an observation containing measurement information, the shared content either directly or indirectly references the anchor context
session event | a user initiated workflow event, communicated to clients, containing the current context
container | the set of resources related to an anchor resource consisting of the resource itself, all resources referring to the resource and all resources the anchor resource refers to.
anchor context | a context that is used as a container for shared content, typical anchor contexts are FHIR resources such as Patient, Encounter, ImagingStudy, and DiagnosticReport
content | FHIR resources created during a user's interaction with the anchor context and shared with other Subscribers; shared content either directly or indirectly references the anchor context - for example, if the anchor context is an imaging study the user may make a measurement resulting in a FHIR observation containing measurement information which is shared with other Subscribers
session event | a user initiated workflow event, communicated to Subscribers, containing the current context or shared content
