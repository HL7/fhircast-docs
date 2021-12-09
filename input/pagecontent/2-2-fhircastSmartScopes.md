### FHIRcast Authorization & SMART scopes

FHIRcast defines OAuth 2.0 access scopes that correspond directly to [FHIRcast events](#events). Our scopes associate read or write permissions to an event. Apps that need to receive workflow related events SHOULD ask for `read` scopes. Apps that request context changes SHOULD ask for `write` scopes. Hubs may decide what specific interactions and operations will be enabled by these scopes.

Expressed in [Extended Backus-Naur Form](https://www.iso.org/obp/ui/#iso:std:iso-iec:14977:ed-1:v1:en) (EBNF) notation, the FHIRcast syntax for OAuth 2.0 access scopes is:

`scope ::= ( 'fhircast' ) '/' ( FHIRcast-event | '*' ) '.' ( 'read' | 'write' | '*' )`

{% include img.html img="fhircast-smart-scopes.png" caption="Figure: Syntax for FHIRcast scopes" %}

For example, a requested scope of `fhircast/patient-open.read` would authorize the subscribing application to receive a notification when the patient in context changed. Similarly, a scope of  `fhircast/patient-open.write` authorizes the subscribed app to [request a context change](#request-context-change).

#### SMART Launch Example

 An example of the launch parameters presented to the app during a SMART on FHIR launch is presented below. 

```
{
  "access_token": "i8hweunweunweofiwweoijewiwe",
  "token_type": "bearer",
  "patient":  "123",
  "expires_in": 3600,
  "encounter": "456",
  "imagingstudy": "789",
  "hub.url" : "https://hub.example.com",
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
}
```

Note that the SMART launch parameters include the Hub's base URL and the session identifier in the `hub.url` and `hub.topic` fields.

