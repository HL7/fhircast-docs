Profile: FHIRcastLogoutContext
Parent: Parameters
Id: fhircast-logout
Title: "FHIRcast context for logout events."
Description: "Contains the rationale behind the userLogout event"
* insert SetWorkgroupFmmAndStatusRule( #inm, 4, #active)
* ^experimental = false
* parameter 1..* MS
* parameter ^slicing.discriminator.type = #value
* parameter ^slicing.discriminator.path = "name"
* parameter ^slicing.rules = #open
* parameter ^slicing.ordered = false   // can be omitted, since false is the default
* parameter ^slicing.description = "Reason for logout."
* parameter contains code 1..1 MS
* parameter[code].name = "code"
* parameter[code] ^short = "Coded reason."
* parameter[code] ^definition = "The reason the Subscriber logout as code."
* parameter[code].value[x] 1..1
* parameter[code].value[x] only Coding
* parameter[code].valueCoding from FHIRcastLogoutReason (extensible)
* parameter[code].value[x] ^short = "Coded reason."
* parameter[code].resource 0..0
* parameter[code].part 0..0

ValueSet: FHIRcastLogoutReason
Title: "Reasons for sending a logout event."
Description: "This ValueSet lists possible reasons a user logs out and send a logout event to other Subscribers."
* insert SetWorkgroupFmmAndStatusRule( #inm, 4, #active)
* ^experimental = false
* FHIRcastCodeSystem#user-initiated "User initiated logout."
* FHIRcastCodeSystem#system-timeout "System initiated logout due to a timeout."
* FHIRcastCodeSystem#system-initiated "System initiated logout for reason other than timeout."

Instance: FHIRcastLogoutContext-Example
InstanceOf: FHIRcastLogoutContext
Description: "Example FHIRcast logout event context."
Usage: #example
* parameter[code]
  * name = "code"
  * valueCoding = FHIRcastCodeSystem#user-initiated
