In addition to basic context synchronization, FHIRcast supports real-time exchange of resources between clients subscribed to the same topic.  A key concept of the content sharing events is that the content is shared in a transactional manner.

The diagram below shows a series of operations beginning with a `[FHIR resource]-open` request followed by three `[FHIR resource]-update` requests.  The content in an anchor context is built up by the successive `[FHIR resource]-update` requests which contain only changes to the current state.  These changes are propagated by the Hub to all subscribed clients using `[FHIR resource]-update` events containing only the changes to be made.

{% include img.html img="TransactionalUpdates.png" caption="Figure: Transactional Content Sharing Approach" %}

In order to avoid lost updates and other out of sync conditions, the Hub serves as the transaction coordinator.  It fulfills this responsibility by creating a version of the content's state with each update operation.  If an operation is requested by a client which provides an incorrect version, this request is rejected.  This approach is similar to the version concurrency approach used by [FHIR versions and managing resource contention](https://www.hl7.org/fhir/http.html#concurrency).  Additionally, many of the FHIRcast content sharing concepts have similarities to the [FHIR messaging mechanisms](https://www.hl7.org/fhir/messaging.html) and where possible the approaches and structures are aligned.

FHIR resources are used to convey the structured information being exchanged in `[FHIR resource]-update` operations.  However, it is possible that these resources are never persisted in a FHIR server.  During the exchange of information, the content (FHIR resource instances) is often very dynamic in nature with a user creating, modifying, and even removing information which is being exchanged.  For example, a measurement made in an imaging application could be altered many times before it is finalized and it could be removed.

### Responsibilities of a FHIRcast Hub and a Subscribed Client

If supporting content sharing, a FHIRcast Hub MUST fulfill additional responsibilities:

1. Assign and maintain an anchor context's `versionId` when processing a `[FHIR resource]-open` request - the `versionId` does not need to follow any convension but must unique in the scope of a topic  
2. Reject `[FHIR resource]-update` and `[FHIR resource]-select` requests if the version does not match the current `versionId` by returning a 4xx/5xx HTTP Status Code rather than updating the content or indication of selection
3. Assign and maintain a new `versionId` for the anchor context's content and provide the new `versionId` along with the `priorVersionId` in the event corresponding to the validated update request
4. Maintain a list of current FHIR resource content in the anchor context so that it may provide the anchor context's content in response to a [`GET Context`](2-9-GetCurrentContext.html) request
5. When a `[FHIR resource]-close` request is received, the Hub should dispose of the content for the anchor context since the Hub has no responsibility to persist the content

A Hub is not responsible for structurally validating FHIR resources.  While a Hub must be able to successfully parse FHIR resources sufficiently to perform its required capabilities (e.g., find the `id` of a resource), a Hub is not responsible for additional structural checking.

A Hub is not responsible for any long-term persistence of shared information and should purge the content when a `[FHIR resource]-close` request is received.

Additionally, a Hub is not responsible to prevent applications participating in exchanging structured information from causing inconsistencies in the information exchanged.  For example, an inconsistency could arise if an application removes from the anchor context's content a resource which is referenced by another resource.  The Hub may check `[FHIR resource]-update` requests for such inconsistencies and reject the request with an appropriate error message; however, it is not required to do so.  Additionally, a Hub may check for inconsistencies which it deems to be critical but not perform exhaustive validation. For example, a Hub could validate that the content in a `DiagnosticReport` anchor context always includes at least one primary imaging study.

Clients wishing to exchange structured information must:

