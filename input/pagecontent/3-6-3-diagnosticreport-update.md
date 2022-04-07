### Event-name: DiagnosticReport-update

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

 The `DiagnosticReport-update` event is used by clients to support content sharing in communication with a Hub which also supports content sharing.  A `DiagnosticReport-update` request will be posted to the Hub when an application desires a change be made to the current state of exchanged information or to add or remove a reference to a FHIR resource contained in the content of the current anchor context. One or more updates MAY occur while the anchor context is open.

The updates include:

* adding, updating, or removing FHIR resources contained in the anchor context
* updating attributes of the anchor context (the DiagnosticReport resource) or associated context resources (Patient and/or ImagingStudy resources)

The context MUST contain a `Bundle` resource in an `updates` key which contains zero or more resources which are to be updated as entries in the Bundle.  Normally at least one entry exists in the `Bundle` resource; however, if only updating attributes of the anchor context or associated context resources the `Bundle` resource may have no entries.

Exchange of information is made transactionally using change sets in the `DiagnosticReport-update` event (i.e., the complete current state of the content is not provided in the `Bundle` resource in the `updates` key).  Therefore it is essential that applications interested in the current state of exchanged information process all events and process the events in the order in which they were successfully received by the Hub.  Each `DiagnosticReport-update` event posted to the Hub SHALL be processed atomically by the Hub (i.e., all entries in the request's `Bundle` should be processed prior to the Hub accepting another request).

The Hub plays a critical role in helping applications stay synchronized with the current state of exchanged information.  On receiving a `[FHIR resource]-update` request the Hub SHALL examine the `context.versionId` of the anchor context.   The Hub SHALL compare the `context.versionId` of the incoming request with the `context.versionId` the Hub previously assigned to the anchor context (i.e, the `context.versionId` assigned by the Hub when the previous `DiagnosticReport-open` or `DiagnosticReport-update` request was processed). If the incoming `context.versionId` and last assigned `context.versionId` do not match, the request SHALL be rejected and the Hub SHALL return a 4xx/5xx HTTP Status Code.

If the `context.versionId` values match, the Hub proceeds with processing each of the FHIR resources in the Bundle and SHALL process all Bundle entries in an atomic manner.  After updating its copy of the current state of exchanged information, the Hub SHALL assign a new `context.versionId` to the anchor context and use this new `context.versionId` in the `DiagnosticReport-update` event it forwards to subscribed applications.  The Hub SHALL also include the `context.priorVersionId` in the distributed event which receiving applications MAY use to ensure they are apply the updates to the proper context version. The distributed update event SHALL contain a Bundle resource with the same Bundle `id` which was contained in the request.

When a  `DiagnosticReport-update` event is received by an application, the application should respond as is appropriate for its clinical use.  For example, an image reading application may choose to ignore an observation describing a patient's blood pressure.  Since transactional change sets are used during information exchange, no problems are caused by applications deciding to ignore exchanged information not relevant to their function.  However, they should read and retain the `context.versionId` of the anchor context provided in the event for later use.

### Content Information

FHIR resources are used to carry the information being displayed.  These are the entries in the `Bundle` resource inside the `updates` key.  Commonly the information is contained in an `entry`'s resource. For example, an `Observation` resource most likely contains all information regarding that observation.

However, in some cases the information of a resource may best be conveyed by reference rather than being self-contained.  When exchanging a resource by reference, an `entry`'s `fullUrl` is populated with a uri from which the full content of the resource may be retrieved.  Additionally, the `entry`'s `resource` attribute contains at least the `type` and `id` of the resource.  Finally, the `method` value in an entry's `request` attribute must be appropriately populated.

If information is exchanged by reference, the `fullUrl` reference could be to a resource already persisted in a FHIR Server having a data store with long-term persistance.  Alternatively, the reference could be to a temporary data store with a lifecycle of the content exchange session and managed by the Hub with a FHIR retrieve endpoint.

### Context

#### Context

Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
`report`| REQUIRED | `DiagnosticReport/{id}?_elements=identifier` | Anchor context
`patient` | OPTIONAL | `Patient/{id}?_elements=identifier` | Present if one or more attributes in the Patient resource associated with the report have changed
`study` | OPTIONAL | `ImagingStudy/{id}?_elements=identifier,accession` | Present if one or more attributes in the Patient resource associated with the report have changed
`updates` | REQUIRED | not applicable | Changes to be made to the current content of the anchor context

### Supported Update Request Methods

Each `entry` in the `updates` Bundle resource must contain one of the below `method` values in an entry's `request` attribute.

Request Method | Operation
--- | ---
`POST` | Add a new resource
`PUT` | Replace/update an existing resource
`DELETE` | Remove an existing resource

### Examples

#### DiagnosticReport-update Request Example

The following example shows adding an imaging study to the existing diagnostic report context and a new observation.  The `context` holds the `id` and `versionId` of the diagnostic report as required in all  `DiagnosticReport-update` events.  The `Bundle` holds the addition (POST) of an imaging study and adds (POST) an observation derived from this study.

```json
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "0d4c7776",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-update",
    "context.versionId": "b9574cb0-e9e5-4be1-8957-5fcb51ef33c1",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366"
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
                "id": "kr8r9rg00094hf331",
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
                    "value": "urn:oid:2.16.124.113543.6003.1154777499.38476.11982.4847614254"
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
                "derivedFrom": {
                  "reference": "ImagingStudy/kr8r9rg00094hf331"
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

#### DiagnosticReport-update Event Example

The HUB SHALL distribute a corresponding event to all applications currently subscribed to the topic. The Hub SHALL replace the `context.versionId` in the request with a new `context.versionId` generated and retained by the Hub.  The prior version, `context.priorVersionId` of the context is also provided to ensure that an application is currently in sync with the latest context prior to applying the new changes.  If the value of `context.priorVersionId` is not in agreement with the `context.versionId` last received by an application, it is recommended that the application issue a GET request to the Hub in order to retrieve the latest version of the context (note that the GET request returns the context, all existing content, and its `context.versionId`).

```json
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "0d4c7776",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-update",
    "context.versionId": "efcac43a-ed38-49e4-8d79-73f78290292a",
    "context.priorVersionId": "b9574cb0-e9e5-4be1-8957-5fcb51ef33c1",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366"
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
                "id": "kr8r9rg00094hf331",
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
                "derivedFrom": {
                  "reference": "ImagingStudy/kr8r9rg00094hf331"
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

### Change Log

Version | Description
---- | ----
0.1 | Initial draft
