# EHR authorizes app to synchronize

FHIRcast extends SMART on FHIR to support clinical context synchronization between disparate, full featured healthcare which cannot be embedded within one another. Multiple launch scenarios are supported. In all cases the app is authorized to synchronize to a user's session using the OAuth2.0 `fhircast` scope.

During the OAuth2.0 handshake, the app [requests and is granted](http://www.hl7.org/fhir/smart-app-launch/#2-ehr-evaluates-authorization-request-asking-for-end-user-input) the `fhircast` scope. The EHR's authorization server returns  the hub url and any relevant session topics as SMART launch parameters. 

| SMART launch parameter | Optionality | Type | Description |
| --- | --- | --- | --- |
| `cast-hub` | Required | string | The base url of the EHR's hub. |
| `cast-session` | Optional | string or array | Zero, one or more session topic urls. The cast-session url is a unique, opaque identifier to the a user's session. |

The app requests the `fhircast` scope.

```
Location: https://ehr/authorize?
            response_type=code&
            client_id=app-client-id&
            redirect_uri=https%3A%2F%2Fapp%2Fafter-auth&
            launch=xyz123&
            scope=fhircast+launch+patient%2FObservation.read+patient%2FPatient.read+openid+profile&
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
  "cast-hub" : "https://hub.example.com",
  "cast-session": "https://hub.example.com/7jaa86kgdudewiaq0wtu"
}
```

The app then [subscribes](/#app-subscribes-to-session) to the identified session


Three different launch scenarios are supported. For each launch scenario, the app discovers the session topic to which it [subscribes](/#app-subscribes-to-session).

## EHR Launch: User SSO's into app from EHR

The simplest launch scenario is the [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch/#ehr-launch-sequence), in which the app is launched from an authenticated EHR session. The app receives information about the user and session as part of the launch and subsequently subscribes to the launching user's session. 

In this scenario, the EHR authorizes the app to synchronize. The EHR provides one or more session topics as SMART launch parameters that belong to the EHR's current user. 

## Standalone launch: User authenticates to EHR to authorize synchronization

If the app can't be launched from the EHR, for example, it's opening on a different machine, it can use the standard [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence). 

In this scenario, the user authorizes the app to synchronize to her session by authenticating to the EHR's authorization server. The EHR provides one or more session topics as SMART launch parameters that belong to the authorizing user.

## Backend: EHR trusts backend system

If the app is not launched from an authenticated EHR session *and* the app can't ask the user to authenticate to the EHR, it can use the standardized [SMART on FHIR Backend Services](https://github.com/smart-on-fhir/fhir-bulk-data-docs/blob/master/authorization.md) to authorize. 

This authorization mechanism enables the app to see potentially many users' sessions. The Hub and it's authorization server SHALL restrict the sessions available to the app.

## App learns about sessions

In the EHR or standalone launch scenarios, the current user is identified and there's likely only a single session topic provided to the app. In these cases, the app doesn't need to choose between sessions. In more complex scenarios the app needs to choose between multiple sessions, for example, the user has multiple, unsynchronized EHR sessions on different devices, the app wishes to synchronize to a session other than the current user's, or the app is using SMART Backend Services.

To support these more advanced scenarios, the app performs a RESTful query against the hub's session endpoint.

```
GET https://hub.example.com/session?user=?&workstation=? HTTP 1.1
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
```

The Hub responds with a list of sessions the app is authorized to synchronize to described in simple json, including the session's owning user, owning workstation, and perhaps even the current content of the session.

TODO
```
```
