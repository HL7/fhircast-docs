The FHIRcast specification can be described as a set of capabilities and any specific FHIRcast Hub may implement a subset of these capabilities. A FHIRcast Hub declares support for FHIRcast and specific capabilities by exposing an extension on the FHIR CapabilityStatement resource as described below. 


### Wellknown Endpoint

To support various architectures, including multiple decentralized FHIRcast hubs, the Hub exposes a `.well-known` endpoint containing additional information about the capabilities of that Hub. A Hub's supported events, version, and other capabilities can be exposed as a Well-Known Uniform Resource Identifiers (URIs) ([RFC5785](https://tools.ietf.org/html/rfc5785)) JSON document.

Hubs SHALL serve a JSON document at the location formed by appending `/.well-known/fhircast-configuration` to their `hub.url`. Contrary to RFC5785 Appendix B.4, the `.well-known` path component may be appended even if the `hub.url` endpoint already contains a path component.

A simple JSON document is returned using the `application/json` mime type, with the following key/value pairs:

{:.grid}
Field              | Optionality | Type  | Description
------------------ | ----------- | ----- | ---
`eventsSupported`  | Required    | array | Array of FHIRcast events supported by the Hub.
`websocketSupport` | Required    | boolean | SHALL have the static value: `true` - indicating support for websockets. FYI to Implementers: Given that websocket support is the only defined communication method in FHIRcast versions STU3 and was required in STU2, it's likely that this element will become Optional and then Deprecated in the future.
`fhircastVersion`  | Optional | string | `1.0.0`, `2.0.0`, or `3.0.0` - indicating support for a specific version of FHIRcast. Hubs SHOULD indicate the version of FHIRcast supported.
`getCurrentSupport` | Optional | boolean | `true` or `false` - indicating support for the "[Get Current Context](2-9-GetCurrentContext.html)" API.
`fhirVersion`  | Optional | string | `DSTU1`, `DSTU2`, `STU3`, `R4`, `R4B`, or `R5` - indicating the specific version of FHIR for this Hub.

A field of `webhookSupport` SHALL be ignored.

#### Wellknown endpoint discovery example

In this example the Hub URL is "www.hub.example.com/".

##### Wellknown endpoint discovery Request

```text
GET /.well-known/fhircast-configuration HTTP/1.1
Host: www.hub.example.com
```

#### Wellknown endpoint discovery Response

```text
HTTP/1.1 200 OK
Content-Type: application/json

{
  "eventsSupported": ["Patient-open", "Patient-close", "SyncError", "com.example.researchstudy-transmogrify"],
  "websocketSupport": true,
  "fhircastVersion": {
    "resourceType": "ValueSet",
    "id": "fhircast-version",
    "url": "http://hl7.org/fhir/ValueSet/fhircast-version",
    "version": "3.0.0",
    "name": "FHIRcastVersion",
    "title": "FHIRcast Version",
    "status": "active",
    "compose": {
      "include": [
        {
          "system": "http://hl7.org/fhir/fhircast-version",
          "concept": [
            {
              "code": "STU3",
              "display": "STU3"
            }
          ]
        }
      ]
    }
  }
}
```

### FHIR Capability Statement

To supplement or optionally identify the location of a FHIRcast hub, a FHIR server MAY declare support for FHIRcast using the FHIRcast extension on its FHIR CapabilityStatement's `rest` element. Note that client-side Hubs without a client-side FHIR server likely will not support communicating the url of a hub in this extension. See [the FHIRcast CapabilityStatement profile](StructureDefinition-fhircast-capabilitystatement.html).

### FHIR Resource Structures

FHIRcast defines profiles for various FHIR resource structures used in the specification, see [`summary of artifacts`](artifacts.html).

#### Must Support

In the context of FHIRcast, must support (MS) on any data element SHALL be interpreted to mean [FHIR’s MustSupport](https://www.hl7.org/fhir/conformance-rules.html#mustSupport). Generally, implementations are expected to:
* if known and possible, populate supported data elements as part of the event notifications as specified by the FHIRcast profiles.
* interpret missing, supported data elements within resource instances as data not present in the sending systems (or for which the requestor is unauthorized).
