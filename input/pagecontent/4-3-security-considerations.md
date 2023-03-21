{% include infonote.html text='This page contains guidance to implementers and is not part of the <a href="2_Specification.html">normative-track.</a>' %}


FHIRcast enables the synchronization of healthcare applications user interfaces in real-time through the exchange of a workflow event to a small number of disparate applications. The notification message which describes the workflow event is a simple json wrapper around one or more FHIR resources. These FHIR resources can contain Protected Health Information (PHI).

### Actors

* Subscribing application
* Hub
* Authorization Server
* Resource server

FHIRcast ties SMART as the authorization layer together with a WebSub mechanism for subscription and event notification.

### Sources of Risk

1. The FHIRcast Hub pushes PHI to a dynamic URL specified by the authenticated application.
1. An application's credentials or a Hub's lack of authentication could be used by a malicious system to control the user's session.
1. FHIRcast recommends the use of SMART on FHIR, but does not require it. Implementation-specific launch, authentication, and authorization protocols may be possible. These alternate protocols should be scrutinized by implementers for additional security risks.

### SMART on FHIR

[SMART on FHIR](http://www.hl7.org/fhir/smart-app-launch/) profiles [OAuth 2.0's authorization code grant type](https://tools.ietf.org/html/rfc6749#section-1.3.1) and extends it by introducing an "[EHR Launch Sequence](http://www.hl7.org/fhir/smart-app-launch/#ehr-launch-sequence)". The Argonaut Project performed a formal security review of SMART on FHIR, resulting in a [Risk Assessment report](http://argonautwiki.hl7.org/images/e/ed/%282015May26%29RiskAssessment_ReportV1.pdf).

FHIRcast builds on SMART by introducing a new [syntax for standard OAuth 2.0 scopes](2-2-FhircastScopes.html), as well as two new SMART launch parameters of `hub.url` and `hub.topic`.

* [HL7 SMART on FHIR specification](http://www.hl7.org/fhir/smart-app-launch/)
* [Argonaut Risk Assessment report](http://argonautwiki.hl7.org/images/e/ed/%282015May26%29RiskAssessment_ReportV1.pdf).
* [OAuth 2.0 Threat Model and Security Considerations](https://tools.ietf.org/html/rfc6819)

### Access to non-authorized content

Access to non-authorized content is a critical issue in healthcare data exchange, as it can lead to privacy breaches and unauthorized use of sensitive information. In the FHIRcast event-based communication model, various types of content can be shared among applications that are connected to a session, such as updates to the current context, selected resources, and exchanged resources.

To ensure that only authorized applications can access and share content, the FHIRcast specification includes a mechanism for checking authorization when a Subscriber subscribes to a session. This mechanism ensures that each application can only receive events related to resources that it is authorized to access. The responsibility of providing a valid set of authorizations lies with the authorization server, which should allow an application that can receive Encounter resources to also access the Patient resource of the encounter.

As all applications subscribed to a FHIRcast session are typically controlled by the same user, they can only access content that the user is authorized to access. This makes it challenging to share content that the user is not allowed to access. However, these applications can create new content, even for resource types that the user cannot retrieve from the FHIR store. Such behavior is acceptable within the context of FHIRcast.

Therefore, FHIRcast hubs do not need to enforce access restrictions on FHIR resources included in events.

### WebSocket Security Considerations

It is recommended that Subscribers use and Hubs should only accept connections made over the secure _wss://_ WebSocket protocol and not the unsecured _ws://_ WebSocket protocol.

The WebSocket standard defines an `Origin` header, sent from the client to the server and intended to contain the url of the client. Subscribers using WebSockets may be running in a Web browser, in which case the Web browser enforces origin reporting to the Hub, or native applications in which the origin reported to the Hub can not be trusted. Therefore, a Hub exposing a WebSocket connection may not rely upon the origin sent by the Subscriber.

While native application Subscribers can send any standard HTTP headers, notably including _Authorization: Bearer_, Web browser-based subscribers are limited to only HTTP Basic Auth or cookies. Therefore, the typical use of the OAuth 2.0 access_token for bearer authentication does not consistently work with WebSockets. FHIRcast describes a "ticket"-based authentication system, in which the `hub.topic` provided to the Subscriber as part of the secured SMART app launch serves not only as a unique session identifier, but also as an "authorization ticket". This authorization ticket effectively acts as a bearer token. The Hub should therefore take care to generate opaque and unique `hub.topic` values.

* [The WebSocket Protocol RFC 6455](https://tools.ietf.org/html/rfc6455)
* [Heroku's excellent explanation of WebSocket security](https://devcenter.heroku.com/articles/websocket-security)

Unauthorized access to Websockets is also addressed by providing a Subscriber unique unguessable WebSocket endpoint with a limited lifetime.
