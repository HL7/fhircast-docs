> This is draft content. Implementer feedback is solicited around this topic.

In some situations, Subscribers may want to verify the current context, or they choose not to subscribe to events. This section defines a method in which the current context can be retrieved using a GET call.

### Get current context Request

The Requester makes an HTTP GET call to the following URL:

`base-hub-URL/{topic}`

### Get current context Response

This method returns an object containing the current context of a topic. The current context is made up of one or more "top-level" contextual resources and the type of the anchor context in the `context.type` field.  For example, if the current context was established using a [`Patient-open`]( 3-3-patient-open.html) request the returned object will contain `context.type: "Patient"`.  If the current context was created by a [`DiagnosticReport-open`](3-6-diagnosticreport-open.html) request the returned object will contain `context.type: "DiagnosticReport"`.

Field | Optionality | Type | Description
---   | --- | --- | ---
`context.type` | Required | string | ResourceType of the context element.
`context.versionId` | Required | string | The versionId of the current context. Each time the context changes, a different versionId is generated.
`context`   | Required | array | The context field of the corresponding context element as defined in the `-open` event of the resourceType.

### Content Sharing Support

If a Hub supports content sharing, the Hub returns the current content in an `content` key and the content version in a `version` key.  `Bundle` entries SHALL not contain a `request` attribute.  The enclosed `Bundle` resource SHALL have a `type` of `collection`.  The `Bundle` SHALL contain no entries if there is no content associated with the current context.

#### Context

Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
resource key | REQUIRED | `[resourceType]/{id}?_elements=identifier` | 1..* contextual resources
`content` | REQUIRED if content sharing is supported | not applicable | Current content of the anchor context

### Examples

#### Get Context Response Example

The following example shows a response to the get context request when the current context was created by a [`DiagnosticReport-open`](3-6-diagnosticreport-open.html) request.  The response contains version 2 of the anchor context's content which contains a single `Observation` resource. 

```json
{
  "context.type": "DiagnosticReport",
  "context.versionId": "023fe970-a6d9-442f-a499-dfb71f1edba6",
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
    }
  ]
}
```
