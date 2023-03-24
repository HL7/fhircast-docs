### Event-name: DiagnosticReport-update

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

 The `DiagnosticReport-update` event is used by Subscribers to support content sharing in communication with a Hub which also supports content sharing.  A `DiagnosticReport-update` request will be posted to the Hub when a Subscriber desires a to add, change, or remove exchanged information in the anchor context.  For a `DiagnosticReport-update`, the anchor context (see: [`anchor context`](5_glossary.html)) is the `DiagnosticReport` context established by the corresponding `DiagnosticReport-open`.  One or more update requests MAY occur while the anchor context is open.

The updates include:

* adding, updating, or removing FHIR resources contained in the DiagnosticReport
* updating attributes of the DiagnosticReport or associated context resources (Patient and/or ImagingStudy resources)

#### Context

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
`report`| REQUIRED | `DiagnosticReport/{id}?_elements=identifier` | Anchor context
`patient` | OPTIONAL | `Patient/{id}?_elements=identifier` | Present if one or more attributes in the Patient resource associated with the report have changed
`study` | OPTIONAL | `ImagingStudy/{id}?_elements=identifier,accession` | Present if one or more attributes in the ImagingStudy resource associated with the report have changed
`updates` | REQUIRED | not applicable | Changes to be made to the current content of the anchor context

#### Supported Update Request Methods

Each `entry` in the `updates` Bundle resource must contain one of the below `method` values in an entry's `request` attribute.

{:.grid}
Request Method | Operation
--- | ---
`POST` | Add a new resource
`PUT` | Replace/update an existing resource
`DELETE` | Remove an existing resource

#### Examples

##### DiagnosticReport-update Request Example

The following example shows adding an imaging study to the existing diagnostic report context and a new observation.  The `context.versionId` matches the `context.versionId` provided by the Hub in the most recent `DiagnosticReport-open` or `DiagnosticsReport-update` event. The `report` key in the `context` array holds the `id` of the diagnostic report and is required in all `DiagnosticReport-update` events.  The `Bundle`in the `updates` key holds the addition (POST) of an imaging study and adds (POST) an observation derived from this study.

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

##### DiagnosticReport-update Event Example

The HUB SHALL distribute a corresponding event to all Subscribers. The Hub SHALL replace the `context.versionId` in the request with a new `context.versionId` generated and retained by the Hub.  The prior version, `context.priorVersionId` of the context is also provided to ensure that a Subscriber is currently in sync with the latest context prior to applying the new updates.  If the value of `context.priorVersionId` is not in agreement with the `context.versionId` last received by a Subscriber, it is recommended that the Subscriber issue a GET request to the Hub in order to retrieve the latest version of the context (note that the GET request returns the context, all existing content, and the current `context.versionId`).

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

#### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 0.1 | Initial draft
