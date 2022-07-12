This chapter consists of the following sections:

[2.1 Session Discovery](2-1-SessionDiscovery.html) |
[2.2 FHIRcast scopes](2-2-FhircastScopes.html) |
[2.3 Event format](2-3-Events.html) |
[2.4 Subscribing to events](2-4-Subscribing.html) |
[2.5 Event notification](2-5-EventNotification.html) |
[2.6 Request context change](2-6-RequestContextChange.html) |
[2.7 Conformance](2-7-Conformance.html) |
[2.8 Extensions](2-8-Extensions.html) |
[2.9 Get Current Context](2-9-GetCurrentContext.html) |
[2.10 Get Current Context](2-10-GetCurrentContext.html) |

The FHIRcast specification describes the APIs used to synchronize disparate healthcare applications' user interfaces in real time,  allowing them to show the same clinical content to a user (or group of users).

Once the subscribing app [knows about](2-1-SessionDiscovery.html) the session, the app [subscribes](2-4-Subscribing.html) to specific workflow-related [events](2-3-Events.html) for the given session. The app is then [notified](2-5-EventNotification.html) when those workflow-related events occur; for example, when the clinician opens a patient's chart. The subscribing app can also [initiate context changes](2-6-RequestContextChange.html) by accessing APIs defined in this specification; for example, closing the patient's chart. The app [unsubscribes from its subscription](2-4-Subscribing.html#unsubscribe) to no longer receive notifications. The notification messages describing the workflow event are defined as a simple JSON wrapper around one or more FHIR resources.

FHIRcast recommends the [HL7 SMART on FHIR launch protocol](http://www.hl7.org/fhir/smart-app-launch) for both session discovery and API authentication. FHIRcast enables a subscriber to receive notifications either through a webhook or over a WebSocket connection. This protocol is modeled on the [W3C WebSub RFC](https://www.w3.org/TR/websub/), such as its use of GET vs POST interactions and a Hub for managing subscriptions. The Hub exposes APIs for subscribing and unsubscribing, requesting context changes, and distributing event notifications. The flow diagram presented below illustrates the series of interactions specified by FHIRcast, their origination and their outcome.

{% include img.html img="FHIRcast overview for abstract.png" caption="Figure: FHIRcast overview" %}

All data exchanged through the HTTP APIs SHALL be formatted, sent and received as [JSON](https://tools.ietf.org/html/rfc8259) structures, and SHALL be transmitted over channels secured using the Hypertext Transfer Protocol (HTTP) over Transport Layer Security (TLS), also known as HTTPS which is defined in [RFC2818](https://tools.ietf.org/html/rfc2818).

All data exchanged through WebSockets SHALL be formatted, sent and received as [JSON](https://tools.ietf.org/html/rfc8259) structures, and SHALL be transmitted over Secure Web Sockets (WSS) as defined in [RFC6455](https://tools.ietf.org/html/rfc6455).
