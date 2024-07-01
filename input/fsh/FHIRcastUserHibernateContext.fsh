Profile: FHIRcastHibernateContext
Parent: Parameters
Id: fhircast-hibernate
Title: "FHIRcast context for userHibernate events."
Description: "Contains the rationale behind the userHibernate event"
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* ^experimental = false
* parameter 1..* MS
* parameter ^slicing.discriminator.type = #value
* parameter ^slicing.discriminator.path = "name"
* parameter ^slicing.rules = #open
* parameter ^slicing.ordered = false   // can be omitted, since false is the default
* parameter ^slicing.description = "Reason for hibernation."
* parameter contains code 1..1 and hub 0..1
* parameter[code]
  * name = "code"
  * ^short = "Coded reason."
  * ^definition = "The reason the Subscriber sends a userHibernate event."
  * value[x] 1..1
  * value[x] only Coding
  * valueCoding from FHIRcastHibernateReason (extensible)
  * value[x] ^short = "Coded reason."
  * resource 0..0
  * part 0..0
* parameter[hub] 
  * ^short = "Whether the system hosting the Hub will hibernate."
  * ^definition = "If `true`, the hub will hibernate and FHIRcast synchronization is suspended."
  * name = "hub"
  * value[x] 1..1
  * value[x] only boolean
    * ^short = "`true` when system hosting hub will hibernate."
  * resource 0..0
  * part 0..0

ValueSet: FHIRcastHibernateReason
Title: "Reasons for sending a userHibernate event."
Description: "This valueset lists possible reasons a hibernate event is send to other Subscribers."
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* ^experimental = false
* FHIRcastCodeSystem#user-initiated "User initiated hibernate."
* FHIRcastCodeSystem#system-initiated "System initiated hibernation."

Instance: FHIRcastHibernateContext-Example
InstanceOf: FHIRcastHibernateContext
Description: "Example of FHIRcast hibernate event context."
Usage: #example
* parameter[code]
  * name = "code"
  * valueCoding = FHIRcastCodeSystem#user-initiated

Instance: FHIRcastHibernateContext-Hub-Hibernate-Example
InstanceOf: FHIRcastHibernateContext
Description: "Example of FHIRcast hibernate event context where hub will hibernate."
Usage: #example
* parameter[code]
  * name = "code"
  * valueCoding = FHIRcastCodeSystem#system-initiated
* parameter[hub]
  * name = "hub"
  * valueBoolean = true
