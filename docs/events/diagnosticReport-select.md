# DiagnosticReport-select
eventMaturity | [1 - Submitted](../../specification/STU3/#event-maturity-model)

## Workflow
A `DiagnosticReport-select` request will be made to the Hub when an application desires to indicate that one or more FHIR resources contained in the anchor context's content are to be made visible, in focus, or otherwise "selected". It is assumed that a FHIR resource (e.g., observation) with the specified `id` is contained in the current anchor context's content, the Hub MAY or MAY NOT provide validation of its presence.

This event allows other participating applications to adjust their UIs as appropriate.  For example, a reporting system may indicate that the user has selected a particular observation associated with a measurement value. After receiving this event an image reading application which created the measurement may wish to change its user display such that the image from which the measurement was acquired is visible.
    
If a resource is noted as selected, any other resource which had been selected is no longer selected (i.e., an implicit unselect of any previously selected resource).  Additionally, an application may indicate that all selections have been cleared by posting a `DiagnosticReport-select` with an empty `select` array. 

    
## Context

### Context

| Key | Optionality | FHIR operation to generate context | Description
| - | - | - | -
`report` | REQUIRED | `DiagnosticReport/{id}?_elements=identifier` | Anchor context
`select` | REQUIRED | not applicable | Contains zero or more references to selected resources. If a reference to a resource is present in the `select` array, there is an implicit unselect of any previously selected resource. If no resource references are present in the `select` array, this is an indication that any previously selected resource is now unselected.
`version` | REQUIRED | not applicable | Current content version

## Examples

### DiagnosticReport-select Example
The following example shows the selection of a single Observation resource in an anchor context of a diagnostic report.

```
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "0e7ac18",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-select",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366"
        }
      },
      {
        "select": [
          {
            "resourceType": "Observation",
            "id": "a67tbi5891trw123u6f9134"
          }
        ]
      },
      {
        "key": "version",
        "versionId": "f2f90ff4-a218-47cb-afa5-b987e1154b3b"
      }
    ]
  }
}
```

## Change Log
| Version | Description   |
| ------- | ------------- |
| 0.1     | Initial draft |
