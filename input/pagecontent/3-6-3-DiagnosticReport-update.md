### Event-name: DiagnosticReport-update

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

 The `DiagnosticReport-update` event is used by Subscribers to support content sharing in communication with a Hub which also supports content sharing.  A `DiagnosticReport-update` request will be posted to the Hub when a Subscriber desires to add, change, or remove exchanged information in the anchor context.  For a `DiagnosticReport-update`, the [`anchor context`](5_glossary.html) is the `DiagnosticReport` context established by the corresponding `DiagnosticReport-open`.  One or more update requests MAY occur while the anchor context is open.

The updates that may be included in the `updates` bundle include:

* adding, updating, or removing FHIR resources contained in the DiagnosticReport
* updating attribute values of the DiagnosticReport or associated context resources (Patient and/or ImagingStudy resources)

#### Context

{:.grid}
Key       | Cardinality | Type      | Description
--------- | ----------- | --------- | --------------
`report`  | 1..1        | reference | Reference to the FHIR DiagnosticReport resource specifying the [`anchor context`](5_glossary.html) in which the update is being made.
`patient` | 0..1        | reference | May be provided so that Subscribers may perform identity verification according to their requirements.
`updates` | 1..1        | resource  | Contains a single `Bundle` resource holding changes to be made to the current content of the [`anchor context`](5_glossary.html)

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in a DiagnosticReport-update request:

* [Content Update Bundle](StructureDefinition-fhircast-content-update-bundle.html)

#### Supported Update Request Methods

Each `entry` in the `updates` Bundle resource SHALL contain one of the below `method` values in an entry's `request` attribute.  No resource SHALL appear multiple times in the `updates` Bundle.  One and only one [transaction `Bundle`](https://www.hl7.org/fhir/http.html#transaction) SHALL be present in a `DiagnosticReport-update` request.

{:.grid}
Request Method | Operation
--- | ---
`PUT` | Add a new resource or update a resource already existing in the content
`DELETE` | Remove an existing resource

#### Number of Entries in Transaction Bundle

FHIRcast doesn't prescribe a limit on the number of entries in the transaction Bundle; however, implementers should expect a limit for production-grade software. Generally, the upper range of entries in a FHIRcast transaction bundle is in the *dozens*. Recipients SHOULD return an error when they receive a FHIRcast event notification that is too large to support. Specifically, recipients SHALL either synchronously return an HTTP error status of [HTTP 413 - Content Too Large](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/413), or asynchronously a `syncerror` with an `OperationOutcome.issue.code` = "[too-long](https://hl7.org/fhir/R4/valueset-issue-type.html)".


#### Examples

##### App adds ImagingStudy and Observation to DiagnosticReport

The following example shows adding an imaging study and a new observation to the existing diagnostic report context.  The `context.versionId` matches the `context.versionId` provided by the Hub in the most recent `DiagnosticReport-open` or `DiagnosticReport-update` event. The `report` key in the `context` array holds the `id` of the diagnostic report and is required in all `DiagnosticReport-update` events.  The `Bundle` in the `updates` key holds the addition (PUT) of an imaging study, adds (PUT) an observation derived from this study, and updates the DiagnosticReport to reference these new resources, in addition to the pre-existing result ("No significant lymphadenopathy").

