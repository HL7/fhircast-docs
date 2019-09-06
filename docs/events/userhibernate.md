# userhibernate

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| eventVersion | 1.0
| eventMaturity | [1 - Submitted](../../specification/1.0/#event-maturity-model)

## Workflow

User temporarily suspended her session. The user's session will eventually resume.
 
Unlike most of FHIRcast events, `userhibernate` is a statically named event and therefore does not follow the `FHIR-resource`-`[open|close]` syntax.

## Context

The context is empty.

### Examples

<mark>
```json
{
}
```
</mark>

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
