{% include infonote.html text='Implementer feedback is solicited on the GetCurrentContext operation.' %}

In some situations, Subscribers may want to verify the current context. This section defines a method in which the current context can be retrieved using a GET call. The Hub responds to this GET request with the most recently communicated open event. 

Hubs MAY support returning the current context of a session, as defined below.

### Get Current Context Request

The requester makes an HTTP GET call to the following URL:

GET `base-hub-URL/{topic}`

### Get Current Context Response

This method returns an object containing the current context of a topic; where the current context is the most recent *-open event for which no *-close event has occurred, according to the Subscriber's subscription.  The current context is made up of one or more "top-level" contextual resources and the type of the anchor context SHALL be in the `context.type` field.  For example, if the current context was established using a [`Patient-open`](3-3-1-patient-open.html) request the returned object will contain `context.type: "Patient"`.  If the current context was created by a [`DiagnosticReport-open`](3-6-1-diagnosticreport-open.html) request the returned object will contain `context.type: "DiagnosticReport"`.  If there is no context currently established, the `context.type` SHALL contain an empty string and the `context` SHALL be an empty array.

{:.grid}
Field | Optionality | Type | Description
----- | --- | --- | ---
`context.type` | Required | string | ResourceType of the context element or an empty string if no context is currently established.
`context.versionId` | Required | string | The versionId of the current context. Each time the context changes, a different versionId is generated.
`context`   | Required | array | The context array of the corresponding context element as was supplied in the most recent `-open` event or an empty array if no context is currently established.

### Content Sharing Support

If a Hub supports content sharing, the Hub returns the current content in a `content` key in the `context` array.  There SHALL be one and only one `Bundle` resource which SHALL have a `type` of `collection`.  No entry in the `Bundle` shall contain a `request` attribute.  The `Bundle` SHALL contain no entries if there is no content associated with the current context.

#### Context

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
`content` | REQUIRED if content sharing is supported | not applicable | Current content of the anchor context or a `Bundle` resource with no entries if no content is associated with the current context. The `Bundle` resource SHALL conform to the [FHIRcast get current content Bundle](StructureDefinition-fhircast-get-current-content-bundle.html) profile.

### Examples

#### Get Context Response Example

The following example shows a response to the get context request when the current context was created by a [`DiagnosticReport-open`](3-6-1-diagnosticreport-open.html) request.  The response contains version "023fe970-a6d9-442f-a499-dfb71f1edba6" of the anchor context's content which contains a single `Observation` resource. 

```json
{
  "context.type": "DiagnosticReport",
  "context.versionId": "023fe970-a6d9-442f-a499-dfb71f1edba6",
  "context": [
    {
      "key": "report",
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
              "subject": {
                "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
              },
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
The following example shows the returned structure when no context is established:

```json
{
  "context.type": "",
  "context": []
}
```
