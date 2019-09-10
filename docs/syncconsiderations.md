# Synchronization Considerations

FHIRcast describes a mechanism for synchronizing distinct applications. 
Sometimes things go wrong and applications fail to synchronize or become out of sync. 
For example, the user within the EHR opens a new patient's record,
but the app fails to process the update and continues displaying the initial patient.  
Depending upon the expectations of the user and the error handling of the applications in use, 
this scenario is potentially risky. 
Identified below are four distinct synchronization scenarios, ranging from lowest level of expected synchronization to highest. 

Overall, FHIRcast does not dictate how applications should react to synchronization failure. 
You should design your product to meet your customer's expectations and needs.
Appropriate error handling is specific to the synchronization scenario, user expectations and implemeter.

Also note that synchronization failure is a worst-case scenario and should rarely occur in production.

## Scenarios
Below a couple of usage scenarios are listed where the risk of becoming out of sync are exemplified

### Machine-to-machine-to-machine: Different machines, different times
**Scenario**: Clinician walks away from her desktop EHR and accesses an app on her mobile device which synchronizes to the EHR's hibernated session. 

| Consideration | Risk |
|--|--|
|Synchronization failure significance | low |
|Performance expectations|negligible|
|User inability to distinguish between synchronized applications| n/a|

**Summary**: This serial or sequential use-case is a convenience synchronization and the clinical risk for synchronization failure is low. 

### Cross device: Different machines, same time
**Scenario**: Clinician accesses her desktop EHR as well an app on her mobile device at the same time. Mobile device synchronizes with the EHR desktop session. 

|Consideration|Risk|
|--|--|
|Synchronization failure significance|medium|
|Performance expectations|low|
|User inability to distinguish between synchronized applications| low|

**Summary**: The user clearly distinguishes between the applications synchronized on multiple devices and therefore clinical risk for a synchronization failure depends upon the workflow and implementer's goals. User manual action may be appropriate when synchronization fails.


### Same machine, same time
**Scenario**: Clinician is accessing two or more applications on the same machine in a single workflow.  

|Consideration|Risk|
|--|--|
|Synchronization failure significance| medium|
|Performance expectations|high|
|User inability to distinguish between synchronized applications| medium|

**Summary**: Although, disparate applications are distinguishable from one another, the workflow requires rapidly accessing one then another application. Application responsivity to synchronization is particularly important. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.


### Embedded apps: Same machine, same time, same UI
**Scenario**: Clinician accesses multiple applications within a single user interface. 

|Consideration|Risk|
|--|--|
|Synchronization failure significance|very high|
|Performance expectations|high|
|User inability to distinguish between synchronized applications|very high|

**Summary**: Disparate applications indistinguishable from one another require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

## Synchronization recommendations
FHIRcast is based on a subscription model where each subscribing client receives notifications of the updated state of the topic being subscribed to. There is no explicit requirement for a subscribing client to follow the context of another client. 
The subscription model also implies that it is the subscribing clients responsibility to maintain a contextual synchronization or to notify end users whenever the contextual synchronization is lost.
However, as noted in above scenarios, there may be risk associated with the end user expectation of have two tightly synchronized applications if they fall out of sync. 
There are in some cases good reasons for a client not to follow the subscribed context and this section will outline some of the recommended approaches

### Blocking action on subscribing client preventing context synchronization
Many systems in some cases go into edit mode or start a modal dialog that locks the system from changing context without user intervention. Examples can be when modifying texts, reports, annotating images or performing administrative tasks. The clients may by design then decline to follow the subscribed context to prevent loss of end user data.

|System|Failure mode|Possible actions|
|--|--|--|
|Subscribing Client|Modal dialog open in UI, unable to change case without losing end user data|Present end user with clear indication that contextual synchronization is lost|
|Subscribing Client|Unable to change context|Respond with a http status code of 409 conflict|
|Hub|One of the subscribing clients cannot follow context| No action/Update all subscribing clients with event sync-error|
 
### Unresponsive callback url of subscribing client 
This error scenario is all about the Hub losing contact with its subscribing clients. This may be due to a client crash, mis-configured callback url or simply an underlying network failure. In these cases the clients are usually not aware of the fact that the context has changed or that the subscription messages are not received.

|System|Failure mode|Possible actions|
|--|--|--|
|Subscribing Client|No event received from Hub|No action possible|
|Hub|Timeout or error from client callback url|No action/Retry/Update all subscribing clients with event sync-error |

### Sync-error event received from Hub 
In the scenarios where the Hub is aware of a synchronization error, it is advisable for the Hub to signal this to the subscribing applications to minimize any patient risk associated with having one or many applications out of sync.

|System|Failure mode|Possible actions|
|--|--|--|
|Subscribing Client|Sync-error event received from Hub|Present end user with clear indication that contextual synchronization is lost|
