
FHIRcast also defines content exchange between clients subscribed to the same topic using FHIRcast messages.  Content is exchanged using FHIR resources contained in the most recently opened context which serves as the anchor context of exchanged information (see [`anchor context`](5_glossary.html)).

FHIR resources are used to carry the information being shared. These resources are entries in the `Bundle` resource inside the `updates` key. One and only one `Bundle` SHALL be present in a `[FHIR resource]-update` request (see [FHIRcast Content Update Bundle](StructureDefinition-fhircast-content-update-bundle.html)). No resource SHALL appear multiple times in the update `Bundle`.

The [FHIR transaction interaction](http://hl7.org/fhir/http.html#transaction) defines how multiple actions can be grouped together and performed as one, such that all information being created or updated is contained in an entry’s resource (i.e., information is passed by value). For example, an `Observation` resource usually contains all relevant information regarding that observation. While it is possible to communicate content by reference even within a transaction bundle, implementer experimentation is needed for increased use of references to resources not contained in the `Bundle`.  

A key concept of the content sharing events is that the content is shared in a transactional manner.  The diagram below shows a series of operations beginning with a `[FHIR resource]-open` request followed by three `[FHIR resource]-update` requests.  The content in an anchor context is built up by the successive `[FHIR resource]-update` requests which contain only changes to the current state.  These changes are propagated by the Hub to all Subscribers using `[FHIR resource]-update` events containing only the changes to be made.

At any time a Subscriber MAY issue a [`GET Context`](2-9-GetCurrentContext.html) request to the Hub in order to retrieve the current context along with all attributes provided in the current context's resources and any content in the anchor context.

{% include img.html img="TransactionalUpdates.png" caption="Figure: Transactional Content Sharing Approach" %}

In order to avoid lost updates and other out of sync conditions, the Hub serves as the transaction coordinator.  It fulfills this responsibility by creating a version of the content's state with each update operation.  If an operation is requested by a Subscriber which provides an incorrect version, this request is rejected.  This approach is similar to the version concurrency approach used by [FHIR versions and managing resource contention](https://www.hl7.org/fhir/http.html#concurrency).  Additionally, many of the FHIRcast content sharing concepts have similarities to the [FHIR messaging mechanisms](https://www.hl7.org/fhir/messaging.html) and where possible the approaches and structures are aligned.

FHIR resources are used to convey the structured information being exchanged in `[FHIR resource]-update` operations.  However, it is possible that these resources are never persisted in a FHIR server.  During the exchange of information, the content (FHIR resource instances) is often very dynamic in nature with a user creating, modifying, and even removing information which is being exchanged.  For example, a measurement made in an imaging application could be altered many times before it is finalized and it could be removed.

### Responsibilities of a FHIRcast Hub and a Subscriber

Support of content sharing by a Hub is optional.  If supporting content sharing, a FHIRcast Hub SHALL fulfill additional responsibilities:

1. Assign and maintain an anchor context's `context.versionId` when processing a `[FHIR resource]-open` request - the `context.versionId` does not need to follow any convention but SHALL be unique in the scope of a topic  
2. Reject `[FHIR resource]-update` request if the version does not match the current `context.versionId`. A request can be rejected by returning a 4xx/5xx HTTP Status Code or a 202 HTTP status code followed by a SyncError.
3. Assign and maintain a new `context.versionId` for the anchor context's content and provide the new `context.versionId` along with the `context.priorVersionId` in the event corresponding to the validated update request
4. Process each `[FHIR resource]-update` request in an atomic fashion and maintain FHIR resource content
5. When a `[FHIR resource]-close` request is received, the Hub should dispose of the content for the current anchor context (i.e., the context being closed by this request) since the Hub has no responsibility to persist the content

A Hub is not responsible for structurally validating FHIR resources.  While a Hub must be able to successfully parse FHIR resources sufficiently to perform its required capabilities (e.g., find the `id` of a resource), a Hub is not responsible for additional structural checking.  If the Hub does reject an update request, for any reason, it SHALL reject the entire request - it SHALL NOT accept some changes specified in the bundle and reject others.

A Hub is not responsible for any long-term persistence of shared information and should purge the content when a `[FHIR resource]-close` request is received. The Hub MAY forward a `[FHIR resource]-select` event to all Subscribers in support of content sharing.

Additionally, a Hub is not responsible to prevent applications participating in exchanging structured information from causing inconsistencies in the information exchanged.  For example, an inconsistency could arise if an application removes from the anchor context's content a resource which is referenced by another resource.  The Hub may check `[FHIR resource]-update` requests for such inconsistencies and MAY reject the request with an appropriate error message; however, it is not required to do so.  Additionally, a Hub MAY check for inconsistencies which it deems to be critical but not perform exhaustive validation. For example, a Hub could validate that the content in a `DiagnosticReport` anchor context always includes at least one primary imaging study.

Clients wishing to exchange structured information SHALL:

1. Handle FHIRcast events for anchor context types it supports: [FHIR resource]-[open\|update\|close\|select]
2. Use a `[FHIR resource]-open` request to open a new resource which becomes the anchor context
3. Make a `[FHIR resource]-update` request when appropriate. The `[FHIR resource]-update` request contains a `Bundle` resource which is a collection of resources that are atomically processed by the Hub with the anchor context's content being adjusted appropriately
4. Maintain the current `context.versionId` of the anchor context provided by the Hub so that a subsequent `[FHIR resource]-update` request may provide the current `context.versionId` which will be validated by the Hub
5. Appropriately process [FHIR resource]-[open\|update\|close] events; note that a Subscriber may choose to ignore the contents of a `[FHIR resource]-update` event but should still track the `context.versionId` for subsequent use
6. If a `[FHIR resource]-update` request fails with the Hub, the Subscriber may issue a [`GET Context`](2-9-GetCurrentContext.html) request to the Hub in order to retrieve the current content in the anchor context and its current `context.versionId`

### Processing Update Events

Exchange of information is made in a transactional manner using change sets in the `[FHIR resource]-update` event (i.e., the complete current state of the content is not provided in the `Bundle` resource in the `updates` key).  Therefore, it is essential that applications interested in the current state of exchanged information process all events and process the events in the order in which they were successfully received by the Hub.  Each `[FHIR resource]-update` event posted to the Hub SHALL be processed atomically by the Hub (i.e., all entries in the request's `Bundle` should be processed prior to the Hub accepting another request).

The Hub plays a critical role in helping Subscribers stay synchronized with the current state of exchanged information and, as described in [Request For Context Change](https://build.fhir.org/ig/HL7/fhircast-docs/2-6-RequestContextChange.html#request-context-change), responds to a FHIRcast event with either a synchronous HTTP status or an HTTP 202 [Accepted] followed by either a SyncError or a broadcast of the FHIRcast event. On receiving a `[FHIR resource]-update` request the Hub SHALL examine the `context.versionId` of the anchor context. The Hub SHALL compare the `context.versionId` of the incoming request with the `context.versionId` the Hub previously assigned to the anchor context (i.e, the `context.versionId` assigned by the Hub when the previous `[FHIR resource]-open` or `[FHIR resource]-update` request was processed).  If the incoming `context.versionId` and last assigned `context.versionId` do not match, the Hub SHALL reject the request and SHOULD do so by returning a 4xx HTTP Status Code. Note that if the Hub rejects the request for any reason, the entire request is rejected - the Hub SHALL NOT accept some updates requested in the `Bundle` resource while reject other updates requested in the `Bundle`.
 
If the `context.versionId` values match, the Hub proceeds with processing each of the FHIR resources in the Bundle and SHALL process all Bundle entries in an atomic manner.  After updating its copy of the current state of exchanged information, the Hub SHALL assign a new `context.versionId` to the anchor context and use this new `context.versionId` in the `[FHIR resource]-update` event it forwards to subscribed applications.  The Hub SHALL also include the `context.priorVersionId` in the distributed event which receiving applications MAY use to ensure they are apply the updates to the proper context version. The distributed update event SHALL contain a Bundle resource with the same Bundle `id` which was contained in the request.

`[FHIR resource]-update` events MAY also update attributes of the anchor context or associated context resources.  For example, a Subscriber might wish to update the `status` attribute of the anchor context resource.  If any updates are made during the content sharing session to a resource in the `context` array that was present in the `[FHIR resource]-open` event, the updated resources SHALL be present in the `Bundle` resource in the `updates` key.

When a `[FHIR resource]-update` event is received by a Subscriber, the application should respond as is appropriate for its clinical use.  For example, an image reading application may choose to ignore an observation describing a patient's blood pressure.  Since transactional change sets are used during information exchange, no problems are caused by applications deciding to ignore exchanged information not relevant to their function.  However, they should read and retain the `context.versionId` of the anchor context provided in the event for later use.

#### Number of Entries in Transaction Bundle

FHIRcast doesn't prescribe a limit on the number of entries in the transaction Bundle; however, implementers should expect a limit for production-grade software. Generally, the upper range of entries in a FHIRcast transaction bundle is in the *dozens*. Recipients SHOULD return an error when they receive a FHIRcast event notification that is too large to support. Specifically, recipients SHALL either synchronously return an HTTP error status of [HTTP 413 - Content Too Large](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/413), or asynchronously a `syncerror` with an `OperationOutcome.issue.code` = "[too-long](https://hl7.org/fhir/R4/valueset-issue-type.html)".

#### Context Array in Update and Select Events

In addition to the `Bundle` resource in the `updates` key, the context array of `[FHIR resource]-update` and `[FHIR resource]-select` events SHALL include the only the anchor context resource which was present in the context array of the corresponding `[FHIR resource]-open` event.  The `Patient` resource which was present in the context array of the corresponding `[FHIR resource]-open` event MAY be present in `[FHIR resource]-update` events to enable Subscribers to mitigate patient safety concerns.

#### Adding/Removing Context Resources

{% include infonote.html text='Implementer feedback on adding and removing resources that may be considered contextual in nature during a content sharing session is solicited' %}

If a resource that may be considered contextual in nature becomes relevant in an established content sharing session, it MAY be added by placing the resource in the `Bundle` resource inside the `updates` key.  Similarly, a resource that may be considered contextual in nature may be removed by indicating the removal in the `Bundle` resource inside the `updates` key.  Subscribers SHALL NOT remove any resources that were present in the `context` array that were provided in the `[FHIR resource]-open` event.

Using a DiagnosticReport centered content sharing session as an example, Subscribers may decide if the addition or removal of a resource that may be considered contextual in nature should trigger an action.  For example, an ImagingStudy resource could be added using the `Bundle` resource inside the `updates` key, an imaging application may decide it should open the imaging study (but is not obligated to do so).  Conversely, if an ImagingStudy resource is removed using the `Bundle` resource inside the `updates` key, an imaging application may decide it should close the imaging study (but is not obligated to do so).  If an ImagingStudy was present in the `context` array that was provided in the `[FHIR resource]-open` event, Subscribers are not permitted to remove the resource using the `Bundle` resource inside the `updates` key.

#### Updating Attributes of Context Resources and Adding/Removing Context Resources

{% include infonote.html text='Implementer feedback on changing attribute values of resources present in the `context` array that was provided in the `[FHIR resource]-open` event is solicited' %}

Occasionally attributes of a resource present in the `context` array that was provided in the `[FHIR resource]-open` event may change.  In such a case the change SHALL be communicated by updating the resource using the `Bundle` resource inside the `updates` key in a `[FHIR resource]-update` event.  It is likely a very rare that such a scenario would occur in an unexpected manner; however, there are specific situations where changing the value of an attribute or adding an attribute value is quite useful.  For example, the `status` attribute of the [`anchor context`](5_glossary.html) may change soon before the content sharing session is closed - this would be communicated by providing the [`anchor context`](5_glossary.html) resource in the `Bundle` resource inside the `updates` key with the `status` attribute's new value in a `[FHIR resource]-update` event.

When responding to a [`GET Context`](2-9-GetCurrentContext.html) request, the Hub SHALL return the `context` array that was provided in the `[FHIR resource]-open` event without providing any changes that may have occurred to these resources since the `[FHIR resource]-open` event occurred.  Any changes to these resources (e.g., the update of a `status` attribute's value) SHALL be present in the `Bundle` resource inside the `content` key of the [`GET Context`](2-9-GetCurrentContext.html) response.  Subscribers then process the resources in the content `Bundle` as per the business logic which they would apply if this information was received in a `[FHIR resource]-update` event.

#### Experimental Capability – Update events outside of current context

{% include infonote.html text='Implementer feedback on safety and complexity vs value of content updates (1) to a report other than the one being authored, and/or (2) outside of a user session entirely. Also, why shouldn\'t this interaction simply use standard RESTful FHIR?' %}

This capability is deemed experimental due to low production adoption and evaluation of potential risk patient safety. This capability may change or be removed in future versions of this specification. 

Towards enabling greater workflow flexibility and greater convenience of subscribers, Subscribers MAY send a [FHIR resource]-update event, that is unrelated to the current context (e.g. an update event in which the anchor context referenced differs from the current context). Subscribers SHALL NOT send select events unrelated to the current context.

If the event recipient supports receiving and processing update events outside of the current context, the event SHALL be processed in scope of the referenced context (not the current context) following the same rules as if the referenced context were the current context.

If the event recipient does not support update events outside of the current context, the recipient SHALL respond with an appropriate [event notification](2-5-EventNotification.html#event-notification-response).

### Content Creation and Reopen Scenario

In order to enable use-cases requiring persistence of content created during a FHIRcast session, including "re-opened" FHIRcast sessions, persistent identifiers are needed. FHIR logical IDs specified during a FHIRcast session are typically not persisted. Subscribers that create new FHIR resources SHOULD specify a business `identifier` for the resource (see: [FHIR's identifier].

For further discussion on the reopening of content sharing sessions see Section [4.6 FHIRcast Event-based Content Sharing](4-6-fhircast-event-content-sharing.html).

