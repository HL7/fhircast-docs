# userlogout

eventMaturity | [1 - Submitted](../../specification/STU1/#event-maturity-model)

## Workflow

User's session has ended, perhaps by exiting the application through a logout, session time-out or other reason.

Unlike most of FHIRcast events, `userlogout` is a statically named event and therefore does not follow the `FHIR-resource`-`[open|close]` syntax.

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
	  "hub.event": "userLogout", 
	  "context": [] 
  }
}
```

</mark>

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
