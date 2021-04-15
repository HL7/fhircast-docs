# Background research for sharing content in a FHIRcast integration

This is non-normative content representing a proposal for sharing additional information in a FHIRcast integration. 

## Sharing of Structured Information in a FHIRcast Context

FHIRcast is a  standard for real-time context synchronization between healthcare applications. For example, a radiologist typically works in disparate client applications at the same time (e.g. a reporting application, a PACS viewer, an interactive AI application, and an EMR) and wants each of these systems to display the same study and patient simultaneously. In addition to basic context synchronization, this proposal extends FHIRcast to support real-time structured data exchange between client applications.

#### Concepts and Terminology

In addition to the core FHIRcast constructs such as topics, subscriptions, and FHIRcast Hubs; the following terminology is introduced to support the sharing of structured information.

 Concept | Description
--- | ---
context | Resource on which the user is currently working such as documenting information associated with a patient's encounter with a care provider. In this case the context is a specific encounter and the patient who is the subject of the encounter.
anchor context | A context which is serving as a container for FHIRcast events that enable sharing of content. The content sharing events include the anchor context and content shared in these events directly or indirectly reference the resource acting as the anchor context. Typical anchor contexts are resources such as Patient, Encounter, ImagingStudy, and DiagnosticReport.
content | Resources created during a user's interaction with the active context. For example, if the current context is an imaging study the user may make a measurement resulting in an observation containing the measurement information. 


##### Transactional Updates
A key concept of the information sharing events is that information is shared in a transactional manner.

![**Transactional Updates**](Images/TransactionalUpdates.png)

