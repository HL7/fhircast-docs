### Event-name: `Encounter-open`

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow

User opened patient's medical record in the context of a single encounter. Only a single patient and encounter is currently in context.

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`encounter` | 1..1 | `Encounter/{id}?_elements=identifier	` | FHIR Encounter resource in context.
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose encounter is currently in context.

### Attribute guidance
This section provides guidance as to which resource attributes should be present and considerations as to how each attribute should be valued.  Other attributes of a resource (or extensions) may be present in the provided resource; however, attributes not called out in the below tables are required by the FHIRcast standard.

#### Encounter resource
{:.grid}
Attribute | Card. | Comments
----- | -------- | ---- | ---- 
`id` | 1..1 | A logical id of the resource must be provided.  It may be the `id` associated with the resource as persisted in a FHIR server.  If the resource is not stored in a FHIR server, the Subscriber requesting the context change SHOULD use a mechanism to generate the `id` such that it will be globally unique (e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)).  When an [Encounter close event](3-4-2-encounter-close.html) for this encounter is requested, the Subscriber requesting the encounter be closed SHALL use the same `id` as provided in the `Encounter` open event.
`identifier` | 1..* | At least one `identifier` SHALL be provided in an `Encounter` open request.  The Subscriber making the open request should not assume all Subscribers will be able to resolve the resource `id` or access a FHIR server where the resource may be stored; hence, the provided `identifier` (or identifiers) should be a value by which all Subscribers likely will be able to identify the `Encounter` to be opened.
`status` | 0..1 | While a FHIR conforming `Encounter` must contain a `status`, since a `status` value is not required to establish an `Encounter` context, `status` is not required to be present.
`subject` | 1..1 | SHALL be valued with a reference to the `Patient` resource which is present in the `Encounter` open event.

#### Patient resource
{:.grid}
Attribute | Card. | Comments
----- | -------- | ---- | ---- 
`id` | 1..1 | A logical id of the resource must be provided.  It may be the `id` associated with the resource as persisted in a FHIR server.  If the resource is not stored in a FHIR server, the Subscriber requesting the context change SHOULD use a mechanism to generate the `id` such that it will be globally unique (e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)).  This `id` SHALL be `id` used in the `subject` attribute reference in the associated `Encounter` resource.
`identifier` | 1..* | At least one `identifier` of the patient SHALL be provided in an `Encounter` open request.  The Subscriber making the open request should not assume all Subscribers will be able to resolve the resource `id` or access a FHIR server where the resource may be stored; hence, the provided `identifier` (or identifiers) should be a value by which all Subscribers likely will be able to identify the `Patient` assocaited with the `Encounter` to be opened.
`name` | 0..1 | It is considered best practice to provide a value for the `name` attribute so that Subscribers may perform identity verification according to their requirements. 
`gender` | 1..1 | It is considered best practice to provide a value for the `gender` attribute if it is available so that Subscribers may perform identity verification according to their requirements.
`birthDate` | 1..1 | The Subscriber making the open request SHOULD provide a value for the `birthDate` attribute if it is available so that Subscribers may perform identity verification according to their requirements.

### Examples


```json
{
  "timestamp": "2018-01-08T01:35:25.33",
  "id": "q9v3jubd43i4ufhff",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "encounter-open",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "type": {
                "coding": [
                  {
                    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "value": "MR",
                    "display": "Medical Record Number"
                  }
                ]
              },
              "system" : "urn:oid:1.2.36.146.595.217.0.1",
              "value" : "12345"
            }
          ]
        }
      },
      {
        "key": "encounter",
        "resource": {
          "resourceType": "Encounter",
          "id": "90235y2347t7nwer7gw7rnhgf",
          "identifier": [
            {
              "system": "28255",
              "value": "344384384"
            }
          ],
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      }
    ]
  }
}
```


### Change Log

{:.grid}
| Version | Description
| ---- | ----
| 1.0 | Initial Release
