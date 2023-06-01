### Event-name: DiagnosticReport-close

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

A `DiagnosticReport-close` event is posted to the Hub when a Subscriber desires to close the active anchor context centered workflow.  After the event is distributed to all Subscribers, it is expected that the Hub will remove any content associated with the anchor context from its memory.

### Context
{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`report` | 1..1 | `DiagnosticReport/{id}?_elements=identifier,subject` | FHIR DiagnosticReport resource describing the report previously in context that is being closed.
`study` | 0..* | `ImagingStudy/{id}?_elements=identifier,subject` | FHIR ImagingStudy resource(s) describing any image study that was opened as part of the report context that is being closed.
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the report being closed.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in DiagnosticReport close request:

* [DiagnosticReport for Close Events](StructureDefinition-fhircast-diagnostic-report-close.html)
* [ImagingStudy for Close Events](StructureDefinition-fhircast-imaging-study-close.html)
* [Patient for Close Events](StructureDefinition-fhircast-patient-close.html)

Other attributes of the DiagnosticReport, ImagingStudy, and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

### Examples

#### DiagnosticReport-close Example

This example closes a DiagnosticReport context.

```json
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
        }
      }
    ]
  }
}
```

### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 0.1 | Initial draft
