# Synchronization Considerations

FHIRcast describes a mechanism for synchronizing distinct applications. 
Sometimes things go wrong and applications fail to synchronize or become out of sync. 
For example, the user within the EHR opens a new patient's record,
but the app fails to process the update and continues displaying the initial patient.  
Depending upon the expectations of the user and the error handling of the applications in use, 
this scenario is potentially risky. 
Identified below are four distinct synchronization scenarios, ranging from lowest level of expected synchronization to highest. 

Overall, FHIRcast does not dictate how applications should react to synrhonization failure. 
You should design your product to meet your customer's expectations and needs.
Appropriate error handling is specific to the synchronization scenario, user expectations and implemeter.

Also note that synchronization failure is a worst-case scenario and should rarely occur in production.

## Machine-to-machine-to-machine: Different machines, different times
**Scenario**: Clinician walks away from her desktop EHR and accesses an app on her mobile device which synchronizes to the EHR's hibernated session. 

| Consideration | Risk |
|--|--|
|Synchronization failure significance | low |
|Performance expectations|negligible|
|User inability to distinguish between synchronized applications| n/a|

**Summary**: This serial or sequential use-case is a convenience synchronization and the clinical risk for synchronization failure is low. 

## Cross device: Different machines, same time
**Scenario**: Clinician accesses her desktop EHR as well an app on her mobile device at the same time. Mobile device synchronizes with the EHR desktop session. 

|Consideration|Risk|
|--|--|
|Synchronization failure significance|medium|
|Performance expectations|low|
|User inability to distinguish between synchronized applications| low|

**Summary**: The user clearly distinguishes between the applications synchronized on multiple devices and therefore clinical risk for a synchronization failure depends upon the workflow and implementer's goals. User manual action may be appropriate when synchronization fails.


## Same machine, same time
**Scenario**: Clinician is accessing two or more applications on the same machine in a single workflow.  

|Consideration|Risk|
|--|--|
|Synchronization failure significance| medium|
|Performance expectations|high|
|User inability to distinguish between synchronized applications| medium|

**Summary**: Although, disparate applications are distinguishable from one another, the workflow requires rapidly accessing one then another application. Application responsivity to synchronization is particularly important. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure may be appropriate.


## Embedded apps: Same machine, same time, same UI
**Scenario**: Clinician accesses multiple applications within a single user interface. 

|Consideration|Risk|
|--|--|
|Synchronization failure significance|very high|
|Performance expectations|high|
|User inability to distinguish between synchronized applications|very high|

**Summary**: Disparate applications indistinguishable from one another require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. 
