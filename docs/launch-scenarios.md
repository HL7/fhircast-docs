
# App launch scenarios and session discovery

A FHIRcast Hub uses a unique `hub.topic` session id to identify a single session across the Hub, subscribing and driving applications which are engaged in the shared session. The `hub.topic` must be known by a system for it to participate in the session. Typically, the Hub defines the `hub.topic`.

The [HL7 SMART on FHIR app launch specification](http://www.hl7.org/fhir/smart-app-launch) enables the launched, synchronizing app to discover the `hub.topic`, because the SMART OAuth 2.0 server provides it during the OAuth 2.0 handshake as a SMART launch parameter. Use of SMART requires either that a synchronizing app supports the SMART on FHIR specification and specifically either be launched from the driving app or use the hub's authorization server's login page. 

Once the `hub.topic` and url to the hub (`hub.url`) are known by the synchronizing app, the subscription and workflow event notification process proceeds per the FHIRcast specification, regardless of the specific app launch used. 

The use of the SMART on FHIR OAuth 2.0 profile simplifies, secures and standardizes FHIRcast context synchronization. While more creative approaches, such as the alternate app launch and shared session identifier generation algorithm are possible to use with FHIRcast, care must be taken by the implementer to ensure synchronization and to protect against PHI loss, session hijacking and other security risks. Specifically, the `hub.topic` session identifier must be unique, unguessable, and specific to the session. 

## SMART on FHIR

FHIRcast extends SMART on FHIR to support clinical context synchronization between disparate, full featured healthcare applications which cannot be embedded within one another. Two launch scenarios are explicitly supported. The app is authorized to synchronize to a user's session using the OAuth2.0 [FHIRcast scopes](../specification/STU1/#fhircast-authorization-smart-scopes).

During the OAuth2.0 handshake, the app [requests and is granted](http://www.hl7.org/fhir/smart-app-launch/#2-ehr-evaluates-authorization-request-asking-for-end-user-input) one or more FHIRcast scopes. The EHR's authorization server returns the hub url and any relevant session topics as SMART launch parameters. 

| SMART launch parameter | Optionality | Type | Description |
| --- | --- | --- | --- |
| `hub.url` | Required | string | The base url of the EHR's hub. |
| `hub.topic` | Optional | string | The session topic identifiers. The `hub.topic` is a unique, opaque identifier to the a user's session, typically expressed as a hub-generated guid. |

The app requests one or more FHIRcast scopes, depending upon its needs to learn about specific workflow events or to direct the workflow itself.

```
Location: https://ehr/authorize?
            response_type=code&
            client_id=app-client-id&
            redirect_uri=https%3A%2F%2Fapp%2Fafter-auth&
            launch=xyz123&
            scope=fhircast%2FImagingStudy-open.read+launch+patient%2FObservation.read+patient%2FPatient.read+openid+profile&
            state=98wrghuwuogerg97&
            aud=https://ehr/fhir
```

Following the OAuth2.0 handshake, the authorization server returns the FHIRcast SMART launch parameters alongside the access_token.

```json
{
  "access_token": "i8hweunweunweofiwweoijewiwe",
  "token_type": "bearer",
  "expires_in": 3600,
  "scope": "patient/Observation.read patient/Patient.read",
  "state": "98wrghuwuogerg97",
  "intent": "client-ui-name",
  "patient":  "123",
  "encounter": "456",
  "hub.url" : "https://hub.example.com",
  "hub.topic": "2e5e1b95-5c7f-4884-b19a-0b058699318b"
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065"
}
```

The app then [subscribes](/#app-subscribes-to-session) to the identified session

Two different launch scenarios are supported. For each launch scenario, the app discovers the session topic to which it [subscribes](/#app-subscribes-to-session).


### EHR Launch: User SSO's into app from EHR

The simplest launch scenario is the [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch/#ehr-launch-sequence), in which the subscribing app is launched from an EHR authenticated session. The app requests both the `launch` and desired FHIRcast scopes (for example, `fhircast/ImagingStudy-open.read`) and  receives information about the user and session as part of the launch. The app subsequently subscribes to the launching user's session. 

In this scenario, the EHR authorizes the app to synchronize. The EHR provides a session topic as a SMART launch parameter which belongs to the EHR's current user. 

### Standalone launch: User authenticates to EHR to authorize synchronization

If the app can't be launched from the EHR, for example, it's opening on a different machine, it can use the standard [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence). 

In this scenario, the user authorizes the app to synchronize to her session by authenticating to the EHR's authorization server. The app requests desired FHIRcast scopes and the EHR provides a session topic as a SMART launch parameter which belongs to the EHR's authorizing user. 

## Alternate app launch

In practice, even enterprise apps are often launched from within a clinician's workflow through a variety of bespoke web and desktop technologies. For example, an EHR might launch a desktop app on the same machine by specifying the executable on the Windows shell and passing contextual information as command line switches to the executable. Similarly, bespoke Microsoft COM APIs, shared polling of designated filesystem directories or web service ticketing APIs are also commonly used in production environments.  The use of OAuth 2.0 strengthens and standardizes the security and interoperability of integrations. In the absence of OAuth 2.0 support, these alternate app launch mechanisms can also be used to share a session topic and therefore initiate a shared FHIRcast session. 

A fictitious example Windows shell integration invokes a PACS system at system startup by passing some credentials, user identity and the FHIRcast session identifier (`hub.topic`) and hub base url (`hub.url`).

```
C:\Windows\System32\PACS.exe /credentials:<secured credentials> /user:jsmith /hub.url:https://hub.example.com /hub.topic:2e5e1b95-5c7f-4884-b19a-0b058699318b
```

An additional example is a simple (and relatively insecure) web application launch extended with the addition of `hub.url` and `hub.topic` query parameters.
```
GET https://app.example.com/launch.html?user=jsmith&hub.url=https%3A%2F%2Fhub.example.com&hub.topic=2e5e1b95-5c7f-4884-b19a-0b058699318b
```

Similarly, any bespoke app launch mechanism can establish a FHIRcast session by adding the `hub.url` and `hub.topic` parameters into the existing contextual information shared during the launch.  Once launched, the app subscribes to the session and receives notifications following the standardized FHIRcast interactions. 

## No app launch

In a scenario in which the user manually starts two or more applications, the applications do not have the capability to establish a shared session topic. Since there's no "app launch", with its corresponding ability to exchange contextual information, the unique, unguessable, and session-specific `hub.topic` must be calculated by both the driving application's hub and the subscribing application. The synchronizing application could use a shared algorithm and secret to generate the `hub.topic`. 

A bespoke session topic generation algorithm could encrypt the current user's username and a nonce with a shared secret to a pre-configured base url. In this contrived example, a base url and secret are securely configured on the subscribing app. The subscribing app generates and appends a nonce to the current user's Active Directory username, encrypts that string with the shared secret according to an agreed upon encryption algorithm, and finally appends that encrypted string to the base url. The resulting url is unique to the current user and unguessable to a middle man due to the shared secret.

```
https://hub.example/com/AES256(username+nonce, shared secret)
```
