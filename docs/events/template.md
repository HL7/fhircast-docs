# <mark>[FHIR resource]-[open|close]</mark>

eventMaturity | [0 - Draft](../../specification/STU1/#event-maturity-model)

## Workflow

<mark>Describe when this event occurs in a workflow. Describe how the context fields relate to one another. Event creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementors.</mark>

## Context

<mark>Define context values that are provided when this event occurs, and indicate whether they must be provided, and the FHIR query used to generate the resource. </mark>

Key | Optionality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
<mark>`example`</mark> | REQUIRED | `FHIRresource/{id}?_elements=identifer` | <mark>Describe the context value</mark>
<mark>`encounter`</mark> | OPTIONAL | `Encounter/{id}` | <mark>Describe the context value</mark>

### Examples

<mark>
```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "patient-open",
    "context": [
    {
      "key": "key-from-above",
      "resource": {
        "resourceType": "resource-type-from-above"
    },
    {
      "key": "encounter",
      "resource": {
        "resourceType": "Encounter"
      } 
    }
  }]
  }
}
```
</mark>

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
