The specification is not prescriptive about support for extensions. However, to support extensions, the specification reserves the name `extension` and will never define an element with that name, allowing implementations to use it to provide custom behavior and information. The value of an extension element SHALL be a pre-coordinated JSON object. For example, an extension on a notification could look like this:

```json
{
 "context": [{
   "key": "patient",
   "resource": {
    "resourceType": "Patient",
    "id": "ewUbXT9RWEbSj5wPEdgRaBw3"
   }
  },
  {
   "key": "extension",
   "data": {
    "user-timezone": "+1:00"
   }
  }
 ]
}
```
