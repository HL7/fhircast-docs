Profile: FHIRcastEncounterOpen
Parent: Encounter
Id: fhircast-encounter-open
Title: "FHIRcast Encounter for Open Events"
Description: "Provides guidance as to which Encounter attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-open events."
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource must be provided. It may be the `id` associated with the resource as persisted in a FHIR server.
If the resource is not stored in a FHIR server, the Subscriber requesting the context change SHOULD use a mechanism to generate
the `id` such that it will be globally unique (e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)). When
a [FHIR resource]-close event including this encounter is requested, the Subscriber requesting the context be closed SHALL use
the same Encounter `id` which was provided in the [FHIR resource]-open event (see also
[FHIRcast Encounter for Close Events](StructureDefinition-fhircast-encounter-close.html)).
"""
* identifier 1..*
* identifier ^short = "At least one identifier of the Encounter SHALL be provided in an [FHIR resource]-open request."
* identifier ^definition = 
"""
At least one `identifier` of the Encounter SHALL be provided in a [FHIR resource]-open request. The Subscriber making the open
request should not assume that all Subscribers will be able to resolve the resource id or access a FHIR server where the
resource may be stored; hence, the provided `identifier` (or identifiers) should be a value by which all Subscribers will
likely be able to identify the Encounter.
"""
* subject 1..1
* subject only Reference(FHIRcastPatientOpen)
* subject ^short = "Reference to the patient associated with the encounter"
* subject ^definition = 
"""
SHALL be valued with a reference to the Patient resource which is present in the [FHIR resource]-open event.
"""

Instance: FHIRcastEncounterOpen-Example
InstanceOf: FHIRcastEncounterOpen
Usage: #example
Description: "Example of an encounter which could be used in a [FHIR resource]-open event"
* id = "8cc652ba-770e-4ae1-b688-6e8e7c737438"
* status = http://terminology.hl7.org/fhir/ValueSet/encounter-status#unknown
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB
* identifier.use = http://terminology.hl7.org/fhir/ValueSet/identifier-use#official
* identifier.value = "r2r22345"
* identifier.system = "http://myhealthcare.com/visits"
* subject = Reference(FHIRcastPatientOpen-Example)
