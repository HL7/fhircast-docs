
{:.grid}
Term | Description
---- | ---
**Anchor Context** | a context that is used as a container for shared content, typical anchor contexts are FHIR resources such as `ImagingStudy` and `DiagnosticReport`
**Container** | the set of resources related to an anchor resource consisting of the resource itself, all resources referring to the resource and all resources the anchor resource refers to.
**Content** | FHIR resources created during a user's interaction with the anchor context and shared with other Subscribers; shared content either directly or indirectly references the anchor context - for example, if the anchor context is a `DiagnosticReport` the user may make a measurement resulting in a FHIR observation containing measurement information which is shared with other Subscribers.
**Context** | a FHIR resource associated with a session which indicates a subject on which applications should synchronize as appropriate to their functionality
**Current Context** | the context associated with a session that is active at a given time, that is the context of the last *-open for which no *-close has occurred.
**Hub** | handles subscription requests, session change requests, and distributes events to Subscribers
**Session Event** | a user initiated workflow event, communicated to Subscribers, containing the current context or shared content
**Subscriber** | an application which subscribes to and requests or receives session events
**Topic** | an identifier of a session
