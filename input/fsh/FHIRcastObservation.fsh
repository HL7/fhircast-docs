Alias: Loinc = http://loinc.org

Profile: FHIRcastObservation
Parent: Observation
Id: fhircast-observation
Title: "FHIRcast Observation"
Description: "Defines the minimum set of attributes which an application wanting to share observation content must support"
* subject 0..0
* hasMember MS
* derivedFrom MS

Instance: FHIRcastObservation-Example
InstanceOf: FHIRcastObservation
Usage: #example
Description: "Example of a simple observation which could be exchanged using FHIRcast"
* id = "435098234"
* derivedFrom.identifier.system = "urn:dicom:uid"
* derivedFrom.identifier.value = "urn:oid:2.16.124.113543.6003.1154777499.30276.83661.3632298176"
* status = #preliminary
* code = Loinc#45651-7 "Pathological bone fracture [Minimum Data Set]"
* issued = "2020-09-07T15:02:03.651Z"
* valueCodeableConcept.coding.code = Loinc#LA33-6 "Yes"
