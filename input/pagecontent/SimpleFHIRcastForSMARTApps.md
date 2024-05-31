# Simple FHIRcast for SMART apps

The FHIRcast implementation guide specifies advanced, pioneering capabilities as well as detailed rules for FHIRcast Hubs and rare, but complex edge cases. These details are irrelevant to most implementers who will simply be developing the capabilty to subscribe to a FHIRcast Hub for context synchronization events into their pre-existing SMART on FHIR app which runs on the same machine as the EHR and Hub and which supports a single user at a time. This limited specification is for that implementer!

## Session Discovery 

Systems SHALL use SMART on FHIR to authorize, authenticate, and exchange initial shared context. 
As part of either a SMART on FHIR EHR launch or SMART on FHIR standalone launch, the application SHALL request the following FHIRcast OAuth 2.0 scopes: `fhircast/Patient-open.read`, `fhircast/Patient-close.read`, 
and SHOULD request `fhircast/Encounter-open.read`, `fhircast/Encounter-close.read`. If the user's workflow enables the user to change context from within the app, the app SHALL also request: `fhircast/Patient-open.write`, `fhircast/Patient-close.write`, and SHOULD request `fhircast/Encounter-open.write`, `fhircast/Encounter-close.write`.

Alongside the access token, the authorization server provides a `patient`, `encounter`, `hub.url`, and `hub.topic` SMART launch parameters, like so:

```
{
	"access_token": "Nxfve4q3H9TKs5F5vf6kRYAZqzK7j9LHvrg1Bw7fU_07_FdV9aRzLCI1GxOn20LuO2Ahl5RkRnz-p8u1MeYWqA85T8s4Ce3LcgQqIwsTkI7wezBsMduPw_xkVtLzLU2O",
	"token_type": "bearer",
	"expires_in": 3240,
	"scope": "openid user/Patient.read user/Encounter.read fhircast/Patient-open.read fhircast/Encounter-open.read fhircast/Patient-close.read fhircast/Encounter-close.read fhircast/Patient-open.write fhircast/Encounter-open.write fhircast/Patient-close.write fhircast/Encounter-close.write"
	"id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IktleUlEIiwidHlwIjoiSldUIn0.eyJhdWQiOiJDbGllbnRJRCIsImV4cCI6RXhwaXJlc0F0LCJpYXQiOklzc3VlZEF0LCJpc3MiOiJJc3N1ZXJVUkwiLCJzdWIiOiJFbmRVc2VySWRlbnRpZmllciJ9",
	"patient": "T1wI5bk8n1YVgvWk9D05BmRV0Pi3ECImNSK8DKyKltsMB",
	"encounter": "eySnzekbpf6uGZz87ndPuRQ3",
	"hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
	"hub.url": "https://hub.example.com/"
}
```

##  ?SHALL query discovery endpoint?

## Subscribing

The app SHALL subscribe to the session identified by the `hub.topic` by issuing an HTTP POST to the `hub.url`, like so -- 

```
POST https://hub.example.com HTTP/1.1
Host: hub.example.com
Authorization: Bearer Nxfve4q3H9TKs5F5vf6kRYAZqzK7j9LHvrg1Bw7fU_07_FdV9aRzLCI1GxOn20LuO2Ahl5RkRnz-p8u1MeYWqA85T8s4Ce3LcgQqIwsTkI7wezBsMduPw_xkVtLzLU2O
Content-Type: application/x-www-form-urlencoded

hub.channel.type=websocket&hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.events=Patient-open,Patient-close,Encounter-open
```



		○ SHOULD receive encounter-open/close, MAY send
		○ SHALL support websocket connection to Hub on localhost, 
Consider Hub SHALL support subscribing on not just localhost