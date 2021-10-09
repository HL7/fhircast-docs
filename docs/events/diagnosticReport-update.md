# DiagnosticReport-update
eventMaturity | [1 - Submitted](../../specification/STU3/#event-maturity-model)

## Workflow
The `DiagnosticReport-update` event is used by clients to support content sharing in communication with a Hub which also supports content sharing.  A `DiagnosticReport-update` request will be posted to the Hub when an application desires a change be made to the current state of exchanged information or to add or remove a reference to a contained FHIR resource in the content of the current anchor context. One or more updates MAY occur while the anchor context is open.

The updates could include (but are not limited to) any of the following:
* adding, updating, or removing observations contained in the DiagnosticReport anchor context
* adding, updating, or removing other FHIR resources contained in the anchor context
* updating attributes of the anchor context resource's attributes

The context MUST contain a `Bundle` in an `updates` key which contains one or more resources as entries in the Bundle.

The exchange of information is made using a transactional approach using change sets in the `DiagnosticReport-update` event (i.e., the complete current state of the content is not provided in the `Bundle` resource in the `updates` key); therefore it is essential that applications interested in the current state of exchanged information process all events and process the events in the order in which they were successfully received by the Hub.  Each `DiagnosticReport-update` event posted to the Hub SHALL be processed atomically by the Hub (i.e., all entries in the request's `Bundle` should be processed prior to the Hub accepting another request).

The Hub plays a critical role in helping applications stay synchronized with the current state of exchanged information.  On receiving a `[FHIR resource]-update` request the Hub SHALL examine the `versionId` of the anchor context, which is in the `version` key of the event.   The Hub SHALL compare the `versionId` of the incoming request with the `versionId` the Hub previously assigned to the anchor context (i.e, the `versionId` assigned by the Hub when the previous `DiagnosticReport-open` or `DiagnosticReport-update` request was processed). If the incoming `versionId` and last assigned `versionId` do not match, the request SHALL be rejected and the Hub SHALL return a 4xx/5xx HTTP Status Code.
 
If the `versionId` values match, the Hub proceeds with processing each of the FHIR resources in the Bundle and SHALL process all Bundle entries in an atomic manner.  After updating its copy of the current state of exchanged information, the Hub SHALL assign a new `versionId` to the anchor context and use this new `versionId` in the `[FHIR resource]-update` event it forwards to subscribed applications.  The distributed update event SHALL contain a Bundle resource with the same Bundle `id` which was contained in the request. 

When a  `[FHIR resource]-update` event is received by an application, the application should respond as is appropriate for its clinical use.  For example, an image reading application may choose to ignore an observation describing a patient's blood pressure.  Since transactional change sets are used during information exchange, no problems are caused by applications deciding to ignore exchanged information not relevant to their function.  However, they should read and retain the `versionId` of the anchor context provided in the event for later use.

## Context

#### Context
Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the diagnostic report
`report`| REQUIRED | `DiagnosticReport/{id}?_elements=identifier` | Type of the [FHIR resource] being opened
`study` | OPTIONAL | ImagingStudy/{id}?_elements=identifier,accession | Information about the imaging study referenced by the report (if an imaging study is referenced) may be provided 
`version`| REQUIRED | not applicable | Current content version

### Examples





#### [FHIR resource]-open Example Request
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
      }
    ]
  }
}
```

#### DiagnosticReport-open Event Example
The event distributed by the Hub includes a version context with a `versionId` which will be used by subscribers to make subsequent [`DiagnosticReport-update`](../diagnosticReport-update) requests.

```
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-open",
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
        "key": "version",
        "versionId": "1"
      }
    ]
  }
}
```

## Change Log
Version | Description
---- | ----
0.1 | Initial draft
