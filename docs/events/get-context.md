# Get Context
eventMaturity | [1 - Submitted](../../specification/STU3/#event-maturity-model)

HTTP Method: GET<br>
Endpoint: base-hub-URL/{topic}<br>
Returns:<br>
This method returns an object containing the current context of a topic. The current context is made up of one or more "top-level" contextual resources and the type of the anchor context in the `contextType` field.  For example, if the current context was established using a [`Patient-open`](./patient-open.md) request the returned object will contain `contextType: "Patient"`.  If the current context was created by a [`DiagnosticReport-open`](./diagnosticReport-open.md) request the returned object will contain `contextType: "DiagnosticReport"`.

## Content Sharing Support
If a Hub supports content sharing, the Hub returns the current content in an `content` key and the content version in a `version` key.  `Bundle` entries SHALL not contain a `request` attribute.  The enclosed `Bundle` resource SHALL have a `type` of `collection`.  The `Bundle` SHALL contain no entries if there is no content associated with the current context.

## Context

#### Context
Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
resource key | REQUIRED | `[resourceType]/{id}?_elements=identifier` | 1..* contextual resources
`content` | REQUIRED if content sharing is supported | not applicable | Current content of the anchor context
`version`| REQUIRED if content sharing is supported | not applicable | Current content version
 
## Examples

### Get Context Response Example
The following example shows a response to the get context request when the current context was created by a [`DiagnosticReport-open`](./diagnosticReport-open.md) request.  The response contains version 2 of the anchor context's content which contains a single `Observation` resource. 

```
{
  "contextType": "DiagnosticReport",
  "context": [
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
    },
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
      "key": "content",
      "resource": {
        "resourceType": "Bundle",
        "id": "8i7tbu6fby5fuuey7133eh",
        "type": "collection",
        "entry": [
          {
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
    },
    {
      "key": "version",
      "versionId": "023fe970-a6d9-442f-a499-dfb71f1edba6"
    }
  ]
}
```

## Change Log
Version | Description
---- | ----
0.1 | Initial draft