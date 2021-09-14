# home-[open|close]

eventMaturity | [0 - Draft](../../specification/STU2/#event-maturity-model)

## Workflow

The user has opened or switched back to the application's home page or tab which does not have any FHIR related context.

Unlike most of FHIRcast events, `home-open` is representing the lack of a FHIR resource context and therefore does not fully follow the FHIR-resource-[open|close] syntax.

## Context

The context is empty.

### Examples

<mark>

```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "home-open",
    "context": []
  }
}
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
