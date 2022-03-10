<img src="Info_Simple_bw.svg.png" width="50" height="50"> 
This page contains guidance to implementers and is not part of the [normative-track](2_Specification.html).
<p></p><p></p>

### Considerations for application with simultaneous contexts

Just as a modern web browser supports multiple pages loaded, but only a single in active use at a given time, some healthcare applications support multiple, distinct patient charts loaded even though  only a single chart is interacted with at a given time. Other applications in healthcare may only support a single patient (or study or ...) context being loaded in the application at a given time. It's important to be able to synchronize the context between two applications supporting these different behaviors. For convenience, we refer to these two types of application behavior as "multi-tab" and "single tab".

#### Single and Multiple Tab Applications

Applications can have different capabilities and layouts, but with FHIRcast they should still be able to stay in sync. A potential situation that could cause confusion is when a single and a multi-tab application work together. While the below guidance describes a patient chart as the primary concept for synchronization, the same guidance applies for other concepts.  

Let's start with a simple case.

##### Opening and Closing a Patient

The diagrams below show two applications without any context, followed by a `patient-open` event communicated to the other app resulting in same patient being opened in the receiving app. When the patient is closed, a `patient-close` event is triggered leading to the patient being closed in the other app as well.

{% include img.html img="PatientOpenAndClose.png" caption="Figure: Simple patient open and close example" %}
<!-- ![Simple patient open and close example](/img/PatientOpenAndClose.png) -->

##### Opening Multiple Patients

As illustrated below, context synchronization is maintained between multiple and single-tabbed applications even across multiple contexts being opened. The initial `patient-open` works as expected by synchronizing the two apps for Patient 1. When the multi-tab app opens a second patient (without closing the first) the single-tab app follows the context change, resulting in the applications staying in sync. Even when the user is working within the multi-tab app, the single-tab app can still stay in sync with the current context.

{% include img.html img="MultiplePatientOpens.png" caption="Figure: Multiple patient open example" %}
<!-- ![Multiple patient open example](/img/MultiplePatientOpens.png) -->

#### Recommendations

* When synchronizing with a multi-tab application, receiving multiple, sequential `-open` events (for example, `patient-open`) does not indicate a synchronization error.
* Multi-tab applications should differentiate between the closing versus inactivating of contexts, by not communicating the inactivation of a context through a `-close` event.

#### Launching A Context-Less Tab

Many applications can have a "home" or "default" tab that contains no clinical context, but may hold useful application features. In some cases other applications may want to subscribe to and be notified when another app has switched to the no context tab. To avoid confusion with other events, a new event is proposed to represent a user switching to this context-less tab.

> note
> Implementer feedback is solicited around the semantics of communicating a context change to a "context-less tab". For example, why not a `patient-open` (or `imagingstudy-open` or ...) with a patient (or study or ...).

Since we are inherently representing the lack of context, the event will not fully conform to the defined event naming syntax and will instead use a static name (similar to `userlogout`).

##### home-open

eventMaturity | [1 - Submitted](3-1-EventMaturityModel.html)

###### Workflow

The user has opened or switched back to the application's home page or tab which does not have any FHIR related context.

Unlike most of FHIRcast events, `home-open` is representing the lack of a FHIR resource context and therefore does not fully follow the `FHIR-resource`-`[open|close]` syntax.

###### Context

The context is empty.

###### Example

```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065", 
  "hub.event": "home-open", 
  "context": [] 
  }
}
```

#### notes

Assumption: Open of an already open means a select.

Late joining  - event stating the current selected patient.

##### Risk

Order of patients can be different between different application. (Late app joining, temporarily out of sync).
