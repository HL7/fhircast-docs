This section presents the template to use for defining new events. 

### Event-name: [FHIR resource]-[suffix]

eventMaturity | [0 - Draft](3-1-2-eventmaturitymodel.html)

### Workflow

Describe when this event occurs in a workflow. Describe how the context fields relate to one another. Event creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementors.

### Context

Define context values that are provided when this event occurs, and indicate whether they must be provided, and the FHIR query used to generate the resource.

{:.grid}
Key | Optionality | Description
----- |  ---- | ---- 
`example` | REQUIRED | Describe the context value
`FHIRresource` | OPTIONAL | Describe the context value

### Examples

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Patient-open",
    "context": [
      {
        "key": "key-from-above",
        "resource": {
          "resourceType": "resource-type-from-above"
        }
      },
      {
        "key": "encounter",
        "resource": {
          "resourceType": "Encounter"
        } 
      }
    ]
  }
}
```

## Change Log

Changes made to an event's definition SHALL be documented in a change log to ensure event consumers can track what has been changed over the life of an event. The change log SHALL contain the following elements:

- Version: The version of the change
- Description: A description of the change and its impact

For example:

{:.grid}
Version | Description
------- | ----
1.1     | Added new context FHIR object
1.0.1   | Clarified workflow description
1.0     | Initial Release
