### Event-name: DiagnosticReport-select

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow
A `DiagnosticReport-select` request will be made to the Hub when a Subscriber desires to indicate that one or more FHIR resources contained in the DiagnosticReport's content are to be made visible, in focus, or otherwise "selected". It is assumed that a FHIR resource (e.g., Observation) with the specified `id` is contained in the specified [`anchor context's`](5_glossary.html) content, the Hub MAY or MAY NOT provide validation of its presence.

This event allows other Subscribers to adjust their UIs as appropriate.  For example, a reporting system may indicate that the user has selected a particular observation associated with a measurement value. After receiving this event an image reading application which created the measurement may wish to change its user display such that the image from which the measurement was acquired is visible.

If one or more resources are noted as selected, any other resource which had been selected is assumed to be no longer selected (i.e., an implicit unselect of any previously selected resource).  Additionally, a Subscriber may indicate that all selections have been cleared by posting a `DiagnosticReport-select` with an empty `select` array. 

### Context

{:.grid}
Key       | Cardinality | Type      | Description
--------- | ----------- | --------- | --------------
`report`  | 1..1        | reference | Reference to the FHIR DiagnosticReport resource specifying the [`anchor context`](5_glossary.html) in which the selection is being made.
`patient`	| 0..1	      | reference	| May be provided so that Subscribers may perform identity verification according to their requirements.
`select`  | 1..*        | reference | Contains zero or more references to selected resources. If a reference to a resource is present , there is an implicit unselect of any previously selected resource. If no resource references are present , this is an indication that any previously selected resource is now unselected.


### Examples

#### DiagnosticReport-select Example

The following example shows the selection of a single Observation resource in an anchor context of a diagnostic report.

```json
{
  "timestamp": "2019-09-10T14:58:45.988Z",
  "id": "78ef1125-7f8b-4cbc-bc59-a2a02f7e04",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "DiagnosticReport-select",
    "context": [
      {
        "key": "report",
        "reference": 
          {
            "reference": "DiagnosticReport/2402d3bd-e988-414b-b7f2-4322e86c9327"
          }
      },
      {
        "key": "patient",
        "reference": { 
          "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
        }
      },
      {
        "key": "select",
        "reference": {
          "reference": "Observation/40afe766-3628-4ded-b5bd-925727c013b3"
        },
      }  
      {
        "key": "select",
        "reference": {
          "reference": "Observation/e25ce4c2-95c1-4078-8ef5-84aab1a69036"
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
| 1.0 | Updated for STU3
