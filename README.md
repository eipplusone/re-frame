Provides rudimentary search of re-frame events.

To view all events in the project:

`(re-frame-search-events)`

That will parse the project with parseclj and give you a list of events to choose from.

Shortcomings:

- If you switch the project, there's no logic to detect that.
