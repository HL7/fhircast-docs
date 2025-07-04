Profile: FHIRcastHibernateContext
Parent: Parameters
Id: fhircast-hibernate
Title: "FHIRcast context for userHibernate events."
Description: "Contains the rationale behind the userHibernate event"
* insert SetWorkgroupFmmAndStatusRule( #inm, 4, #active)
* ^experimental = false
* parameter 1..* MS
* parameter ^slicing.discriminator.type = #value
* parameter ^slicing.discriminator.path = "name"
* parameter ^slicing.rules = #open
* parameter ^slicing.ordered = false   // can be omitted, since false is the default
* parameter ^slicing.description = "Reason for hibernation."
* parameter contains code 1..1 MS and hub 0..1
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
Description: "This ValueSet lists possible reasons a hibernate event is send to other Subscribers."
* insert SetWorkgroupFmmAndStatusRule( #inm, 4, #active)
* ^experimental = false
* FHIRcastCodeSystem#user-initiated "User initiated hibernate."
* FHIRcastCodeSystem#system-timeout "System initiated logout due to a timeout."
* FHIRcastCodeSystem#system-initiated "System initiated logout for reason other than timeout."

Instance: FHIRcastHibernateContext-Example
InstanceOf: FHIRcastHibernateContext
Description: "Example of FHIRcast hibernate event context."
Usage: #example
* parameter[code]
  * name = "code"
  * valueCoding = FHIRcastCodeSystem#user-initiated
