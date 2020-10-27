!!! info "Implementer guidance" 
    This page contains guidance to implementers and is not part of the normative-track [FHIRcast specification](../specification/STU2).

#Dealing with Multi-Tab Applications
    
## Single and Multiple Tab Applications
Applications can have different capabilities and layouts, but with FHIRcast they should still be able to stay in sync. A potential situation that could cause confusion is when a single and a multi-tab application work together. 

Let's start with a simple case.

### Opening and Closing a Patient
The diagrams below show that the apps will start without any context, then one will open a patient triggering a Patient-open event to the other app leading to that same patient being opened in the receiving app. When the patient is closed, that triggers a Patient-close event leading to the patient being closed in the other app as well.

![Simple patient open and close example](/img/PatientOpenAndClose.png)


### Opening Multiple Patients
As you can see in the diagrams below, we can still maintain context sync between multiple and single-tabbed applications even when there is multiple contexts being opened. The initial Patient-open works as expected in syncing the two apps for that patient. When the multi-tab app opens another patient (without closing the first) the single-tab app should still follow the context change to keep the applications in sync. Even if the multi-tab app is leading the context changes, the single-tab app can still stay in sync with the current context.

![Multiple patient open example](/img/MultiplePatientOpens.png)

## Launching A Context-Less Tab
Many applications can have a "home" or "default" tab that contains no clinical context, but may hold useful application features. In some cases other applications may want to subscribe to and be notified when another app has switched to the no context tab. To avoid confusion with other events, a new event will be created to represent a user switching to this context-less tab. Keep in mind that this is different than closing events and how it works between single and multi-tab applications should be considered. For example, similar to multiple open events (as described above) this event could be received, opening or switching to the context-less tab, without closing the currently open context. 

Since we are inherently representing the lack of context, the event will not fully conform to the defined event naming syntax and will instead use a static name (similar to `userlogout`).

### home-open

eventMaturity | [1 - Submitted](../../specification/STU1/#event-maturity-model)

#### Workflow

The user has opened or switched back to the application's home page or tab which does not have any FHIR related context.

Unlike most of FHIRcast events, `home-open` is representing the lack of a FHIR resource context and therefore does not fully follow the `FHIR-resource`-`[open|close]` syntax.

#### Context

The context is empty.

#### Example

<mark>
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
</mark>



