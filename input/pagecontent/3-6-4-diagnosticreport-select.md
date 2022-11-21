### Event-name: DiagnosticReport-select

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow
A `DiagnosticReport-select` request will be made to the Hub when a Subscriber desires to indicate that one or more FHIR resources contained in the DiagnosticReport context's content are to be made visible, in focus, or otherwise "selected". It is assumed that a FHIR resource (e.g., observation) with the specified `id` is contained in the current anchor context's content, the Hub MAY or MAY NOT provide validation of its presence.

This event allows other Subscribers to adjust their UIs as appropriate.  For example, a reporting system may indicate that the user has selected a particular observation associated with a measurement value. After receiving this event an image reading application which created the measurement may wish to change its user display such that the image from which the measurement was acquired is visible.

If one or more resources are noted as selected, any other resource which had been selected is assumed to be no longer selected (i.e., an implicit unselect of any previously selected resource).  Additionally, a Subscriber may indicate that all selections have been cleared by posting a `DiagnosticReport-select` with an empty `select` array. 

### Context

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
---- | ---- | ---- | ----
`report` | REQUIRED | `DiagnosticReport/{id}?_elements=identifier` | Anchor context
`select` | REQUIRED | not applicable | Contains zero or more references to selected resources. If a reference to a resource is present in the `select` array, there is an implicit unselect of any previously selected resource. If no resource references are present in the `select` array, this is an indication that any previously selected resource is now unselected.

### Examples

#### DiagnosticReport-select Example

The following example shows the selection of a single Observation resource in an anchor context of a diagnostic report.

```json
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "0e7ac18",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-select",
    "context.versionId": "f2f90ff4-a218-47cb-afa5-b987e1154b3b",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366"
        }
      },
      {
        "key": "select",
        "resource": {
          "resourceType": "Observation",
          "id": "a67tbi5891trw123u6f9134"
        }
        
      }
    ]
  }
}
```

### Change Log

{:.grid}
| Version | Description
| ------- | -------------
| 0.1     | Initial draft
