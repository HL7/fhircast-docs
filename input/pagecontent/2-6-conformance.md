
## Conformance

The FHIRcast specification can be described as a set of capabilities and any specific FHIRcast Hub may implement a subset of these capabilities. A FHIRcast Hub declares support for FHIRcast and specific capabilities by exposing an extension on its FHIR server's CapabilityStatement as described below. 

### Declaring support for FHIRcast 

To support various architectures, including multiple decentralized FHIRcast hubs, the Hub exposes a .well-known endpoint containing additional information about the capabilities of that hub. A Hub's supported events, version and other capabilities can be exposed as a Well-Known Uniform Resource Identifiers (URIs) ([RFC5785](https://tools.ietf.org/html/rfc5785)) JSON document.

Hubs SHOULD serve a JSON document at the location formed by appending `/.well-known/fhircast-configuration` to their `hub.url`. Contrary to RFC5785 Appendix B.4, the .well-known path component may be appended even if the `hub.url` endpoint already contains a path component.

A simple JSON document is returned using the `application/json` mime type, with the following key/value pairs -- 

Field | Optionality | Type | Description
--- | --- | --- | ---
`eventsSupported` | Required | array | Array of FHIRcast events supported by the Hub.
`websocketSupport` | Required | boolean | The static value: `true`, indicating support for websockets.
`webhookSupport` | Optional | boolean | `true` or `false` indicating support for webhooks. Hubs SHOULD indicate their support for web hooks. 
`fhircastVersion` | Optional | string | `STU1` or `STU2` indicating support for a specific version of FHIRcast. Hubs SHOULD indicate the version of FHIRcast supported. 

#### Discovery Request Example

##### Base URL "www.hub.example.com/"

```
GET /.well-known/fhircast-configuration HTTP/1.1
Host: www.hub.example.com
```

#### Discovery Response Example  

```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "eventsSupported": ["patient-open", "patient-close", "syncerror", "com.example.researchstudy-transmogrify"],
  "websocketSupport": true,
  "webhookSupport": false,
  "fhircastVersion": "STU2"
}
```

#### FHIR Capability Statement 

To supplement or optionally identify the location of a FHIRcast hub, a FHIR server MAY declare support for FHIRcast using the FHIRcast extension on its FHIR CapabilityStatement's `rest` element. The FHIRcast extension has the following internal components:

Component | Cardinality | Type | Description
--- | --- | --- | ---
`hub.url`| 0..1 | url | The url at which an app subscribes. May not be supported by client-side Hubs.

### CapabilityStatement Extension Example 

```
{
  "resourceType": "CapabilityStatement",
...
  "rest": [{
   ...
        "extension": [
          {
            "url": "http://fhircast.hl7.org/StructureDefinition/fhircast-configuration",
            "extension": [
              {
                "url": "hub.url",
                "valueUri": "https://hub.example.com/fhircast/hub.v2"
              }
            ]
        ]      ...
```