The above diagram shows a series of operations beginning with an [`<DiagnosticReport>FHIR Resource>-open` request](#fhir-resource-open-message) followed by three [`<FHIR Resource>-update` requests](#fhir-resource-update-message).  The anchor context is built up by the successive [`<FHIR Resource>-update` requests](#fhir-resource-update-message) which contain only changes to the current state.  These changes are propagated by the Hub to all subscribed clients with the [`<FHIR Resource>-update` events](#fhir-resource-update-message) containing only the changes.

In order to avoid lost updates and other out of sync conditions, the Hub serves as the transaction coordinator.  It fulfills this responsibility by creating a version of the information's state with each operation.  If an operation is requested with the client providing the incorrect version, this request is rejected.  This approach is similar to the version concurrency approach used by the FHIR standard ([FHIR versions and managing resource contention](https://www.hl7.org/fhir/http.html#concurrency)).  Additionally, many of the concepts have similarities to the [FHIR subscription mechanisms](https://www.hl7.org/fhir/subscription.html) and where possible the basic constructs of FHIRcast content sharing are aligned with FHIR Subscriptions.

FHIR resources are using to convey the structure information being exchanged in [`<FHIR Resource>-update` operations](#fhir-resource-update-message).  However, it is possible that these resources are never persisted in a FHIR server.  During the exchange of information, resources may be very dynamic in nature with a user creating, modifying, and even removing information which is being exchanged.  For example, a measurement a user makes in an imaging application may be altered many times before it is finalized and it may be removed entirely.

### Responsibilities of a FHIRcast Hub and a Subscribed Client

The existing responsibilities of a FHIRcast Hub remain when supporting information exchange operations:
1. Accept subscriptions to new or already established topics
2. Maintain a list of subscribers and events for which they would like notification
3. Distribute events to subscribers as appropriate

Hubs must fulfill these addition responsibilities when they support the exchange of structured information:
1. Assign and validate the diagnostic report's `versionId` when processing a [`<FHIR Resource>-update` request](#fhir-resource-update-message) or a [`<FHIR Resource>-select` request](#fhir-resource-select-message)
2. Assign and maintain a current `versionId` of the content in the anchor context
2. Validate every [`<FHIR Resource>-update` request](#fhir-resource-update-message) and [`<FHIR Resource>-select` request](#fhir-resource-select-message) for the current `versionId` and reject the request if the version is not correct; returning a `412 Precondition Failed` status code rather than updating the content
3. Maintain a list of current FHIR resource content in the anchor context so that it may provide them in response to a <FHIR Resource>-open request and respond to a GET request
4. When a [`<FHIR Resource>-close` request](#fhir-resource-close-message) is received, the Hub no longer retains the content for that anchor context

A Hub is not responsible for structurally validating FHIR resources.  While a Hub must be able to successfully parse FHIR resources in a manner sufficient to perform its required capabilities (e.g. find the `id` of a resource and the `versionId` of the anchor resource), a Hub is not responsible for additional structural checking. 

A Hub is not responsible for any long-term persistence of shared information and should purge the content when a [`DiagnosticReport-close`](#diagnostic-report-close-message) is received.

Additionally, it is not a mandatory responsibility of a Hub to prevent applications participating in exchanging structured information from causing inconsistencies in exchanged information.  For example, an inconsistency would arise if an application removes an Observation resource on which another resource is based.  The Hub MAY check updates for such inconsistencies and fail the transaction with an appropriate error message; however, it is not required that the Hub perform such validation.  Additionally, a Hub MAY check for inconsistencies which it deems to be critical but not perform exhaustive validation. For example, a Hub could validate that the content in a `DiagnosticReport` anchor context always includes at least one primary imaging study.

Clients wishing to exchange structure information must:
1. Adhere to a FHIRcast event naming convention as follows: <FHIR Resource>-[open, update, select, close]
2. Use the <FHIR Resource>-open event to open a new resource which becomes the anchor context
3. Make a <FHIR Resource>-update request following the specification as documented below and process the associated event; the <FHIR Resource>-update event contains a `Bundle` resource which is a collection of resources that are atomically processed by the Hub with the current FHIR resource content adjusted appropriately
4. Maintain the current `versionId` of the anchor context provided by the Hub so that subsequent <FHIR Resource>-update requests may provide this `versionId`
4. Appropriately process <FHIR Resource>-[open, update, select, close] events; note that a client may choose to ignore the contents of <FHIR Resource>-[update, select] events but should still track the `versionId` for subsequent use
5. If a <FHIR Resource>-update request fails with the Hub returning a `412 Precondition Failed` status code, the client may issue a GET request to the Hub in order to retrieve the current content and associated version of the anchor context
5. Clients will now receive a content payload (if one exists) in response to the Subscribe request which contains the current context and any content associated with the context.  Clients that don't support the exchange of structured information may ignore the contents of the response payload.
6. For WebSocket subscriptions, this will be a change since the Subscribe method previously returned only a string value with the WebSocket endpoint URL.


### DIAGNOSTIC REPORT CENTERED WORKFLOW

For the purpose simplifying the conveyance of  the information sharing mechanisms, further details will use a `DiagnosticReport` as the anchor context.  However, all of the below requests and messages support using other FHIR resource types as the anchor context.

#### Discussion
When reporting applications integrate with PACS and/or RIS applications, a radiologist's (or other clinician's) workflow is centered on the final deliverable, a diagnostic report. In radiology the imaging study (exam) is an integral resource with the report referencing one or more imaging studies. Structured data, many times represented by an `Observation` resource, may also be captured as part of a report.  In addition to basic context synchronization, a diagnostic report centered workflow builds upon the basic FHIRcast transactions to support near real-time exchange of structured information between applications participating in a diagnostic report context.  Also, the `DiagnosticReport` resource contains certain attributes (such as report status), that are useful to the PACS/RIS applications and don't exist in other types of FHIR resources (e.g. an ImagingStudy).  Participating applications may include clients such as reporting applications, PACS, EHR, workflow orchestrators, and interactive AI applications.

Observation resources need not have an independent existence. For the purposes of a working session in FHIRcast, they are all "contained" in one resource (the `DiagnosticReport` anchor context). This is important, especially when software applications are communicating information that the user may not even find useful. For example, a radiologist may use the PACS viewer to create a measurement. The PACS application sends this measurement as an `Observation` to the other subscribing applications for consideration. If the radiologist determines the measurement is useful in another application (and accurate), it may then become an `Observation` to be included in the diagnostic report. Only when that diagnostic report becomes an official signed document would that `Observation` possibly be maintained with an independent existence. Until that time, FHIR domain resources serve as a convenient means to transfer data within a FHIRcast context.

Structured information may be added, changed, or removed quite frequently during the lifetime of a Diagnostic Report context. Exchanged information is transitory and it is not required that the information exchanged during the collaboration is persisted. However, as required by their use cases, each participating application may choose to persist information in their own structures which may or may not be expressed as a FHIR resource. Even if stored in the form of a FHIR resource, the resource may or may not be stored in a system which provides access to the information through a FHIR server and associated FHIR operations.

#### FHIRcast Notification Request Event Fields
Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The session topic given in the subscription request.
`hub.event` | Required | string | The event that triggered this notification (see list of supported events below).
`context` | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred. The contents of this field will vary depending on the event. However, in a diagnostic report centered workflow, this context will be a `DiagnosticReport` FHIR resource.  Attributes may be valued and other FHIR resources associated with the report may be embedded in the resource.

#### Diagnostic Report Centered Workflow Events
Operation | Description
--- | --- 
[`DiagnosticReport-open`](#diagnostic-report-open-message) | This notification is used to begin a new report. This should be the first event and establishes the anchor context.
[`DiagnosticReport-update`](#diagnostic-report-update-message) | This notification is used to make changes (updates) to the current report. These changes usually include adding/removing imaging studies and/or observations to the current report.
[`DiagnosticReport-select`](#diagnostic-report-select-message) | This notification is sent to tell subscribers to make one or more images or observations visible (in focus), such as a measurement (or other finding).
[`DiagnosticReport-close`](#diagnostic-report-close-message) | This notification is used to close the current diagnostic report anchor context with the current state of the exchanged content stored by subscribed applications as appropriate and cleared from these applications and the Hub. 

### Supported User Stories
A diagnostic report centered workflow supports the following user stories.

I as a clinical user want to:
1. open one or more applications through a single interaction in a **shared reporting session**  for a **new or existing** report
2. use any application participating in the shared reporting session to **create, update, and delete structured information** and exchange this information with all other participating applications in a near real-time manner with **receiving applications using the information as appropriate to their function**
3. **add a comparison study or a primary study** that was not originally a subject of the report in the reporting session
4. open applications which can join an **existing reporting session**, have **access to information** which has been **previously exchanged**, and **immediately begin** exchanging structured information with other applications participating in the shared reporting session
5. **select or deselect** a representation of shared structured information in one application with the other applications appropriately reacting to this new selection state
6. **close the reporting session** in an orderly manner ensuring contextual consistency across all applications after the close operation is completed


### Example Use Case
A frequent scenario which illustrates a diagnostic report centered workflow involves an EHR, an image reading application, a reporting application, and an advanced quantification application.  The EHR, image reading application, and reporting application are authenticated and subscribed to the same topic using a FHIRcast Hub with the EHR establishing a patient context.  Using a reporting application, a clinical user decides to create a report by choosing an imaging study as the primary subject of the report.  The reporting application creates a report and then opens a diagnostic report context by posting a [`DiagnosticReport-open` request](#fhir-resource-open-message) to the Hub. On receiving the [`DiagnosticReport-open` event](#fhir-resource-open-message) from the Hub, an EHR decides not to react to this event noticing that the patient context has not changed. The image reading application responds to the event by opening the imaging study referenced in the `DiagnosticReport` anchor context.

The clinical user takes a measurement using the imaging reading application which then provides the reporting application this measurement by making a [`DiagnosticReport-update` request](#fhir-resource-update-message) to the Hub. The reporting application receives the measurement through a [`DiagnosticReport-update` event](#fhir-resource-update-message) from the Hub and adds this information to the report. As the clinical user continues the reporting process they select a measurement or other structured information in the reporting application, the reporting application may note this selection by posting a [`DiagnosticReport-select` request](#fhir-resource-select-message) to the Hub. Upon receiving the [`DiagnosticReport-select` event](#fhir-resource-select-message) the image reading application may navigate to the image on which this measurement was acquired.

**ToDo: Here's where we left off**

At some point the image reading application (automatically or through user interaction) may determine that an advanced quantification application should be used and launches this application including the appropriate FHIRcast topic.  The advanced quantification application then requests the current context including any already exchanged structured information by making a [`GET` topic request](#GET-context-request) to the Hub which returns the context in the response.

Finally the clinical user closes the report in the reporting application. The reporting application posts a [DiagnosticReport-close event](#diagnostic-report-close-message). Upon receipt of the [DiagnosticReport-close event](#diagnostic-report-close-message) both the imaging reading application and advanced quantification application close all relevant image studies.

### HTTP Method GET to HTTP Endpoint: base-hub-URL/<topic>
Returns: This method returns an object containing the current context of the topic session. The current context is made up of one or more "top-level" contextual resource types such as an ImagingStudy or a DiagnosticReport. The `contextType` field identifies how the context was created. For example, a DiagnosticReport-open event will create a new context with `contextType=DiagnosticReport`.

Each resource is listed in Key/Resource pairs to follow the FHIRCast spec for event notifications.

Example: two context resources, one DiagnosticReport and one ImagingStudy.  Note that the DiagnosticReport uses the **contained** field for observations. The contained entire Observation resource must be included in the contained field - references are not allowed.

```
[
  {
    "contextType": "ImagingStudy",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "description": "CHEST XRAY",
          "started": "2010-01-30T23:00:00.000Z",
          "status": "available",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "identifier": [
            {
              "type": {
                "coding": [
                  {
                    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code": "ACSN"
                  }
                ]
              },
              "value": "342123458"
            }
          ],
          "patient": { "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3" }
        }
      }
    ]
  },
  {
    "contextType": "DiagnosticReport",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "description": "CHEST XRAY",
          "started": "2010-01-30T23:00:00.000Z",
          "status": "available",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "identifier": [
            {
              "type": {
                "coding": [
                  {
                    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code": "ACSN"
                  }
                ]
              },
              "value": "342123458"
            }
          ],
          "subject": { "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3" }
        }
      },
      {
        "key": "Report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "status": "unknown",
          "subject": { "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3" }
          "imagingStudy": [ { "reference": "ImagingStudy/8i7tbu6fby5ftfbku6fniuf" } ],
          "contained": [
            {
              "resourceType": "Observation",
              "id": "9450878527",
              "identifier": [
                {
                  "system": "dcm:121151",
                  "value": "L1"
                }
              ],
              "status": "preliminary",
              "issued": "2001-07-23T06:02:11-04:00",
              "component": [
                {
                  "code": {
                    "coding": [
                      {
                        "system": "https://loinc.org",
                        "code": "21889-1",
                        "display": "Distance"
                      }
                    ]
                  },
                  "valueQuantity": {
                    "system": "http://unitsofmeasure.org",
                    "value": "30.3134634578934",
                    "code": "mm",
                    "unit": "mm"
                  }
                }
              ],
              "category": {
                "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                "code": "imaging",
                "display": "Imaging"
              },
              "code": {
                "system": "http://hl7.org/fhir/ValueSet/observation-codes",
                "code": "32449-1",
                "display": "Physical findings of Lung"
              }
            }
          ]
        }
      }
    ]
  }
]
```

### Diagnostic Report Open Request and Event
A `DiagnosticReport-open` request is posted to the Hub when a new or existing report is opened by an application. The `context` field contains one `Patient` FHIR resource and one `DiagnosticReport` FHIR resource. If the report being opened is a new report, the report status should be "unknown". For an anchor context such as a DiagnosticReport, an implementation guide could require specific contexts to be present.  For example, an implementation guide using a DiagnosticReport anchor context could require an imaging study context be present in the DiagnosticReport-open request. Note that one or more primary studies (those which are the primary subject of the report) may be included and zero or more comparison (prior) studies may also be present.

When the Hub distributes a DiagnosticReport-open event, it associates a versionId with the DiagnosticReport so that subscribed applications may submit this versionId in subsequent DiagnosticReport-update requests.

When a DiagnosticReport-open event is received by an application, the application should respond as is appropriate for its clinical use.  For example, an image reading application may want to respond to an event posted by a reporting application by opening the imaging study(ies) specified in the context. A reporting application may want to respond to an event posted by an image reading application by creating and opening a new report (or existing report as an addendum).

**[ToDo]** The id of the request in the below example (0d4c9998) should be the same as the id of the event distributed by the Hub so that the requestor can unambiguously record the versionId provided by the Hub.  At present the STU2 specification says: "Following an accepted context change request, the Hub MAY re-use this value in the broadcasted event notifications" (see Request Context Change Request - Request Context Change Parameters). This should be changed to "the Hub SHALL re-use".

#### Context
Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the diagnostic report currently in context.
`study` | OPTIONAL | `ImagingStudy/{id}?_elements=identifier,accession` | FHIR ImagingStudy resource in context. Note that in addition to the request identifier and accession elements, the DICOM uid and FHIR patient reference are included because they're required by the FHIR specification.  Implementation guides may specify that this context is required (not optional).
`report`| REQUIRED | `DiagnosticReport/{id}?_elements=identifier,accession` | FHIR DiagnosticReport resource in context

##### DiagnosticReport-open Example Request
The following example shows a report being opened that contains a single primary study.  Note that the diagnostic report's `imagingStudy` and `subject` attributes have references to the imaging study and patient which are also in the open request.
```
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-open",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "description": "CHEST XRAY",
          "started": "2010-01-30T23:00:00.000Z",
          "status": "available",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "identifier": [
            {
              "type": {
                "coding": [
                  {
                    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code": "ACSN"
                  }
                ]
              },
              "value": "342123458"
            },
            {
              "system": "urn:dicom:uid",
              "value": "urn:oid:2.16.124.113543.6003.1154777499.38476.11982.4847614254"
            }
          ],
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      },
      {
        "key": "Report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "status": "unknown",
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          },
          "imagingStudy": [
            {
              "reference": "ImagingStudy/8i7tbu6fby5ftfbku6fniuf"
            }
          ]
        }
      }
    ]
  }
}
```

##### DiagnosticReport-open Event Example
The event distributed by the Hub includes a meta section in the anchor context object (in this case a DiagnosticReport) with a versionId which will be used by subscribers to make subsequent DiagnosticReport-update requests.
```
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-open",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "description": "CHEST XRAY",
          "started": "2010-01-30T23:00:00.000Z",
          "status": "available",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "identifier": [
            {
              "type": {
                "coding": [
                  {
                    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code": "ACSN"
                  }
                ]
              },
              "value": "342123458"
            },
            {
              "system": "urn:dicom:uid",
              "value": "urn:oid:2.16.124.113543.6003.1154777499.38476.11982.4847614254"
            }
          ],
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      },
      {
        "key": "Report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "meta": {
            "versionId": "0"
          },
          "status": "unknown",
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          },
          "imagingStudy": [
            {
              "reference": "ImagingStudy/8i7tbu6fby5ftfbku6fniuf"
            }
          ]
        }
      }
    ]
  }
}
```

### Diagnostic Report Update Message
A `DiagnosticReport-update` request will be posted to the Hub when an application desires a change be made to the current state of exchanged information or to add or remove an imaging study to the context of the report.

The updates could include (but are not limited to) any of the following:
* adding, updating, or removing observations
* adding or removing primary imaging studies
* adding or removing comparison imaging studies
* updating attributes of the diagnostic report

The context will contain a Bundle in an updates key which contains one or more resources as entries in the Bundle.

The exchange of information is made using a transactional approach using change sets in the `DiagnosticReport-update` event (i.e. not the complete current state); therefore it is essential that applications interested in the current state of exchanged information process all events and process the events in the order in which they were successfully received by the Hub.  Each `DiagnosticReport-update` event posted to the Hub will be processed atomically by the Hub.

The Hub plays a critical role in helping applications stay in sync with the current state of exchanged information.  On receiving a posted `DiagnosticReport-update` event the Hub will examine the `versionId` of the inbound diagnostic report, which is in the resource's `meta` attribute.   The Hub compares the `versionId` of the incoming request with the `versionId` the Hub previously assigned to the diagnostic report when it received and processed the previous `DiagnosticReport-open` or `DiagnosticReport-update` request. If the incoming `versionId` and last assigned `versionId`  do not match, the message is rejected and the Hub returns an HTTP error status code of 428 (Precondition Required). If the `versionId` values match, the Hub proceeds with processing each of the FHIR resources in the Bundle.  After updating its copy of the current state of exchanged information, the Hub assigns a new `versionId` to the diagnostic report and uses this new `versionId` in the `DiagnosticReport-update` event it forwards to subscribed applications.  The distributed update event contains the same Bundle resource which was contained in the request. 

When a  `DiagnosticReport-update` event is received by an application, the application should respond as is appropriate for its clinical use.    For example, an image reading application may choose to ignore an observation describing a patient's blood pressure.  Since transactional change sets are used during information exchange, no problems are caused by applications deciding to ignore exchanged information not relevant to their function.

#### Context
Key | Optionality | Description
--- | --- | ---
`report`| REQUIRED | FHIR DiagnosticReport resource in context is included for risk mitigation. The `id` and `versionId` of the diagnostic report SHALL be provided; however, additional attributes MAY be present.
`updates`| REQUIRED | Contains one and only one FHIR Bundle resource with a `type` of `transaction`. The Bundle contains 1 to n entries with each `entry` containing a FHIR resource containing structured information that according to the `method` of the entry's `request` attribute should be added (POST), updated (PUT), or removed (DELETE) from the current state of exchanged structured information.

Resource Types that the Hub SHALL Support in the Transaction Bundle:

Resource Type | Comments
--- | ---
DiagnosticReport | Only updates (PUT) on the diagnostic report in the current context are supported. The DiagnosticReport resource `id` MUST match the `id` of the current report. The purpose of this operation is to allow other report attributes (such as report status or referenced imaging studies) to be updated.
ImagingStudy | Both primary studies and comparison studies (priors) are supported in the same manner as the [DiagnosticReport-open event](#diagnostic-report-open-message). All request types (POST, PUT, DELETE) are supported.<br><table>  <thead>  <tr>  <th>Request Type</th>  <th>Comments</th>  </tr>  </thead>  <tbody>  <tr>  <td>POST</td>  <td>Add a new study to the current report, the use of the study as a primary or comparison (prior) study is indicated by updating the imagingStudy attribute in the DiagnosticReport in the same Bundle (see  [DiagnosticReport-open event](#diagnostic-report-open-message))</td>  </tr>  <tr>  <td>PUT</td>  <td>Update attributes of an imaging study already identified as a subject of the report</td>  </tr>  <tr>  <td>DELETE</td>  <td>Remove an imaging study already identified as a subject of the report</td>  </tr>  </tbody>  </table>
Observation | All request types (POST, PUT, DELETE) are supported.<br><table>  <thead>  <tr>  <th>Request Type</th>  <th>Comments</th>  </tr>  </thead>  <tbody>  <tr>  <td>POST</td>  <td>Add a new resource</td>  </tr>  <tr>  <td>PUT</td>  <td>Replace/update an existing resource</td>  </tr>  <tr>  <td>DELETE</td>  <td>Remove an existing resource</td>  </tr>  </tbody>  </table>

Hubs may choose to support additional resource types.

##### DiagnosticReport-update Request Example (Adding an Observation)
The following example shows a request to add an observation to the current state of the exchanged information.

```
{
  "timestamp": "2020-09-07T15:00:15.939Z",
  "id": "0404011",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-update",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "meta": {
            "versionId": "0"
          }
        }
      },
      {
        "key": "updates",
        "resource": {
          "resourceType": "Bundle",
          "id": "345345345",
          "type": "transaction",
          "entry": [
            {
              "request": {
                "method": "POST"
              },
              "resource": {
                "resourceType": "Observation",
                "id": "435098234",
                "partOf": {
                  "reference": "ImagingStudy/8i7tbu6fby5ftfbku6fniuf"
                },
                "status": "preliminary",
                "category": {
                  "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                  "code": "imaging",
                  "display": "Imaging"
                },
                "code": {
                  "coding": [
                    {
                      "system": "http://hl7.org/fhir/ValueSet/observation-codes",
                      "code": "10193-1",
                      "display": "Physical findings of Breasts Narrative"
                    }
                  ]
 
                },
                "issued": "2020-09-07T14:59:55.848Z",
                "identifier": [
                  {
                    "system": "dcm:121151",
                    "value": "Lesion-1"
                  }
                ],
                "component": [
                  {
                    "code": {
                      "coding": [
                        {
                          "system": "https://loinc.org",
                          "code": "21889-1",
                          "display": "Size Tumor"
                        }
                      ]
                    },
                    "valueQuantity": {
                      "value": "13.3",
                      "unit": "mm",
                      "system": "http://unitsofmeasure.org",
                      "code": "mm"
                    }
                  },
                  {
                    "code": {
                      "coding": [
                        {
                          "system": "dcm",
                          "code": "121242",
                          "display": "Distance from Nipple"
                        }
                      ]
                    },
                    "valueQuantity": {
                      "value": "60",
                      "unit": "mm",
                      "system": "http://unitsofmeasure.org",
                      "code": "mm"
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    ]
  }
}
```

The corresponding event distributed by the Hub in response to the above request would replace the versionId in the request with a new versionId generated and retained by the Hub so that it may verify the appropriate versionId is provided in subsequent update requests. 

##### DiagnosticReport-update Request Example for Adding a Comparison (Prior) Study
The following example shows adding an imaging study to the existing diagnostic report context.  The `context` holds the `id` and `versionId` of the diagnostic report as required in all  `DiagnosticReport-update` events.  The Bundle holds the addition (POST) of an imaging study and adds (POST) an observation derived from this study. 

```
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "0d4c7776",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-update",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "meta": {
            "versionId": "1"
          }
        }
      },
      {
        "key": "updates",
        "resource": {
          "resourceType": "Bundle",
          "id": "8i7tbu6fby5fuuey7133eh",
          "type": "transaction",
          "entry": [
            {
              "request": {
                "method": "POST"
              },
              "resource": {
                "resourceType": "ImagingStudy",
                "description": "CHEST XRAY",
                "started": "2010-02-14T01:10:00.000Z",
                "id": "3478116342",
                "identifier": [
                  {
                    "type": {
                      "coding": [
                        {
                          "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                          "code": "ACSN"
                        }
                      ]
                    },
                    "value": "3478116342"
                  },
                  {
                    "system": "urn:dicom:uid",
                    "value": "urn:oid:2.16.124.113543.6003.1154777499.30276.83661.3632298176"
                  }
                ]
              }
            },
            {
              "request": {
                "method": "POST"
              },
              "resource": {
                "resourceType": "Observation",
                "id": "435098234",
                "partOf": {
                  "reference": "ImagingStudy/3478116342"
                },
                "status": "preliminary",
                "category": {
                  "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                  "code": "imaging",
                  "display": "Imaging"
                },
                "code": {
                  "coding": [
                    {
                      "system": "http://www.radlex.org",
                      "code": "RID49690",
                      "display": "simple cyst"
                    }
                  ] 
                },
                "issued": "2020-09-07T15:02:03.651Z"
              }
            }
          ]
        }
      }
    ]
  }
}
```


### Diagnostic Report Select Message
The `DiagnosticReport-select` event will be posted to the Hub when an application desires to indicate that it has selected a specific resource as it is represented in its user interface. This event allows other participating applications to adjust their UIs as appropriate.  For example, a reporting system may indicate that the user has selected a particular observation associated with a measurement value — after receiving this event an imaging reading application which created the measurement may wish to change its user display such that the image from which the measurement was acquired is visible. If a resource is noted as selected, this indicates that any other resource which had been selected is no longer selected (i.e. an implicit unselect of the previously selected resource).  Additionally, an application may indicate that all selections have been cleared by posting a `DiagnosticReport-select` with an empty `select` array.

NOTE: While it is assumed that an observation with an id of a67tbi5891trw123u6f9134 is contained in the current DiagnosticReport content, the Hub DOES NOT provide validation

#### Context
Key | Optionality | Description
--- | --- | ---
`report`| REQUIRED | FHIR DiagnosticReport resource in context is included for risk mitigation. The `id` and `versionId` of the diagnostic report SHALL be provided; however, additional attributes MAY be present.
`select`| REQUIRED | Contains zero or more references to the selected resources. If a reference to a resource is present in the `select` array, there is an implicit unselect of any previously selected resource. If no resource references are present in the `select` array this is an indication that any previously selected resource is now unselected.

##### DiagnosticReport-select Example
The following example shows the selection of a single Observation resource. 

```
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "0e7ac18",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-select",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "meta": {
            "versionId": "2019-08-23T22:21:42.11"
          }
        }
      },
      {
        "select": [
          {
            "resourceType": "Observation",
            "id": "a67tbi5891trw123u6f9134"
          }
        ]
      }
    ]
  }
}
```


### Diagnostic Report Close Message
The `DiagnosticReport-close` event is posted to the Hub when an application desires to close the active diagnostic report centered workflow.

##### DiagnosticReport-close Example
This example sets the status of the report to `final`.

```
{
  "timestamp": "2020-09-07T15:04:43.133Z",
  "id": "4441881",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-close",
    "context": [
      {
        "key": "Report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "status": "final",
          "issued": "2020-09-07T15:04:42.134Z"
        }
      }
    ]
  }
}
```

