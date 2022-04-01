Alias: LOINC =  http://loinc.org

Profile: FHIRcastDiagnosticReport
Parent: DiagnosticReport
Id: fhircast-diagnostic-report
Title: "FHIRcast Diagnostic Report"
Description: "Defines the minimum set of attributes which an application handling DiagnosticReport contexts must support"
* subject 1..1
* imagingStudy MS

Instance: FHIRcastDiagnosticReport-Example
InstanceOf: FHIRcastDiagnosticReport
Usage: #example
Description: "Example of a simple diagnostic report used to establish a FHIRcast context"
* id = "40012366"
* subject = Reference(Patient/ewUbXT9RWEbSj5wPEdgRaBw3)
* subject.identifier.system = "urn:oid:1.2.840.114350"
* subject.identifier.value = "185444"
* status = #preliminary
* code = LOINC#30675-3 "MR Prostate"
