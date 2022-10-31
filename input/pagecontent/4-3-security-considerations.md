<img src="Info_Simple_bw.svg.png" width="50" height="50"> 
This page contains guidance to implementers and is not part of the [normative-track](2_Specification.html). 
<p></p><p></p>

FHIRcast enables the synchronization of healthcare applications user interfaces in real-time through the exchange of a workflow event to a small number of disparate applications. The notification message which describes the workflow event is a simple json wrapper around one or more FHIR resources. These FHIR resources can contain Protected Health Information (PHI).

### Actors

* Subscribing app
* Hub
* Authorization Server
* Resource server

FHIRcast ties SMART as the authorization layer together with a web-sub mechanism for subscription and event notification.

### Sources of Risk

1. The FHIRcast Hub pushes PHI to a dynamic URL specified by the authenticated app.
1. An app's credentials or a Hub's lack of authentication could be used by a malicious system to control the user's session.
1. FHIRcast recommends the use of SMART on FHIR, but does not require it. Implementation-specific launch, authentication, and authorization protocols may be possible. These alternate protocols should be scrutinized by implementers for additional security risks.

### SMART on FHIR

[SMART on FHIR](http://www.hl7.org/fhir/smart-app-launch/) profiles [OAuth 2.0's authorization code grant type](https://tools.ietf.org/html/rfc6749#section-1.3.1) and extends it by introducing an "[EHR Launch Sequence](http://www.hl7.org/fhir/smart-app-launch/#ehr-launch-sequence)". The Argonaut Project performed a formal security review of SMART on FHIR, resulting in a [Risk Assessment report](http://argonautwiki.hl7.org/images/e/ed/%282015May26%29RiskAssessment_ReportV1.pdf).

FHIRcast builds on SMART by introducing a new [syntax for standard OAuth 2.0 scopes](2-2-FhircastScopes.html), as well as two new SMART launch parameters of `hub.url` and `hub.topic`.

* [HL7 SMART on FHIR specification](http://www.hl7.org/fhir/smart-app-launch/)
* [Argonaut Risk Assessment report](http://argonautwiki.hl7.org/images/e/ed/%282015May26%29RiskAssessment_ReportV1.pdf).
* [OAuth 2.0 Threat Model and Security Considerations](https://tools.ietf.org/html/rfc6819)

### Websockets Security Considerations

Below are the considerations for a websockets implementation.

Subscribers SHOULD only use and Hub's SHOULD only accept connections made over the secure _wss://_ websocket protocol and not the unsecured _ws://_ websocket protocol.

The WebSockets standard defines an `Origin` header, sent from the client to the server and intended to contain the url of the client. Subscribers using websockets may be running in a browser, in which case the browser enforces origin reporting to the Hub, or native apps in which the origin reported to the Hub can not be trusted. Therefore, a Hub exposing a websocket connection MUST not rely upon the origin sent by the subscriber.

While native app subscribers can send any standard HTTP headers, notably including _Authorization: Bearer_, browser-based subscribers are limited to only HTTP Basic Auth or cookies. Therefore, the typical use of the OAuth 2.0 access_token for bearer authentication does not consistently work with websockets. FHIRcast describes a "ticket"-based authentication system, in which the `hub.topic` provided to the subscriber as part of the secured SMART app launch serves not only as a unique session identifier, but also as an "authorization ticket". This authorization ticket effectively acts as a bearer token. The Hub should therefore take care to generate opaque and unique `hub.topic` values.

* [The WebSocket Protocol RFC 6455](https://tools.ietf.org/html/rfc6455)
* [Heroku's excellent explanation of websocket security](https://devcenter.heroku.com/articles/websocket-security)

Unauthorized access to Websockets is also addressed by providing a Subscriber unique unguessable websocket endpoint with a limited lifetime.
