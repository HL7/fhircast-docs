Profile: FHIRcastLogoutContext
Parent: Parameters
Id: fhircast-logout
Title: "FHIRcast context for logout events."
Description: "Contains the rationale behind the userLogout event"
* parameter 1..* MS
* parameter ^slicing.discriminator.type = #value
* parameter ^slicing.discriminator.path = "name"
* parameter ^slicing.rules = #open
* parameter ^slicing.ordered = false   // can be omitted, since false is the default
* parameter ^slicing.description = "Reason for logout."
* parameter contains code 1..1
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
Description: "This valueset lists possible reasons a user logs out and send a logout event to other Subscribers."
* include codes from system FHIRcastLogoutCodeSystem

Instance: LogoutExample
InstanceOf: FHIRcastLogoutContext
Usage: #example
* parameter[code]
  * name = "code"
  * valueCoding = FHIRcastLogoutCodeSystem#user-initiated

CodeSystem: FHIRcastLogoutCodeSystem
Id: fhircast-logout-codesystem
Title: "FHIRcast logout related Terminology."
Description: """
    This codesystem defines logout related terminology that is used within the FHIRcast specification.
"""
* ^experimental = false
* ^caseSensitive = true
* #user-initiated "User initiated logout"
      "The user initiated the logour and suggests all Subscribers should logout."
* #system-initiated "System initiated logout"
      "The system of the Subscriber is shutting down and the Subscriber requests all Subscribers to log-out."
