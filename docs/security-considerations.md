# Security Considerations

FHIRcast enables the synchronization of healthcare applications user interfaces in real-time through the exchange of a workflow event to a small number of disparate applications. The notification message which describes the workflow event is a simple json wrapper around one or more FHIR resources. These FHIR resources can contain Protected Health Information (PHI). 

## Actors 

* Subscribing app
* Hub
* Authorization Server
* Resource server

FHIRcast ties SMART as the authnz layer together with WebSub for subscription and event notification.

## Sources of Risk
1. The FHIRcast Hub pushes PHI to a dynamic url specified by the authenticated app. 
1. An app's credentials or a Hub's lack of authentication could be used by a malicious system to control the user's session.
1. FHIRcast recommends the use of SMART on FHIR, but does not require it. Implementation-specific launch, authentication, and authorization protocols may be possible. These alternate protocols should be scrutinized by implementers for additional security risks.


## SMART on FHIR
[SMART on FHIR](http://www.hl7.org/fhir/smart-app-launch/) profiles [OAuth 2.0's authorization code grant type](https://tools.ietf.org/html/rfc6749#section-1.3.1) and extends it by introducing an "[EHR Launch Sequence](http://www.hl7.org/fhir/smart-app-launch/#ehr-launch-sequence)". The Argonaut Project performed a formal security review of SMART on FHIR, resulting in a [Risk Assessment report](http://argonautwiki.hl7.org/images/e/ed/%282015May26%29RiskAssessment_ReportV1.pdf).

FHIRcast builds on SMART by introducing a new [syntax for standard OAuth 2.0 scopes](/specification/STU1/#fhircast-authorization-smart-scopes), as well as two new SMART launch parameters of `hub.url` and `hub.topic`. 

* [HL7 SMART on FHIR specification](http://www.hl7.org/fhir/smart-app-launch/)
* [Argonaut Risk Assessment report](http://argonautwiki.hl7.org/images/e/ed/%282015May26%29RiskAssessment_ReportV1.pdf).
* [OAuth 2.0 Threat Model and Security Considerations](https://tools.ietf.org/html/rfc6819)

## HTTP Web Hooks using WebSub

[WebSub](https://www.w3.org/TR/websub/) is a W3C RFC designed for the distribution of web content through a standardized web hooks architecture. FHIRcast uses WebSub to allow clients to subscribe and unsubscribe to the Hub and, for the Hub to notify subscribers of events. 

Unlike WebSub, FHIRcast requires that both the Hub and the subscribing apps endpoints are exposed over https.

The below [flow diagram](https://drive.google.com/file/d/16pdG6Kw4pAG53J9d7_rK98DSvm_GMiCC/view?usp=sharing) illustrates each of the interactions. 

![FHIRcast flow diagram](/img/FHIRcast%20WebSub%20security%20sequence.png)


### How does the subscriber authenticate to the Hub?
The subscribing app can make three distinct API calls to the Hub. For each of these calls, the subscribing app authenticates to the Hub with the Hub's authorization server issued SMART `access_token`. Per SMART on FHIR, this `access_token` is presented to the Hub in the HTTP Authorization header.

1. App subscribes to Hub
1. App requests change to shared context
1. App unsubscribes from session

```
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
```

### How does the Hub validate the subscriber?
The Hub can make three distinct API calls to the subscribing app's `hub.callback` url. 

1. Hub verifies callback url with app
1. Hub notifies app of event
1. Hub denies subscription


This [flow diagram](https://drive.google.com/file/d/1sqh3Jghd2QGzq_EhRR-uv6axgIkVW1EE/view?usp=sharing) describes the actors and actions. 

![WebSub security flow](/img/WebSub%20security%20sequence%20flow.png)


The [subscribing app initiates](http://fhircast.org/#app-subscribes-to-session) the FHIRcast subscription, authenticating to the Hub with its bearer token, and providing the `hub.secret` and `hub.callback` url. The Hub verifies intent and ownership by performing an HTTP GET to the `hub.callback` url, with a `hub.challenge`. The subscribing app must echo the `hub.challenge` in the body of an HTTP 202 response. Once a workflow event occurs, the Hub notifies the app of the event by POSTing to the subscribing app's `hub.callback` url. The Hub provides an [HMAC signature](https://www.w3.org/TR/websub/#bib-RFC6151) of the previously provided `hub.secret` in the `X-Hub-Signature` HTTP header.

```
POST https://app.example.com/session/callback/v7tfwuk17a HTTP/1.1
Host: subscriber
X-Hub-Signature: sha256=dce85dc8dfde2426079063ad413268ac72dcf845f9f923193285e693be6ff3ae
```

The client that creates the subscription may not be the same system as the server hosting the callback url. (For example, some type of federated authorization model could possibly exist between these two systems.) However, in FHIRcast, the Hub assumes that the same authorization and access rights apply to both the subscribing client and the callback url.

### WebSub Security Considerations
The WebSub RFC defines [specific security considerations](https://www.w3.org/TR/websub/#security-considerations), including the below, which are listed here for emphasis or elevation from optional to mandatory.
* Subscribers must communicate with a Hub over https.
* Hub must reject unsecured http callback urls. 
* The subscribing app's `hub.callback` url should be unique and unguessable. 
* Subscribing apps must provide a `hub.secret` and validate the `X-Hub-Signature` in the notification message.
* Hubs must reject subscriptions if the callback url does not echo the `hub.challenge` as part of the intent verification GET.
* When computing the HMAC digest with the `hub.secret` for the `X-Hub-Signature` HTTP header, Hubs must use SHA-256 or greater and must not use SHA-1.
* For each subscription, the `hub.secret` must be unique, unguessable and securely stored by both the Hub and the app. 
* To prevent a subscriber from continuing to receive information after its authorization has ended, if using OAuth 2.0, the Hub must limit the subscription's `lease_seconds` to be less than or equal to the access token's expiration timestamp.


* [W3C WebSub RFC](https://www.w3.org/TR/websub/)
* [W3C WebSub RFC's Security Considerations](https://www.w3.org/TR/websub/#security-considerations)
* [HMAC RFC 6151](https://www.w3.org/TR/websub/#bib-RFC6151)


## Experimental Websockets support

In addition to the web hooks communication pattern, the FHIRcast community is experimenting with the use of websockets for event notification. Below are some incomplete considerations for a potential websockets implementation.

Subscribers SHOULD only use and Hub's SHOULD only accept connections made over the secure _wss://_ websocket protocol and not the unsecured _ws://_ websocket protocol.

The WebSockets standard defines an `Origin` header, sent from the client to the server and intended to contain the url of the client. Subscribers using websockets may be running in a browser, in which case the browser enforces origin reporting to the Hub, or native apps in which the origin reported to the Hub can not be trusted. Therefore, a Hub exposing a websocket connection MUST not rely upon the origin sent by the subscriber. 

While native app subscribers can send any standard HTTP headers, notably including _Authorization: Bearer_, browser-based subscribers are limited to only HTTP Basic Auth or cookies. Therefore, the typical use of the OAuth 2.0 access_token for bearer authentication does not consistently work with websockets. FHIRcast describes a "ticket"-based authentication system, in which the `hub.topic` provided to the subscriber as part of the secured SMART app launch serves not only as a unique session identifier, but also as an "authorization ticket". This authorization ticket effectively acts as a bearer token. The Hub should therefore take care to generate opaque and unique `hub.topic` values. 

* [The WebSocket Protocol RFC 6455](https://tools.ietf.org/html/rfc6455)
* [Heroku's excellent explanation of websocket security](https://devcenter.heroku.com/articles/websocket-security)
