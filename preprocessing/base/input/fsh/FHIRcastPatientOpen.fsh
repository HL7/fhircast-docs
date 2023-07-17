Profile: FHIRcast{{fhirNoUc}}PatientOpen
Parent: Patient
Id: fhircast-{{fhirNoLc}}-patient-open
Title: "{{fhirNoUc}} FHIRcast Patient for Open Events"
Description: "Provides guidance as to which Patient attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-open events."
* id 1..1 
* id ^short = "A logical id of the resource SHALL be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided. It may be the `id` associated with the resource as persisted in a FHIR server.
If the resource is not stored in a FHIR server, the Subscriber requesting the context change SHOULD use a mechanism to generate
the `id` such that it will be globally unique (e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)).
When a [FHIR resource]-close event including this patient is requested, the Subscriber requesting the context be closed SHALL use
the same Patient `id` which was provided in the [FHIR resource]-open event (see also
[FHIRcast Patient for Close Events](StructureDefinition-fhircast-{{fhirNoLc}}-patient-close.html)). Additionally, this `id` SHALL be the `id` used
in the `subject` attribute's Patient reference in all resources containing a `subject` attribute in a given [FHIR resource]-open event.
"""
* identifier 1..*
* identifier ^short = "At least one identifier of the Patient SHALL be provided in a [FHIR resource]-open request."
* identifier ^definition = 
"""
At least one `identifier` of the Patient SHALL be provided in a [FHIR resource]-open request. The Subscriber making the open
request should not assume that all Subscribers will be able to resolve the resource `id` or access a FHIR server where the
resource may be stored; hence, the provided `identifier` (or identifiers) should be a value by which all Subscribers will
likely be able to identify the Patient (e.g., a patient's MRN or MPI identifier).
"""
* name 0..1 MS
* name ^short = "Name of the patient which may be used for identity verification"
* name ^definition =
"""
The Subscriber making the open request SHOULD provide a value for the `name` attribute, if it is available, so that Subscribers may perform
identity verification according to their requirements.
"""
* gender 0..1 MS
* gender ^short = "Gender of the patient which may be used for identity verification"
* gender ^definition =
"""
The Subscriber making the open request SHOULD provide a value for the `gender` attribute, if it is available, so that Subscribers may perform
identity verification according to their requirements.
"""
* birthDate 0..1 MS
* birthDate ^short = "Birth date of the patient which may be used for identity verification"
* birthDate ^definition =
"""
The Subscriber making the open request SHOULD provide a value for the `birthDate` attribute, if it is available, so that Subscribers may perform
identity verification according to their requirements
"""

Instance: FHIRcast{{fhirNoUc}}PatientOpen-Example
InstanceOf: FHIRcast{{fhirNoUc}}PatientOpen
Usage: #example
Description: "Example of a patient which could be used in a [FHIR resource]-open event"
* id = "{{fhirNoLc}}-503824b8-fe8c-4227-b061-7181ba6c3926"
* identifier[0].use = http://hl7.org/fhir/identifier-use#official
* identifier[=].type = http://terminology.hl7.org/CodeSystem/v2-0203#MR
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