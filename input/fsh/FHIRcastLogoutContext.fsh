Profile: FHIRcastLogoutContext
Parent: Parameters
Id: fhircast-logout
Title: "FHIRcast context for logout events."
Description: "Defines the minimum set of attributes which an application wanting to share observation content must support"
* obeys userlogout-1
* parameter 1..* MS
* parameter ^slicing.discriminator.type = #value
* parameter ^slicing.discriminator.path = "valueCoding"
* parameter ^slicing.rules = #open
* parameter ^slicing.ordered = false   // can be omitted, since false is the default
* parameter ^slicing.description = "Reason for logout."
* parameter contains code 1..1 and reason 0..1
* parameter[code].name = "code"
* parameter[code] ^short = "Coded reason."
* parameter[code] ^definition = "The reason the Subscriber logout as code."
* parameter[code].value[x] 1..1
* parameter[code].value[x] only Coding
* parameter[code].valueCoding from FHIRcastLogoutReason (extensible)
* parameter[code].value[x] ^short = "Coded reason."
* parameter[code].resource 0..0
* parameter[code].part 0..0
* parameter[reason].name = "reason"
* parameter[reason] ^short = "Human readable reason."
* parameter[reason] ^definition = "The reason the Subscriber logout in a human readable string."
* parameter[reason].value[x] 1..1
* parameter[reason].value[x] only string
* parameter[reason].value[x] ^short = "Human readable reason."
* parameter[reason].resource 0..0
* parameter[reason].part 0..0

Invariant: userlogout-1
Description: "An unspecified reason requires a human readable string."
Expression: "(Parameters.parameter.exists( name='code' and valueCoding.system='http://hl7.org/fhir/uv/fhircast/CodeSystem/fhircast-codesystem' and valueCoding.code='unspecified' ) and Parameters.parameter.exists( name='reason' and valueString.empty().not() ) )"
Severity: #error

ValueSet: FHIRcastLogoutReason
Title: "Reasons for sending a logout event."
Description: "This valueset lists possible reasons a user logs out and send a logout event to other Subscribers."
* include codes from system FHIRcastCodeSystem where concept is-a #logout-reason

Instance: LogoutExample
InstanceOf: FHIRcastLogoutContext
Usage: #example
* parameter[code]
  * name = "code"
  * valueCoding = FHIRcastCodeSystem#user-requested
* parameter[reason]
  * name = "reason"
  * valueString = "Please logout from all applications."