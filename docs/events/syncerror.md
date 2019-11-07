# syncerror

eventMaturity | [2 - Tested](../../specification/STU1/#event-maturity-model)

## Workflow

A synchronization error has been detected. Inform subscribed clients. 

Unlike most of FHIRcast events, `syncerror` is an infrastructural event and does not follow the `FHIR-resource`-`[open|close]` syntax and is directly referenced in the [underlying specification](../../specification/STU1/#event-notification-errors).

## Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`operationoutcome` | OPTIONAL | `OperationOutcome` | FHIR resource describing an outcome of an unsuccessful system action.


### Examples

<mark>
```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "syncerror",
    "context": [
      {
        "key": "operationoutcome",
        "resource": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "warning",
              "code": "processing",
              "diagnostics": "AppId3456 failed to follow context"
            }
          ]
        }
      }
    ]
  }
}
```


</mark>

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
