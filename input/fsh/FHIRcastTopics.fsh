Instance: FhirCastContainerTopicTopic
InstanceOf: SubscriptionTopic
* id =  "container-update-topic"
* url = "http://hl7.org/fhir/uv/fhircast/SubscriptionTopic/container-update-topic"
* title = "Subscribe to container changes in a topic"
* description = """
  Requests a topic and an anchor-type to be set.   
  Sends updates when content in the Container of the anchor of a type 
  anchor-type for the specified topic changes.
  """
* status = #active
* canFilterBy[+]
  * description = "filters to events for a specific topic"
  * filterParameter = "topic"
  * modifier = #exact
  // * modifier = #eq
* canFilterBy[+]
  * description = "filters to events for a specific anchor type"
  * filterParameter = "anchor-type"
  * modifier = #exact
  // * modifier = #eq

Instance: FhirCastContainerResourceTopic
InstanceOf: SubscriptionTopic
* id = "container-update-resource"
* url = "http://hl7.org/fhir/uv/fhircast/SubscriptionTopic/container-update-resource"
* title = "Subscribe to container changes of an resource"
* description = """
  Requests an anchor-type and anchor-id to be set.   
  Sends updates when content in the Container of the anchor of a type 
  anchor-type with the id anchor-id changes.
  """
* status = #active
* canFilterBy[+]
  * description = "filters to events for a specific anchor type"
  * filterParameter = "anchor-type"
// * modifier = #eq
  * modifier = #exact
* canFilterBy[+]
  * description = "filters to events for a specific anchor (type and id))"
  * filterParameter = "anchor-id"
// * modifier = #eq
  * modifier = #exact

// Instance: FhirCastContainerResourceTopic
// InstanceOf: SubscriptionTopic
// * url = "http://fhircast.hl7.org/container-update/resource"
// * title = "FHIRcast container updates when content in a container changes"
// * description = ""
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-type"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor type"
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-id"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor (type and id))"

// Instance: FhirCastContainerTopicTopic
// InstanceOf: SubscriptionTopic
// * url = "http://fhircast.hl7.org/container-update/topic"
// * title = "FHIRcast container updates when content in the current anchor of a type for a topic changes"
// * description = ""
// * resourceTrigger.canFilterBy[+}.searchParamName = "topic"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific topic"
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-type"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor type"

// Instance: FhirCastContainerResourceTopic
// InstanceOf: SubscriptionTopic
// * url = "http://fhircast.hl7.org/container-update/resource"
// * title = "FHIRcast container updates when content in a container changes"
// * description = ""
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-type"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor type"
// * resourceTrigger.canFilterBy[+}.searchParamName = "anchor-id"
// * resourceTrigger.canFilterBy[=}.searchModifier = "eq"
// * resourceTrigger.canFilterBy[=}.documentation = "filters to events for a specific anchor (type and id))"
