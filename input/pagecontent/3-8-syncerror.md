### Event-name: syncerror

eventMaturity | [2 - Tested](3-0-EventMaturityModel.html)

### Workflow

A synchronization error has been detected. Inform subscribed clients. 

Unlike most of FHIRcast events, `syncerror` is an infrastructural event and does not follow the `FHIR-resource`-`[open|close]` syntax and is directly referenced in the [underlying specification](2_Specification.html).

### Context

An array containing a single FHIR OperationOutcome. The OperationOutcome SHALL use a code of `processing`. The OperationOutcome's details SHALL contain the id of the event that this error is related to as a `code` with the `system` value of `https://fhircast.hl7.org/events/syncerror/eventid` and the name of the relevant event with a `system` value of `https://fhircast.hl7.org/events/syncerror/eventname`. Other `coding` values can be included with different `system` values so as to include extra information about the `syncerror`. The OperationOutcome's `diagnostics` element should contain additional information to aid subsequent investigation or presentation to the end-user.

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`operationoutcome` | OPTIONAL | `OperationOutcome` | FHIR resource describing an outcome of an unsuccessful system action.

The OperationOutcome SHALL use a code of `processing`.  
The OperationOutcome's `issue[0].details.coding.code` SHALL contain the id of the event that this error is related to as a `code` with the `system` value of "https://fhircast.hl7.org/events/syncerror/eventid".  
The OperationOutcome's `issue[0].details.coding.code` SHALL contain the name of the relevant event with a `system` value of "https://fhircast.hl7.org/events/syncerror/eventname".  
The OperationOutcome's `issue[0].details.coding.code` SHALL contain the name of the relevant subscriber `system` value of "https://fhircast.hl7.org/events/syncerror/subscriber".  
Other `coding` values can be included with different `system` values so as to include extra information about the `syncerror`.
The `diagnostics` field SHALL contain a human readable explanation on the source and reason for the error.

### OperationOutcome profile

The profile of the OperationOutcome resource expressed in FHIR shorthand.

```text

Profile:     SyncErrorOperationOutcome
Parent:      OperationOutcome
Id:          sync-error-operationoutcome
Description: The OperationOutcome included in a syncerror event.
* issue[0].severity.code = #error
* issue[0].code = #processing
* issue[0].diagnostics MS
* issue[0].diagnostics 1..1
* issue[0].details.coding ^slicing.discriminator.type = #value
* issue[0].details.coding ^slicing.discriminator.path = "system"
* issue[0].details.coding ^slicing.discriminator.description = "Reason and source of syncerror."
* issue[0].details.coding 
        contains eventid 1..1 MS and 
                 eventname 1..1 MS
* issue[0].details.coding[eventid].system = https://fhircast.hl7.org/events/syncerror/eventid
* issue[0].details.coding[eventname].system = https://fhircast.hl7.org/events/syncerror/eventname

```

### Examples

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "7544fe65-ea26-44b5-835d-14287e46390b",
    "hub.event": "syncerror",
    "context": [
      {
        "key": "operationoutcome",
        "resource": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "error",
              "code": "processing",
              "diagnostics": "AppId3456 failed to follow context",
              "details": {
                "coding": [
                  {
                    "system": "https://fhircast.hl7.org/events/syncerror/eventid",
                    "code": "fdb2f928-5546-4f52-87a0-0648e9ded065"
                  },
                  {
                    "system": "https://fhircast.hl7.org/events/syncerror/eventname",
                    "code": "patient-open"
                  },
                  {
                    "system": "http://example.com/events/syncerror/your-error-code-system",
                    "code": "FHIRcast sync error"
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

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
2.0 | Require id of event syncerror is about, in `OperationOutcome.details.coding.code`
