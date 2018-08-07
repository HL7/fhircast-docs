# EHR authorizes app to synchronize

FHIRcast extends SMART on FHIR to support clinical context synchronization between disparate, full featured healthcare which cannot be embedded within one another. Two launch scenarios are supported. In all cases the app is authorized to synchronize to a user's session using the OAuth2.0 `fhircast` scope.

During the OAuth2.0 handshake, the app [requests and is granted](http://www.hl7.org/fhir/smart-app-launch/#2-ehr-evaluates-authorization-request-asking-for-end-user-input) the `fhircast` scope. The EHR's authorization server returns the hub url and any relevant session topics as SMART launch parameters. 

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

Two different launch scenarios are supported. For each launch scenario, the app discovers the session topic to which it [subscribes](/#app-subscribes-to-session).

## EHR Launch: User SSO's into app from EHR

The simplest launch scenario is the [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch/#ehr-launch-sequence), in which the app is launched from an authenticated EHR session. The app receives information about the user and session as part of the launch and subsequently subscribes to the launching user's session. 

In this scenario, the EHR authorizes the app to synchronize. The EHR provides one or more session topics as SMART launch parameters that belong to the EHR's current user. 

## Standalone launch: User authenticates to EHR to authorize synchronization

If the app can't be launched from the EHR, for example, it's opening on a different machine, it can use the standard [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence). 

In this scenario, the user authorizes the app to synchronize to her session by authenticating to the EHR's authorization server. The EHR provides one or more session topics as SMART launch parameters that belong to the authorizing user.