1. Handle FHIRcast events for anchor context types it supports: [FHIR resource]-[open\|update\|close\|select]
2. Use a `[FHIR resource]-open` request to open a new resource which becomes the anchor context
3. Make a `[FHIR resource]-update` request when appropriate. The `[FHIR resource]-update` request contains a `Bundle` resource which is a collection of resources that are atomically processed by the Hub with the anchor context's content being adjusted appropriately
4. Maintain the current `versionId` of the anchor context provided by the Hub so that a subsequent `[FHIR resource]-update` request may provide the current `versionId` which will be validated by the Hub
5. Appropriately process [FHIR resource]-[open\|update\|close\|select] events; note that a client may choose to ignore the contents of a `[FHIR resource]-update` event but should still track the `versionId` for subsequent use
6. If a `[FHIR resource]-update` request fails with the Hub, the client may issue a [`GET Context`](2-9-GetCurrentContext.html) request to the Hub in order to retrieve the current content in the anchor context and its current `versionId`
7. When using websockets, clients will now receive the current content (if any exists) of the anchor context (if one has been established) in response to the Subscribe request, see [`return of current content`](#websocket-return-of-current-content).  Clients that don't support the exchange of structured information may ignore the content of the Subscribe response payload.

### FHIR Resource Profiles for Content Sharing

The following profiles ensure a basic level of interoperability between applications participating in a content sharing session:

* [`Observation`](StructureDefinition-fhircast-observation.html)
* ImagingStudy

### Example of Content Sharing in an Anchor Context

The below example uses a `DiagnosticReport` as the anchor context.  However, the pattern of the example holds when other FHIR resource types are the anchor context.

#### Diagnostic Report Content Sharing Basics

When reporting applications integrate with PACS and/or RIS applications, a radiologist's (or other clinician's) workflow is centered on the final deliverable, a diagnostic report. In radiology, the imaging study (exam) is an integral resource with the report referencing one or more imaging studies. Structured data, many times represented by a FHIR `Observation` resource, may also be captured as part of a report.  In addition to basic context synchronization, a diagnostic report centered workflow builds upon the basic FHIRcast operations to support near real-time exchange of structured information between applications participating in a diagnostic report context.  Also, the `DiagnosticReport` resource contains certain attributes (such as report status), that are useful to PACS/RIS applications.  Participating applications may include clients such as reporting applications, PACS, EHRs, workflow orchestrators, and interactive AI applications.

Exchanged content need not have an independent existence. For the purposes of a working session in FHIRcast, they are all "contained" in one resource (the `DiagnosticReport` anchor context). For example, a radiologist may use the PACS viewer to create a measurement. The PACS application sends this measurement as an `Observation` to the other subscribing applications for consideration. If the radiologist determines the measurement is useful in another application (and accurate), it may then become an `Observation` to be included in the diagnostic report. Only when that diagnostic report becomes an official signed document would that `Observation` possibly be maintained with an independent existence. Until that time, FHIR domain resources serve as a convenient means to transfer data within a FHIRcast context.

Structured information may be added, changed, or removed quite frequently during the lifetime of a context. Exchanged information is transitory and it is not required that the information exchanged during the collaboration is persisted. However, as required by their use cases, each participating application may choose to persist information in their own structures which may or may not be expressed as a FHIR resource. Even if stored in the form of a FHIR resource, the resource may or may not be stored in a system which provides access to the information through a FHIR server and associated FHIR operations (i.e., it may be persisted only in storage specific to a given application).

{% include img.html img="Basic%20Content%20Exchange.png" caption="Figure: Basics of Content Sharing" %}

#### Diagnostic Report Centered Workflow Events

When the anchor context is a 'DiagnosticReport' the following events are possible during content sharing.

Operation | Description
--- | ---
[`DiagnosticReport-open`](3-12-diagnosticReport-open.html) | This notification is used to begin a new report. This should be the first event and establishes the anchor context.
[`DiagnosticReport-update`](3-13-diagnosticReport-update.html) | This notification is used to make changes (updates) to the current report. These changes usually include adding/removing imaging studies and/or observations to the current report.
[`DiagnosticReport-close`](3-14-diagnosticReport-close.html) | This notification is used to close the current diagnostic report anchor context with the current state of the exchanged content stored by subscribed applications as appropriate and cleared from these applications and the Hub.
[`DiagnosticReport-select`](3-15-diagnosticReport-select.html) | This notification is sent to tell subscribers to make one or more images or observations visible (in focus), such as a measurement (or other finding).

#### Example Use Case

A frequent scenario which illustrates a diagnostic report centered workflow involves an EHR, an image reading application, a reporting application, and an advanced quantification application.  The EHR, image reading application, and reporting application are authenticated and subscribed to the same topic using a FHIRcast Hub with the EHR establishing a patient context, see messages 1 through 7 in the below sequence diagram.

