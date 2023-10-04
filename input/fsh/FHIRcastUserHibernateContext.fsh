Profile: FHIRcastHibernateContext
Parent: Parameters
Id: fhircast-hibernate
Title: "FHIRcast context for userHibernate events."
Description: "Contains the rationale behind the userHibernate event"
* parameter 1..* MS
* parameter ^slicing.discriminator.type = #value
* parameter ^slicing.discriminator.path = "name"
* parameter ^slicing.rules = #open
* parameter ^slicing.ordered = false   // can be omitted, since false is the default
* parameter ^slicing.description = "Reason for logout."
* parameter contains code 1..1 
* parameter[code].name = "code"
* parameter[code] ^short = "Coded reason."
* parameter[code] ^definition = "The reason the Subscriber sends a userHybernate event."
* parameter[code].value[x] 1..1
* parameter[code].value[x] only Coding
* parameter[code].valueCoding from FHIRcastHibernateReason (extensible)
* parameter[code].value[x] ^short = "Coded reason."
* parameter[code].resource 0..0
* parameter[code].part 0..0

ValueSet: FHIRcastHibernateReason
Title: "Reasons for sending a userHibernate event."
Description: "This valueset lists possible reasons a hybernate event is send to other Subscribers."
* include codes from system FHIRcastHibernateCodeSystem

Instance: HibernateExample
InstanceOf: FHIRcastHibernateContext
Usage: #example
* parameter[code]
  * name = "code"
  * valueCoding = FHIRcastHibernateCodeSystem#user-initiated

CodeSystem: FHIRcastHibernateCodeSystem
Id: fhircast-hibernate-codesystem
Title: "FHIRcast hibernate related Terminology."
Description: """
    This codesystem defines hibernate related terminology that is used within the FHIRcast specification.
"""
* ^experimental = false
* ^caseSensitive = true
* #user-initiated "User initiated hibernate."
      "The user initiated the hibernation."
* #system-initiated "System initiated hibernation"
      "The system of the Subscriber is hibernating, e.g. do an inactivity timeout."
  