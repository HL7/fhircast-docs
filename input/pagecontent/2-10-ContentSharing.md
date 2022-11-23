In addition to basic context synchronization, FHIRcast supports real-time exchange of resources between clients subscribed to the same topic.  Content is exchanged using FHIR resources contained in the most recently opened context which serves as the anchor context of exchanged information (see [`anchor context`](5_glossary.html)). 

A key concept of the content sharing events is that the content is shared in a transactional manner.  The diagram below shows a series of operations beginning with a `[FHIR resource]-open` request followed by three `[FHIR resource]-update` requests.  The content in an anchor context is built up by the successive `[FHIR resource]-update` requests which contain only changes to the current state.  These changes are propagated by the Hub to all subscribed clients using `[FHIR resource]-update` events containing only the changes to be made.

{% include img.html img="TransactionalUpdates.png" caption="Figure: Transactional Content Sharing Approach" %}

In order to avoid lost updates and other out of sync conditions, the Hub serves as the transaction coordinator.  It fulfills this responsibility by creating a version of the content's state with each update operation.  If an operation is requested by a client which provides an incorrect version, this request is rejected.  This approach is similar to the version concurrency approach used by [FHIR versions and managing resource contention](https://www.hl7.org/fhir/http.html#concurrency).  Additionally, many of the FHIRcast content sharing concepts have similarities to the [FHIR messaging mechanisms](https://www.hl7.org/fhir/messaging.html) and where possible the approaches and structures are aligned.

FHIR resources are used to convey the structured information being exchanged in `[FHIR resource]-update` operations.  However, it is possible that these resources are never persisted in a FHIR server.  During the exchange of information, the content (FHIR resource instances) is often very dynamic in nature with a user creating, modifying, and even removing information which is being exchanged.  For example, a measurement made in an imaging application could be altered many times before it is finalized and it could be removed.

### Responsibilities of a FHIRcast Hub and a Subscribed Client

Support of content sharing by a Hub is optional.  If supporting content sharing, a FHIRcast Hub MUST fulfill additional responsibilities:

1. Assign and maintain an anchor context's `context.versionId` when processing a `[FHIR resource]-open` request - the `context.versionId` does not need to follow any convention but must unique in the scope of a topic  
2. Reject `[FHIR resource]-update` and `[FHIR resource]-select` requests if the version does not match the current `context.versionId` by returning a 4xx/5xx HTTP Status Code rather than updating the content or indication of selection
3. Assign and maintain a new `context.versionId` for the anchor context's content and provide the new `context.versionId` along with the `context.priorVersionId` in the event corresponding to the validated update request
4. Process each `[FHIR resource]-update` request in an atomic fashion and maintain a list of current FHIR resource content in the anchor context so that it may provide the anchor context's content in response to a [`GET Context`](2-9-GetCurrentContext.html) request
5. When a `[FHIR resource]-close` request is received, the Hub should dispose of the content for the anchor context since the Hub has no responsibility to persist the content
6. Forward a `[FHIR resource]-select` event to all subscribed applications 

A Hub is not responsible for structurally validating FHIR resources.  While a Hub must be able to successfully parse FHIR resources sufficiently to perform its required capabilities (e.g., find the `id` of a resource), a Hub is not responsible for additional structural checking.  If the Hub does not rejects an update request, for any reason, it SHALL reject the entire request - it SHALL NOT accept some changes specified in the bundle and reject others.

A Hub is not responsible for any long-term persistence of shared information and should purge the content when a `[FHIR resource]-close` request is received.

Additionally, a Hub is not responsible to prevent applications participating in exchanging structured information from causing inconsistencies in the information exchanged.  For example, an inconsistency could arise if an application removes from the anchor context's content a resource which is referenced by another resource.  The Hub may check `[FHIR resource]-update` requests for such inconsistencies and MAY reject the request with an appropriate error message; however, it is not required to do so.  Additionally, a Hub MAY check for inconsistencies which it deems to be critical but not perform exhaustive validation. For example, a Hub could validate that the content in a `DiagnosticReport` anchor context always includes at least one primary imaging study.

Clients wishing to exchange structured information MUST:

1. Handle FHIRcast events for anchor context types it supports: [FHIR resource]-[open\|update\|close\|select]
2. Use a `[FHIR resource]-open` request to open a new resource which becomes the anchor context
3. Make a `[FHIR resource]-update` request when appropriate. The `[FHIR resource]-update` request contains a `Bundle` resource which is a collection of resources that are atomically processed by the Hub with the anchor context's content being adjusted appropriately
4. Maintain the current `context.versionId` of the anchor context provided by the Hub so that a subsequent `[FHIR resource]-update` request may provide the current `context.versionId` which will be validated by the Hub
5. Appropriately process [FHIR resource]-[open\|update\|close\|select] events; note that a client may choose to ignore the contents of a `[FHIR resource]-update` event but should still track the `context.versionId` for subsequent use
6. If a `[FHIR resource]-update` request fails with the Hub, the client may issue a [`GET Context`](2-9-GetCurrentContext.html) request to the Hub in order to retrieve the current content in the anchor context and its current `context.versionId`
7. Send and respond to a `[FHIR resource]-select` event as appropriate for their use case

### FHIR Resource Profiles for Content Sharing

The following profiles ensure a basic level of interoperability between applications participating in a content sharing session:

* ImagingStudy
* DiagnosticReport
* [`Observation`](StructureDefinition-fhircast-observation.html)

#### Diagnostic Report Centered Workflow Events

When the anchor context is a 'DiagnosticReport' the following events are possible during content sharing.

{:.grid}
Operation | Description
--- | ---
[`DiagnosticReport-open`](3-6-1-diagnosticreport-open.html) | This notification is used to begin a new report. This should be the first event and establishes the anchor context.
[`DiagnosticReport-update`](3-6-3-diagnosticreport-update.html) | This notification is used to make changes (updates) to the current report. These changes usually include adding/removing imaging studies and/or observations to the current report.
[`DiagnosticReport-close`](3-6-2-diagnosticreport-close.html) | This notification is used to close the current diagnostic report anchor context with the current state of the exchanged content stored by subscribed applications as appropriate and cleared from these applications and the Hub.
[`DiagnosticReport-select`](3-6-4-diagnosticreport-select.html) | This notification is sent to tell subscribers to make one or more images or observations visible (in focus), such as a measurement (or other finding).
{:.grid}