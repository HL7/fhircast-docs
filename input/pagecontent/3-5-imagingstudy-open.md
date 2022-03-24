### Event-name: ImagingStudy-open

eventMaturity | [2 - Tested](3-1-EventMaturityModel.html)

### Workflow

An `ImagingStudy-open` request is posted to the Hub when an image study is opened by an application and established as the anchor context of a topic. The `context` field MUST contain at least one `Patient` resource and the `ImagingStudy` resource.

When an `ImagingStudy-open` event is received by an application, the application should respond as is appropriate for its clinical use.

#### Content Sharing Support

If a Hub supports content sharing, when it distributes an `ImagingStudy-open` event the Hub associates a `context.versionId` with the anchor context.

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | Patient resource describing the patient associated with the imaging study
`encounter` | OPTIONAL | `Encounter/{id}?_elements=identifier	` | Encounter resource describing the encounter associated with the imaging study, if known
`study` | REQUIRED | `ImagingStudy/{id}?_elements=identifier` | ImagingStudy being opened

### Examples

#### ImagingStudy-open Example Request

The following example shows an image study being opened.  Note that the imaging study's `subject` attribute references the patient which is also in the open request.

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "imagingstudy-open",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "type" : {
                "coding" : [
                  {
                    "system" : "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code" : "MR",
                    "display" : "Medical Record Number"
                  }
                ]
              },
              "system" : "urn:oid:1.2.36.146.595.217.0.1",
              "value" : "213434"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "status": "unknown",
          "identifier": [
            {
              "system": "urn:dicom:uid",
              "value": "urn:oid:2.16.124.113543.6003.1154777499.30246.19789.3503430045"
            }
          ],
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      }
    ]
  }
}
```

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
