/*
 NOTE: @_exported is an undisclosed feature not publicly supported.
 It has been used to expose the dependency to the full app,
 in order to make the SnowplowTracker dependency customizable by CI.
 */
@_exported import SnowplowTracker

public struct Dependencies {
    public var text = "Dummy text"
}
