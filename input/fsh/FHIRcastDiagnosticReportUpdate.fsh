Profile: FHIRcastDiagnosticReportUpdate
Parent: DiagnosticReport
Id: fhircast-diagnostic-report-update
Title: "FHIRcast Diagnostic Report for Update Events"
Description:
"""
Provides guidance as to which `DiagnosticReport` attributes should be present and considerations as to how each attribute should be valued in [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) events.

The `DiagnosticReport` in [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) events serves two purposes.  First its presence enables verification that the content in the [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) event's Bundle attribute belongs to the DiagnosticReport which is the current anchor context.  Additionally, attributes of the DiagnosticReport which is the current anchor context may be updated in a [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) event.

Hence, the only required attributes of `DiagnosticReport` in the [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) event is the resources' `id`, as well as its `status` since this attribute is required by FHIR.  Other attributes of the `DiagnosticReport` MAY be valued if they have changed from their original values or no value had been provided in the [`DiagnosticReport-open`](3-6-1-DiagnosticReport-open.html) event.

"""
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* id 1..1 
* id ^short = "A logical id of the resource SHALL be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided.
"""
* status 1..1
* status ^short = "Status of the DiagnosticReport, note this may not be known and hence have a value of `unknown`; however, is included since it is required by FHIR"
* status ^definition = 
"""
While initially the `status` of the report may begin as `unknown` or `preliminary` (or something else), throughout the lifecycle of the context the report's status may transition.  For example, a reporting application may enable a clinician to sign the report.  In such a situation this change in status could become final and would be communicated through a [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html)
event prior to the DiagnosticReport context being closed by a DiagnosticReport-close event.  
"""

Instance: FHIRcastDiagnosticReportUpdate-Example
InstanceOf: FHIRcastDiagnosticReportUpdate
Usage: #example
Description: "Example of a `DiagnosticReport` which could be used in a [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) event.  Note that due to limitation of tools used to publishing the specification the below resource `id` is appended with '-update'.  The specification requires that the resource `id` in the [FHIR resource]-update be identical to the resource `id` provided in the corresponding [FHIR resource]-open; hence in the real world the '-update' suffix would not be present."
* id = "2402d3bd-e988-414b-b7f2-4322e86c9327-update"
* status = http://terminology.hl7.org/fhir/ValueSet/diagnostic-report-status#unknown
* code = http://loinc.org#19005-8 "Radiology Imaging study [Impression] (narrative)"
