Profile: FHIRcastImagingStudy
Parent: ImagingStudy
Id: fhircast-imaging-study
Title: "FHIRcast Observation"
Description: "Defines the minimum set of attributes which an application handling ImagingStudy contexts must support"
* numberOfSeries 0..0
* numberOfInstances 0..0
* series 0..0

Instance: FHIRcastImagingStudy-Example
InstanceOf: FHIRcastImagingStudy
Usage: #example
Description: "Example of a simple imaging study used to establish a FHIRcast context"
* id = "8i7tbu6fby5ftfbku6fniuf"
* status = #unknown
* identifier.system = "urn:dicom:uid"
* identifier.value = "urn:oid:2.16.124.113543.6003.1154777499.30246.19789.3503430045"
* subject = Reference(Patient/ewUbXT9RWEbSj5wPEdgRaBw3)
* subject.identifier.system = "urn:oid:1.2.840.114350"
* subject.identifier.value = "185444"