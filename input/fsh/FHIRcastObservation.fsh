Alias: RadLex = http://www.radlex.org

Profile: FHIRcastObservation
Parent: Observation
Id: fhircast-observation
Title: "FHIRcast Observation"
Description: "Defines the minimum set of attributes which an application wanting to share observation content must support"
* subject 0..0
* hasMember MS
* derivedFrom MS

Instance: FHIRcastObservation-1
InstanceOf: FHIRcastObservation
Usage: #example
Description: "CT Radiation Dose Summary example 1"
* id = "435098234"
* derivedFrom = Reference(ImagingStudy/3478116342)
* derivedFrom.identifier.system = "urn:dicom:uid"
* derivedFrom.identifier.value = "urn:oid:2.16.124.113543.6003.1154777499.30276.83661.3632298176"
* status = #preliminary
* code = RadLex#RID49690 "simple cyst"
* issued = "2020-09-07T15:02:03.651Z"
