
FHIRcast also defines content exchange between clients subscribed to the same topic using FHIRcast messages.  Content is exchanged using FHIR resources contained in the most recently opened context which serves as the anchor context of exchanged information (see [`anchor context`](5_glossary.html)).

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
6. Forward a `[FHIR resource]-select` event to all subscribed applications.
7. Generate `[FHIR resource]-update` events when a resource in the Container of another Anchor Resource changes

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

### Processing updates

Exchange of information is made transactionally using change sets in the `[FHIR-resource]-update` event (i.e., the complete current state of the content is not provided in the `Bundle` resource in the `updates` key).  Therefore, it is essential that applications interested in the current state of exchanged information process all events and process the events in the order in which they were successfully received by the Hub.  Each `[FHIR-resource]-update` event posted to the Hub SHALL be processed atomically by the Hub (i.e., all entries in the request's `Bundle` should be processed prior to the Hub accepting another request).

The Hub plays a critical role in helping applications stay synchronized with the current state of exchanged information.  On receiving a `[FHIR-resource]-update` request the Hub SHALL examine the `context.versionId` of the anchor context.   The Hub SHALL compare the `context.versionId` of the incoming request with the `context.versionId` the Hub previously assigned to the anchor context (i.e, the `context.versionId` assigned by the Hub when the previous `[FHIR-resource]-open` or `[FHIR-resource]-update` request was processed). If the incoming `context.versionId` and last assigned `context.versionId` do not match, the request SHALL be rejected and the Hub SHALL return a 4xx/5xx HTTP Status Code.  Note that if the Hub rejects the request for any reason, the entire request is rejected - the Hub SHALL NOT accept some updates requested in the `Bundle` resource while reject other updates requested in the `Bundle`.
 
If the `context.versionId` values match, the Hub proceeds with processing each of the FHIR resources in the Bundle and SHALL process all Bundle entries in an atomic manner.  After updating its copy of the current state of exchanged information, the Hub SHALL assign a new `context.versionId` to the anchor context and use this new `context.versionId` in the `DiagnosticReport-update` event it forwards to subscribed applications.  The Hub SHALL also include the `context.priorVersionId` in the distributed event which receiving applications MAY use to ensure they are apply the updates to the proper context version. The distributed update event SHALL contain a Bundle resource with the same Bundle `id` which was contained in the request.

When a  `DiagnosticReport-update` event is received by an application, the application should respond as is appropriate for its clinical use.  For example, an image reading application may choose to ignore an observation describing a patient's blood pressure.  Since transactional change sets are used during information exchange, no problems are caused by applications deciding to ignore exchanged information not relevant to their function.  However, they should read and retain the `context.versionId` of the anchor context provided in the event for later use.
