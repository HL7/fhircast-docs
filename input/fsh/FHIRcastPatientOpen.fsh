Profile: FHIRcastPatientOpen
Parent: Patient
Id: fhircast-patient-open
Title: "FHIRcast Patient for Open Events"
Description: "Provides guidance as to which Patient attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-open events."
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided. It may be the `id` associated with the resource as persisted in a FHIR server.
If the resource is not stored in a FHIR server, the Subscriber requesting the context change SHOULD use a mechanism to generate
the `id` such that it will be globally unique (e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)).
When a [FHIR resource]-close event including this patient is requested, the Subscriber requesting the context be closed SHALL use
the same Patient `id` which was provided in the [FHIR resource]-open event (see also
[FHIRcast Patient for Close Events](StructureDefinition-fhircast-patient-close.html)). Additionally, this `id` SHALL be the `id` used
in the `subject` attribute's Patient reference in all resources containing a `subject` attribute in a given [FHIR resource]-open event.
"""
* identifier 1..*
* identifier ^short = "At least one identifier of the Patient SHALL be provided in an [FHIR resource]-open request."
* identifier ^definition = 
"""
At least one `identifier` of the Patient SHALL be provided in a [FHIR resource]-open request. The Subscriber making the open
request should not assume that all Subscribers will be able to resolve the resource id or access a FHIR server where the
resource may be stored; hence, the provided `identifier` (or identifiers) SHOULD be a value by which all Subscribers will
likely be able to identify the Patient.
"""
* name 0..1 MS
* name ^short = "Optional name of the patient for identity verification"
* name ^definition =
"""
It is considered best practice to provide a value for the `name` attribute so that Subscribers may perform identity verification
according to their requirements.
"""
* gender 0..1 MS
* gender ^short = "Optional gender of the patient for identity verification"
* gender ^definition =
"""
It is considered best practice to provide a value for the `gender` attribute if it is available so that Subscribers may perform
identity verification according to their requirements.
"""
* birthDate 0..1 MS
* ^short = "Optional birth date of the patient for identity verification"
* birthDate ^definition =
"""
The Subscriber making the open request SHOULD provide a value for the `birthDate` attribute if it is available so that
Subscribers may perform identity verification according to their requirements
"""

Instance: FHIRcastPatientOpen-Example
InstanceOf: FHIRcastPatientOpen
Usage: #example
Description: "Example of a patient which could be used in a [FHIR resource]-open event"
* id = "503824b8-fe8c-4227-b061-7181ba6c3926"
* identifier[0].use = http://terminology.hl7.org/fhir/ValueSet/identifier-use#official
* identifier[=].type = http://terminology.hl7.org/fhir/ValueSet/identifier-type#MR
* identifier[=].system = "urn:oid:2.16.840.1.113883.19.5"
* identifier[=].value = "4438001"
* identifier[=].assigner.reference = "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc"
* identifier[=].assigner.display = "My Healthcare Provider"
* name.use = http://terminology.hl7.org/fhir/ValueSet/name-use#official
* name.given = "John"
* name.family = "Smith"
* name.prefix = "Dr."
* name.suffix[0] = "Jr."
* name.suffix[1] = "M.D."
* gender = http://terminology.hl7.org/fhir/ValueSet/administrative-gender#male
* birthDate = "1978-11-03"