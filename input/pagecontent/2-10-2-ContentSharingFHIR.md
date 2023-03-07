In this approach, a FHIR server is used to synchronized content between different FHIRcast Subscribers. This is illustrated in the figure below.

<figure>
  {% include ContentExchangeFHIR.svg %}
  <figcaption><b>Figure: FHIRcast deployment supporting FHIR based content exchange</b></figcaption>
</figure>

Each Subscriber uses FHIRcast to exchange context. The common FHIR server is used to align on content using the [RESTful API](https://build.fhir.org/http) defined by FHIR. Typically this is the server used in a [SMART on FHIR launch](4-1-launch-scenarios.html).

In this deployment, the FHIR server acts independently from the FHIRcast Hub.

Notifications on content changes are supported using the [FHIR subscription mechanism](https://build.fhir.org/subscriptions.html).