```json
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "cc4d016a-f516-4ce7-8f1a-e0baf0beb94d",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "DiagnosticReport-update",
    "context.versionId": "b9574cb0-e9e5-4be1-8957-5fcb51ef33c1",
    "context": [
      {
        "key": "report",
        "reference": { "reference": "DiagnosticReport/2402d3bd-e988-414b-b7f2-4322e86c9327"
        }
      },
      {
        "key": "patient",
        "reference": { 
          "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
        }
      },
      {
        "key": "updates",
        "resource": {
          "resourceType": "Bundle",
          "type": "transaction",
          "entry": [
            {
              "request": {
                "method": "PUT"
              },
              "resource": {
                "resourceType": "ImagingStudy",
                "description": "CHEST XRAY",
                "started": "2010-02-14T01:10:00.000Z",
                "id": "7e9deb91-0017-4690-aebd-951cef34aba4",
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
                "method": "PUT"
              },
              "resource": {
                "resourceType": "Observation",
                "id": "40afe766-3628-4ded-b5bd-925727c013b3",
                "partOf": {
                  "reference": "ImagingStudy/7e9deb91-0017-4690-aebd-951cef34aba4"
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
            },
            {
              "request": {
                "method": "PUT"
              },
              "resource": {
                "resourceType": "DiagnosticReport",
                "id": "2402d3bd-e988-414b-b7f2-4322e86c9327",
                "imagingStudy": [
                  {
                    "reference": "ImagingStudy/7e9deb91-0017-4690-aebd-951cef34aba4"
                  }
                ],
                "result": [
                  {
                    "reference": "Observation/1e057514-e069-4eb1-aed9-5e70c693fe28",
                    "display": "No significant lymphadenopathy"
                  },
                  {
                    "reference": "Observation/40afe766-3628-4ded-b5bd-925727c013b3",
                    "display": "Microcalcifications in left breast"
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

##### Hub broadcasts with new `versionid`

The Hub distributes the corresponding event to all Subscribers. The Hub replaces the `context.versionId` in the request with a new `context.versionId` generated by the Hub.  The prior version, `context.priorVersionId` of the context enables continuity.  If the value of `context.priorVersionId` is not in agreement with the `context.versionId` last received by a Subscriber, the Subscriber can [retrieve the current context](2-9-GetCurrentContext.html). 

```json
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "cc4d016a-f516-4ce7-8f1a-e0baf0beb94d",
   "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "DiagnosticReport-update",
    "context.versionId": "efcac43a-ed38-49e4-8d79-73f78290292a",
    "context.priorVersionId": "b9574cb0-e9e5-4be1-8957-5fcb51ef33c1",
    "context": [
      {
        "key": "report",
        "reference": { "reference" : "DiagnosticReport/2402d3bd-e988-414b-b7f2-4322e86c9327"
        }
      },
      {
        "key": "patient",
        "reference": { "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
        }
      },
      {
        "key": "updates",
        "resource": {
          "resourceType": "Bundle",
          "type": "transaction",
          "entry": [
            {
              "request": {
                "method": "PUT"
              },
              "resource": {
                "resourceType": "ImagingStudy",
                "description": "CHEST XRAY",
                "started": "2010-02-14T01:10:00.000Z",
                "id": "7e9deb91-0017-4690-aebd-951cef34aba4",
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
                "method": "PUT"
              },
              "resource": {
                "resourceType": "Observation",
                "id": "40afe766-3628-4ded-b5bd-925727c013b3",
                "partOf": {
                  "reference": "ImagingStudy/7e9deb91-0017-4690-aebd-951cef34aba4"
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
            },
            {
              "request": {
                "method": "PUT"
              },
              "resource": {
                "resourceType": "DiagnosticReport",
                "id": "2402d3bd-e988-414b-b7f2-4322e86c9327",
                "imagingStudy": [
                  {
                    "reference": "ImagingStudy/7e9deb91-0017-4690-aebd-951cef34aba4"
                  }
                ],
                "result": [
                  {
                    "reference": "Observation/1e057514-e069-4eb1-aed9-5e70c693fe28",
                    "display": "No significant lymphadenopathy"
                  },
                  {
                    "reference": "Observation/40afe766-3628-4ded-b5bd-925727c013b3",
                    "display": "Microcalcifications in left breast"
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

##### App later deletes Observation from DiagnosticReport

The following example shows a request to delete an observation from a content sharing session.

```json
{
  "timestamp": "2019-09-10T15:02:33.343Z",
  "id": "d30734f1-3c7d-4fe4-a343-fbf4d80faddb",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "DiagnosticReport-update",
    "context.versionId": "efcac43a-ed38-49e4-8d79-73f78290292a",
    "context": [
      {
        "key": "report",
        "reference": { "reference": "DiagnosticReport/2402d3bd-e988-414b-b7f2-4322e86c9327"
        }
      },
      {
        "key": "patient",
        "reference": { "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
        }
      },
      {
        "key": "updates",
        "resource": {
          "resourceType": "Bundle",
          "type": "transaction",
          "entry": [
            {
              "fullUrl": "Observation/40afe766-3628-4ded-b5bd-925727c013b3",
              "request": {
                "method": "DELETE"
              }
            },
            {
              "request": {
                "method": "PUT"
              },
              "resource": {
                "resourceType": "DiagnosticReport",
                "id": "2402d3bd-e988-414b-b7f2-4322e86c9327",
                "imagingStudy": [
                  {
                    "reference": "ImagingStudy/7e9deb91-0017-4690-aebd-951cef34aba4"
                  }
                ],
                "result": [
                  {
                    "reference": "Observation/1e057514-e069-4eb1-aed9-5e70c693fe28",
                    "display": "No significant lymphadenopathy"
                  }
                ]
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
| 1.0 | Updated for STU3
