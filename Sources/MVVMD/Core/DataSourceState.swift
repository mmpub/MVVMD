// DataSourceState

/// Every Data Source will manage and report this state
public enum DataSourceState {
    /// No OS resources are allocated for the data source.
    case uninitialized
    /// Data source is connecting to OS-system resources.
    /// If not available, data source will enter error state
    case initializing
    /// OS-system resources are allocated, but no OS-domain resources are allocated
    /// Data source is not ready to enter active state
    case standby
    /// OS-system resources are allocated, but no OS-domain resources are allocated
    /// Data source is ready to enter active state
    case ready
    /// OS-domain resources are allocated and data streaming is active
    case active
    /// OS-domain resources are allocated and data streaming is suspended due to
    /// external condition: App is backgrounded, Radio is out-of-range, etc.
    case suspended
    /// Error has occurred during initialization or active/suspended states.
    /// OS-system or -domain resources may be allocated.
    case error(Error)
}
