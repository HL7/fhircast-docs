# home-[open|close]

eventMaturity | [0 - Draft](../../specification/STU2/#event-maturity-model)

## Workflow

For multi-tab applications, this event occurs when the user switches to a context-less activity. 

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
    "hub.event": "userHibernate",
    "context": []
  }
}
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
