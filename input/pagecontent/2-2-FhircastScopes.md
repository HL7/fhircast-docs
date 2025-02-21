FHIRcast defines OAuth 2.0 access scopes that correspond directly to [FHIRcast events](3_Events.html). These scopes associate read or write permissions to an event. Applications that need to receive workflow related events SHOULD ask for `read` scopes. Applications that request context changes SHOULD ask for `write` scopes.

Expressed in [Extended Backus-Naur Form](https://www.iso.org/obp/ui/#iso:std:iso-iec:14977:ed-1:v1:en) (EBNF) notation, the FHIRcast syntax for OAuth 2.0 access scopes is:

```ebnf
FhircastScopes ::= fhircast  '/' ( FHIRcast-event-name | '*' ) '.' ( 'read' | 'write' | '*' )
```

{% include img.html img="FhircastScopes.png" caption="Figure: Syntax for FHIRcast scopes" %}

Note the [FHIRcast event format](2-3-Events.html#event-name) contains a noun-verb, for example: `Patient-open`. So, a requested scope of `fhircast/Patient-open.read` would authorize the subscribing application to receive a notification when the patient in context changed. Similarly, a scope of  `fhircast/Patient-open.write` authorizes the subscribing application to [request a context change](2-5-ReceiveEventNotification.html).