In an EHR a clinical users opens a patient with the EHR sending a Patient-open request to the Hub (messages 1 and 2).  The Hub notes the context and if it supports content sharing assigns a version to the context then distributes the Patient-open events (messages 3 and 4a, 4b, and 4c). The reporting application reacts to the patient context in some manner such as displaying available reports and imaging studies associated with the patient while storing the version of the patient context in case content is shared in this anchor context (message 5).  The imaging application is not interested in patient contexts so it ignores the event entirely (message 6) while the EHR identifies the Patient-open event as one it triggered and stores the version of the context provided by the Hub in case it would like to contribute content is this context (message 7).

Next the clinical user decides to create diagnostic report using the reporting application, see messages 8 through 14 in the below sequence diagram.

Using a reporting application, a clinical user creates a report by choosing an imaging study as the primary subject of the report (message 8).  The reporting application creates a report and then opens a diagnostic report context by posting a [`DiagnosticReport-open`](3-12-diagnosticReport-open.html) request to the Hub (message 9). The Hub notes the context, assigns a version to the context and then distributes a [`DiagnosticReport-open`](3-12-diagnosticReport-open.html) event with the generated `versionId` to subscribed applications (messages 10, 11a, 11b, and 11c). On receiving the [`DiagnosticReport-open`](3-12-diagnosticReport-open.html) event from the Hub, an EHR decides not to react to this event noticing that the patient context has not changed (message 14). The image reading application responds to the event by opening the imaging study referenced in the diagnostic report anchor context (message 13) while the reporting application identifies the [`DiagnosticReport-open`](3-12-diagnosticReport-open.html) event as one it triggered and stores the version of the context provided by the Hub (message 12).

{% include img.html img="Open%20Report.png" caption="Figure: Opening a Diagnostic Report Context" %}

The clinical user takes a measurement using the imaging reading application (message 1 in the below sequence diagram) which then shares this measurement by making a [`DiagnosticReport-update`](3-13-diagnosticReport-update.html) request to the Hub (message 2). The Hub validates that the `versionId` provided in the request is correct, updates its content, generates a new `versionId` (message 3). If the `versionId` provided in the request is not correct the Hub rejects the request (response to message 2). The Hub then distributes `DiagnosticReport-update`](3-13-diagnosticReport-update.html) events which contain the newly generated `versionId` and the `priorVersionId` to all subscribed applications (messages 4a, 4b, and 4c). The reporting application receives the measurement through a [`DiagnosticReport-update`](3-13-diagnosticReport-update.html) event from the Hub and adds this information to the report if the `versionId` it currently holds matches the `priorVersionId` provided in the event (message 7). If the `priorVersionId` does not match the `versionId` of the content known to the reporting application, it may resynchronize its content by requesting the current context from the Hub (message 8).

As the clinical user continues the reporting process they select a measurement or other structured information in the reporting application, the reporting application may note this selection by posting a [`DiagnosticReport-select`](3-15-diagnosticReport-select.html) request to the Hub. Upon receiving the [`DiagnosticReport-select`](3-15-diagnosticReport-select.html) event the image reading application may navigate to the image on which this measurement was acquired.

{% include img.html img="Share%20Content.png" caption="Figure: Create a Measurement" %}

At some point the image reading application (automatically or through user interaction) may determine that an advanced quantification application should be used and launches this application including the appropriate FHIRcast topic (messages 1 and 2 in the below sequence diagram).  The advanced quantification application then subscribes to the topic and requests the current context including any already exchanged structured information by making a [`GET Context`](2-9-GetCurrentContext.html) request to the Hub which returns the current context including existing content in the response (messages 3 and 4).  The user interacts with the advanced quantification application which then adds content to the anchor context (messages 6 through 13).

{% include img.html img="Advanced%20Quantification.png" caption="Figure: Newly Subscribed Application Contributes Content" %}

Finally the clinical user closes the report in the reporting application. The reporting application makes a [`DiagnosticReport-close`](3-14-diagnosticReport-close.html) request. Upon receipt of the [`DiagnosticReport-close`](3-14-diagnosticReport-close.html) event both the imaging reading application and advanced quantification application close all relevant image studies.
