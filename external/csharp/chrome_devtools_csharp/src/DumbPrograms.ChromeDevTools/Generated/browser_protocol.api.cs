using System;
using System.Threading;
using System.Threading.Tasks;

namespace DumbPrograms.ChromeDevTools
{
    partial class InspectorClient
    {

        /// <summary />
        public AccessibilityInspectorClient Accessibility => __Accessibility__ ?? (__Accessibility__ = new AccessibilityInspectorClient(this));
        private AccessibilityInspectorClient __Accessibility__;

        /// <summary />
        public AnimationInspectorClient Animation => __Animation__ ?? (__Animation__ = new AnimationInspectorClient(this));
        private AnimationInspectorClient __Animation__;

        /// <summary />
        public ApplicationCacheInspectorClient ApplicationCache => __ApplicationCache__ ?? (__ApplicationCache__ = new ApplicationCacheInspectorClient(this));
        private ApplicationCacheInspectorClient __ApplicationCache__;

        /// <summary>
        /// Audits domain allows investigation of page violations and possible improvements.
        /// </summary>
        public AuditsInspectorClient Audits => __Audits__ ?? (__Audits__ = new AuditsInspectorClient(this));
        private AuditsInspectorClient __Audits__;

        /// <summary>
        /// The Browser domain defines methods and events for browser managing.
        /// </summary>
        public BrowserInspectorClient Browser => __Browser__ ?? (__Browser__ = new BrowserInspectorClient(this));
        private BrowserInspectorClient __Browser__;

        /// <summary>
        /// This domain exposes CSS read/write operations. All CSS objects (stylesheets, rules, and styles)
        /// have an associated `id` used in subsequent operations on the related object. Each object type has
        /// a specific `id` structure, and those are not interchangeable between objects of different kinds.
        /// CSS objects can be loaded using the `get*ForNode()` calls (which accept a DOM node id). A client
        /// can also keep track of stylesheets via the `styleSheetAdded`/`styleSheetRemoved` events and
        /// subsequently load the required stylesheet contents using the `getStyleSheet[Text]()` methods.
        /// </summary>
        public CSSInspectorClient CSS => __CSS__ ?? (__CSS__ = new CSSInspectorClient(this));
        private CSSInspectorClient __CSS__;

        /// <summary />
        public CacheStorageInspectorClient CacheStorage => __CacheStorage__ ?? (__CacheStorage__ = new CacheStorageInspectorClient(this));
        private CacheStorageInspectorClient __CacheStorage__;

        /// <summary>
        /// A domain for interacting with Cast, Presentation API, and Remote Playback API
        /// functionalities.
        /// </summary>
        public CastInspectorClient Cast => __Cast__ ?? (__Cast__ = new CastInspectorClient(this));
        private CastInspectorClient __Cast__;

        /// <summary>
        /// This domain exposes DOM read/write operations. Each DOM Node is represented with its mirror object
        /// that has an `id`. This `id` can be used to get additional information on the Node, resolve it into
        /// the JavaScript object wrapper, etc. It is important that client receives DOM events only for the
        /// nodes that are known to the client. Backend keeps track of the nodes that were sent to the client
        /// and never sends the same node twice. It is client's responsibility to collect information about
        /// the nodes that were sent to the client.&lt;p&gt;Note that `iframe` owner elements will return
        /// corresponding document elements as their child nodes.&lt;/p&gt;
        /// </summary>
        public DOMInspectorClient DOM => __DOM__ ?? (__DOM__ = new DOMInspectorClient(this));
        private DOMInspectorClient __DOM__;

        /// <summary>
        /// DOM debugging allows setting breakpoints on particular DOM operations and events. JavaScript
        /// execution will stop on these operations as if there was a regular breakpoint set.
        /// </summary>
        public DOMDebuggerInspectorClient DOMDebugger => __DOMDebugger__ ?? (__DOMDebugger__ = new DOMDebuggerInspectorClient(this));
        private DOMDebuggerInspectorClient __DOMDebugger__;

        /// <summary>
        /// This domain facilitates obtaining document snapshots with DOM, layout, and style information.
        /// </summary>
        public DOMSnapshotInspectorClient DOMSnapshot => __DOMSnapshot__ ?? (__DOMSnapshot__ = new DOMSnapshotInspectorClient(this));
        private DOMSnapshotInspectorClient __DOMSnapshot__;

        /// <summary>
        /// Query and modify DOM storage.
        /// </summary>
        public DOMStorageInspectorClient DOMStorage => __DOMStorage__ ?? (__DOMStorage__ = new DOMStorageInspectorClient(this));
        private DOMStorageInspectorClient __DOMStorage__;

        /// <summary />
        public DatabaseInspectorClient Database => __Database__ ?? (__Database__ = new DatabaseInspectorClient(this));
        private DatabaseInspectorClient __Database__;

        /// <summary />
        public DeviceOrientationInspectorClient DeviceOrientation => __DeviceOrientation__ ?? (__DeviceOrientation__ = new DeviceOrientationInspectorClient(this));
        private DeviceOrientationInspectorClient __DeviceOrientation__;

        /// <summary>
        /// This domain emulates different environments for the page.
        /// </summary>
        public EmulationInspectorClient Emulation => __Emulation__ ?? (__Emulation__ = new EmulationInspectorClient(this));
        private EmulationInspectorClient __Emulation__;

        /// <summary>
        /// This domain provides experimental commands only supported in headless mode.
        /// </summary>
        public HeadlessExperimentalInspectorClient HeadlessExperimental => __HeadlessExperimental__ ?? (__HeadlessExperimental__ = new HeadlessExperimentalInspectorClient(this));
        private HeadlessExperimentalInspectorClient __HeadlessExperimental__;

        /// <summary>
        /// Input/Output operations for streams produced by DevTools.
        /// </summary>
        public IOInspectorClient IO => __IO__ ?? (__IO__ = new IOInspectorClient(this));
        private IOInspectorClient __IO__;

        /// <summary />
        public IndexedDBInspectorClient IndexedDB => __IndexedDB__ ?? (__IndexedDB__ = new IndexedDBInspectorClient(this));
        private IndexedDBInspectorClient __IndexedDB__;

        /// <summary />
        public InputInspectorClient Input => __Input__ ?? (__Input__ = new InputInspectorClient(this));
        private InputInspectorClient __Input__;

        /// <summary />
        public InspectorInspectorClient Inspector => __Inspector__ ?? (__Inspector__ = new InspectorInspectorClient(this));
        private InspectorInspectorClient __Inspector__;

        /// <summary />
        public LayerTreeInspectorClient LayerTree => __LayerTree__ ?? (__LayerTree__ = new LayerTreeInspectorClient(this));
        private LayerTreeInspectorClient __LayerTree__;

        /// <summary>
        /// Provides access to log entries.
        /// </summary>
        public LogInspectorClient Log => __Log__ ?? (__Log__ = new LogInspectorClient(this));
        private LogInspectorClient __Log__;

        /// <summary />
        public MemoryInspectorClient Memory => __Memory__ ?? (__Memory__ = new MemoryInspectorClient(this));
        private MemoryInspectorClient __Memory__;

        /// <summary>
        /// Network domain allows tracking network activities of the page. It exposes information about http,
        /// file, data and other requests and responses, their headers, bodies, timing, etc.
        /// </summary>
        public NetworkInspectorClient Network => __Network__ ?? (__Network__ = new NetworkInspectorClient(this));
        private NetworkInspectorClient __Network__;

        /// <summary>
        /// This domain provides various functionality related to drawing atop the inspected page.
        /// </summary>
        public OverlayInspectorClient Overlay => __Overlay__ ?? (__Overlay__ = new OverlayInspectorClient(this));
        private OverlayInspectorClient __Overlay__;

        /// <summary>
        /// Actions and events related to the inspected page belong to the page domain.
        /// </summary>
        public PageInspectorClient Page => __Page__ ?? (__Page__ = new PageInspectorClient(this));
        private PageInspectorClient __Page__;

        /// <summary />
        public PerformanceInspectorClient Performance => __Performance__ ?? (__Performance__ = new PerformanceInspectorClient(this));
        private PerformanceInspectorClient __Performance__;

        /// <summary>
        /// Security
        /// </summary>
        public SecurityInspectorClient Security => __Security__ ?? (__Security__ = new SecurityInspectorClient(this));
        private SecurityInspectorClient __Security__;

        /// <summary />
        public ServiceWorkerInspectorClient ServiceWorker => __ServiceWorker__ ?? (__ServiceWorker__ = new ServiceWorkerInspectorClient(this));
        private ServiceWorkerInspectorClient __ServiceWorker__;

        /// <summary />
        public StorageInspectorClient Storage => __Storage__ ?? (__Storage__ = new StorageInspectorClient(this));
        private StorageInspectorClient __Storage__;

        /// <summary>
        /// The SystemInfo domain defines methods and events for querying low-level system information.
        /// </summary>
        public SystemInfoInspectorClient SystemInfo => __SystemInfo__ ?? (__SystemInfo__ = new SystemInfoInspectorClient(this));
        private SystemInfoInspectorClient __SystemInfo__;

        /// <summary>
        /// Supports additional targets discovery and allows to attach to them.
        /// </summary>
        public TargetInspectorClient Target => __Target__ ?? (__Target__ = new TargetInspectorClient(this));
        private TargetInspectorClient __Target__;

        /// <summary>
        /// The Tethering domain defines methods and events for browser port binding.
        /// </summary>
        public TetheringInspectorClient Tethering => __Tethering__ ?? (__Tethering__ = new TetheringInspectorClient(this));
        private TetheringInspectorClient __Tethering__;

        /// <summary />
        public TracingInspectorClient Tracing => __Tracing__ ?? (__Tracing__ = new TracingInspectorClient(this));
        private TracingInspectorClient __Tracing__;

        /// <summary>
        /// Testing domain is a dumping ground for the capabilities requires for browser or app testing that do not fit other
        /// domains.
        /// </summary>
        public TestingInspectorClient Testing => __Testing__ ?? (__Testing__ = new TestingInspectorClient(this));
        private TestingInspectorClient __Testing__;

        /// <summary>
        /// A domain for letting clients substitute browser's network layer with client code.
        /// </summary>
        public FetchInspectorClient Fetch => __Fetch__ ?? (__Fetch__ = new FetchInspectorClient(this));
        private FetchInspectorClient __Fetch__;

        /// <summary>
        /// Inspector client for domain Accessibility.
        /// </summary>
        public class AccessibilityInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal AccessibilityInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disables the accessibility domain.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Accessibility.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables the accessibility domain which causes `AXNodeId`s to remain consistent between method calls.
            /// This turns on accessibility for the page, which can impact performance until accessibility is disabled.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Accessibility.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fetches the accessibility node and partial accessibility tree for this DOM node, if it exists.
            /// </summary>
            /// <param name="nodeId">
            /// Identifier of the node to get the partial accessibility tree for.
            /// </param>
            /// <param name="backendNodeId">
            /// Identifier of the backend node to get the partial accessibility tree for.
            /// </param>
            /// <param name="objectId">
            /// JavaScript object id of the node wrapper to get the partial accessibility tree for.
            /// </param>
            /// <param name="fetchRelatives">
            /// Whether to fetch this nodes ancestors, siblings and children. Defaults to true.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Accessibility.GetPartialAXTreeResponse> GetPartialAXTree
            (
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                bool? @fetchRelatives = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Accessibility.GetPartialAXTreeCommand
                    {
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectId = @objectId,
                        FetchRelatives = @fetchRelatives,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fetches the entire accessibility tree
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Accessibility.GetFullAXTreeResponse> GetFullAXTree
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Accessibility.GetFullAXTreeCommand
                    {
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Animation.
        /// </summary>
        public class AnimationInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal AnimationInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disables animation domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables animation domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the current time of the an animation.
            /// </summary>
            /// <param name="id">
            /// Id of animation.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Animation.GetCurrentTimeResponse> GetCurrentTime
            (
                string @id, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.GetCurrentTimeCommand
                    {
                        Id = @id,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Gets the playback rate of the document timeline.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Animation.GetPlaybackRateResponse> GetPlaybackRate
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.GetPlaybackRateCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Releases a set of animations to no longer be manipulated.
            /// </summary>
            /// <param name="animations">
            /// List of animation ids to seek.
            /// </param>
            /// <param name="cancellation" />
            public Task ReleaseAnimations
            (
                string[] @animations, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.ReleaseAnimationsCommand
                    {
                        Animations = @animations,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Gets the remote object of the Animation.
            /// </summary>
            /// <param name="animationId">
            /// Animation id.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Animation.ResolveAnimationResponse> ResolveAnimation
            (
                string @animationId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.ResolveAnimationCommand
                    {
                        AnimationId = @animationId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Seek a set of animations to a particular time within each animation.
            /// </summary>
            /// <param name="animations">
            /// List of animation ids to seek.
            /// </param>
            /// <param name="currentTime">
            /// Set the current time of each animation.
            /// </param>
            /// <param name="cancellation" />
            public Task SeekAnimations
            (
                string[] @animations, 
                double @currentTime, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.SeekAnimationsCommand
                    {
                        Animations = @animations,
                        CurrentTime = @currentTime,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets the paused state of a set of animations.
            /// </summary>
            /// <param name="animations">
            /// Animations to set the pause state of.
            /// </param>
            /// <param name="paused">
            /// Paused state to set to.
            /// </param>
            /// <param name="cancellation" />
            public Task SetPaused
            (
                string[] @animations, 
                bool @paused, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.SetPausedCommand
                    {
                        Animations = @animations,
                        Paused = @paused,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets the playback rate of the document timeline.
            /// </summary>
            /// <param name="playbackRate">
            /// Playback rate for animations on page
            /// </param>
            /// <param name="cancellation" />
            public Task SetPlaybackRate
            (
                double @playbackRate, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.SetPlaybackRateCommand
                    {
                        PlaybackRate = @playbackRate,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets the timing of an animation node.
            /// </summary>
            /// <param name="animationId">
            /// Animation id.
            /// </param>
            /// <param name="duration">
            /// Duration of the animation.
            /// </param>
            /// <param name="delay">
            /// Delay of the animation.
            /// </param>
            /// <param name="cancellation" />
            public Task SetTiming
            (
                string @animationId, 
                double @duration, 
                double @delay, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Animation.SetTimingCommand
                    {
                        AnimationId = @animationId,
                        Duration = @duration,
                        Delay = @delay,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Event for when an animation has been cancelled.
            /// </summary>
            public event Func<Protocol.Animation.AnimationCanceledEvent, Task> AnimationCanceled
            {
                add => InspectorClient.AddEventHandlerCore("Animation.animationCanceled", value);
                remove => InspectorClient.RemoveEventHandlerCore("Animation.animationCanceled", value);
            }

            /// <summary>
            /// Event for each animation that has been created.
            /// </summary>
            public event Func<Protocol.Animation.AnimationCreatedEvent, Task> AnimationCreated
            {
                add => InspectorClient.AddEventHandlerCore("Animation.animationCreated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Animation.animationCreated", value);
            }

            /// <summary>
            /// Event for animation that has been started.
            /// </summary>
            public event Func<Protocol.Animation.AnimationStartedEvent, Task> AnimationStarted
            {
                add => InspectorClient.AddEventHandlerCore("Animation.animationStarted", value);
                remove => InspectorClient.RemoveEventHandlerCore("Animation.animationStarted", value);
            }

            /// <summary>
            /// Event for when an animation has been cancelled.
            /// </summary>
            public Task<Protocol.Animation.AnimationCanceledEvent> AnimationCanceledEvent(Func<Protocol.Animation.AnimationCanceledEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Animation.animationCanceled", until);
            }

            /// <summary>
            /// Event for each animation that has been created.
            /// </summary>
            public Task<Protocol.Animation.AnimationCreatedEvent> AnimationCreatedEvent(Func<Protocol.Animation.AnimationCreatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Animation.animationCreated", until);
            }

            /// <summary>
            /// Event for animation that has been started.
            /// </summary>
            public Task<Protocol.Animation.AnimationStartedEvent> AnimationStartedEvent(Func<Protocol.Animation.AnimationStartedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Animation.animationStarted", until);
            }
        }

        /// <summary>
        /// Inspector client for domain ApplicationCache.
        /// </summary>
        public class ApplicationCacheInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal ApplicationCacheInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Enables application cache domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ApplicationCache.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns relevant application cache data for the document in given frame.
            /// </summary>
            /// <param name="frameId">
            /// Identifier of the frame containing document whose application cache is retrieved.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.ApplicationCache.GetApplicationCacheForFrameResponse> GetApplicationCacheForFrame
            (
                Protocol.Page.FrameId @frameId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ApplicationCache.GetApplicationCacheForFrameCommand
                    {
                        FrameId = @frameId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns array of frame identifiers with manifest urls for each frame containing a document
            /// associated with some application cache.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.ApplicationCache.GetFramesWithManifestsResponse> GetFramesWithManifests
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ApplicationCache.GetFramesWithManifestsCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns manifest URL for document in the given frame.
            /// </summary>
            /// <param name="frameId">
            /// Identifier of the frame containing document whose manifest is retrieved.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.ApplicationCache.GetManifestForFrameResponse> GetManifestForFrame
            (
                Protocol.Page.FrameId @frameId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ApplicationCache.GetManifestForFrameCommand
                    {
                        FrameId = @frameId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.ApplicationCache.ApplicationCacheStatusUpdatedEvent, Task> ApplicationCacheStatusUpdated
            {
                add => InspectorClient.AddEventHandlerCore("ApplicationCache.applicationCacheStatusUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("ApplicationCache.applicationCacheStatusUpdated", value);
            }

            /// <summary />
            public event Func<Protocol.ApplicationCache.NetworkStateUpdatedEvent, Task> NetworkStateUpdated
            {
                add => InspectorClient.AddEventHandlerCore("ApplicationCache.networkStateUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("ApplicationCache.networkStateUpdated", value);
            }

            /// <summary />
            public Task<Protocol.ApplicationCache.ApplicationCacheStatusUpdatedEvent> ApplicationCacheStatusUpdatedEvent(Func<Protocol.ApplicationCache.ApplicationCacheStatusUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("ApplicationCache.applicationCacheStatusUpdated", until);
            }

            /// <summary />
            public Task<Protocol.ApplicationCache.NetworkStateUpdatedEvent> NetworkStateUpdatedEvent(Func<Protocol.ApplicationCache.NetworkStateUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("ApplicationCache.networkStateUpdated", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Audits.
        /// </summary>
        public class AuditsInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal AuditsInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Returns the response body and size if it were re-encoded with the specified settings. Only
            /// applies to images.
            /// </summary>
            /// <param name="requestId">
            /// Identifier of the network request to get content for.
            /// </param>
            /// <param name="encoding">
            /// The encoding to use.
            /// </param>
            /// <param name="quality">
            /// The quality of the encoding (0-1). (defaults to 1)
            /// </param>
            /// <param name="sizeOnly">
            /// Whether to only return the size information (defaults to false).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Audits.GetEncodedResponseResponse> GetEncodedResponse
            (
                Protocol.Network.RequestId @requestId, 
                string @encoding, 
                double? @quality = default, 
                bool? @sizeOnly = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Audits.GetEncodedResponseCommand
                    {
                        RequestId = @requestId,
                        Encoding = @encoding,
                        Quality = @quality,
                        SizeOnly = @sizeOnly,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Browser.
        /// </summary>
        public class BrowserInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal BrowserInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Grant specific permissions to the given origin and reject all others.
            /// </summary>
            /// <param name="origin" />
            /// <param name="permissions" />
            /// <param name="browserContextId">
            /// BrowserContext to override permissions. When omitted, default browser context is used.
            /// </param>
            /// <param name="cancellation" />
            public Task GrantPermissions
            (
                string @origin, 
                Protocol.Browser.PermissionType[] @permissions, 
                Protocol.Target.BrowserContextID @browserContextId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.GrantPermissionsCommand
                    {
                        Origin = @origin,
                        Permissions = @permissions,
                        BrowserContextId = @browserContextId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Reset all permission management for all origins.
            /// </summary>
            /// <param name="browserContextId">
            /// BrowserContext to reset permissions. When omitted, default browser context is used.
            /// </param>
            /// <param name="cancellation" />
            public Task ResetPermissions
            (
                Protocol.Target.BrowserContextID @browserContextId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.ResetPermissionsCommand
                    {
                        BrowserContextId = @browserContextId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Close browser gracefully.
            /// </summary>
            /// <param name="cancellation" />
            public Task Close
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.CloseCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Crashes browser on the main thread.
            /// </summary>
            /// <param name="cancellation" />
            public Task Crash
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.CrashCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Crashes GPU process.
            /// </summary>
            /// <param name="cancellation" />
            public Task CrashGpuProcess
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.CrashGpuProcessCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns version information.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Browser.GetVersionResponse> GetVersion
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.GetVersionCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the command line switches for the browser process if, and only if
            /// --enable-automation is on the commandline.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Browser.GetBrowserCommandLineResponse> GetBrowserCommandLine
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.GetBrowserCommandLineCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Get Chrome histograms.
            /// </summary>
            /// <param name="query">
            /// Requested substring in name. Only histograms which have query as a
            /// substring in their name are extracted. An empty or absent query returns
            /// all histograms.
            /// </param>
            /// <param name="delta">
            /// If true, retrieve delta since last call.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Browser.GetHistogramsResponse> GetHistograms
            (
                string @query = default, 
                bool? @delta = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.GetHistogramsCommand
                    {
                        Query = @query,
                        Delta = @delta,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Get a Chrome histogram by name.
            /// </summary>
            /// <param name="name">
            /// Requested histogram name.
            /// </param>
            /// <param name="delta">
            /// If true, retrieve delta since last call.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Browser.GetHistogramResponse> GetHistogram
            (
                string @name, 
                bool? @delta = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.GetHistogramCommand
                    {
                        Name = @name,
                        Delta = @delta,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Get position and size of the browser window.
            /// </summary>
            /// <param name="windowId">
            /// Browser window id.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Browser.GetWindowBoundsResponse> GetWindowBounds
            (
                Protocol.Browser.WindowID @windowId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.GetWindowBoundsCommand
                    {
                        WindowId = @windowId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Get the browser window that contains the devtools target.
            /// </summary>
            /// <param name="targetId">
            /// Devtools agent host id. If called as a part of the session, associated targetId is used.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Browser.GetWindowForTargetResponse> GetWindowForTarget
            (
                Protocol.Target.TargetID @targetId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.GetWindowForTargetCommand
                    {
                        TargetId = @targetId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Set position and/or size of the browser window.
            /// </summary>
            /// <param name="windowId">
            /// Browser window id.
            /// </param>
            /// <param name="bounds">
            /// New window bounds. The 'minimized', 'maximized' and 'fullscreen' states cannot be combined
            /// with 'left', 'top', 'width' or 'height'. Leaves unspecified fields unchanged.
            /// </param>
            /// <param name="cancellation" />
            public Task SetWindowBounds
            (
                Protocol.Browser.WindowID @windowId, 
                Protocol.Browser.Bounds @bounds, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.SetWindowBoundsCommand
                    {
                        WindowId = @windowId,
                        Bounds = @bounds,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Set dock tile details, platform-specific.
            /// </summary>
            /// <param name="badgeLabel" />
            /// <param name="image">
            /// Png encoded image.
            /// </param>
            /// <param name="cancellation" />
            public Task SetDockTile
            (
                string @badgeLabel = default, 
                string @image = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Browser.SetDockTileCommand
                    {
                        BadgeLabel = @badgeLabel,
                        Image = @image,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain CSS.
        /// </summary>
        public class CSSInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal CSSInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Inserts a new rule with the given `ruleText` in a stylesheet with given `styleSheetId`, at the
            /// position specified by `location`.
            /// </summary>
            /// <param name="styleSheetId">
            /// The css style sheet identifier where a new rule should be inserted.
            /// </param>
            /// <param name="ruleText">
            /// The text of a new rule.
            /// </param>
            /// <param name="location">
            /// Text position of a new rule in the target style sheet.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.CSS.AddRuleResponse> AddRule
            (
                Protocol.CSS.StyleSheetId @styleSheetId, 
                string @ruleText, 
                Protocol.CSS.SourceRange @location, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.AddRuleCommand
                    {
                        StyleSheetId = @styleSheetId,
                        RuleText = @ruleText,
                        Location = @location,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns all class names from specified stylesheet.
            /// </summary>
            /// <param name="styleSheetId" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.CollectClassNamesResponse> CollectClassNames
            (
                Protocol.CSS.StyleSheetId @styleSheetId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.CollectClassNamesCommand
                    {
                        StyleSheetId = @styleSheetId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Creates a new special "via-inspector" stylesheet in the frame with given `frameId`.
            /// </summary>
            /// <param name="frameId">
            /// Identifier of the frame where "via-inspector" stylesheet should be created.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.CSS.CreateStyleSheetResponse> CreateStyleSheet
            (
                Protocol.Page.FrameId @frameId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.CreateStyleSheetCommand
                    {
                        FrameId = @frameId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables the CSS agent for the given page.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables the CSS agent for the given page. Clients should not assume that the CSS agent has been
            /// enabled until the result of this command is received.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Ensures that the given node will have specified pseudo-classes whenever its style is computed by
            /// the browser.
            /// </summary>
            /// <param name="nodeId">
            /// The element id for which to force the pseudo state.
            /// </param>
            /// <param name="forcedPseudoClasses">
            /// Element pseudo classes to force when computing the element's style.
            /// </param>
            /// <param name="cancellation" />
            public Task ForcePseudoState
            (
                Protocol.DOM.NodeId @nodeId, 
                string[] @forcedPseudoClasses, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.ForcePseudoStateCommand
                    {
                        NodeId = @nodeId,
                        ForcedPseudoClasses = @forcedPseudoClasses,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="nodeId">
            /// Id of the node to get background colors for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.CSS.GetBackgroundColorsResponse> GetBackgroundColors
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.GetBackgroundColorsCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the computed style for a DOM node identified by `nodeId`.
            /// </summary>
            /// <param name="nodeId" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.GetComputedStyleForNodeResponse> GetComputedStyleForNode
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.GetComputedStyleForNodeCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the styles defined inline (explicitly in the "style" attribute and implicitly, using DOM
            /// attributes) for a DOM node identified by `nodeId`.
            /// </summary>
            /// <param name="nodeId" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.GetInlineStylesForNodeResponse> GetInlineStylesForNode
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.GetInlineStylesForNodeCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns requested styles for a DOM node identified by `nodeId`.
            /// </summary>
            /// <param name="nodeId" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.GetMatchedStylesForNodeResponse> GetMatchedStylesForNode
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.GetMatchedStylesForNodeCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns all media queries parsed by the rendering engine.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.CSS.GetMediaQueriesResponse> GetMediaQueries
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.GetMediaQueriesCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests information about platform fonts which we used to render child TextNodes in the given
            /// node.
            /// </summary>
            /// <param name="nodeId" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.GetPlatformFontsForNodeResponse> GetPlatformFontsForNode
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.GetPlatformFontsForNodeCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the current textual content for a stylesheet.
            /// </summary>
            /// <param name="styleSheetId" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.GetStyleSheetTextResponse> GetStyleSheetText
            (
                Protocol.CSS.StyleSheetId @styleSheetId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.GetStyleSheetTextCommand
                    {
                        StyleSheetId = @styleSheetId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Find a rule with the given active property for the given node and set the new value for this
            /// property
            /// </summary>
            /// <param name="nodeId">
            /// The element id for which to set property.
            /// </param>
            /// <param name="propertyName" />
            /// <param name="value" />
            /// <param name="cancellation" />
            public Task SetEffectivePropertyValueForNode
            (
                Protocol.DOM.NodeId @nodeId, 
                string @propertyName, 
                string @value, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.SetEffectivePropertyValueForNodeCommand
                    {
                        NodeId = @nodeId,
                        PropertyName = @propertyName,
                        Value = @value,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Modifies the keyframe rule key text.
            /// </summary>
            /// <param name="styleSheetId" />
            /// <param name="range" />
            /// <param name="keyText" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.SetKeyframeKeyResponse> SetKeyframeKey
            (
                Protocol.CSS.StyleSheetId @styleSheetId, 
                Protocol.CSS.SourceRange @range, 
                string @keyText, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.SetKeyframeKeyCommand
                    {
                        StyleSheetId = @styleSheetId,
                        Range = @range,
                        KeyText = @keyText,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Modifies the rule selector.
            /// </summary>
            /// <param name="styleSheetId" />
            /// <param name="range" />
            /// <param name="text" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.SetMediaTextResponse> SetMediaText
            (
                Protocol.CSS.StyleSheetId @styleSheetId, 
                Protocol.CSS.SourceRange @range, 
                string @text, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.SetMediaTextCommand
                    {
                        StyleSheetId = @styleSheetId,
                        Range = @range,
                        Text = @text,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Modifies the rule selector.
            /// </summary>
            /// <param name="styleSheetId" />
            /// <param name="range" />
            /// <param name="selector" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.SetRuleSelectorResponse> SetRuleSelector
            (
                Protocol.CSS.StyleSheetId @styleSheetId, 
                Protocol.CSS.SourceRange @range, 
                string @selector, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.SetRuleSelectorCommand
                    {
                        StyleSheetId = @styleSheetId,
                        Range = @range,
                        Selector = @selector,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets the new stylesheet text.
            /// </summary>
            /// <param name="styleSheetId" />
            /// <param name="text" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.SetStyleSheetTextResponse> SetStyleSheetText
            (
                Protocol.CSS.StyleSheetId @styleSheetId, 
                string @text, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.SetStyleSheetTextCommand
                    {
                        StyleSheetId = @styleSheetId,
                        Text = @text,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Applies specified style edits one after another in the given order.
            /// </summary>
            /// <param name="edits" />
            /// <param name="cancellation" />
            public Task<Protocol.CSS.SetStyleTextsResponse> SetStyleTexts
            (
                Protocol.CSS.StyleDeclarationEdit[] @edits, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.SetStyleTextsCommand
                    {
                        Edits = @edits,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables the selector recording.
            /// </summary>
            /// <param name="cancellation" />
            public Task StartRuleUsageTracking
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.StartRuleUsageTrackingCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Stop tracking rule usage and return the list of rules that were used since last call to
            /// `takeCoverageDelta` (or since start of coverage instrumentation)
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.CSS.StopRuleUsageTrackingResponse> StopRuleUsageTracking
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.StopRuleUsageTrackingCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Obtain list of rules that became used since last call to this method (or since start of coverage
            /// instrumentation)
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.CSS.TakeCoverageDeltaResponse> TakeCoverageDelta
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CSS.TakeCoverageDeltaCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fires whenever a web font is updated.  A non-empty font parameter indicates a successfully loaded
            /// web font
            /// </summary>
            public event Func<Protocol.CSS.FontsUpdatedEvent, Task> FontsUpdated
            {
                add => InspectorClient.AddEventHandlerCore("CSS.fontsUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("CSS.fontsUpdated", value);
            }

            /// <summary>
            /// Fires whenever a MediaQuery result changes (for example, after a browser window has been
            /// resized.) The current implementation considers only viewport-dependent media features.
            /// </summary>
            public event Func<Protocol.CSS.MediaQueryResultChangedEvent, Task> MediaQueryResultChanged
            {
                add => InspectorClient.AddEventHandlerCore("CSS.mediaQueryResultChanged", value);
                remove => InspectorClient.RemoveEventHandlerCore("CSS.mediaQueryResultChanged", value);
            }

            /// <summary>
            /// Fired whenever an active document stylesheet is added.
            /// </summary>
            public event Func<Protocol.CSS.StyleSheetAddedEvent, Task> StyleSheetAdded
            {
                add => InspectorClient.AddEventHandlerCore("CSS.styleSheetAdded", value);
                remove => InspectorClient.RemoveEventHandlerCore("CSS.styleSheetAdded", value);
            }

            /// <summary>
            /// Fired whenever a stylesheet is changed as a result of the client operation.
            /// </summary>
            public event Func<Protocol.CSS.StyleSheetChangedEvent, Task> StyleSheetChanged
            {
                add => InspectorClient.AddEventHandlerCore("CSS.styleSheetChanged", value);
                remove => InspectorClient.RemoveEventHandlerCore("CSS.styleSheetChanged", value);
            }

            /// <summary>
            /// Fired whenever an active document stylesheet is removed.
            /// </summary>
            public event Func<Protocol.CSS.StyleSheetRemovedEvent, Task> StyleSheetRemoved
            {
                add => InspectorClient.AddEventHandlerCore("CSS.styleSheetRemoved", value);
                remove => InspectorClient.RemoveEventHandlerCore("CSS.styleSheetRemoved", value);
            }

            /// <summary>
            /// Fires whenever a web font is updated.  A non-empty font parameter indicates a successfully loaded
            /// web font
            /// </summary>
            public Task<Protocol.CSS.FontsUpdatedEvent> FontsUpdatedEvent(Func<Protocol.CSS.FontsUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("CSS.fontsUpdated", until);
            }

            /// <summary>
            /// Fires whenever a MediaQuery result changes (for example, after a browser window has been
            /// resized.) The current implementation considers only viewport-dependent media features.
            /// </summary>
            public Task<Protocol.CSS.MediaQueryResultChangedEvent> MediaQueryResultChangedEvent(Func<Protocol.CSS.MediaQueryResultChangedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("CSS.mediaQueryResultChanged", until);
            }

            /// <summary>
            /// Fired whenever an active document stylesheet is added.
            /// </summary>
            public Task<Protocol.CSS.StyleSheetAddedEvent> StyleSheetAddedEvent(Func<Protocol.CSS.StyleSheetAddedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("CSS.styleSheetAdded", until);
            }

            /// <summary>
            /// Fired whenever a stylesheet is changed as a result of the client operation.
            /// </summary>
            public Task<Protocol.CSS.StyleSheetChangedEvent> StyleSheetChangedEvent(Func<Protocol.CSS.StyleSheetChangedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("CSS.styleSheetChanged", until);
            }

            /// <summary>
            /// Fired whenever an active document stylesheet is removed.
            /// </summary>
            public Task<Protocol.CSS.StyleSheetRemovedEvent> StyleSheetRemovedEvent(Func<Protocol.CSS.StyleSheetRemovedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("CSS.styleSheetRemoved", until);
            }
        }

        /// <summary>
        /// Inspector client for domain CacheStorage.
        /// </summary>
        public class CacheStorageInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal CacheStorageInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Deletes a cache.
            /// </summary>
            /// <param name="cacheId">
            /// Id of cache for deletion.
            /// </param>
            /// <param name="cancellation" />
            public Task DeleteCache
            (
                Protocol.CacheStorage.CacheId @cacheId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CacheStorage.DeleteCacheCommand
                    {
                        CacheId = @cacheId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Deletes a cache entry.
            /// </summary>
            /// <param name="cacheId">
            /// Id of cache where the entry will be deleted.
            /// </param>
            /// <param name="request">
            /// URL spec of the request.
            /// </param>
            /// <param name="cancellation" />
            public Task DeleteEntry
            (
                Protocol.CacheStorage.CacheId @cacheId, 
                string @request, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CacheStorage.DeleteEntryCommand
                    {
                        CacheId = @cacheId,
                        Request = @request,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests cache names.
            /// </summary>
            /// <param name="securityOrigin">
            /// Security origin.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.CacheStorage.RequestCacheNamesResponse> RequestCacheNames
            (
                string @securityOrigin, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CacheStorage.RequestCacheNamesCommand
                    {
                        SecurityOrigin = @securityOrigin,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fetches cache entry.
            /// </summary>
            /// <param name="cacheId">
            /// Id of cache that contains the entry.
            /// </param>
            /// <param name="requestURL">
            /// URL spec of the request.
            /// </param>
            /// <param name="requestHeaders">
            /// headers of the request.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.CacheStorage.RequestCachedResponseResponse> RequestCachedResponse
            (
                Protocol.CacheStorage.CacheId @cacheId, 
                string @requestURL, 
                Protocol.CacheStorage.Header[] @requestHeaders, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CacheStorage.RequestCachedResponseCommand
                    {
                        CacheId = @cacheId,
                        RequestURL = @requestURL,
                        RequestHeaders = @requestHeaders,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests data from cache.
            /// </summary>
            /// <param name="cacheId">
            /// ID of cache to get entries from.
            /// </param>
            /// <param name="skipCount">
            /// Number of records to skip.
            /// </param>
            /// <param name="pageSize">
            /// Number of records to fetch.
            /// </param>
            /// <param name="pathFilter">
            /// If present, only return the entries containing this substring in the path
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.CacheStorage.RequestEntriesResponse> RequestEntries
            (
                Protocol.CacheStorage.CacheId @cacheId, 
                long @skipCount, 
                long @pageSize, 
                string @pathFilter = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.CacheStorage.RequestEntriesCommand
                    {
                        CacheId = @cacheId,
                        SkipCount = @skipCount,
                        PageSize = @pageSize,
                        PathFilter = @pathFilter,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Cast.
        /// </summary>
        public class CastInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal CastInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Starts observing for sinks that can be used for tab mirroring, and if set,
            /// sinks compatible with |presentationUrl| as well. When sinks are found, a
            /// |sinksUpdated| event is fired.
            /// Also starts observing for issue messages. When an issue is added or removed,
            /// an |issueUpdated| event is fired.
            /// </summary>
            /// <param name="presentationUrl" />
            /// <param name="cancellation" />
            public Task Enable
            (
                string @presentationUrl = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Cast.EnableCommand
                    {
                        PresentationUrl = @presentationUrl,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Stops observing for sinks and issues.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Cast.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets a sink to be used when the web page requests the browser to choose a
            /// sink via Presentation API, Remote Playback API, or Cast SDK.
            /// </summary>
            /// <param name="sinkName" />
            /// <param name="cancellation" />
            public Task SetSinkToUse
            (
                string @sinkName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Cast.SetSinkToUseCommand
                    {
                        SinkName = @sinkName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Starts mirroring the tab to the sink.
            /// </summary>
            /// <param name="sinkName" />
            /// <param name="cancellation" />
            public Task StartTabMirroring
            (
                string @sinkName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Cast.StartTabMirroringCommand
                    {
                        SinkName = @sinkName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Stops the active Cast session on the sink.
            /// </summary>
            /// <param name="sinkName" />
            /// <param name="cancellation" />
            public Task StopCasting
            (
                string @sinkName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Cast.StopCastingCommand
                    {
                        SinkName = @sinkName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// This is fired whenever the list of available sinks changes. A sink is a
            /// device or a software surface that you can cast to.
            /// </summary>
            public event Func<Protocol.Cast.SinksUpdatedEvent, Task> SinksUpdated
            {
                add => InspectorClient.AddEventHandlerCore("Cast.sinksUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Cast.sinksUpdated", value);
            }

            /// <summary>
            /// This is fired whenever the outstanding issue/error message changes.
            /// |issueMessage| is empty if there is no issue.
            /// </summary>
            public event Func<Protocol.Cast.IssueUpdatedEvent, Task> IssueUpdated
            {
                add => InspectorClient.AddEventHandlerCore("Cast.issueUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Cast.issueUpdated", value);
            }

            /// <summary>
            /// This is fired whenever the list of available sinks changes. A sink is a
            /// device or a software surface that you can cast to.
            /// </summary>
            public Task<Protocol.Cast.SinksUpdatedEvent> SinksUpdatedEvent(Func<Protocol.Cast.SinksUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Cast.sinksUpdated", until);
            }

            /// <summary>
            /// This is fired whenever the outstanding issue/error message changes.
            /// |issueMessage| is empty if there is no issue.
            /// </summary>
            public Task<Protocol.Cast.IssueUpdatedEvent> IssueUpdatedEvent(Func<Protocol.Cast.IssueUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Cast.issueUpdated", until);
            }
        }

        /// <summary>
        /// Inspector client for domain DOM.
        /// </summary>
        public class DOMInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal DOMInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Collects class names for the node with given id and all of it's child nodes.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to collect class names.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.CollectClassNamesFromSubtreeResponse> CollectClassNamesFromSubtree
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.CollectClassNamesFromSubtreeCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Creates a deep copy of the specified node and places it into the target container before the
            /// given anchor.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to copy.
            /// </param>
            /// <param name="targetNodeId">
            /// Id of the element to drop the copy into.
            /// </param>
            /// <param name="insertBeforeNodeId">
            /// Drop the copy before this node (if absent, the copy becomes the last child of
            /// `targetNodeId`).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.CopyToResponse> CopyTo
            (
                Protocol.DOM.NodeId @nodeId, 
                Protocol.DOM.NodeId @targetNodeId, 
                Protocol.DOM.NodeId @insertBeforeNodeId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.CopyToCommand
                    {
                        NodeId = @nodeId,
                        TargetNodeId = @targetNodeId,
                        InsertBeforeNodeId = @insertBeforeNodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Describes node given its id, does not require domain to be enabled. Does not start tracking any
            /// objects, can be used for automation.
            /// </summary>
            /// <param name="nodeId">
            /// Identifier of the node.
            /// </param>
            /// <param name="backendNodeId">
            /// Identifier of the backend node.
            /// </param>
            /// <param name="objectId">
            /// JavaScript object id of the node wrapper.
            /// </param>
            /// <param name="depth">
            /// The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
            /// entire subtree or provide an integer larger than 0.
            /// </param>
            /// <param name="pierce">
            /// Whether or not iframes and shadow roots should be traversed when returning the subtree
            /// (default is false).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.DescribeNodeResponse> DescribeNode
            (
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                long? @depth = default, 
                bool? @pierce = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.DescribeNodeCommand
                    {
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectId = @objectId,
                        Depth = @depth,
                        Pierce = @pierce,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables DOM agent for the given page.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Discards search results from the session with the given id. `getSearchResults` should no longer
            /// be called for that search.
            /// </summary>
            /// <param name="searchId">
            /// Unique search session identifier.
            /// </param>
            /// <param name="cancellation" />
            public Task DiscardSearchResults
            (
                string @searchId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.DiscardSearchResultsCommand
                    {
                        SearchId = @searchId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables DOM agent for the given page.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Focuses the given element.
            /// </summary>
            /// <param name="nodeId">
            /// Identifier of the node.
            /// </param>
            /// <param name="backendNodeId">
            /// Identifier of the backend node.
            /// </param>
            /// <param name="objectId">
            /// JavaScript object id of the node wrapper.
            /// </param>
            /// <param name="cancellation" />
            public Task Focus
            (
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.FocusCommand
                    {
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns attributes for the specified node.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to retrieve attibutes for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetAttributesResponse> GetAttributes
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetAttributesCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns boxes for the given node.
            /// </summary>
            /// <param name="nodeId">
            /// Identifier of the node.
            /// </param>
            /// <param name="backendNodeId">
            /// Identifier of the backend node.
            /// </param>
            /// <param name="objectId">
            /// JavaScript object id of the node wrapper.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetBoxModelResponse> GetBoxModel
            (
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetBoxModelCommand
                    {
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns quads that describe node position on the page. This method
            /// might return multiple quads for inline nodes.
            /// </summary>
            /// <param name="nodeId">
            /// Identifier of the node.
            /// </param>
            /// <param name="backendNodeId">
            /// Identifier of the backend node.
            /// </param>
            /// <param name="objectId">
            /// JavaScript object id of the node wrapper.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetContentQuadsResponse> GetContentQuads
            (
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetContentQuadsCommand
                    {
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the root DOM node (and optionally the subtree) to the caller.
            /// </summary>
            /// <param name="depth">
            /// The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
            /// entire subtree or provide an integer larger than 0.
            /// </param>
            /// <param name="pierce">
            /// Whether or not iframes and shadow roots should be traversed when returning the subtree
            /// (default is false).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetDocumentResponse> GetDocument
            (
                long? @depth = default, 
                bool? @pierce = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetDocumentCommand
                    {
                        Depth = @depth,
                        Pierce = @pierce,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the root DOM node (and optionally the subtree) to the caller.
            /// </summary>
            /// <param name="depth">
            /// The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
            /// entire subtree or provide an integer larger than 0.
            /// </param>
            /// <param name="pierce">
            /// Whether or not iframes and shadow roots should be traversed when returning the subtree
            /// (default is false).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetFlattenedDocumentResponse> GetFlattenedDocument
            (
                long? @depth = default, 
                bool? @pierce = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetFlattenedDocumentCommand
                    {
                        Depth = @depth,
                        Pierce = @pierce,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns node id at given location. Depending on whether DOM domain is enabled, nodeId is
            /// either returned or not.
            /// </summary>
            /// <param name="x">
            /// X coordinate.
            /// </param>
            /// <param name="y">
            /// Y coordinate.
            /// </param>
            /// <param name="includeUserAgentShadowDOM">
            /// False to skip to the nearest non-UA shadow root ancestor (default: false).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetNodeForLocationResponse> GetNodeForLocation
            (
                long @x, 
                long @y, 
                bool? @includeUserAgentShadowDOM = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetNodeForLocationCommand
                    {
                        X = @x,
                        Y = @y,
                        IncludeUserAgentShadowDOM = @includeUserAgentShadowDOM,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns node's HTML markup.
            /// </summary>
            /// <param name="nodeId">
            /// Identifier of the node.
            /// </param>
            /// <param name="backendNodeId">
            /// Identifier of the backend node.
            /// </param>
            /// <param name="objectId">
            /// JavaScript object id of the node wrapper.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetOuterHTMLResponse> GetOuterHTML
            (
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetOuterHTMLCommand
                    {
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the id of the nearest ancestor that is a relayout boundary.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetRelayoutBoundaryResponse> GetRelayoutBoundary
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetRelayoutBoundaryCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns search results from given `fromIndex` to given `toIndex` from the search with the given
            /// identifier.
            /// </summary>
            /// <param name="searchId">
            /// Unique search session identifier.
            /// </param>
            /// <param name="fromIndex">
            /// Start index of the search result to be returned.
            /// </param>
            /// <param name="toIndex">
            /// End index of the search result to be returned.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetSearchResultsResponse> GetSearchResults
            (
                string @searchId, 
                long @fromIndex, 
                long @toIndex, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetSearchResultsCommand
                    {
                        SearchId = @searchId,
                        FromIndex = @fromIndex,
                        ToIndex = @toIndex,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Hides any highlight.
            /// </summary>
            /// <param name="cancellation" />
            public Task HideHighlight
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.HideHighlightCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Highlights DOM node.
            /// </summary>
            /// <param name="cancellation" />
            public Task HighlightNode
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.HighlightNodeCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Highlights given rectangle.
            /// </summary>
            /// <param name="cancellation" />
            public Task HighlightRect
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.HighlightRectCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Marks last undoable state.
            /// </summary>
            /// <param name="cancellation" />
            public Task MarkUndoableState
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.MarkUndoableStateCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Moves node into the new container, places it before the given anchor.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to move.
            /// </param>
            /// <param name="targetNodeId">
            /// Id of the element to drop the moved node into.
            /// </param>
            /// <param name="insertBeforeNodeId">
            /// Drop node before this one (if absent, the moved node becomes the last child of
            /// `targetNodeId`).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.MoveToResponse> MoveTo
            (
                Protocol.DOM.NodeId @nodeId, 
                Protocol.DOM.NodeId @targetNodeId, 
                Protocol.DOM.NodeId @insertBeforeNodeId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.MoveToCommand
                    {
                        NodeId = @nodeId,
                        TargetNodeId = @targetNodeId,
                        InsertBeforeNodeId = @insertBeforeNodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Searches for a given string in the DOM tree. Use `getSearchResults` to access search results or
            /// `cancelSearch` to end this search session.
            /// </summary>
            /// <param name="query">
            /// Plain text or query selector or XPath search query.
            /// </param>
            /// <param name="includeUserAgentShadowDOM">
            /// True to search in user agent shadow DOM.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.PerformSearchResponse> PerformSearch
            (
                string @query, 
                bool? @includeUserAgentShadowDOM = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.PerformSearchCommand
                    {
                        Query = @query,
                        IncludeUserAgentShadowDOM = @includeUserAgentShadowDOM,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that the node is sent to the caller given its path. // FIXME, use XPath
            /// </summary>
            /// <param name="path">
            /// Path to node in the proprietary format.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.PushNodeByPathToFrontendResponse> PushNodeByPathToFrontend
            (
                string @path, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.PushNodeByPathToFrontendCommand
                    {
                        Path = @path,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that a batch of nodes is sent to the caller given their backend node ids.
            /// </summary>
            /// <param name="backendNodeIds">
            /// The array of backend node ids.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.PushNodesByBackendIdsToFrontendResponse> PushNodesByBackendIdsToFrontend
            (
                Protocol.DOM.BackendNodeId[] @backendNodeIds, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.PushNodesByBackendIdsToFrontendCommand
                    {
                        BackendNodeIds = @backendNodeIds,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Executes `querySelector` on a given node.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to query upon.
            /// </param>
            /// <param name="selector">
            /// Selector string.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.QuerySelectorResponse> QuerySelector
            (
                Protocol.DOM.NodeId @nodeId, 
                string @selector, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.QuerySelectorCommand
                    {
                        NodeId = @nodeId,
                        Selector = @selector,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Executes `querySelectorAll` on a given node.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to query upon.
            /// </param>
            /// <param name="selector">
            /// Selector string.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.QuerySelectorAllResponse> QuerySelectorAll
            (
                Protocol.DOM.NodeId @nodeId, 
                string @selector, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.QuerySelectorAllCommand
                    {
                        NodeId = @nodeId,
                        Selector = @selector,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Re-does the last undone action.
            /// </summary>
            /// <param name="cancellation" />
            public Task Redo
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.RedoCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Removes attribute with given name from an element with given id.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the element to remove attribute from.
            /// </param>
            /// <param name="name">
            /// Name of the attribute to remove.
            /// </param>
            /// <param name="cancellation" />
            public Task RemoveAttribute
            (
                Protocol.DOM.NodeId @nodeId, 
                string @name, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.RemoveAttributeCommand
                    {
                        NodeId = @nodeId,
                        Name = @name,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Removes node with given id.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to remove.
            /// </param>
            /// <param name="cancellation" />
            public Task RemoveNode
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.RemoveNodeCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that children of the node with given id are returned to the caller in form of
            /// `setChildNodes` events where not only immediate children are retrieved, but all children down to
            /// the specified depth.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to get children for.
            /// </param>
            /// <param name="depth">
            /// The maximum depth at which children should be retrieved, defaults to 1. Use -1 for the
            /// entire subtree or provide an integer larger than 0.
            /// </param>
            /// <param name="pierce">
            /// Whether or not iframes and shadow roots should be traversed when returning the sub-tree
            /// (default is false).
            /// </param>
            /// <param name="cancellation" />
            public Task RequestChildNodes
            (
                Protocol.DOM.NodeId @nodeId, 
                long? @depth = default, 
                bool? @pierce = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.RequestChildNodesCommand
                    {
                        NodeId = @nodeId,
                        Depth = @depth,
                        Pierce = @pierce,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that the node is sent to the caller given the JavaScript node object reference. All
            /// nodes that form the path from the node to the root are also sent to the client as a series of
            /// `setChildNodes` notifications.
            /// </summary>
            /// <param name="objectId">
            /// JavaScript object id to convert into node.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.RequestNodeResponse> RequestNode
            (
                Protocol.Runtime.RemoteObjectId @objectId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.RequestNodeCommand
                    {
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Resolves the JavaScript node object for a given NodeId or BackendNodeId.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to resolve.
            /// </param>
            /// <param name="backendNodeId">
            /// Backend identifier of the node to resolve.
            /// </param>
            /// <param name="objectGroup">
            /// Symbolic group name that can be used to release multiple objects.
            /// </param>
            /// <param name="executionContextId">
            /// Execution context in which to resolve the node.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.ResolveNodeResponse> ResolveNode
            (
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                string @objectGroup = default, 
                Protocol.Runtime.ExecutionContextId @executionContextId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.ResolveNodeCommand
                    {
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectGroup = @objectGroup,
                        ExecutionContextId = @executionContextId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets attribute for an element with given id.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the element to set attribute for.
            /// </param>
            /// <param name="name">
            /// Attribute name.
            /// </param>
            /// <param name="value">
            /// Attribute value.
            /// </param>
            /// <param name="cancellation" />
            public Task SetAttributeValue
            (
                Protocol.DOM.NodeId @nodeId, 
                string @name, 
                string @value, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.SetAttributeValueCommand
                    {
                        NodeId = @nodeId,
                        Name = @name,
                        Value = @value,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets attributes on element with given id. This method is useful when user edits some existing
            /// attribute value and types in several attribute name/value pairs.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the element to set attributes for.
            /// </param>
            /// <param name="text">
            /// Text with a number of attributes. Will parse this text using HTML parser.
            /// </param>
            /// <param name="name">
            /// Attribute name to replace with new attributes derived from text in case text parsed
            /// successfully.
            /// </param>
            /// <param name="cancellation" />
            public Task SetAttributesAsText
            (
                Protocol.DOM.NodeId @nodeId, 
                string @text, 
                string @name = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.SetAttributesAsTextCommand
                    {
                        NodeId = @nodeId,
                        Text = @text,
                        Name = @name,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets files for the given file input element.
            /// </summary>
            /// <param name="files">
            /// Array of file paths to set.
            /// </param>
            /// <param name="nodeId">
            /// Identifier of the node.
            /// </param>
            /// <param name="backendNodeId">
            /// Identifier of the backend node.
            /// </param>
            /// <param name="objectId">
            /// JavaScript object id of the node wrapper.
            /// </param>
            /// <param name="cancellation" />
            public Task SetFileInputFiles
            (
                string[] @files, 
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.SetFileInputFilesCommand
                    {
                        Files = @files,
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns file information for the given
            /// File wrapper.
            /// </summary>
            /// <param name="objectId">
            /// JavaScript object id of the node wrapper.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetFileInfoResponse> GetFileInfo
            (
                Protocol.Runtime.RemoteObjectId @objectId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetFileInfoCommand
                    {
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables console to refer to the node with given id via $x (see Command Line API for more details
            /// $x functions).
            /// </summary>
            /// <param name="nodeId">
            /// DOM node id to be accessible by means of $x command line API.
            /// </param>
            /// <param name="cancellation" />
            public Task SetInspectedNode
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.SetInspectedNodeCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets node name for a node with given id.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to set name for.
            /// </param>
            /// <param name="name">
            /// New node's name.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOM.SetNodeNameResponse> SetNodeName
            (
                Protocol.DOM.NodeId @nodeId, 
                string @name, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.SetNodeNameCommand
                    {
                        NodeId = @nodeId,
                        Name = @name,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets node value for a node with given id.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to set value for.
            /// </param>
            /// <param name="value">
            /// New node's value.
            /// </param>
            /// <param name="cancellation" />
            public Task SetNodeValue
            (
                Protocol.DOM.NodeId @nodeId, 
                string @value, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.SetNodeValueCommand
                    {
                        NodeId = @nodeId,
                        Value = @value,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets node HTML markup, returns new node id.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to set markup for.
            /// </param>
            /// <param name="outerHTML">
            /// Outer HTML markup to set.
            /// </param>
            /// <param name="cancellation" />
            public Task SetOuterHTML
            (
                Protocol.DOM.NodeId @nodeId, 
                string @outerHTML, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.SetOuterHTMLCommand
                    {
                        NodeId = @nodeId,
                        OuterHTML = @outerHTML,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Undoes the last performed action.
            /// </summary>
            /// <param name="cancellation" />
            public Task Undo
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.UndoCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns iframe node that owns iframe with the given domain.
            /// </summary>
            /// <param name="frameId" />
            /// <param name="cancellation" />
            public Task<Protocol.DOM.GetFrameOwnerResponse> GetFrameOwner
            (
                Protocol.Page.FrameId @frameId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOM.GetFrameOwnerCommand
                    {
                        FrameId = @frameId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fired when `Element`'s attribute is modified.
            /// </summary>
            public event Func<Protocol.DOM.AttributeModifiedEvent, Task> AttributeModified
            {
                add => InspectorClient.AddEventHandlerCore("DOM.attributeModified", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.attributeModified", value);
            }

            /// <summary>
            /// Fired when `Element`'s attribute is removed.
            /// </summary>
            public event Func<Protocol.DOM.AttributeRemovedEvent, Task> AttributeRemoved
            {
                add => InspectorClient.AddEventHandlerCore("DOM.attributeRemoved", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.attributeRemoved", value);
            }

            /// <summary>
            /// Mirrors `DOMCharacterDataModified` event.
            /// </summary>
            public event Func<Protocol.DOM.CharacterDataModifiedEvent, Task> CharacterDataModified
            {
                add => InspectorClient.AddEventHandlerCore("DOM.characterDataModified", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.characterDataModified", value);
            }

            /// <summary>
            /// Fired when `Container`'s child node count has changed.
            /// </summary>
            public event Func<Protocol.DOM.ChildNodeCountUpdatedEvent, Task> ChildNodeCountUpdated
            {
                add => InspectorClient.AddEventHandlerCore("DOM.childNodeCountUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.childNodeCountUpdated", value);
            }

            /// <summary>
            /// Mirrors `DOMNodeInserted` event.
            /// </summary>
            public event Func<Protocol.DOM.ChildNodeInsertedEvent, Task> ChildNodeInserted
            {
                add => InspectorClient.AddEventHandlerCore("DOM.childNodeInserted", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.childNodeInserted", value);
            }

            /// <summary>
            /// Mirrors `DOMNodeRemoved` event.
            /// </summary>
            public event Func<Protocol.DOM.ChildNodeRemovedEvent, Task> ChildNodeRemoved
            {
                add => InspectorClient.AddEventHandlerCore("DOM.childNodeRemoved", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.childNodeRemoved", value);
            }

            /// <summary>
            /// Called when distrubution is changed.
            /// </summary>
            public event Func<Protocol.DOM.DistributedNodesUpdatedEvent, Task> DistributedNodesUpdated
            {
                add => InspectorClient.AddEventHandlerCore("DOM.distributedNodesUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.distributedNodesUpdated", value);
            }

            /// <summary>
            /// Fired when `Document` has been totally updated. Node ids are no longer valid.
            /// </summary>
            public event Func<Protocol.DOM.DocumentUpdatedEvent, Task> DocumentUpdated
            {
                add => InspectorClient.AddEventHandlerCore("DOM.documentUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.documentUpdated", value);
            }

            /// <summary>
            /// Fired when `Element`'s inline style is modified via a CSS property modification.
            /// </summary>
            public event Func<Protocol.DOM.InlineStyleInvalidatedEvent, Task> InlineStyleInvalidated
            {
                add => InspectorClient.AddEventHandlerCore("DOM.inlineStyleInvalidated", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.inlineStyleInvalidated", value);
            }

            /// <summary>
            /// Called when a pseudo element is added to an element.
            /// </summary>
            public event Func<Protocol.DOM.PseudoElementAddedEvent, Task> PseudoElementAdded
            {
                add => InspectorClient.AddEventHandlerCore("DOM.pseudoElementAdded", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.pseudoElementAdded", value);
            }

            /// <summary>
            /// Called when a pseudo element is removed from an element.
            /// </summary>
            public event Func<Protocol.DOM.PseudoElementRemovedEvent, Task> PseudoElementRemoved
            {
                add => InspectorClient.AddEventHandlerCore("DOM.pseudoElementRemoved", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.pseudoElementRemoved", value);
            }

            /// <summary>
            /// Fired when backend wants to provide client with the missing DOM structure. This happens upon
            /// most of the calls requesting node ids.
            /// </summary>
            public event Func<Protocol.DOM.SetChildNodesEvent, Task> SetChildNodes
            {
                add => InspectorClient.AddEventHandlerCore("DOM.setChildNodes", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.setChildNodes", value);
            }

            /// <summary>
            /// Called when shadow root is popped from the element.
            /// </summary>
            public event Func<Protocol.DOM.ShadowRootPoppedEvent, Task> ShadowRootPopped
            {
                add => InspectorClient.AddEventHandlerCore("DOM.shadowRootPopped", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.shadowRootPopped", value);
            }

            /// <summary>
            /// Called when shadow root is pushed into the element.
            /// </summary>
            public event Func<Protocol.DOM.ShadowRootPushedEvent, Task> ShadowRootPushed
            {
                add => InspectorClient.AddEventHandlerCore("DOM.shadowRootPushed", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOM.shadowRootPushed", value);
            }

            /// <summary>
            /// Fired when `Element`'s attribute is modified.
            /// </summary>
            public Task<Protocol.DOM.AttributeModifiedEvent> AttributeModifiedEvent(Func<Protocol.DOM.AttributeModifiedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.attributeModified", until);
            }

            /// <summary>
            /// Fired when `Element`'s attribute is removed.
            /// </summary>
            public Task<Protocol.DOM.AttributeRemovedEvent> AttributeRemovedEvent(Func<Protocol.DOM.AttributeRemovedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.attributeRemoved", until);
            }

            /// <summary>
            /// Mirrors `DOMCharacterDataModified` event.
            /// </summary>
            public Task<Protocol.DOM.CharacterDataModifiedEvent> CharacterDataModifiedEvent(Func<Protocol.DOM.CharacterDataModifiedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.characterDataModified", until);
            }

            /// <summary>
            /// Fired when `Container`'s child node count has changed.
            /// </summary>
            public Task<Protocol.DOM.ChildNodeCountUpdatedEvent> ChildNodeCountUpdatedEvent(Func<Protocol.DOM.ChildNodeCountUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.childNodeCountUpdated", until);
            }

            /// <summary>
            /// Mirrors `DOMNodeInserted` event.
            /// </summary>
            public Task<Protocol.DOM.ChildNodeInsertedEvent> ChildNodeInsertedEvent(Func<Protocol.DOM.ChildNodeInsertedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.childNodeInserted", until);
            }

            /// <summary>
            /// Mirrors `DOMNodeRemoved` event.
            /// </summary>
            public Task<Protocol.DOM.ChildNodeRemovedEvent> ChildNodeRemovedEvent(Func<Protocol.DOM.ChildNodeRemovedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.childNodeRemoved", until);
            }

            /// <summary>
            /// Called when distrubution is changed.
            /// </summary>
            public Task<Protocol.DOM.DistributedNodesUpdatedEvent> DistributedNodesUpdatedEvent(Func<Protocol.DOM.DistributedNodesUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.distributedNodesUpdated", until);
            }

            /// <summary>
            /// Fired when `Document` has been totally updated. Node ids are no longer valid.
            /// </summary>
            public Task<Protocol.DOM.DocumentUpdatedEvent> DocumentUpdatedEvent(Func<Protocol.DOM.DocumentUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.documentUpdated", until);
            }

            /// <summary>
            /// Fired when `Element`'s inline style is modified via a CSS property modification.
            /// </summary>
            public Task<Protocol.DOM.InlineStyleInvalidatedEvent> InlineStyleInvalidatedEvent(Func<Protocol.DOM.InlineStyleInvalidatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.inlineStyleInvalidated", until);
            }

            /// <summary>
            /// Called when a pseudo element is added to an element.
            /// </summary>
            public Task<Protocol.DOM.PseudoElementAddedEvent> PseudoElementAddedEvent(Func<Protocol.DOM.PseudoElementAddedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.pseudoElementAdded", until);
            }

            /// <summary>
            /// Called when a pseudo element is removed from an element.
            /// </summary>
            public Task<Protocol.DOM.PseudoElementRemovedEvent> PseudoElementRemovedEvent(Func<Protocol.DOM.PseudoElementRemovedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.pseudoElementRemoved", until);
            }

            /// <summary>
            /// Fired when backend wants to provide client with the missing DOM structure. This happens upon
            /// most of the calls requesting node ids.
            /// </summary>
            public Task<Protocol.DOM.SetChildNodesEvent> SetChildNodesEvent(Func<Protocol.DOM.SetChildNodesEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.setChildNodes", until);
            }

            /// <summary>
            /// Called when shadow root is popped from the element.
            /// </summary>
            public Task<Protocol.DOM.ShadowRootPoppedEvent> ShadowRootPoppedEvent(Func<Protocol.DOM.ShadowRootPoppedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.shadowRootPopped", until);
            }

            /// <summary>
            /// Called when shadow root is pushed into the element.
            /// </summary>
            public Task<Protocol.DOM.ShadowRootPushedEvent> ShadowRootPushedEvent(Func<Protocol.DOM.ShadowRootPushedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOM.shadowRootPushed", until);
            }
        }

        /// <summary>
        /// Inspector client for domain DOMDebugger.
        /// </summary>
        public class DOMDebuggerInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal DOMDebuggerInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Returns event listeners of the given object.
            /// </summary>
            /// <param name="objectId">
            /// Identifier of the object to return listeners for.
            /// </param>
            /// <param name="depth">
            /// The maximum depth at which Node children should be retrieved, defaults to 1. Use -1 for the
            /// entire subtree or provide an integer larger than 0.
            /// </param>
            /// <param name="pierce">
            /// Whether or not iframes and shadow roots should be traversed when returning the subtree
            /// (default is false). Reports listeners for all contexts if pierce is enabled.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOMDebugger.GetEventListenersResponse> GetEventListeners
            (
                Protocol.Runtime.RemoteObjectId @objectId, 
                long? @depth = default, 
                bool? @pierce = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.GetEventListenersCommand
                    {
                        ObjectId = @objectId,
                        Depth = @depth,
                        Pierce = @pierce,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Removes DOM breakpoint that was set using `setDOMBreakpoint`.
            /// </summary>
            /// <param name="nodeId">
            /// Identifier of the node to remove breakpoint from.
            /// </param>
            /// <param name="type">
            /// Type of the breakpoint to remove.
            /// </param>
            /// <param name="cancellation" />
            public Task RemoveDOMBreakpoint
            (
                Protocol.DOM.NodeId @nodeId, 
                Protocol.DOMDebugger.DOMBreakpointType @type, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.RemoveDOMBreakpointCommand
                    {
                        NodeId = @nodeId,
                        Type = @type,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Removes breakpoint on particular DOM event.
            /// </summary>
            /// <param name="eventName">
            /// Event name.
            /// </param>
            /// <param name="targetName">
            /// EventTarget interface name.
            /// </param>
            /// <param name="cancellation" />
            public Task RemoveEventListenerBreakpoint
            (
                string @eventName, 
                string @targetName = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.RemoveEventListenerBreakpointCommand
                    {
                        EventName = @eventName,
                        TargetName = @targetName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Removes breakpoint on particular native event.
            /// </summary>
            /// <param name="eventName">
            /// Instrumentation name to stop on.
            /// </param>
            /// <param name="cancellation" />
            public Task RemoveInstrumentationBreakpoint
            (
                string @eventName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.RemoveInstrumentationBreakpointCommand
                    {
                        EventName = @eventName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Removes breakpoint from XMLHttpRequest.
            /// </summary>
            /// <param name="url">
            /// Resource URL substring.
            /// </param>
            /// <param name="cancellation" />
            public Task RemoveXHRBreakpoint
            (
                string @url, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.RemoveXHRBreakpointCommand
                    {
                        Url = @url,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets breakpoint on particular operation with DOM.
            /// </summary>
            /// <param name="nodeId">
            /// Identifier of the node to set breakpoint on.
            /// </param>
            /// <param name="type">
            /// Type of the operation to stop upon.
            /// </param>
            /// <param name="cancellation" />
            public Task SetDOMBreakpoint
            (
                Protocol.DOM.NodeId @nodeId, 
                Protocol.DOMDebugger.DOMBreakpointType @type, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.SetDOMBreakpointCommand
                    {
                        NodeId = @nodeId,
                        Type = @type,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets breakpoint on particular DOM event.
            /// </summary>
            /// <param name="eventName">
            /// DOM Event name to stop on (any DOM event will do).
            /// </param>
            /// <param name="targetName">
            /// EventTarget interface name to stop on. If equal to `"*"` or not provided, will stop on any
            /// EventTarget.
            /// </param>
            /// <param name="cancellation" />
            public Task SetEventListenerBreakpoint
            (
                string @eventName, 
                string @targetName = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.SetEventListenerBreakpointCommand
                    {
                        EventName = @eventName,
                        TargetName = @targetName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets breakpoint on particular native event.
            /// </summary>
            /// <param name="eventName">
            /// Instrumentation name to stop on.
            /// </param>
            /// <param name="cancellation" />
            public Task SetInstrumentationBreakpoint
            (
                string @eventName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.SetInstrumentationBreakpointCommand
                    {
                        EventName = @eventName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets breakpoint on XMLHttpRequest.
            /// </summary>
            /// <param name="url">
            /// Resource URL substring. All XHRs having this substring in the URL will get stopped upon.
            /// </param>
            /// <param name="cancellation" />
            public Task SetXHRBreakpoint
            (
                string @url, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMDebugger.SetXHRBreakpointCommand
                    {
                        Url = @url,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain DOMSnapshot.
        /// </summary>
        public class DOMSnapshotInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal DOMSnapshotInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disables DOM snapshot agent for the given page.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMSnapshot.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables DOM snapshot agent for the given page.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMSnapshot.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns a document snapshot, including the full DOM tree of the root node (including iframes,
            /// template contents, and imported documents) in a flattened array, as well as layout and
            /// white-listed computed style information for the nodes. Shadow DOM in the returned DOM tree is
            /// flattened.
            /// </summary>
            /// <param name="computedStyleWhitelist">
            /// Whitelist of computed styles to return.
            /// </param>
            /// <param name="includeEventListeners">
            /// Whether or not to retrieve details of DOM listeners (default false).
            /// </param>
            /// <param name="includePaintOrder">
            /// Whether to determine and include the paint order index of LayoutTreeNodes (default false).
            /// </param>
            /// <param name="includeUserAgentShadowTree">
            /// Whether to include UA shadow tree in the snapshot (default false).
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task<Protocol.DOMSnapshot.GetSnapshotResponse> GetSnapshot
            (
                string[] @computedStyleWhitelist, 
                bool? @includeEventListeners = default, 
                bool? @includePaintOrder = default, 
                bool? @includeUserAgentShadowTree = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMSnapshot.GetSnapshotCommand
                    {
                        ComputedStyleWhitelist = @computedStyleWhitelist,
                        IncludeEventListeners = @includeEventListeners,
                        IncludePaintOrder = @includePaintOrder,
                        IncludeUserAgentShadowTree = @includeUserAgentShadowTree,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns a document snapshot, including the full DOM tree of the root node (including iframes,
            /// template contents, and imported documents) in a flattened array, as well as layout and
            /// white-listed computed style information for the nodes. Shadow DOM in the returned DOM tree is
            /// flattened.
            /// </summary>
            /// <param name="computedStyles">
            /// Whitelist of computed styles to return.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.DOMSnapshot.CaptureSnapshotResponse> CaptureSnapshot
            (
                string[] @computedStyles, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMSnapshot.CaptureSnapshotCommand
                    {
                        ComputedStyles = @computedStyles,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain DOMStorage.
        /// </summary>
        public class DOMStorageInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal DOMStorageInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary />
            /// <param name="storageId" />
            /// <param name="cancellation" />
            public Task Clear
            (
                Protocol.DOMStorage.StorageId @storageId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMStorage.ClearCommand
                    {
                        StorageId = @storageId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables storage tracking, prevents storage events from being sent to the client.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMStorage.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables storage tracking, storage events will now be delivered to the client.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMStorage.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="storageId" />
            /// <param name="cancellation" />
            public Task<Protocol.DOMStorage.GetDOMStorageItemsResponse> GetDOMStorageItems
            (
                Protocol.DOMStorage.StorageId @storageId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMStorage.GetDOMStorageItemsCommand
                    {
                        StorageId = @storageId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="storageId" />
            /// <param name="key" />
            /// <param name="cancellation" />
            public Task RemoveDOMStorageItem
            (
                Protocol.DOMStorage.StorageId @storageId, 
                string @key, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMStorage.RemoveDOMStorageItemCommand
                    {
                        StorageId = @storageId,
                        Key = @key,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="storageId" />
            /// <param name="key" />
            /// <param name="value" />
            /// <param name="cancellation" />
            public Task SetDOMStorageItem
            (
                Protocol.DOMStorage.StorageId @storageId, 
                string @key, 
                string @value, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DOMStorage.SetDOMStorageItemCommand
                    {
                        StorageId = @storageId,
                        Key = @key,
                        Value = @value,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.DOMStorage.DomStorageItemAddedEvent, Task> DomStorageItemAdded
            {
                add => InspectorClient.AddEventHandlerCore("DOMStorage.domStorageItemAdded", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOMStorage.domStorageItemAdded", value);
            }

            /// <summary />
            public event Func<Protocol.DOMStorage.DomStorageItemRemovedEvent, Task> DomStorageItemRemoved
            {
                add => InspectorClient.AddEventHandlerCore("DOMStorage.domStorageItemRemoved", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOMStorage.domStorageItemRemoved", value);
            }

            /// <summary />
            public event Func<Protocol.DOMStorage.DomStorageItemUpdatedEvent, Task> DomStorageItemUpdated
            {
                add => InspectorClient.AddEventHandlerCore("DOMStorage.domStorageItemUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOMStorage.domStorageItemUpdated", value);
            }

            /// <summary />
            public event Func<Protocol.DOMStorage.DomStorageItemsClearedEvent, Task> DomStorageItemsCleared
            {
                add => InspectorClient.AddEventHandlerCore("DOMStorage.domStorageItemsCleared", value);
                remove => InspectorClient.RemoveEventHandlerCore("DOMStorage.domStorageItemsCleared", value);
            }

            /// <summary />
            public Task<Protocol.DOMStorage.DomStorageItemAddedEvent> DomStorageItemAddedEvent(Func<Protocol.DOMStorage.DomStorageItemAddedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOMStorage.domStorageItemAdded", until);
            }

            /// <summary />
            public Task<Protocol.DOMStorage.DomStorageItemRemovedEvent> DomStorageItemRemovedEvent(Func<Protocol.DOMStorage.DomStorageItemRemovedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOMStorage.domStorageItemRemoved", until);
            }

            /// <summary />
            public Task<Protocol.DOMStorage.DomStorageItemUpdatedEvent> DomStorageItemUpdatedEvent(Func<Protocol.DOMStorage.DomStorageItemUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOMStorage.domStorageItemUpdated", until);
            }

            /// <summary />
            public Task<Protocol.DOMStorage.DomStorageItemsClearedEvent> DomStorageItemsClearedEvent(Func<Protocol.DOMStorage.DomStorageItemsClearedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("DOMStorage.domStorageItemsCleared", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Database.
        /// </summary>
        public class DatabaseInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal DatabaseInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disables database tracking, prevents database events from being sent to the client.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Database.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables database tracking, database events will now be delivered to the client.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Database.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="databaseId" />
            /// <param name="query" />
            /// <param name="cancellation" />
            public Task<Protocol.Database.ExecuteSQLResponse> ExecuteSQL
            (
                Protocol.Database.DatabaseId @databaseId, 
                string @query, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Database.ExecuteSQLCommand
                    {
                        DatabaseId = @databaseId,
                        Query = @query,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="databaseId" />
            /// <param name="cancellation" />
            public Task<Protocol.Database.GetDatabaseTableNamesResponse> GetDatabaseTableNames
            (
                Protocol.Database.DatabaseId @databaseId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Database.GetDatabaseTableNamesCommand
                    {
                        DatabaseId = @databaseId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.Database.AddDatabaseEvent, Task> AddDatabase
            {
                add => InspectorClient.AddEventHandlerCore("Database.addDatabase", value);
                remove => InspectorClient.RemoveEventHandlerCore("Database.addDatabase", value);
            }

            /// <summary />
            public Task<Protocol.Database.AddDatabaseEvent> AddDatabaseEvent(Func<Protocol.Database.AddDatabaseEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Database.addDatabase", until);
            }
        }

        /// <summary>
        /// Inspector client for domain DeviceOrientation.
        /// </summary>
        public class DeviceOrientationInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal DeviceOrientationInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Clears the overridden Device Orientation.
            /// </summary>
            /// <param name="cancellation" />
            public Task ClearDeviceOrientationOverride
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DeviceOrientation.ClearDeviceOrientationOverrideCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Overrides the Device Orientation.
            /// </summary>
            /// <param name="alpha">
            /// Mock alpha
            /// </param>
            /// <param name="beta">
            /// Mock beta
            /// </param>
            /// <param name="gamma">
            /// Mock gamma
            /// </param>
            /// <param name="cancellation" />
            public Task SetDeviceOrientationOverride
            (
                double @alpha, 
                double @beta, 
                double @gamma, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.DeviceOrientation.SetDeviceOrientationOverrideCommand
                    {
                        Alpha = @alpha,
                        Beta = @beta,
                        Gamma = @gamma,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Emulation.
        /// </summary>
        public class EmulationInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal EmulationInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Tells whether emulation is supported.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Emulation.CanEmulateResponse> CanEmulate
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.CanEmulateCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Clears the overriden device metrics.
            /// </summary>
            /// <param name="cancellation" />
            public Task ClearDeviceMetricsOverride
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.ClearDeviceMetricsOverrideCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Clears the overriden Geolocation Position and Error.
            /// </summary>
            /// <param name="cancellation" />
            public Task ClearGeolocationOverride
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.ClearGeolocationOverrideCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that page scale factor is reset to initial values.
            /// </summary>
            /// <param name="cancellation" />
            public Task ResetPageScaleFactor
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.ResetPageScaleFactorCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables or disables simulating a focused and active page.
            /// </summary>
            /// <param name="enabled">
            /// Whether to enable to disable focus emulation.
            /// </param>
            /// <param name="cancellation" />
            public Task SetFocusEmulationEnabled
            (
                bool @enabled, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetFocusEmulationEnabledCommand
                    {
                        Enabled = @enabled,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables CPU throttling to emulate slow CPUs.
            /// </summary>
            /// <param name="rate">
            /// Throttling rate as a slowdown factor (1 is no throttle, 2 is 2x slowdown, etc).
            /// </param>
            /// <param name="cancellation" />
            public Task SetCPUThrottlingRate
            (
                double @rate, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetCPUThrottlingRateCommand
                    {
                        Rate = @rate,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets or clears an override of the default background color of the frame. This override is used
            /// if the content does not specify one.
            /// </summary>
            /// <param name="color">
            /// RGBA of the default background color. If not specified, any existing override will be
            /// cleared.
            /// </param>
            /// <param name="cancellation" />
            public Task SetDefaultBackgroundColorOverride
            (
                Protocol.DOM.RGBA @color = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetDefaultBackgroundColorOverrideCommand
                    {
                        Color = @color,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Overrides the values of device screen dimensions (window.screen.width, window.screen.height,
            /// window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS media
            /// query results).
            /// </summary>
            /// <param name="width">
            /// Overriding width value in pixels (minimum 0, maximum 10000000). 0 disables the override.
            /// </param>
            /// <param name="height">
            /// Overriding height value in pixels (minimum 0, maximum 10000000). 0 disables the override.
            /// </param>
            /// <param name="deviceScaleFactor">
            /// Overriding device scale factor value. 0 disables the override.
            /// </param>
            /// <param name="mobile">
            /// Whether to emulate mobile device. This includes viewport meta tag, overlay scrollbars, text
            /// autosizing and more.
            /// </param>
            /// <param name="scale">
            /// Scale to apply to resulting view image.
            /// </param>
            /// <param name="screenWidth">
            /// Overriding screen width value in pixels (minimum 0, maximum 10000000).
            /// </param>
            /// <param name="screenHeight">
            /// Overriding screen height value in pixels (minimum 0, maximum 10000000).
            /// </param>
            /// <param name="positionX">
            /// Overriding view X position on screen in pixels (minimum 0, maximum 10000000).
            /// </param>
            /// <param name="positionY">
            /// Overriding view Y position on screen in pixels (minimum 0, maximum 10000000).
            /// </param>
            /// <param name="dontSetVisibleSize">
            /// Do not set visible view size, rely upon explicit setVisibleSize call.
            /// </param>
            /// <param name="screenOrientation">
            /// Screen orientation override.
            /// </param>
            /// <param name="viewport">
            /// If set, the visible area of the page will be overridden to this viewport. This viewport
            /// change is not observed by the page, e.g. viewport-relative elements do not change positions.
            /// </param>
            /// <param name="cancellation" />
            public Task SetDeviceMetricsOverride
            (
                long @width, 
                long @height, 
                double @deviceScaleFactor, 
                bool @mobile, 
                double? @scale = default, 
                long? @screenWidth = default, 
                long? @screenHeight = default, 
                long? @positionX = default, 
                long? @positionY = default, 
                bool? @dontSetVisibleSize = default, 
                Protocol.Emulation.ScreenOrientation @screenOrientation = default, 
                Protocol.Page.Viewport @viewport = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetDeviceMetricsOverrideCommand
                    {
                        Width = @width,
                        Height = @height,
                        DeviceScaleFactor = @deviceScaleFactor,
                        Mobile = @mobile,
                        Scale = @scale,
                        ScreenWidth = @screenWidth,
                        ScreenHeight = @screenHeight,
                        PositionX = @positionX,
                        PositionY = @positionY,
                        DontSetVisibleSize = @dontSetVisibleSize,
                        ScreenOrientation = @screenOrientation,
                        Viewport = @viewport,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="hidden">
            /// Whether scrollbars should be always hidden.
            /// </param>
            /// <param name="cancellation" />
            public Task SetScrollbarsHidden
            (
                bool @hidden, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetScrollbarsHiddenCommand
                    {
                        Hidden = @hidden,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="disabled">
            /// Whether document.coookie API should be disabled.
            /// </param>
            /// <param name="cancellation" />
            public Task SetDocumentCookieDisabled
            (
                bool @disabled, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetDocumentCookieDisabledCommand
                    {
                        Disabled = @disabled,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="enabled">
            /// Whether touch emulation based on mouse input should be enabled.
            /// </param>
            /// <param name="configuration">
            /// Touch/gesture events configuration. Default: current platform.
            /// </param>
            /// <param name="cancellation" />
            public Task SetEmitTouchEventsForMouse
            (
                bool @enabled, 
                string @configuration = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetEmitTouchEventsForMouseCommand
                    {
                        Enabled = @enabled,
                        Configuration = @configuration,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Emulates the given media for CSS media queries.
            /// </summary>
            /// <param name="media">
            /// Media type to emulate. Empty string disables the override.
            /// </param>
            /// <param name="cancellation" />
            public Task SetEmulatedMedia
            (
                string @media, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetEmulatedMediaCommand
                    {
                        Media = @media,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position
            /// unavailable.
            /// </summary>
            /// <param name="latitude">
            /// Mock latitude
            /// </param>
            /// <param name="longitude">
            /// Mock longitude
            /// </param>
            /// <param name="accuracy">
            /// Mock accuracy
            /// </param>
            /// <param name="cancellation" />
            public Task SetGeolocationOverride
            (
                double? @latitude = default, 
                double? @longitude = default, 
                double? @accuracy = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetGeolocationOverrideCommand
                    {
                        Latitude = @latitude,
                        Longitude = @longitude,
                        Accuracy = @accuracy,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Overrides value returned by the javascript navigator object.
            /// </summary>
            /// <param name="platform">
            /// The platform navigator.platform should return.
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task SetNavigatorOverrides
            (
                string @platform, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetNavigatorOverridesCommand
                    {
                        Platform = @platform,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets a specified page scale factor.
            /// </summary>
            /// <param name="pageScaleFactor">
            /// Page scale factor.
            /// </param>
            /// <param name="cancellation" />
            public Task SetPageScaleFactor
            (
                double @pageScaleFactor, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetPageScaleFactorCommand
                    {
                        PageScaleFactor = @pageScaleFactor,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Switches script execution in the page.
            /// </summary>
            /// <param name="value">
            /// Whether script execution should be disabled in the page.
            /// </param>
            /// <param name="cancellation" />
            public Task SetScriptExecutionDisabled
            (
                bool @value, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetScriptExecutionDisabledCommand
                    {
                        Value = @value,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables touch on platforms which do not support them.
            /// </summary>
            /// <param name="enabled">
            /// Whether the touch event emulation should be enabled.
            /// </param>
            /// <param name="maxTouchPoints">
            /// Maximum touch points supported. Defaults to one.
            /// </param>
            /// <param name="cancellation" />
            public Task SetTouchEmulationEnabled
            (
                bool @enabled, 
                long? @maxTouchPoints = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetTouchEmulationEnabledCommand
                    {
                        Enabled = @enabled,
                        MaxTouchPoints = @maxTouchPoints,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Turns on virtual time for all frames (replacing real-time with a synthetic time source) and sets
            /// the current virtual time policy.  Note this supersedes any previous time budget.
            /// </summary>
            /// <param name="policy" />
            /// <param name="budget">
            /// If set, after this many virtual milliseconds have elapsed virtual time will be paused and a
            /// virtualTimeBudgetExpired event is sent.
            /// </param>
            /// <param name="maxVirtualTimeTaskStarvationCount">
            /// If set this specifies the maximum number of tasks that can be run before virtual is forced
            /// forwards to prevent deadlock.
            /// </param>
            /// <param name="waitForNavigation">
            /// If set the virtual time policy change should be deferred until any frame starts navigating.
            /// Note any previous deferred policy change is superseded.
            /// </param>
            /// <param name="initialVirtualTime">
            /// If set, base::Time::Now will be overriden to initially return this value.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Emulation.SetVirtualTimePolicyResponse> SetVirtualTimePolicy
            (
                Protocol.Emulation.VirtualTimePolicy @policy, 
                double? @budget = default, 
                long? @maxVirtualTimeTaskStarvationCount = default, 
                bool? @waitForNavigation = default, 
                Protocol.Network.TimeSinceEpoch @initialVirtualTime = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetVirtualTimePolicyCommand
                    {
                        Policy = @policy,
                        Budget = @budget,
                        MaxVirtualTimeTaskStarvationCount = @maxVirtualTimeTaskStarvationCount,
                        WaitForNavigation = @waitForNavigation,
                        InitialVirtualTime = @initialVirtualTime,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Resizes the frame/viewport of the page. Note that this does not affect the frame's container
            /// (e.g. browser window). Can be used to produce screenshots of the specified size. Not supported
            /// on Android.
            /// </summary>
            /// <param name="width">
            /// Frame width (DIP).
            /// </param>
            /// <param name="height">
            /// Frame height (DIP).
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task SetVisibleSize
            (
                long @width, 
                long @height, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetVisibleSizeCommand
                    {
                        Width = @width,
                        Height = @height,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Allows overriding user agent with the given string.
            /// </summary>
            /// <param name="userAgent">
            /// User agent to use.
            /// </param>
            /// <param name="acceptLanguage">
            /// Browser langugage to emulate.
            /// </param>
            /// <param name="platform">
            /// The platform navigator.platform should return.
            /// </param>
            /// <param name="cancellation" />
            public Task SetUserAgentOverride
            (
                string @userAgent, 
                string @acceptLanguage = default, 
                string @platform = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Emulation.SetUserAgentOverrideCommand
                    {
                        UserAgent = @userAgent,
                        AcceptLanguage = @acceptLanguage,
                        Platform = @platform,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Notification sent after the virtual time budget for the current VirtualTimePolicy has run out.
            /// </summary>
            public event Func<Protocol.Emulation.VirtualTimeBudgetExpiredEvent, Task> VirtualTimeBudgetExpired
            {
                add => InspectorClient.AddEventHandlerCore("Emulation.virtualTimeBudgetExpired", value);
                remove => InspectorClient.RemoveEventHandlerCore("Emulation.virtualTimeBudgetExpired", value);
            }

            /// <summary>
            /// Notification sent after the virtual time budget for the current VirtualTimePolicy has run out.
            /// </summary>
            public Task<Protocol.Emulation.VirtualTimeBudgetExpiredEvent> VirtualTimeBudgetExpiredEvent(Func<Protocol.Emulation.VirtualTimeBudgetExpiredEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Emulation.virtualTimeBudgetExpired", until);
            }
        }

        /// <summary>
        /// Inspector client for domain HeadlessExperimental.
        /// </summary>
        public class HeadlessExperimentalInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal HeadlessExperimentalInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Sends a BeginFrame to the target and returns when the frame was completed. Optionally captures a
            /// screenshot from the resulting frame. Requires that the target was created with enabled
            /// BeginFrameControl. Designed for use with --run-all-compositor-stages-before-draw, see also
            /// https://goo.gl/3zHXhB for more background.
            /// </summary>
            /// <param name="frameTimeTicks">
            /// Timestamp of this BeginFrame in Renderer TimeTicks (milliseconds of uptime). If not set,
            /// the current time will be used.
            /// </param>
            /// <param name="interval">
            /// The interval between BeginFrames that is reported to the compositor, in milliseconds.
            /// Defaults to a 60 frames/second interval, i.e. about 16.666 milliseconds.
            /// </param>
            /// <param name="noDisplayUpdates">
            /// Whether updates should not be committed and drawn onto the display. False by default. If
            /// true, only side effects of the BeginFrame will be run, such as layout and animations, but
            /// any visual updates may not be visible on the display or in screenshots.
            /// </param>
            /// <param name="screenshot">
            /// If set, a screenshot of the frame will be captured and returned in the response. Otherwise,
            /// no screenshot will be captured. Note that capturing a screenshot can fail, for example,
            /// during renderer initialization. In such a case, no screenshot data will be returned.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.HeadlessExperimental.BeginFrameResponse> BeginFrame
            (
                double? @frameTimeTicks = default, 
                double? @interval = default, 
                bool? @noDisplayUpdates = default, 
                Protocol.HeadlessExperimental.ScreenshotParams @screenshot = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeadlessExperimental.BeginFrameCommand
                    {
                        FrameTimeTicks = @frameTimeTicks,
                        Interval = @interval,
                        NoDisplayUpdates = @noDisplayUpdates,
                        Screenshot = @screenshot,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables headless events for the target.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeadlessExperimental.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables headless events for the target.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeadlessExperimental.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Issued when the target starts or stops needing BeginFrames.
            /// </summary>
            public event Func<Protocol.HeadlessExperimental.NeedsBeginFramesChangedEvent, Task> NeedsBeginFramesChanged
            {
                add => InspectorClient.AddEventHandlerCore("HeadlessExperimental.needsBeginFramesChanged", value);
                remove => InspectorClient.RemoveEventHandlerCore("HeadlessExperimental.needsBeginFramesChanged", value);
            }

            /// <summary>
            /// Issued when the target starts or stops needing BeginFrames.
            /// </summary>
            public Task<Protocol.HeadlessExperimental.NeedsBeginFramesChangedEvent> NeedsBeginFramesChangedEvent(Func<Protocol.HeadlessExperimental.NeedsBeginFramesChangedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("HeadlessExperimental.needsBeginFramesChanged", until);
            }
        }

        /// <summary>
        /// Inspector client for domain IO.
        /// </summary>
        public class IOInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal IOInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Close the stream, discard any temporary backing storage.
            /// </summary>
            /// <param name="handle">
            /// Handle of the stream to close.
            /// </param>
            /// <param name="cancellation" />
            public Task Close
            (
                Protocol.IO.StreamHandle @handle, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IO.CloseCommand
                    {
                        Handle = @handle,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Read a chunk of the stream
            /// </summary>
            /// <param name="handle">
            /// Handle of the stream to read.
            /// </param>
            /// <param name="offset">
            /// Seek to the specified offset before reading (if not specificed, proceed with offset
            /// following the last read). Some types of streams may only support sequential reads.
            /// </param>
            /// <param name="size">
            /// Maximum number of bytes to read (left upon the agent discretion if not specified).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.IO.ReadResponse> Read
            (
                Protocol.IO.StreamHandle @handle, 
                long? @offset = default, 
                long? @size = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IO.ReadCommand
                    {
                        Handle = @handle,
                        Offset = @offset,
                        Size = @size,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Return UUID of Blob object specified by a remote object id.
            /// </summary>
            /// <param name="objectId">
            /// Object id of a Blob object wrapper.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.IO.ResolveBlobResponse> ResolveBlob
            (
                Protocol.Runtime.RemoteObjectId @objectId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IO.ResolveBlobCommand
                    {
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain IndexedDB.
        /// </summary>
        public class IndexedDBInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal IndexedDBInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Clears all entries from an object store.
            /// </summary>
            /// <param name="securityOrigin">
            /// Security origin.
            /// </param>
            /// <param name="databaseName">
            /// Database name.
            /// </param>
            /// <param name="objectStoreName">
            /// Object store name.
            /// </param>
            /// <param name="cancellation" />
            public Task ClearObjectStore
            (
                string @securityOrigin, 
                string @databaseName, 
                string @objectStoreName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.ClearObjectStoreCommand
                    {
                        SecurityOrigin = @securityOrigin,
                        DatabaseName = @databaseName,
                        ObjectStoreName = @objectStoreName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Deletes a database.
            /// </summary>
            /// <param name="securityOrigin">
            /// Security origin.
            /// </param>
            /// <param name="databaseName">
            /// Database name.
            /// </param>
            /// <param name="cancellation" />
            public Task DeleteDatabase
            (
                string @securityOrigin, 
                string @databaseName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.DeleteDatabaseCommand
                    {
                        SecurityOrigin = @securityOrigin,
                        DatabaseName = @databaseName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Delete a range of entries from an object store
            /// </summary>
            /// <param name="securityOrigin" />
            /// <param name="databaseName" />
            /// <param name="objectStoreName" />
            /// <param name="keyRange">
            /// Range of entry keys to delete
            /// </param>
            /// <param name="cancellation" />
            public Task DeleteObjectStoreEntries
            (
                string @securityOrigin, 
                string @databaseName, 
                string @objectStoreName, 
                Protocol.IndexedDB.KeyRange @keyRange, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.DeleteObjectStoreEntriesCommand
                    {
                        SecurityOrigin = @securityOrigin,
                        DatabaseName = @databaseName,
                        ObjectStoreName = @objectStoreName,
                        KeyRange = @keyRange,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables events from backend.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables events from backend.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests data from object store or index.
            /// </summary>
            /// <param name="securityOrigin">
            /// Security origin.
            /// </param>
            /// <param name="databaseName">
            /// Database name.
            /// </param>
            /// <param name="objectStoreName">
            /// Object store name.
            /// </param>
            /// <param name="indexName">
            /// Index name, empty string for object store data requests.
            /// </param>
            /// <param name="skipCount">
            /// Number of records to skip.
            /// </param>
            /// <param name="pageSize">
            /// Number of records to fetch.
            /// </param>
            /// <param name="keyRange">
            /// Key range.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.IndexedDB.RequestDataResponse> RequestData
            (
                string @securityOrigin, 
                string @databaseName, 
                string @objectStoreName, 
                string @indexName, 
                long @skipCount, 
                long @pageSize, 
                Protocol.IndexedDB.KeyRange @keyRange = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.RequestDataCommand
                    {
                        SecurityOrigin = @securityOrigin,
                        DatabaseName = @databaseName,
                        ObjectStoreName = @objectStoreName,
                        IndexName = @indexName,
                        SkipCount = @skipCount,
                        PageSize = @pageSize,
                        KeyRange = @keyRange,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Gets the auto increment number of an object store. Only meaningful
            /// when objectStore.autoIncrement is true.
            /// </summary>
            /// <param name="securityOrigin">
            /// Security origin.
            /// </param>
            /// <param name="databaseName">
            /// Database name.
            /// </param>
            /// <param name="objectStoreName">
            /// Object store name.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.IndexedDB.GetKeyGeneratorCurrentNumberResponse> GetKeyGeneratorCurrentNumber
            (
                string @securityOrigin, 
                string @databaseName, 
                string @objectStoreName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.GetKeyGeneratorCurrentNumberCommand
                    {
                        SecurityOrigin = @securityOrigin,
                        DatabaseName = @databaseName,
                        ObjectStoreName = @objectStoreName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests database with given name in given frame.
            /// </summary>
            /// <param name="securityOrigin">
            /// Security origin.
            /// </param>
            /// <param name="databaseName">
            /// Database name.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.IndexedDB.RequestDatabaseResponse> RequestDatabase
            (
                string @securityOrigin, 
                string @databaseName, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.RequestDatabaseCommand
                    {
                        SecurityOrigin = @securityOrigin,
                        DatabaseName = @databaseName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests database names for given security origin.
            /// </summary>
            /// <param name="securityOrigin">
            /// Security origin.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.IndexedDB.RequestDatabaseNamesResponse> RequestDatabaseNames
            (
                string @securityOrigin, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.IndexedDB.RequestDatabaseNamesCommand
                    {
                        SecurityOrigin = @securityOrigin,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Input.
        /// </summary>
        public class InputInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal InputInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Dispatches a key event to the page.
            /// </summary>
            /// <param name="type">
            /// Type of the key event.
            /// </param>
            /// <param name="modifiers">
            /// Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
            /// (default: 0).
            /// </param>
            /// <param name="timestamp">
            /// Time at which the event occurred.
            /// </param>
            /// <param name="text">
            /// Text as generated by processing a virtual key code with a keyboard layout. Not needed for
            /// for `keyUp` and `rawKeyDown` events (default: "")
            /// </param>
            /// <param name="unmodifiedText">
            /// Text that would have been generated by the keyboard if no modifiers were pressed (except for
            /// shift). Useful for shortcut (accelerator) key handling (default: "").
            /// </param>
            /// <param name="keyIdentifier">
            /// Unique key identifier (e.g., 'U+0041') (default: "").
            /// </param>
            /// <param name="code">
            /// Unique DOM defined string value for each physical key (e.g., 'KeyA') (default: "").
            /// </param>
            /// <param name="key">
            /// Unique DOM defined string value describing the meaning of the key in the context of active
            /// modifiers, keyboard layout, etc (e.g., 'AltGr') (default: "").
            /// </param>
            /// <param name="windowsVirtualKeyCode">
            /// Windows virtual key code (default: 0).
            /// </param>
            /// <param name="nativeVirtualKeyCode">
            /// Native virtual key code (default: 0).
            /// </param>
            /// <param name="autoRepeat">
            /// Whether the event was generated from auto repeat (default: false).
            /// </param>
            /// <param name="isKeypad">
            /// Whether the event was generated from the keypad (default: false).
            /// </param>
            /// <param name="isSystemKey">
            /// Whether the event was a system key event (default: false).
            /// </param>
            /// <param name="location">
            /// Whether the event was from the left or right side of the keyboard. 1=Left, 2=Right (default:
            /// 0).
            /// </param>
            /// <param name="cancellation" />
            public Task DispatchKeyEvent
            (
                string @type, 
                long? @modifiers = default, 
                Protocol.Input.TimeSinceEpoch @timestamp = default, 
                string @text = default, 
                string @unmodifiedText = default, 
                string @keyIdentifier = default, 
                string @code = default, 
                string @key = default, 
                long? @windowsVirtualKeyCode = default, 
                long? @nativeVirtualKeyCode = default, 
                bool? @autoRepeat = default, 
                bool? @isKeypad = default, 
                bool? @isSystemKey = default, 
                long? @location = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.DispatchKeyEventCommand
                    {
                        Type = @type,
                        Modifiers = @modifiers,
                        Timestamp = @timestamp,
                        Text = @text,
                        UnmodifiedText = @unmodifiedText,
                        KeyIdentifier = @keyIdentifier,
                        Code = @code,
                        Key = @key,
                        WindowsVirtualKeyCode = @windowsVirtualKeyCode,
                        NativeVirtualKeyCode = @nativeVirtualKeyCode,
                        AutoRepeat = @autoRepeat,
                        IsKeypad = @isKeypad,
                        IsSystemKey = @isSystemKey,
                        Location = @location,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// This method emulates inserting text that doesn't come from a key press,
            /// for example an emoji keyboard or an IME.
            /// </summary>
            /// <param name="text">
            /// The text to insert.
            /// </param>
            /// <param name="cancellation" />
            public Task InsertText
            (
                string @text, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.InsertTextCommand
                    {
                        Text = @text,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Dispatches a mouse event to the page.
            /// </summary>
            /// <param name="type">
            /// Type of the mouse event.
            /// </param>
            /// <param name="x">
            /// X coordinate of the event relative to the main frame's viewport in CSS pixels.
            /// </param>
            /// <param name="y">
            /// Y coordinate of the event relative to the main frame's viewport in CSS pixels. 0 refers to
            /// the top of the viewport and Y increases as it proceeds towards the bottom of the viewport.
            /// </param>
            /// <param name="modifiers">
            /// Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
            /// (default: 0).
            /// </param>
            /// <param name="timestamp">
            /// Time at which the event occurred.
            /// </param>
            /// <param name="button">
            /// Mouse button (default: "none").
            /// </param>
            /// <param name="buttons">
            /// A number indicating which buttons are pressed on the mouse when a mouse event is triggered.
            /// Left=1, Right=2, Middle=4, Back=8, Forward=16, None=0.
            /// </param>
            /// <param name="clickCount">
            /// Number of times the mouse button was clicked (default: 0).
            /// </param>
            /// <param name="deltaX">
            /// X delta in CSS pixels for mouse wheel event (default: 0).
            /// </param>
            /// <param name="deltaY">
            /// Y delta in CSS pixels for mouse wheel event (default: 0).
            /// </param>
            /// <param name="pointerType">
            /// Pointer type (default: "mouse").
            /// </param>
            /// <param name="cancellation" />
            public Task DispatchMouseEvent
            (
                string @type, 
                double @x, 
                double @y, 
                long? @modifiers = default, 
                Protocol.Input.TimeSinceEpoch @timestamp = default, 
                string @button = default, 
                long? @buttons = default, 
                long? @clickCount = default, 
                double? @deltaX = default, 
                double? @deltaY = default, 
                string @pointerType = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.DispatchMouseEventCommand
                    {
                        Type = @type,
                        X = @x,
                        Y = @y,
                        Modifiers = @modifiers,
                        Timestamp = @timestamp,
                        Button = @button,
                        Buttons = @buttons,
                        ClickCount = @clickCount,
                        DeltaX = @deltaX,
                        DeltaY = @deltaY,
                        PointerType = @pointerType,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Dispatches a touch event to the page.
            /// </summary>
            /// <param name="type">
            /// Type of the touch event. TouchEnd and TouchCancel must not contain any touch points, while
            /// TouchStart and TouchMove must contains at least one.
            /// </param>
            /// <param name="touchPoints">
            /// Active touch points on the touch device. One event per any changed point (compared to
            /// previous touch event in a sequence) is generated, emulating pressing/moving/releasing points
            /// one by one.
            /// </param>
            /// <param name="modifiers">
            /// Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
            /// (default: 0).
            /// </param>
            /// <param name="timestamp">
            /// Time at which the event occurred.
            /// </param>
            /// <param name="cancellation" />
            public Task DispatchTouchEvent
            (
                string @type, 
                Protocol.Input.TouchPoint[] @touchPoints, 
                long? @modifiers = default, 
                Protocol.Input.TimeSinceEpoch @timestamp = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.DispatchTouchEventCommand
                    {
                        Type = @type,
                        TouchPoints = @touchPoints,
                        Modifiers = @modifiers,
                        Timestamp = @timestamp,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Emulates touch event from the mouse event parameters.
            /// </summary>
            /// <param name="type">
            /// Type of the mouse event.
            /// </param>
            /// <param name="x">
            /// X coordinate of the mouse pointer in DIP.
            /// </param>
            /// <param name="y">
            /// Y coordinate of the mouse pointer in DIP.
            /// </param>
            /// <param name="button">
            /// Mouse button.
            /// </param>
            /// <param name="timestamp">
            /// Time at which the event occurred (default: current time).
            /// </param>
            /// <param name="deltaX">
            /// X delta in DIP for mouse wheel event (default: 0).
            /// </param>
            /// <param name="deltaY">
            /// Y delta in DIP for mouse wheel event (default: 0).
            /// </param>
            /// <param name="modifiers">
            /// Bit field representing pressed modifier keys. Alt=1, Ctrl=2, Meta/Command=4, Shift=8
            /// (default: 0).
            /// </param>
            /// <param name="clickCount">
            /// Number of times the mouse button was clicked (default: 0).
            /// </param>
            /// <param name="cancellation" />
            public Task EmulateTouchFromMouseEvent
            (
                string @type, 
                long @x, 
                long @y, 
                string @button, 
                Protocol.Input.TimeSinceEpoch @timestamp = default, 
                double? @deltaX = default, 
                double? @deltaY = default, 
                long? @modifiers = default, 
                long? @clickCount = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.EmulateTouchFromMouseEventCommand
                    {
                        Type = @type,
                        X = @x,
                        Y = @y,
                        Button = @button,
                        Timestamp = @timestamp,
                        DeltaX = @deltaX,
                        DeltaY = @deltaY,
                        Modifiers = @modifiers,
                        ClickCount = @clickCount,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Ignores input events (useful while auditing page).
            /// </summary>
            /// <param name="ignore">
            /// Ignores input events processing when set to true.
            /// </param>
            /// <param name="cancellation" />
            public Task SetIgnoreInputEvents
            (
                bool @ignore, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.SetIgnoreInputEventsCommand
                    {
                        Ignore = @ignore,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Synthesizes a pinch gesture over a time period by issuing appropriate touch events.
            /// </summary>
            /// <param name="x">
            /// X coordinate of the start of the gesture in CSS pixels.
            /// </param>
            /// <param name="y">
            /// Y coordinate of the start of the gesture in CSS pixels.
            /// </param>
            /// <param name="scaleFactor">
            /// Relative scale factor after zooming (&gt;1.0 zooms in, &lt;1.0 zooms out).
            /// </param>
            /// <param name="relativeSpeed">
            /// Relative pointer speed in pixels per second (default: 800).
            /// </param>
            /// <param name="gestureSourceType">
            /// Which type of input events to be generated (default: 'default', which queries the platform
            /// for the preferred input type).
            /// </param>
            /// <param name="cancellation" />
            public Task SynthesizePinchGesture
            (
                double @x, 
                double @y, 
                double @scaleFactor, 
                long? @relativeSpeed = default, 
                Protocol.Input.GestureSourceType @gestureSourceType = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.SynthesizePinchGestureCommand
                    {
                        X = @x,
                        Y = @y,
                        ScaleFactor = @scaleFactor,
                        RelativeSpeed = @relativeSpeed,
                        GestureSourceType = @gestureSourceType,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Synthesizes a scroll gesture over a time period by issuing appropriate touch events.
            /// </summary>
            /// <param name="x">
            /// X coordinate of the start of the gesture in CSS pixels.
            /// </param>
            /// <param name="y">
            /// Y coordinate of the start of the gesture in CSS pixels.
            /// </param>
            /// <param name="xDistance">
            /// The distance to scroll along the X axis (positive to scroll left).
            /// </param>
            /// <param name="yDistance">
            /// The distance to scroll along the Y axis (positive to scroll up).
            /// </param>
            /// <param name="xOverscroll">
            /// The number of additional pixels to scroll back along the X axis, in addition to the given
            /// distance.
            /// </param>
            /// <param name="yOverscroll">
            /// The number of additional pixels to scroll back along the Y axis, in addition to the given
            /// distance.
            /// </param>
            /// <param name="preventFling">
            /// Prevent fling (default: true).
            /// </param>
            /// <param name="speed">
            /// Swipe speed in pixels per second (default: 800).
            /// </param>
            /// <param name="gestureSourceType">
            /// Which type of input events to be generated (default: 'default', which queries the platform
            /// for the preferred input type).
            /// </param>
            /// <param name="repeatCount">
            /// The number of times to repeat the gesture (default: 0).
            /// </param>
            /// <param name="repeatDelayMs">
            /// The number of milliseconds delay between each repeat. (default: 250).
            /// </param>
            /// <param name="interactionMarkerName">
            /// The name of the interaction markers to generate, if not empty (default: "").
            /// </param>
            /// <param name="cancellation" />
            public Task SynthesizeScrollGesture
            (
                double @x, 
                double @y, 
                double? @xDistance = default, 
                double? @yDistance = default, 
                double? @xOverscroll = default, 
                double? @yOverscroll = default, 
                bool? @preventFling = default, 
                long? @speed = default, 
                Protocol.Input.GestureSourceType @gestureSourceType = default, 
                long? @repeatCount = default, 
                long? @repeatDelayMs = default, 
                string @interactionMarkerName = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.SynthesizeScrollGestureCommand
                    {
                        X = @x,
                        Y = @y,
                        XDistance = @xDistance,
                        YDistance = @yDistance,
                        XOverscroll = @xOverscroll,
                        YOverscroll = @yOverscroll,
                        PreventFling = @preventFling,
                        Speed = @speed,
                        GestureSourceType = @gestureSourceType,
                        RepeatCount = @repeatCount,
                        RepeatDelayMs = @repeatDelayMs,
                        InteractionMarkerName = @interactionMarkerName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Synthesizes a tap gesture over a time period by issuing appropriate touch events.
            /// </summary>
            /// <param name="x">
            /// X coordinate of the start of the gesture in CSS pixels.
            /// </param>
            /// <param name="y">
            /// Y coordinate of the start of the gesture in CSS pixels.
            /// </param>
            /// <param name="duration">
            /// Duration between touchdown and touchup events in ms (default: 50).
            /// </param>
            /// <param name="tapCount">
            /// Number of times to perform the tap (e.g. 2 for double tap, default: 1).
            /// </param>
            /// <param name="gestureSourceType">
            /// Which type of input events to be generated (default: 'default', which queries the platform
            /// for the preferred input type).
            /// </param>
            /// <param name="cancellation" />
            public Task SynthesizeTapGesture
            (
                double @x, 
                double @y, 
                long? @duration = default, 
                long? @tapCount = default, 
                Protocol.Input.GestureSourceType @gestureSourceType = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Input.SynthesizeTapGestureCommand
                    {
                        X = @x,
                        Y = @y,
                        Duration = @duration,
                        TapCount = @tapCount,
                        GestureSourceType = @gestureSourceType,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Inspector.
        /// </summary>
        public class InspectorInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal InspectorInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disables inspector domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Inspector.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables inspector domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Inspector.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fired when remote debugging connection is about to be terminated. Contains detach reason.
            /// </summary>
            public event Func<Protocol.Inspector.DetachedEvent, Task> Detached
            {
                add => InspectorClient.AddEventHandlerCore("Inspector.detached", value);
                remove => InspectorClient.RemoveEventHandlerCore("Inspector.detached", value);
            }

            /// <summary>
            /// Fired when debugging target has crashed
            /// </summary>
            public event Func<Protocol.Inspector.TargetCrashedEvent, Task> TargetCrashed
            {
                add => InspectorClient.AddEventHandlerCore("Inspector.targetCrashed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Inspector.targetCrashed", value);
            }

            /// <summary>
            /// Fired when debugging target has reloaded after crash
            /// </summary>
            public event Func<Protocol.Inspector.TargetReloadedAfterCrashEvent, Task> TargetReloadedAfterCrash
            {
                add => InspectorClient.AddEventHandlerCore("Inspector.targetReloadedAfterCrash", value);
                remove => InspectorClient.RemoveEventHandlerCore("Inspector.targetReloadedAfterCrash", value);
            }

            /// <summary>
            /// Fired when remote debugging connection is about to be terminated. Contains detach reason.
            /// </summary>
            public Task<Protocol.Inspector.DetachedEvent> DetachedEvent(Func<Protocol.Inspector.DetachedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Inspector.detached", until);
            }

            /// <summary>
            /// Fired when debugging target has crashed
            /// </summary>
            public Task<Protocol.Inspector.TargetCrashedEvent> TargetCrashedEvent(Func<Protocol.Inspector.TargetCrashedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Inspector.targetCrashed", until);
            }

            /// <summary>
            /// Fired when debugging target has reloaded after crash
            /// </summary>
            public Task<Protocol.Inspector.TargetReloadedAfterCrashEvent> TargetReloadedAfterCrashEvent(Func<Protocol.Inspector.TargetReloadedAfterCrashEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Inspector.targetReloadedAfterCrash", until);
            }
        }

        /// <summary>
        /// Inspector client for domain LayerTree.
        /// </summary>
        public class LayerTreeInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal LayerTreeInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Provides the reasons why the given layer was composited.
            /// </summary>
            /// <param name="layerId">
            /// The id of the layer for which we want to get the reasons it was composited.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.LayerTree.CompositingReasonsResponse> CompositingReasons
            (
                Protocol.LayerTree.LayerId @layerId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.CompositingReasonsCommand
                    {
                        LayerId = @layerId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables compositing tree inspection.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables compositing tree inspection.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the snapshot identifier.
            /// </summary>
            /// <param name="tiles">
            /// An array of tiles composing the snapshot.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.LayerTree.LoadSnapshotResponse> LoadSnapshot
            (
                Protocol.LayerTree.PictureTile[] @tiles, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.LoadSnapshotCommand
                    {
                        Tiles = @tiles,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the layer snapshot identifier.
            /// </summary>
            /// <param name="layerId">
            /// The id of the layer.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.LayerTree.MakeSnapshotResponse> MakeSnapshot
            (
                Protocol.LayerTree.LayerId @layerId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.MakeSnapshotCommand
                    {
                        LayerId = @layerId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="snapshotId">
            /// The id of the layer snapshot.
            /// </param>
            /// <param name="minRepeatCount">
            /// The maximum number of times to replay the snapshot (1, if not specified).
            /// </param>
            /// <param name="minDuration">
            /// The minimum duration (in seconds) to replay the snapshot.
            /// </param>
            /// <param name="clipRect">
            /// The clip rectangle to apply when replaying the snapshot.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.LayerTree.ProfileSnapshotResponse> ProfileSnapshot
            (
                Protocol.LayerTree.SnapshotId @snapshotId, 
                long? @minRepeatCount = default, 
                double? @minDuration = default, 
                Protocol.DOM.Rect @clipRect = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.ProfileSnapshotCommand
                    {
                        SnapshotId = @snapshotId,
                        MinRepeatCount = @minRepeatCount,
                        MinDuration = @minDuration,
                        ClipRect = @clipRect,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Releases layer snapshot captured by the back-end.
            /// </summary>
            /// <param name="snapshotId">
            /// The id of the layer snapshot.
            /// </param>
            /// <param name="cancellation" />
            public Task ReleaseSnapshot
            (
                Protocol.LayerTree.SnapshotId @snapshotId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.ReleaseSnapshotCommand
                    {
                        SnapshotId = @snapshotId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Replays the layer snapshot and returns the resulting bitmap.
            /// </summary>
            /// <param name="snapshotId">
            /// The id of the layer snapshot.
            /// </param>
            /// <param name="fromStep">
            /// The first step to replay from (replay from the very start if not specified).
            /// </param>
            /// <param name="toStep">
            /// The last step to replay to (replay till the end if not specified).
            /// </param>
            /// <param name="scale">
            /// The scale to apply while replaying (defaults to 1).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.LayerTree.ReplaySnapshotResponse> ReplaySnapshot
            (
                Protocol.LayerTree.SnapshotId @snapshotId, 
                long? @fromStep = default, 
                long? @toStep = default, 
                double? @scale = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.ReplaySnapshotCommand
                    {
                        SnapshotId = @snapshotId,
                        FromStep = @fromStep,
                        ToStep = @toStep,
                        Scale = @scale,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Replays the layer snapshot and returns canvas log.
            /// </summary>
            /// <param name="snapshotId">
            /// The id of the layer snapshot.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.LayerTree.SnapshotCommandLogResponse> SnapshotCommandLog
            (
                Protocol.LayerTree.SnapshotId @snapshotId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.LayerTree.SnapshotCommandLogCommand
                    {
                        SnapshotId = @snapshotId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.LayerTree.LayerPaintedEvent, Task> LayerPainted
            {
                add => InspectorClient.AddEventHandlerCore("LayerTree.layerPainted", value);
                remove => InspectorClient.RemoveEventHandlerCore("LayerTree.layerPainted", value);
            }

            /// <summary />
            public event Func<Protocol.LayerTree.LayerTreeDidChangeEvent, Task> LayerTreeDidChange
            {
                add => InspectorClient.AddEventHandlerCore("LayerTree.layerTreeDidChange", value);
                remove => InspectorClient.RemoveEventHandlerCore("LayerTree.layerTreeDidChange", value);
            }

            /// <summary />
            public Task<Protocol.LayerTree.LayerPaintedEvent> LayerPaintedEvent(Func<Protocol.LayerTree.LayerPaintedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("LayerTree.layerPainted", until);
            }

            /// <summary />
            public Task<Protocol.LayerTree.LayerTreeDidChangeEvent> LayerTreeDidChangeEvent(Func<Protocol.LayerTree.LayerTreeDidChangeEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("LayerTree.layerTreeDidChange", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Log.
        /// </summary>
        public class LogInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal LogInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Clears the log.
            /// </summary>
            /// <param name="cancellation" />
            public Task Clear
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Log.ClearCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables log domain, prevents further log entries from being reported to the client.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Log.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables log domain, sends the entries collected so far to the client by means of the
            /// `entryAdded` notification.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Log.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// start violation reporting.
            /// </summary>
            /// <param name="config">
            /// Configuration for violations.
            /// </param>
            /// <param name="cancellation" />
            public Task StartViolationsReport
            (
                Protocol.Log.ViolationSetting[] @config, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Log.StartViolationsReportCommand
                    {
                        Config = @config,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Stop violation reporting.
            /// </summary>
            /// <param name="cancellation" />
            public Task StopViolationsReport
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Log.StopViolationsReportCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Issued when new message was logged.
            /// </summary>
            public event Func<Protocol.Log.EntryAddedEvent, Task> EntryAdded
            {
                add => InspectorClient.AddEventHandlerCore("Log.entryAdded", value);
                remove => InspectorClient.RemoveEventHandlerCore("Log.entryAdded", value);
            }

            /// <summary>
            /// Issued when new message was logged.
            /// </summary>
            public Task<Protocol.Log.EntryAddedEvent> EntryAddedEvent(Func<Protocol.Log.EntryAddedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Log.entryAdded", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Memory.
        /// </summary>
        public class MemoryInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal MemoryInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task<Protocol.Memory.GetDOMCountersResponse> GetDOMCounters
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.GetDOMCountersCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task PrepareForLeakDetection
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.PrepareForLeakDetectionCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Simulate OomIntervention by purging V8 memory.
            /// </summary>
            /// <param name="cancellation" />
            public Task ForciblyPurgeJavaScriptMemory
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.ForciblyPurgeJavaScriptMemoryCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enable/disable suppressing memory pressure notifications in all processes.
            /// </summary>
            /// <param name="suppressed">
            /// If true, memory pressure notifications will be suppressed.
            /// </param>
            /// <param name="cancellation" />
            public Task SetPressureNotificationsSuppressed
            (
                bool @suppressed, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.SetPressureNotificationsSuppressedCommand
                    {
                        Suppressed = @suppressed,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Simulate a memory pressure notification in all processes.
            /// </summary>
            /// <param name="level">
            /// Memory pressure level of the notification.
            /// </param>
            /// <param name="cancellation" />
            public Task SimulatePressureNotification
            (
                Protocol.Memory.PressureLevel @level, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.SimulatePressureNotificationCommand
                    {
                        Level = @level,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Start collecting native memory profile.
            /// </summary>
            /// <param name="samplingInterval">
            /// Average number of bytes between samples.
            /// </param>
            /// <param name="suppressRandomness">
            /// Do not randomize intervals between samples.
            /// </param>
            /// <param name="cancellation" />
            public Task StartSampling
            (
                long? @samplingInterval = default, 
                bool? @suppressRandomness = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.StartSamplingCommand
                    {
                        SamplingInterval = @samplingInterval,
                        SuppressRandomness = @suppressRandomness,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Stop collecting native memory profile.
            /// </summary>
            /// <param name="cancellation" />
            public Task StopSampling
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.StopSamplingCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Retrieve native memory allocations profile
            /// collected since renderer process startup.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Memory.GetAllTimeSamplingProfileResponse> GetAllTimeSamplingProfile
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.GetAllTimeSamplingProfileCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Retrieve native memory allocations profile
            /// collected since browser process startup.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Memory.GetBrowserSamplingProfileResponse> GetBrowserSamplingProfile
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.GetBrowserSamplingProfileCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Retrieve native memory allocations profile collected since last
            /// `startSampling` call.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Memory.GetSamplingProfileResponse> GetSamplingProfile
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Memory.GetSamplingProfileCommand
                    {
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Network.
        /// </summary>
        public class NetworkInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal NetworkInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Tells whether clearing browser cache is supported.
            /// </summary>
            /// <param name="cancellation" />
            [Obsolete]
            public Task<Protocol.Network.CanClearBrowserCacheResponse> CanClearBrowserCache
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.CanClearBrowserCacheCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Tells whether clearing browser cookies is supported.
            /// </summary>
            /// <param name="cancellation" />
            [Obsolete]
            public Task<Protocol.Network.CanClearBrowserCookiesResponse> CanClearBrowserCookies
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.CanClearBrowserCookiesCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Tells whether emulation of network conditions is supported.
            /// </summary>
            /// <param name="cancellation" />
            [Obsolete]
            public Task<Protocol.Network.CanEmulateNetworkConditionsResponse> CanEmulateNetworkConditions
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.CanEmulateNetworkConditionsCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Clears browser cache.
            /// </summary>
            /// <param name="cancellation" />
            public Task ClearBrowserCache
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.ClearBrowserCacheCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Clears browser cookies.
            /// </summary>
            /// <param name="cancellation" />
            public Task ClearBrowserCookies
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.ClearBrowserCookiesCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Response to Network.requestIntercepted which either modifies the request to continue with any
            /// modifications, or blocks it, or completes it with the provided response bytes. If a network
            /// fetch occurs as a result which encounters a redirect an additional Network.requestIntercepted
            /// event will be sent with the same InterceptionId.
            /// </summary>
            /// <param name="interceptionId" />
            /// <param name="errorReason">
            /// If set this causes the request to fail with the given reason. Passing `Aborted` for requests
            /// marked with `isNavigationRequest` also cancels the navigation. Must not be set in response
            /// to an authChallenge.
            /// </param>
            /// <param name="rawResponse">
            /// If set the requests completes using with the provided base64 encoded raw response, including
            /// HTTP status line and headers etc... Must not be set in response to an authChallenge.
            /// </param>
            /// <param name="url">
            /// If set the request url will be modified in a way that's not observable by page. Must not be
            /// set in response to an authChallenge.
            /// </param>
            /// <param name="method">
            /// If set this allows the request method to be overridden. Must not be set in response to an
            /// authChallenge.
            /// </param>
            /// <param name="postData">
            /// If set this allows postData to be set. Must not be set in response to an authChallenge.
            /// </param>
            /// <param name="headers">
            /// If set this allows the request headers to be changed. Must not be set in response to an
            /// authChallenge.
            /// </param>
            /// <param name="authChallengeResponse">
            /// Response to a requestIntercepted with an authChallenge. Must not be set otherwise.
            /// </param>
            /// <param name="cancellation" />
            public Task ContinueInterceptedRequest
            (
                Protocol.Network.InterceptionId @interceptionId, 
                Protocol.Network.ErrorReason @errorReason = default, 
                string @rawResponse = default, 
                string @url = default, 
                string @method = default, 
                string @postData = default, 
                Protocol.Network.Headers @headers = default, 
                Protocol.Network.AuthChallengeResponse @authChallengeResponse = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.ContinueInterceptedRequestCommand
                    {
                        InterceptionId = @interceptionId,
                        ErrorReason = @errorReason,
                        RawResponse = @rawResponse,
                        Url = @url,
                        Method = @method,
                        PostData = @postData,
                        Headers = @headers,
                        AuthChallengeResponse = @authChallengeResponse,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Deletes browser cookies with matching name and url or domain/path pair.
            /// </summary>
            /// <param name="name">
            /// Name of the cookies to remove.
            /// </param>
            /// <param name="url">
            /// If specified, deletes all the cookies with the given name where domain and path match
            /// provided URL.
            /// </param>
            /// <param name="domain">
            /// If specified, deletes only cookies with the exact domain.
            /// </param>
            /// <param name="path">
            /// If specified, deletes only cookies with the exact path.
            /// </param>
            /// <param name="cancellation" />
            public Task DeleteCookies
            (
                string @name, 
                string @url = default, 
                string @domain = default, 
                string @path = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.DeleteCookiesCommand
                    {
                        Name = @name,
                        Url = @url,
                        Domain = @domain,
                        Path = @path,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables network tracking, prevents network events from being sent to the client.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Activates emulation of network conditions.
            /// </summary>
            /// <param name="offline">
            /// True to emulate internet disconnection.
            /// </param>
            /// <param name="latency">
            /// Minimum latency from request sent to response headers received (ms).
            /// </param>
            /// <param name="downloadThroughput">
            /// Maximal aggregated download throughput (bytes/sec). -1 disables download throttling.
            /// </param>
            /// <param name="uploadThroughput">
            /// Maximal aggregated upload throughput (bytes/sec).  -1 disables upload throttling.
            /// </param>
            /// <param name="connectionType">
            /// Connection type if known.
            /// </param>
            /// <param name="cancellation" />
            public Task EmulateNetworkConditions
            (
                bool @offline, 
                double @latency, 
                double @downloadThroughput, 
                double @uploadThroughput, 
                Protocol.Network.ConnectionType @connectionType = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.EmulateNetworkConditionsCommand
                    {
                        Offline = @offline,
                        Latency = @latency,
                        DownloadThroughput = @downloadThroughput,
                        UploadThroughput = @uploadThroughput,
                        ConnectionType = @connectionType,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables network tracking, network events will now be delivered to the client.
            /// </summary>
            /// <param name="maxTotalBufferSize">
            /// Buffer size in bytes to use when preserving network payloads (XHRs, etc).
            /// </param>
            /// <param name="maxResourceBufferSize">
            /// Per-resource buffer size in bytes to use when preserving network payloads (XHRs, etc).
            /// </param>
            /// <param name="maxPostDataSize">
            /// Longest post body size (in bytes) that would be included in requestWillBeSent notification
            /// </param>
            /// <param name="cancellation" />
            public Task Enable
            (
                long? @maxTotalBufferSize = default, 
                long? @maxResourceBufferSize = default, 
                long? @maxPostDataSize = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.EnableCommand
                    {
                        MaxTotalBufferSize = @maxTotalBufferSize,
                        MaxResourceBufferSize = @maxResourceBufferSize,
                        MaxPostDataSize = @maxPostDataSize,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns all browser cookies. Depending on the backend support, will return detailed cookie
            /// information in the `cookies` field.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Network.GetAllCookiesResponse> GetAllCookies
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.GetAllCookiesCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the DER-encoded certificate.
            /// </summary>
            /// <param name="origin">
            /// Origin to get certificate for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Network.GetCertificateResponse> GetCertificate
            (
                string @origin, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.GetCertificateCommand
                    {
                        Origin = @origin,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns all browser cookies for the current URL. Depending on the backend support, will return
            /// detailed cookie information in the `cookies` field.
            /// </summary>
            /// <param name="urls">
            /// The list of URLs for which applicable cookies will be fetched
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Network.GetCookiesResponse> GetCookies
            (
                string[] @urls = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.GetCookiesCommand
                    {
                        Urls = @urls,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns content served for the given request.
            /// </summary>
            /// <param name="requestId">
            /// Identifier of the network request to get content for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Network.GetResponseBodyResponse> GetResponseBody
            (
                Protocol.Network.RequestId @requestId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.GetResponseBodyCommand
                    {
                        RequestId = @requestId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns post data sent with the request. Returns an error when no data was sent with the request.
            /// </summary>
            /// <param name="requestId">
            /// Identifier of the network request to get content for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Network.GetRequestPostDataResponse> GetRequestPostData
            (
                Protocol.Network.RequestId @requestId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.GetRequestPostDataCommand
                    {
                        RequestId = @requestId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns content served for the given currently intercepted request.
            /// </summary>
            /// <param name="interceptionId">
            /// Identifier for the intercepted request to get body for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Network.GetResponseBodyForInterceptionResponse> GetResponseBodyForInterception
            (
                Protocol.Network.InterceptionId @interceptionId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.GetResponseBodyForInterceptionCommand
                    {
                        InterceptionId = @interceptionId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns a handle to the stream representing the response body. Note that after this command,
            /// the intercepted request can't be continued as is -- you either need to cancel it or to provide
            /// the response body. The stream only supports sequential read, IO.read will fail if the position
            /// is specified.
            /// </summary>
            /// <param name="interceptionId" />
            /// <param name="cancellation" />
            public Task<Protocol.Network.TakeResponseBodyForInterceptionAsStreamResponse> TakeResponseBodyForInterceptionAsStream
            (
                Protocol.Network.InterceptionId @interceptionId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.TakeResponseBodyForInterceptionAsStreamCommand
                    {
                        InterceptionId = @interceptionId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// This method sends a new XMLHttpRequest which is identical to the original one. The following
            /// parameters should be identical: method, url, async, request body, extra headers, withCredentials
            /// attribute, user, password.
            /// </summary>
            /// <param name="requestId">
            /// Identifier of XHR to replay.
            /// </param>
            /// <param name="cancellation" />
            public Task ReplayXHR
            (
                Protocol.Network.RequestId @requestId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.ReplayXHRCommand
                    {
                        RequestId = @requestId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Searches for given string in response content.
            /// </summary>
            /// <param name="requestId">
            /// Identifier of the network response to search.
            /// </param>
            /// <param name="query">
            /// String to search for.
            /// </param>
            /// <param name="caseSensitive">
            /// If true, search is case sensitive.
            /// </param>
            /// <param name="isRegex">
            /// If true, treats string parameter as regex.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Network.SearchInResponseBodyResponse> SearchInResponseBody
            (
                Protocol.Network.RequestId @requestId, 
                string @query, 
                bool? @caseSensitive = default, 
                bool? @isRegex = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SearchInResponseBodyCommand
                    {
                        RequestId = @requestId,
                        Query = @query,
                        CaseSensitive = @caseSensitive,
                        IsRegex = @isRegex,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Blocks URLs from loading.
            /// </summary>
            /// <param name="urls">
            /// URL patterns to block. Wildcards ('*') are allowed.
            /// </param>
            /// <param name="cancellation" />
            public Task SetBlockedURLs
            (
                string[] @urls, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetBlockedURLsCommand
                    {
                        Urls = @urls,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Toggles ignoring of service worker for each request.
            /// </summary>
            /// <param name="bypass">
            /// Bypass service worker and load from network.
            /// </param>
            /// <param name="cancellation" />
            public Task SetBypassServiceWorker
            (
                bool @bypass, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetBypassServiceWorkerCommand
                    {
                        Bypass = @bypass,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Toggles ignoring cache for each request. If `true`, cache will not be used.
            /// </summary>
            /// <param name="cacheDisabled">
            /// Cache disabled state.
            /// </param>
            /// <param name="cancellation" />
            public Task SetCacheDisabled
            (
                bool @cacheDisabled, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetCacheDisabledCommand
                    {
                        CacheDisabled = @cacheDisabled,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets a cookie with the given cookie data; may overwrite equivalent cookies if they exist.
            /// </summary>
            /// <param name="name">
            /// Cookie name.
            /// </param>
            /// <param name="value">
            /// Cookie value.
            /// </param>
            /// <param name="url">
            /// The request-URI to associate with the setting of the cookie. This value can affect the
            /// default domain and path values of the created cookie.
            /// </param>
            /// <param name="domain">
            /// Cookie domain.
            /// </param>
            /// <param name="path">
            /// Cookie path.
            /// </param>
            /// <param name="secure">
            /// True if cookie is secure.
            /// </param>
            /// <param name="httpOnly">
            /// True if cookie is http-only.
            /// </param>
            /// <param name="sameSite">
            /// Cookie SameSite type.
            /// </param>
            /// <param name="expires">
            /// Cookie expiration date, session cookie if not set
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Network.SetCookieResponse> SetCookie
            (
                string @name, 
                string @value, 
                string @url = default, 
                string @domain = default, 
                string @path = default, 
                bool? @secure = default, 
                bool? @httpOnly = default, 
                Protocol.Network.CookieSameSite @sameSite = default, 
                Protocol.Network.TimeSinceEpoch @expires = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetCookieCommand
                    {
                        Name = @name,
                        Value = @value,
                        Url = @url,
                        Domain = @domain,
                        Path = @path,
                        Secure = @secure,
                        HttpOnly = @httpOnly,
                        SameSite = @sameSite,
                        Expires = @expires,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets given cookies.
            /// </summary>
            /// <param name="cookies">
            /// Cookies to be set.
            /// </param>
            /// <param name="cancellation" />
            public Task SetCookies
            (
                Protocol.Network.CookieParam[] @cookies, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetCookiesCommand
                    {
                        Cookies = @cookies,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// For testing.
            /// </summary>
            /// <param name="maxTotalSize">
            /// Maximum total buffer size.
            /// </param>
            /// <param name="maxResourceSize">
            /// Maximum per-resource size.
            /// </param>
            /// <param name="cancellation" />
            public Task SetDataSizeLimitsForTest
            (
                long @maxTotalSize, 
                long @maxResourceSize, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetDataSizeLimitsForTestCommand
                    {
                        MaxTotalSize = @maxTotalSize,
                        MaxResourceSize = @maxResourceSize,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Specifies whether to always send extra HTTP headers with the requests from this page.
            /// </summary>
            /// <param name="headers">
            /// Map with extra HTTP headers.
            /// </param>
            /// <param name="cancellation" />
            public Task SetExtraHTTPHeaders
            (
                Protocol.Network.Headers @headers, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetExtraHTTPHeadersCommand
                    {
                        Headers = @headers,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets the requests to intercept that match a the provided patterns and optionally resource types.
            /// </summary>
            /// <param name="patterns">
            /// Requests matching any of these patterns will be forwarded and wait for the corresponding
            /// continueInterceptedRequest call.
            /// </param>
            /// <param name="cancellation" />
            public Task SetRequestInterception
            (
                Protocol.Network.RequestPattern[] @patterns, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetRequestInterceptionCommand
                    {
                        Patterns = @patterns,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Allows overriding user agent with the given string.
            /// </summary>
            /// <param name="userAgent">
            /// User agent to use.
            /// </param>
            /// <param name="acceptLanguage">
            /// Browser langugage to emulate.
            /// </param>
            /// <param name="platform">
            /// The platform navigator.platform should return.
            /// </param>
            /// <param name="cancellation" />
            public Task SetUserAgentOverride
            (
                string @userAgent, 
                string @acceptLanguage = default, 
                string @platform = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Network.SetUserAgentOverrideCommand
                    {
                        UserAgent = @userAgent,
                        AcceptLanguage = @acceptLanguage,
                        Platform = @platform,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fired when data chunk was received over the network.
            /// </summary>
            public event Func<Protocol.Network.DataReceivedEvent, Task> DataReceived
            {
                add => InspectorClient.AddEventHandlerCore("Network.dataReceived", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.dataReceived", value);
            }

            /// <summary>
            /// Fired when EventSource message is received.
            /// </summary>
            public event Func<Protocol.Network.EventSourceMessageReceivedEvent, Task> EventSourceMessageReceived
            {
                add => InspectorClient.AddEventHandlerCore("Network.eventSourceMessageReceived", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.eventSourceMessageReceived", value);
            }

            /// <summary>
            /// Fired when HTTP request has failed to load.
            /// </summary>
            public event Func<Protocol.Network.LoadingFailedEvent, Task> LoadingFailed
            {
                add => InspectorClient.AddEventHandlerCore("Network.loadingFailed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.loadingFailed", value);
            }

            /// <summary>
            /// Fired when HTTP request has finished loading.
            /// </summary>
            public event Func<Protocol.Network.LoadingFinishedEvent, Task> LoadingFinished
            {
                add => InspectorClient.AddEventHandlerCore("Network.loadingFinished", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.loadingFinished", value);
            }

            /// <summary>
            /// Details of an intercepted HTTP request, which must be either allowed, blocked, modified or
            /// mocked.
            /// </summary>
            public event Func<Protocol.Network.RequestInterceptedEvent, Task> RequestIntercepted
            {
                add => InspectorClient.AddEventHandlerCore("Network.requestIntercepted", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.requestIntercepted", value);
            }

            /// <summary>
            /// Fired if request ended up loading from cache.
            /// </summary>
            public event Func<Protocol.Network.RequestServedFromCacheEvent, Task> RequestServedFromCache
            {
                add => InspectorClient.AddEventHandlerCore("Network.requestServedFromCache", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.requestServedFromCache", value);
            }

            /// <summary>
            /// Fired when page is about to send HTTP request.
            /// </summary>
            public event Func<Protocol.Network.RequestWillBeSentEvent, Task> RequestWillBeSent
            {
                add => InspectorClient.AddEventHandlerCore("Network.requestWillBeSent", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.requestWillBeSent", value);
            }

            /// <summary>
            /// Fired when resource loading priority is changed
            /// </summary>
            public event Func<Protocol.Network.ResourceChangedPriorityEvent, Task> ResourceChangedPriority
            {
                add => InspectorClient.AddEventHandlerCore("Network.resourceChangedPriority", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.resourceChangedPriority", value);
            }

            /// <summary>
            /// Fired when a signed exchange was received over the network
            /// </summary>
            public event Func<Protocol.Network.SignedExchangeReceivedEvent, Task> SignedExchangeReceived
            {
                add => InspectorClient.AddEventHandlerCore("Network.signedExchangeReceived", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.signedExchangeReceived", value);
            }

            /// <summary>
            /// Fired when HTTP response is available.
            /// </summary>
            public event Func<Protocol.Network.ResponseReceivedEvent, Task> ResponseReceived
            {
                add => InspectorClient.AddEventHandlerCore("Network.responseReceived", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.responseReceived", value);
            }

            /// <summary>
            /// Fired when WebSocket is closed.
            /// </summary>
            public event Func<Protocol.Network.WebSocketClosedEvent, Task> WebSocketClosed
            {
                add => InspectorClient.AddEventHandlerCore("Network.webSocketClosed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.webSocketClosed", value);
            }

            /// <summary>
            /// Fired upon WebSocket creation.
            /// </summary>
            public event Func<Protocol.Network.WebSocketCreatedEvent, Task> WebSocketCreated
            {
                add => InspectorClient.AddEventHandlerCore("Network.webSocketCreated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.webSocketCreated", value);
            }

            /// <summary>
            /// Fired when WebSocket message error occurs.
            /// </summary>
            public event Func<Protocol.Network.WebSocketFrameErrorEvent, Task> WebSocketFrameError
            {
                add => InspectorClient.AddEventHandlerCore("Network.webSocketFrameError", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.webSocketFrameError", value);
            }

            /// <summary>
            /// Fired when WebSocket message is received.
            /// </summary>
            public event Func<Protocol.Network.WebSocketFrameReceivedEvent, Task> WebSocketFrameReceived
            {
                add => InspectorClient.AddEventHandlerCore("Network.webSocketFrameReceived", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.webSocketFrameReceived", value);
            }

            /// <summary>
            /// Fired when WebSocket message is sent.
            /// </summary>
            public event Func<Protocol.Network.WebSocketFrameSentEvent, Task> WebSocketFrameSent
            {
                add => InspectorClient.AddEventHandlerCore("Network.webSocketFrameSent", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.webSocketFrameSent", value);
            }

            /// <summary>
            /// Fired when WebSocket handshake response becomes available.
            /// </summary>
            public event Func<Protocol.Network.WebSocketHandshakeResponseReceivedEvent, Task> WebSocketHandshakeResponseReceived
            {
                add => InspectorClient.AddEventHandlerCore("Network.webSocketHandshakeResponseReceived", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.webSocketHandshakeResponseReceived", value);
            }

            /// <summary>
            /// Fired when WebSocket is about to initiate handshake.
            /// </summary>
            public event Func<Protocol.Network.WebSocketWillSendHandshakeRequestEvent, Task> WebSocketWillSendHandshakeRequest
            {
                add => InspectorClient.AddEventHandlerCore("Network.webSocketWillSendHandshakeRequest", value);
                remove => InspectorClient.RemoveEventHandlerCore("Network.webSocketWillSendHandshakeRequest", value);
            }

            /// <summary>
            /// Fired when data chunk was received over the network.
            /// </summary>
            public Task<Protocol.Network.DataReceivedEvent> DataReceivedEvent(Func<Protocol.Network.DataReceivedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.dataReceived", until);
            }

            /// <summary>
            /// Fired when EventSource message is received.
            /// </summary>
            public Task<Protocol.Network.EventSourceMessageReceivedEvent> EventSourceMessageReceivedEvent(Func<Protocol.Network.EventSourceMessageReceivedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.eventSourceMessageReceived", until);
            }

            /// <summary>
            /// Fired when HTTP request has failed to load.
            /// </summary>
            public Task<Protocol.Network.LoadingFailedEvent> LoadingFailedEvent(Func<Protocol.Network.LoadingFailedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.loadingFailed", until);
            }

            /// <summary>
            /// Fired when HTTP request has finished loading.
            /// </summary>
            public Task<Protocol.Network.LoadingFinishedEvent> LoadingFinishedEvent(Func<Protocol.Network.LoadingFinishedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.loadingFinished", until);
            }

            /// <summary>
            /// Details of an intercepted HTTP request, which must be either allowed, blocked, modified or
            /// mocked.
            /// </summary>
            public Task<Protocol.Network.RequestInterceptedEvent> RequestInterceptedEvent(Func<Protocol.Network.RequestInterceptedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.requestIntercepted", until);
            }

            /// <summary>
            /// Fired if request ended up loading from cache.
            /// </summary>
            public Task<Protocol.Network.RequestServedFromCacheEvent> RequestServedFromCacheEvent(Func<Protocol.Network.RequestServedFromCacheEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.requestServedFromCache", until);
            }

            /// <summary>
            /// Fired when page is about to send HTTP request.
            /// </summary>
            public Task<Protocol.Network.RequestWillBeSentEvent> RequestWillBeSentEvent(Func<Protocol.Network.RequestWillBeSentEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.requestWillBeSent", until);
            }

            /// <summary>
            /// Fired when resource loading priority is changed
            /// </summary>
            public Task<Protocol.Network.ResourceChangedPriorityEvent> ResourceChangedPriorityEvent(Func<Protocol.Network.ResourceChangedPriorityEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.resourceChangedPriority", until);
            }

            /// <summary>
            /// Fired when a signed exchange was received over the network
            /// </summary>
            public Task<Protocol.Network.SignedExchangeReceivedEvent> SignedExchangeReceivedEvent(Func<Protocol.Network.SignedExchangeReceivedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.signedExchangeReceived", until);
            }

            /// <summary>
            /// Fired when HTTP response is available.
            /// </summary>
            public Task<Protocol.Network.ResponseReceivedEvent> ResponseReceivedEvent(Func<Protocol.Network.ResponseReceivedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.responseReceived", until);
            }

            /// <summary>
            /// Fired when WebSocket is closed.
            /// </summary>
            public Task<Protocol.Network.WebSocketClosedEvent> WebSocketClosedEvent(Func<Protocol.Network.WebSocketClosedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.webSocketClosed", until);
            }

            /// <summary>
            /// Fired upon WebSocket creation.
            /// </summary>
            public Task<Protocol.Network.WebSocketCreatedEvent> WebSocketCreatedEvent(Func<Protocol.Network.WebSocketCreatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.webSocketCreated", until);
            }

            /// <summary>
            /// Fired when WebSocket message error occurs.
            /// </summary>
            public Task<Protocol.Network.WebSocketFrameErrorEvent> WebSocketFrameErrorEvent(Func<Protocol.Network.WebSocketFrameErrorEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.webSocketFrameError", until);
            }

            /// <summary>
            /// Fired when WebSocket message is received.
            /// </summary>
            public Task<Protocol.Network.WebSocketFrameReceivedEvent> WebSocketFrameReceivedEvent(Func<Protocol.Network.WebSocketFrameReceivedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.webSocketFrameReceived", until);
            }

            /// <summary>
            /// Fired when WebSocket message is sent.
            /// </summary>
            public Task<Protocol.Network.WebSocketFrameSentEvent> WebSocketFrameSentEvent(Func<Protocol.Network.WebSocketFrameSentEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.webSocketFrameSent", until);
            }

            /// <summary>
            /// Fired when WebSocket handshake response becomes available.
            /// </summary>
            public Task<Protocol.Network.WebSocketHandshakeResponseReceivedEvent> WebSocketHandshakeResponseReceivedEvent(Func<Protocol.Network.WebSocketHandshakeResponseReceivedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.webSocketHandshakeResponseReceived", until);
            }

            /// <summary>
            /// Fired when WebSocket is about to initiate handshake.
            /// </summary>
            public Task<Protocol.Network.WebSocketWillSendHandshakeRequestEvent> WebSocketWillSendHandshakeRequestEvent(Func<Protocol.Network.WebSocketWillSendHandshakeRequestEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Network.webSocketWillSendHandshakeRequest", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Overlay.
        /// </summary>
        public class OverlayInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal OverlayInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disables domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// For testing.
            /// </summary>
            /// <param name="nodeId">
            /// Id of the node to get highlight object for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Overlay.GetHighlightObjectForTestResponse> GetHighlightObjectForTest
            (
                Protocol.DOM.NodeId @nodeId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.GetHighlightObjectForTestCommand
                    {
                        NodeId = @nodeId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Hides any highlight.
            /// </summary>
            /// <param name="cancellation" />
            public Task HideHighlight
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.HideHighlightCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Highlights owner element of the frame with given id.
            /// </summary>
            /// <param name="frameId">
            /// Identifier of the frame to highlight.
            /// </param>
            /// <param name="contentColor">
            /// The content box highlight fill color (default: transparent).
            /// </param>
            /// <param name="contentOutlineColor">
            /// The content box highlight outline color (default: transparent).
            /// </param>
            /// <param name="cancellation" />
            public Task HighlightFrame
            (
                Protocol.Page.FrameId @frameId, 
                Protocol.DOM.RGBA @contentColor = default, 
                Protocol.DOM.RGBA @contentOutlineColor = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.HighlightFrameCommand
                    {
                        FrameId = @frameId,
                        ContentColor = @contentColor,
                        ContentOutlineColor = @contentOutlineColor,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Highlights DOM node with given id or with the given JavaScript object wrapper. Either nodeId or
            /// objectId must be specified.
            /// </summary>
            /// <param name="highlightConfig">
            /// A descriptor for the highlight appearance.
            /// </param>
            /// <param name="nodeId">
            /// Identifier of the node to highlight.
            /// </param>
            /// <param name="backendNodeId">
            /// Identifier of the backend node to highlight.
            /// </param>
            /// <param name="objectId">
            /// JavaScript object id of the node to be highlighted.
            /// </param>
            /// <param name="selector">
            /// Selectors to highlight relevant nodes.
            /// </param>
            /// <param name="cancellation" />
            public Task HighlightNode
            (
                Protocol.Overlay.HighlightConfig @highlightConfig, 
                Protocol.DOM.NodeId @nodeId = default, 
                Protocol.DOM.BackendNodeId @backendNodeId = default, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                string @selector = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.HighlightNodeCommand
                    {
                        HighlightConfig = @highlightConfig,
                        NodeId = @nodeId,
                        BackendNodeId = @backendNodeId,
                        ObjectId = @objectId,
                        Selector = @selector,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Highlights given quad. Coordinates are absolute with respect to the main frame viewport.
            /// </summary>
            /// <param name="quad">
            /// Quad to highlight
            /// </param>
            /// <param name="color">
            /// The highlight fill color (default: transparent).
            /// </param>
            /// <param name="outlineColor">
            /// The highlight outline color (default: transparent).
            /// </param>
            /// <param name="cancellation" />
            public Task HighlightQuad
            (
                Protocol.DOM.Quad @quad, 
                Protocol.DOM.RGBA @color = default, 
                Protocol.DOM.RGBA @outlineColor = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.HighlightQuadCommand
                    {
                        Quad = @quad,
                        Color = @color,
                        OutlineColor = @outlineColor,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Highlights given rectangle. Coordinates are absolute with respect to the main frame viewport.
            /// </summary>
            /// <param name="x">
            /// X coordinate
            /// </param>
            /// <param name="y">
            /// Y coordinate
            /// </param>
            /// <param name="width">
            /// Rectangle width
            /// </param>
            /// <param name="height">
            /// Rectangle height
            /// </param>
            /// <param name="color">
            /// The highlight fill color (default: transparent).
            /// </param>
            /// <param name="outlineColor">
            /// The highlight outline color (default: transparent).
            /// </param>
            /// <param name="cancellation" />
            public Task HighlightRect
            (
                long @x, 
                long @y, 
                long @width, 
                long @height, 
                Protocol.DOM.RGBA @color = default, 
                Protocol.DOM.RGBA @outlineColor = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.HighlightRectCommand
                    {
                        X = @x,
                        Y = @y,
                        Width = @width,
                        Height = @height,
                        Color = @color,
                        OutlineColor = @outlineColor,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enters the 'inspect' mode. In this mode, elements that user is hovering over are highlighted.
            /// Backend then generates 'inspectNodeRequested' event upon element selection.
            /// </summary>
            /// <param name="mode">
            /// Set an inspection mode.
            /// </param>
            /// <param name="highlightConfig">
            /// A descriptor for the highlight appearance of hovered-over nodes. May be omitted if `enabled
            /// == false`.
            /// </param>
            /// <param name="cancellation" />
            public Task SetInspectMode
            (
                Protocol.Overlay.InspectMode @mode, 
                Protocol.Overlay.HighlightConfig @highlightConfig = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetInspectModeCommand
                    {
                        Mode = @mode,
                        HighlightConfig = @highlightConfig,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Highlights owner element of all frames detected to be ads.
            /// </summary>
            /// <param name="show">
            /// True for showing ad highlights
            /// </param>
            /// <param name="cancellation" />
            public Task SetShowAdHighlights
            (
                bool @show, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetShowAdHighlightsCommand
                    {
                        Show = @show,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="message">
            /// The message to display, also triggers resume and step over controls.
            /// </param>
            /// <param name="cancellation" />
            public Task SetPausedInDebuggerMessage
            (
                string @message = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetPausedInDebuggerMessageCommand
                    {
                        Message = @message,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that backend shows debug borders on layers
            /// </summary>
            /// <param name="show">
            /// True for showing debug borders
            /// </param>
            /// <param name="cancellation" />
            public Task SetShowDebugBorders
            (
                bool @show, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetShowDebugBordersCommand
                    {
                        Show = @show,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that backend shows the FPS counter
            /// </summary>
            /// <param name="show">
            /// True for showing the FPS counter
            /// </param>
            /// <param name="cancellation" />
            public Task SetShowFPSCounter
            (
                bool @show, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetShowFPSCounterCommand
                    {
                        Show = @show,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that backend shows paint rectangles
            /// </summary>
            /// <param name="result">
            /// True for showing paint rectangles
            /// </param>
            /// <param name="cancellation" />
            public Task SetShowPaintRects
            (
                bool @result, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetShowPaintRectsCommand
                    {
                        Result = @result,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that backend shows scroll bottleneck rects
            /// </summary>
            /// <param name="show">
            /// True for showing scroll bottleneck rects
            /// </param>
            /// <param name="cancellation" />
            public Task SetShowScrollBottleneckRects
            (
                bool @show, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetShowScrollBottleneckRectsCommand
                    {
                        Show = @show,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Requests that backend shows hit-test borders on layers
            /// </summary>
            /// <param name="show">
            /// True for showing hit-test borders
            /// </param>
            /// <param name="cancellation" />
            public Task SetShowHitTestBorders
            (
                bool @show, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetShowHitTestBordersCommand
                    {
                        Show = @show,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Paints viewport size upon main frame resize.
            /// </summary>
            /// <param name="show">
            /// Whether to paint size or not.
            /// </param>
            /// <param name="cancellation" />
            public Task SetShowViewportSizeOnResize
            (
                bool @show, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetShowViewportSizeOnResizeCommand
                    {
                        Show = @show,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="suspended">
            /// Whether overlay should be suspended and not consume any resources until resumed.
            /// </param>
            /// <param name="cancellation" />
            public Task SetSuspended
            (
                bool @suspended, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Overlay.SetSuspendedCommand
                    {
                        Suspended = @suspended,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fired when the node should be inspected. This happens after call to `setInspectMode` or when
            /// user manually inspects an element.
            /// </summary>
            public event Func<Protocol.Overlay.InspectNodeRequestedEvent, Task> InspectNodeRequested
            {
                add => InspectorClient.AddEventHandlerCore("Overlay.inspectNodeRequested", value);
                remove => InspectorClient.RemoveEventHandlerCore("Overlay.inspectNodeRequested", value);
            }

            /// <summary>
            /// Fired when the node should be highlighted. This happens after call to `setInspectMode`.
            /// </summary>
            public event Func<Protocol.Overlay.NodeHighlightRequestedEvent, Task> NodeHighlightRequested
            {
                add => InspectorClient.AddEventHandlerCore("Overlay.nodeHighlightRequested", value);
                remove => InspectorClient.RemoveEventHandlerCore("Overlay.nodeHighlightRequested", value);
            }

            /// <summary>
            /// Fired when user asks to capture screenshot of some area on the page.
            /// </summary>
            public event Func<Protocol.Overlay.ScreenshotRequestedEvent, Task> ScreenshotRequested
            {
                add => InspectorClient.AddEventHandlerCore("Overlay.screenshotRequested", value);
                remove => InspectorClient.RemoveEventHandlerCore("Overlay.screenshotRequested", value);
            }

            /// <summary>
            /// Fired when user cancels the inspect mode.
            /// </summary>
            public event Func<Protocol.Overlay.InspectModeCanceledEvent, Task> InspectModeCanceled
            {
                add => InspectorClient.AddEventHandlerCore("Overlay.inspectModeCanceled", value);
                remove => InspectorClient.RemoveEventHandlerCore("Overlay.inspectModeCanceled", value);
            }

            /// <summary>
            /// Fired when the node should be inspected. This happens after call to `setInspectMode` or when
            /// user manually inspects an element.
            /// </summary>
            public Task<Protocol.Overlay.InspectNodeRequestedEvent> InspectNodeRequestedEvent(Func<Protocol.Overlay.InspectNodeRequestedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Overlay.inspectNodeRequested", until);
            }

            /// <summary>
            /// Fired when the node should be highlighted. This happens after call to `setInspectMode`.
            /// </summary>
            public Task<Protocol.Overlay.NodeHighlightRequestedEvent> NodeHighlightRequestedEvent(Func<Protocol.Overlay.NodeHighlightRequestedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Overlay.nodeHighlightRequested", until);
            }

            /// <summary>
            /// Fired when user asks to capture screenshot of some area on the page.
            /// </summary>
            public Task<Protocol.Overlay.ScreenshotRequestedEvent> ScreenshotRequestedEvent(Func<Protocol.Overlay.ScreenshotRequestedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Overlay.screenshotRequested", until);
            }

            /// <summary>
            /// Fired when user cancels the inspect mode.
            /// </summary>
            public Task<Protocol.Overlay.InspectModeCanceledEvent> InspectModeCanceledEvent(Func<Protocol.Overlay.InspectModeCanceledEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Overlay.inspectModeCanceled", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Page.
        /// </summary>
        public class PageInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal PageInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Deprecated, please use addScriptToEvaluateOnNewDocument instead.
            /// </summary>
            /// <param name="scriptSource" />
            /// <param name="cancellation" />
            [Obsolete]
            public Task<Protocol.Page.AddScriptToEvaluateOnLoadResponse> AddScriptToEvaluateOnLoad
            (
                string @scriptSource, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.AddScriptToEvaluateOnLoadCommand
                    {
                        ScriptSource = @scriptSource,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Evaluates given script in every frame upon creation (before loading frame's scripts).
            /// </summary>
            /// <param name="source" />
            /// <param name="worldName">
            /// If specified, creates an isolated world with the given name and evaluates given script in it.
            /// This world name will be used as the ExecutionContextDescription::name when the corresponding
            /// event is emitted.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Page.AddScriptToEvaluateOnNewDocumentResponse> AddScriptToEvaluateOnNewDocument
            (
                string @source, 
                string @worldName = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.AddScriptToEvaluateOnNewDocumentCommand
                    {
                        Source = @source,
                        WorldName = @worldName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Brings page to front (activates tab).
            /// </summary>
            /// <param name="cancellation" />
            public Task BringToFront
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.BringToFrontCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Capture page screenshot.
            /// </summary>
            /// <param name="format">
            /// Image compression format (defaults to png).
            /// </param>
            /// <param name="quality">
            /// Compression quality from range [0..100] (jpeg only).
            /// </param>
            /// <param name="clip">
            /// Capture the screenshot of a given region only.
            /// </param>
            /// <param name="fromSurface">
            /// Capture the screenshot from the surface, rather than the view. Defaults to true.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Page.CaptureScreenshotResponse> CaptureScreenshot
            (
                string @format = default, 
                long? @quality = default, 
                Protocol.Page.Viewport @clip = default, 
                bool? @fromSurface = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.CaptureScreenshotCommand
                    {
                        Format = @format,
                        Quality = @quality,
                        Clip = @clip,
                        FromSurface = @fromSurface,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns a snapshot of the page as a string. For MHTML format, the serialization includes
            /// iframes, shadow DOM, external resources, and element-inline styles.
            /// </summary>
            /// <param name="format">
            /// Format (defaults to mhtml).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Page.CaptureSnapshotResponse> CaptureSnapshot
            (
                string @format = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.CaptureSnapshotCommand
                    {
                        Format = @format,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Clears the overriden device metrics.
            /// </summary>
            /// <param name="cancellation" />
            [Obsolete]
            public Task ClearDeviceMetricsOverride
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.ClearDeviceMetricsOverrideCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Clears the overridden Device Orientation.
            /// </summary>
            /// <param name="cancellation" />
            [Obsolete]
            public Task ClearDeviceOrientationOverride
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.ClearDeviceOrientationOverrideCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Clears the overriden Geolocation Position and Error.
            /// </summary>
            /// <param name="cancellation" />
            [Obsolete]
            public Task ClearGeolocationOverride
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.ClearGeolocationOverrideCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Creates an isolated world for the given frame.
            /// </summary>
            /// <param name="frameId">
            /// Id of the frame in which the isolated world should be created.
            /// </param>
            /// <param name="worldName">
            /// An optional name which is reported in the Execution Context.
            /// </param>
            /// <param name="grantUniveralAccess">
            /// Whether or not universal access should be granted to the isolated world. This is a powerful
            /// option, use with caution.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Page.CreateIsolatedWorldResponse> CreateIsolatedWorld
            (
                Protocol.Page.FrameId @frameId, 
                string @worldName = default, 
                bool? @grantUniveralAccess = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.CreateIsolatedWorldCommand
                    {
                        FrameId = @frameId,
                        WorldName = @worldName,
                        GrantUniveralAccess = @grantUniveralAccess,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Deletes browser cookie with given name, domain and path.
            /// </summary>
            /// <param name="cookieName">
            /// Name of the cookie to remove.
            /// </param>
            /// <param name="url">
            /// URL to match cooke domain and path.
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task DeleteCookie
            (
                string @cookieName, 
                string @url, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.DeleteCookieCommand
                    {
                        CookieName = @cookieName,
                        Url = @url,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables page domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables page domain notifications.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task<Protocol.Page.GetAppManifestResponse> GetAppManifest
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.GetAppManifestCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns all browser cookies. Depending on the backend support, will return detailed cookie
            /// information in the `cookies` field.
            /// </summary>
            /// <param name="cancellation" />
            [Obsolete]
            public Task<Protocol.Page.GetCookiesResponse> GetCookies
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.GetCookiesCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns present frame tree structure.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Page.GetFrameTreeResponse> GetFrameTree
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.GetFrameTreeCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns metrics relating to the layouting of the page, such as viewport bounds/scale.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Page.GetLayoutMetricsResponse> GetLayoutMetrics
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.GetLayoutMetricsCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns navigation history for the current page.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Page.GetNavigationHistoryResponse> GetNavigationHistory
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.GetNavigationHistoryCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Resets navigation history for the current page.
            /// </summary>
            /// <param name="cancellation" />
            public Task ResetNavigationHistory
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.ResetNavigationHistoryCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns content of the given resource.
            /// </summary>
            /// <param name="frameId">
            /// Frame id to get resource for.
            /// </param>
            /// <param name="url">
            /// URL of the resource to get content for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Page.GetResourceContentResponse> GetResourceContent
            (
                Protocol.Page.FrameId @frameId, 
                string @url, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.GetResourceContentCommand
                    {
                        FrameId = @frameId,
                        Url = @url,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns present frame / resource tree structure.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Page.GetResourceTreeResponse> GetResourceTree
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.GetResourceTreeCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Accepts or dismisses a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload).
            /// </summary>
            /// <param name="accept">
            /// Whether to accept or dismiss the dialog.
            /// </param>
            /// <param name="promptText">
            /// The text to enter into the dialog prompt before accepting. Used only if this is a prompt
            /// dialog.
            /// </param>
            /// <param name="cancellation" />
            public Task HandleJavaScriptDialog
            (
                bool @accept, 
                string @promptText = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.HandleJavaScriptDialogCommand
                    {
                        Accept = @accept,
                        PromptText = @promptText,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Navigates current page to the given URL.
            /// </summary>
            /// <param name="url">
            /// URL to navigate the page to.
            /// </param>
            /// <param name="referrer">
            /// Referrer URL.
            /// </param>
            /// <param name="transitionType">
            /// Intended transition type.
            /// </param>
            /// <param name="frameId">
            /// Frame id to navigate, if not specified navigates the top frame.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Page.NavigateResponse> Navigate
            (
                string @url, 
                string @referrer = default, 
                Protocol.Page.TransitionType @transitionType = default, 
                Protocol.Page.FrameId @frameId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.NavigateCommand
                    {
                        Url = @url,
                        Referrer = @referrer,
                        TransitionType = @transitionType,
                        FrameId = @frameId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Navigates current page to the given history entry.
            /// </summary>
            /// <param name="entryId">
            /// Unique id of the entry to navigate to.
            /// </param>
            /// <param name="cancellation" />
            public Task NavigateToHistoryEntry
            (
                long @entryId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.NavigateToHistoryEntryCommand
                    {
                        EntryId = @entryId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Print page as PDF.
            /// </summary>
            /// <param name="landscape">
            /// Paper orientation. Defaults to false.
            /// </param>
            /// <param name="displayHeaderFooter">
            /// Display header and footer. Defaults to false.
            /// </param>
            /// <param name="printBackground">
            /// Print background graphics. Defaults to false.
            /// </param>
            /// <param name="scale">
            /// Scale of the webpage rendering. Defaults to 1.
            /// </param>
            /// <param name="paperWidth">
            /// Paper width in inches. Defaults to 8.5 inches.
            /// </param>
            /// <param name="paperHeight">
            /// Paper height in inches. Defaults to 11 inches.
            /// </param>
            /// <param name="marginTop">
            /// Top margin in inches. Defaults to 1cm (~0.4 inches).
            /// </param>
            /// <param name="marginBottom">
            /// Bottom margin in inches. Defaults to 1cm (~0.4 inches).
            /// </param>
            /// <param name="marginLeft">
            /// Left margin in inches. Defaults to 1cm (~0.4 inches).
            /// </param>
            /// <param name="marginRight">
            /// Right margin in inches. Defaults to 1cm (~0.4 inches).
            /// </param>
            /// <param name="pageRanges">
            /// Paper ranges to print, e.g., '1-5, 8, 11-13'. Defaults to the empty string, which means
            /// print all pages.
            /// </param>
            /// <param name="ignoreInvalidPageRanges">
            /// Whether to silently ignore invalid but successfully parsed page ranges, such as '3-2'.
            /// Defaults to false.
            /// </param>
            /// <param name="headerTemplate">
            /// HTML template for the print header. Should be valid HTML markup with following
            /// classes used to inject printing values into them:
            /// - `date`: formatted print date
            /// - `title`: document title
            /// - `url`: document location
            /// - `pageNumber`: current page number
            /// - `totalPages`: total pages in the document
            /// 
            /// For example, `&lt;span class=title&gt;&lt;/span&gt;` would generate span containing the title.
            /// </param>
            /// <param name="footerTemplate">
            /// HTML template for the print footer. Should use the same format as the `headerTemplate`.
            /// </param>
            /// <param name="preferCSSPageSize">
            /// Whether or not to prefer page size as defined by css. Defaults to false,
            /// in which case the content will be scaled to fit the paper size.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Page.PrintToPDFResponse> PrintToPDF
            (
                bool? @landscape = default, 
                bool? @displayHeaderFooter = default, 
                bool? @printBackground = default, 
                double? @scale = default, 
                double? @paperWidth = default, 
                double? @paperHeight = default, 
                double? @marginTop = default, 
                double? @marginBottom = default, 
                double? @marginLeft = default, 
                double? @marginRight = default, 
                string @pageRanges = default, 
                bool? @ignoreInvalidPageRanges = default, 
                string @headerTemplate = default, 
                string @footerTemplate = default, 
                bool? @preferCSSPageSize = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.PrintToPDFCommand
                    {
                        Landscape = @landscape,
                        DisplayHeaderFooter = @displayHeaderFooter,
                        PrintBackground = @printBackground,
                        Scale = @scale,
                        PaperWidth = @paperWidth,
                        PaperHeight = @paperHeight,
                        MarginTop = @marginTop,
                        MarginBottom = @marginBottom,
                        MarginLeft = @marginLeft,
                        MarginRight = @marginRight,
                        PageRanges = @pageRanges,
                        IgnoreInvalidPageRanges = @ignoreInvalidPageRanges,
                        HeaderTemplate = @headerTemplate,
                        FooterTemplate = @footerTemplate,
                        PreferCSSPageSize = @preferCSSPageSize,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Reloads given page optionally ignoring the cache.
            /// </summary>
            /// <param name="ignoreCache">
            /// If true, browser cache is ignored (as if the user pressed Shift+refresh).
            /// </param>
            /// <param name="scriptToEvaluateOnLoad">
            /// If set, the script will be injected into all frames of the inspected page after reload.
            /// Argument will be ignored if reloading dataURL origin.
            /// </param>
            /// <param name="cancellation" />
            public Task Reload
            (
                bool? @ignoreCache = default, 
                string @scriptToEvaluateOnLoad = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.ReloadCommand
                    {
                        IgnoreCache = @ignoreCache,
                        ScriptToEvaluateOnLoad = @scriptToEvaluateOnLoad,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Deprecated, please use removeScriptToEvaluateOnNewDocument instead.
            /// </summary>
            /// <param name="identifier" />
            /// <param name="cancellation" />
            [Obsolete]
            public Task RemoveScriptToEvaluateOnLoad
            (
                Protocol.Page.ScriptIdentifier @identifier, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.RemoveScriptToEvaluateOnLoadCommand
                    {
                        Identifier = @identifier,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Removes given script from the list.
            /// </summary>
            /// <param name="identifier" />
            /// <param name="cancellation" />
            public Task RemoveScriptToEvaluateOnNewDocument
            (
                Protocol.Page.ScriptIdentifier @identifier, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.RemoveScriptToEvaluateOnNewDocumentCommand
                    {
                        Identifier = @identifier,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Acknowledges that a screencast frame has been received by the frontend.
            /// </summary>
            /// <param name="sessionId">
            /// Frame number.
            /// </param>
            /// <param name="cancellation" />
            public Task ScreencastFrameAck
            (
                long @sessionId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.ScreencastFrameAckCommand
                    {
                        SessionId = @sessionId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Searches for given string in resource content.
            /// </summary>
            /// <param name="frameId">
            /// Frame id for resource to search in.
            /// </param>
            /// <param name="url">
            /// URL of the resource to search in.
            /// </param>
            /// <param name="query">
            /// String to search for.
            /// </param>
            /// <param name="caseSensitive">
            /// If true, search is case sensitive.
            /// </param>
            /// <param name="isRegex">
            /// If true, treats string parameter as regex.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Page.SearchInResourceResponse> SearchInResource
            (
                Protocol.Page.FrameId @frameId, 
                string @url, 
                string @query, 
                bool? @caseSensitive = default, 
                bool? @isRegex = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SearchInResourceCommand
                    {
                        FrameId = @frameId,
                        Url = @url,
                        Query = @query,
                        CaseSensitive = @caseSensitive,
                        IsRegex = @isRegex,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enable Chrome's experimental ad filter on all sites.
            /// </summary>
            /// <param name="enabled">
            /// Whether to block ads.
            /// </param>
            /// <param name="cancellation" />
            public Task SetAdBlockingEnabled
            (
                bool @enabled, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetAdBlockingEnabledCommand
                    {
                        Enabled = @enabled,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enable page Content Security Policy by-passing.
            /// </summary>
            /// <param name="enabled">
            /// Whether to bypass page CSP.
            /// </param>
            /// <param name="cancellation" />
            public Task SetBypassCSP
            (
                bool @enabled, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetBypassCSPCommand
                    {
                        Enabled = @enabled,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Overrides the values of device screen dimensions (window.screen.width, window.screen.height,
            /// window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS media
            /// query results).
            /// </summary>
            /// <param name="width">
            /// Overriding width value in pixels (minimum 0, maximum 10000000). 0 disables the override.
            /// </param>
            /// <param name="height">
            /// Overriding height value in pixels (minimum 0, maximum 10000000). 0 disables the override.
            /// </param>
            /// <param name="deviceScaleFactor">
            /// Overriding device scale factor value. 0 disables the override.
            /// </param>
            /// <param name="mobile">
            /// Whether to emulate mobile device. This includes viewport meta tag, overlay scrollbars, text
            /// autosizing and more.
            /// </param>
            /// <param name="scale">
            /// Scale to apply to resulting view image.
            /// </param>
            /// <param name="screenWidth">
            /// Overriding screen width value in pixels (minimum 0, maximum 10000000).
            /// </param>
            /// <param name="screenHeight">
            /// Overriding screen height value in pixels (minimum 0, maximum 10000000).
            /// </param>
            /// <param name="positionX">
            /// Overriding view X position on screen in pixels (minimum 0, maximum 10000000).
            /// </param>
            /// <param name="positionY">
            /// Overriding view Y position on screen in pixels (minimum 0, maximum 10000000).
            /// </param>
            /// <param name="dontSetVisibleSize">
            /// Do not set visible view size, rely upon explicit setVisibleSize call.
            /// </param>
            /// <param name="screenOrientation">
            /// Screen orientation override.
            /// </param>
            /// <param name="viewport">
            /// The viewport dimensions and scale. If not set, the override is cleared.
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task SetDeviceMetricsOverride
            (
                long @width, 
                long @height, 
                double @deviceScaleFactor, 
                bool @mobile, 
                double? @scale = default, 
                long? @screenWidth = default, 
                long? @screenHeight = default, 
                long? @positionX = default, 
                long? @positionY = default, 
                bool? @dontSetVisibleSize = default, 
                Protocol.Emulation.ScreenOrientation @screenOrientation = default, 
                Protocol.Page.Viewport @viewport = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetDeviceMetricsOverrideCommand
                    {
                        Width = @width,
                        Height = @height,
                        DeviceScaleFactor = @deviceScaleFactor,
                        Mobile = @mobile,
                        Scale = @scale,
                        ScreenWidth = @screenWidth,
                        ScreenHeight = @screenHeight,
                        PositionX = @positionX,
                        PositionY = @positionY,
                        DontSetVisibleSize = @dontSetVisibleSize,
                        ScreenOrientation = @screenOrientation,
                        Viewport = @viewport,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Overrides the Device Orientation.
            /// </summary>
            /// <param name="alpha">
            /// Mock alpha
            /// </param>
            /// <param name="beta">
            /// Mock beta
            /// </param>
            /// <param name="gamma">
            /// Mock gamma
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task SetDeviceOrientationOverride
            (
                double @alpha, 
                double @beta, 
                double @gamma, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetDeviceOrientationOverrideCommand
                    {
                        Alpha = @alpha,
                        Beta = @beta,
                        Gamma = @gamma,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Set generic font families.
            /// </summary>
            /// <param name="fontFamilies">
            /// Specifies font families to set. If a font family is not specified, it won't be changed.
            /// </param>
            /// <param name="cancellation" />
            public Task SetFontFamilies
            (
                Protocol.Page.FontFamilies @fontFamilies, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetFontFamiliesCommand
                    {
                        FontFamilies = @fontFamilies,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Set default font sizes.
            /// </summary>
            /// <param name="fontSizes">
            /// Specifies font sizes to set. If a font size is not specified, it won't be changed.
            /// </param>
            /// <param name="cancellation" />
            public Task SetFontSizes
            (
                Protocol.Page.FontSizes @fontSizes, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetFontSizesCommand
                    {
                        FontSizes = @fontSizes,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets given markup as the document's HTML.
            /// </summary>
            /// <param name="frameId">
            /// Frame id to set HTML for.
            /// </param>
            /// <param name="html">
            /// HTML content to set.
            /// </param>
            /// <param name="cancellation" />
            public Task SetDocumentContent
            (
                Protocol.Page.FrameId @frameId, 
                string @html, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetDocumentContentCommand
                    {
                        FrameId = @frameId,
                        Html = @html,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Set the behavior when downloading a file.
            /// </summary>
            /// <param name="behavior">
            /// Whether to allow all or deny all download requests, or use default Chrome behavior if
            /// available (otherwise deny).
            /// </param>
            /// <param name="downloadPath">
            /// The default path to save downloaded files to. This is requred if behavior is set to 'allow'
            /// </param>
            /// <param name="cancellation" />
            public Task SetDownloadBehavior
            (
                string @behavior, 
                string @downloadPath = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetDownloadBehaviorCommand
                    {
                        Behavior = @behavior,
                        DownloadPath = @downloadPath,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Overrides the Geolocation Position or Error. Omitting any of the parameters emulates position
            /// unavailable.
            /// </summary>
            /// <param name="latitude">
            /// Mock latitude
            /// </param>
            /// <param name="longitude">
            /// Mock longitude
            /// </param>
            /// <param name="accuracy">
            /// Mock accuracy
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task SetGeolocationOverride
            (
                double? @latitude = default, 
                double? @longitude = default, 
                double? @accuracy = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetGeolocationOverrideCommand
                    {
                        Latitude = @latitude,
                        Longitude = @longitude,
                        Accuracy = @accuracy,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Controls whether page will emit lifecycle events.
            /// </summary>
            /// <param name="enabled">
            /// If true, starts emitting lifecycle events.
            /// </param>
            /// <param name="cancellation" />
            public Task SetLifecycleEventsEnabled
            (
                bool @enabled, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetLifecycleEventsEnabledCommand
                    {
                        Enabled = @enabled,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Toggles mouse event-based touch event emulation.
            /// </summary>
            /// <param name="enabled">
            /// Whether the touch event emulation should be enabled.
            /// </param>
            /// <param name="configuration">
            /// Touch/gesture events configuration. Default: current platform.
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task SetTouchEmulationEnabled
            (
                bool @enabled, 
                string @configuration = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetTouchEmulationEnabledCommand
                    {
                        Enabled = @enabled,
                        Configuration = @configuration,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Starts sending each frame using the `screencastFrame` event.
            /// </summary>
            /// <param name="format">
            /// Image compression format.
            /// </param>
            /// <param name="quality">
            /// Compression quality from range [0..100].
            /// </param>
            /// <param name="maxWidth">
            /// Maximum screenshot width.
            /// </param>
            /// <param name="maxHeight">
            /// Maximum screenshot height.
            /// </param>
            /// <param name="everyNthFrame">
            /// Send every n-th frame.
            /// </param>
            /// <param name="cancellation" />
            public Task StartScreencast
            (
                string @format = default, 
                long? @quality = default, 
                long? @maxWidth = default, 
                long? @maxHeight = default, 
                long? @everyNthFrame = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.StartScreencastCommand
                    {
                        Format = @format,
                        Quality = @quality,
                        MaxWidth = @maxWidth,
                        MaxHeight = @maxHeight,
                        EveryNthFrame = @everyNthFrame,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Force the page stop all navigations and pending resource fetches.
            /// </summary>
            /// <param name="cancellation" />
            public Task StopLoading
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.StopLoadingCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Crashes renderer on the IO thread, generates minidumps.
            /// </summary>
            /// <param name="cancellation" />
            public Task Crash
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.CrashCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Tries to close page, running its beforeunload hooks, if any.
            /// </summary>
            /// <param name="cancellation" />
            public Task Close
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.CloseCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Tries to update the web lifecycle state of the page.
            /// It will transition the page to the given state according to:
            /// https://github.com/WICG/web-lifecycle/
            /// </summary>
            /// <param name="state">
            /// Target lifecycle state
            /// </param>
            /// <param name="cancellation" />
            public Task SetWebLifecycleState
            (
                string @state, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetWebLifecycleStateCommand
                    {
                        State = @state,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Stops sending each frame in the `screencastFrame`.
            /// </summary>
            /// <param name="cancellation" />
            public Task StopScreencast
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.StopScreencastCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Forces compilation cache to be generated for every subresource script.
            /// </summary>
            /// <param name="enabled" />
            /// <param name="cancellation" />
            public Task SetProduceCompilationCache
            (
                bool @enabled, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.SetProduceCompilationCacheCommand
                    {
                        Enabled = @enabled,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Seeds compilation cache for given url. Compilation cache does not survive
            /// cross-process navigation.
            /// </summary>
            /// <param name="url" />
            /// <param name="data">
            /// Base64-encoded data
            /// </param>
            /// <param name="cancellation" />
            public Task AddCompilationCache
            (
                string @url, 
                string @data, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.AddCompilationCacheCommand
                    {
                        Url = @url,
                        Data = @data,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Clears seeded compilation cache.
            /// </summary>
            /// <param name="cancellation" />
            public Task ClearCompilationCache
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.ClearCompilationCacheCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Generates a report for testing.
            /// </summary>
            /// <param name="message">
            /// Message to be displayed in the report.
            /// </param>
            /// <param name="group">
            /// Specifies the endpoint group to deliver the report to.
            /// </param>
            /// <param name="cancellation" />
            public Task GenerateTestReport
            (
                string @message, 
                string @group = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.GenerateTestReportCommand
                    {
                        Message = @message,
                        Group = @group,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Pauses page execution. Can be resumed using generic Runtime.runIfWaitingForDebugger.
            /// </summary>
            /// <param name="cancellation" />
            public Task WaitForDebugger
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Page.WaitForDebuggerCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.Page.DomContentEventFiredEvent, Task> DomContentEventFired
            {
                add => InspectorClient.AddEventHandlerCore("Page.domContentEventFired", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.domContentEventFired", value);
            }

            /// <summary>
            /// Fired when frame has been attached to its parent.
            /// </summary>
            public event Func<Protocol.Page.FrameAttachedEvent, Task> FrameAttached
            {
                add => InspectorClient.AddEventHandlerCore("Page.frameAttached", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.frameAttached", value);
            }

            /// <summary>
            /// Fired when frame no longer has a scheduled navigation.
            /// </summary>
            public event Func<Protocol.Page.FrameClearedScheduledNavigationEvent, Task> FrameClearedScheduledNavigation
            {
                add => InspectorClient.AddEventHandlerCore("Page.frameClearedScheduledNavigation", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.frameClearedScheduledNavigation", value);
            }

            /// <summary>
            /// Fired when frame has been detached from its parent.
            /// </summary>
            public event Func<Protocol.Page.FrameDetachedEvent, Task> FrameDetached
            {
                add => InspectorClient.AddEventHandlerCore("Page.frameDetached", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.frameDetached", value);
            }

            /// <summary>
            /// Fired once navigation of the frame has completed. Frame is now associated with the new loader.
            /// </summary>
            public event Func<Protocol.Page.FrameNavigatedEvent, Task> FrameNavigated
            {
                add => InspectorClient.AddEventHandlerCore("Page.frameNavigated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.frameNavigated", value);
            }

            /// <summary />
            public event Func<Protocol.Page.FrameResizedEvent, Task> FrameResized
            {
                add => InspectorClient.AddEventHandlerCore("Page.frameResized", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.frameResized", value);
            }

            /// <summary>
            /// Fired when frame schedules a potential navigation.
            /// </summary>
            public event Func<Protocol.Page.FrameScheduledNavigationEvent, Task> FrameScheduledNavigation
            {
                add => InspectorClient.AddEventHandlerCore("Page.frameScheduledNavigation", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.frameScheduledNavigation", value);
            }

            /// <summary>
            /// Fired when frame has started loading.
            /// </summary>
            public event Func<Protocol.Page.FrameStartedLoadingEvent, Task> FrameStartedLoading
            {
                add => InspectorClient.AddEventHandlerCore("Page.frameStartedLoading", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.frameStartedLoading", value);
            }

            /// <summary>
            /// Fired when frame has stopped loading.
            /// </summary>
            public event Func<Protocol.Page.FrameStoppedLoadingEvent, Task> FrameStoppedLoading
            {
                add => InspectorClient.AddEventHandlerCore("Page.frameStoppedLoading", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.frameStoppedLoading", value);
            }

            /// <summary>
            /// Fired when interstitial page was hidden
            /// </summary>
            public event Func<Protocol.Page.InterstitialHiddenEvent, Task> InterstitialHidden
            {
                add => InspectorClient.AddEventHandlerCore("Page.interstitialHidden", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.interstitialHidden", value);
            }

            /// <summary>
            /// Fired when interstitial page was shown
            /// </summary>
            public event Func<Protocol.Page.InterstitialShownEvent, Task> InterstitialShown
            {
                add => InspectorClient.AddEventHandlerCore("Page.interstitialShown", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.interstitialShown", value);
            }

            /// <summary>
            /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) has been
            /// closed.
            /// </summary>
            public event Func<Protocol.Page.JavascriptDialogClosedEvent, Task> JavascriptDialogClosed
            {
                add => InspectorClient.AddEventHandlerCore("Page.javascriptDialogClosed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.javascriptDialogClosed", value);
            }

            /// <summary>
            /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) is about to
            /// open.
            /// </summary>
            public event Func<Protocol.Page.JavascriptDialogOpeningEvent, Task> JavascriptDialogOpening
            {
                add => InspectorClient.AddEventHandlerCore("Page.javascriptDialogOpening", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.javascriptDialogOpening", value);
            }

            /// <summary>
            /// Fired for top level page lifecycle events such as navigation, load, paint, etc.
            /// </summary>
            public event Func<Protocol.Page.LifecycleEventEvent, Task> LifecycleEvent
            {
                add => InspectorClient.AddEventHandlerCore("Page.lifecycleEvent", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.lifecycleEvent", value);
            }

            /// <summary />
            public event Func<Protocol.Page.LoadEventFiredEvent, Task> LoadEventFired
            {
                add => InspectorClient.AddEventHandlerCore("Page.loadEventFired", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.loadEventFired", value);
            }

            /// <summary>
            /// Fired when same-document navigation happens, e.g. due to history API usage or anchor navigation.
            /// </summary>
            public event Func<Protocol.Page.NavigatedWithinDocumentEvent, Task> NavigatedWithinDocument
            {
                add => InspectorClient.AddEventHandlerCore("Page.navigatedWithinDocument", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.navigatedWithinDocument", value);
            }

            /// <summary>
            /// Compressed image data requested by the `startScreencast`.
            /// </summary>
            public event Func<Protocol.Page.ScreencastFrameEvent, Task> ScreencastFrame
            {
                add => InspectorClient.AddEventHandlerCore("Page.screencastFrame", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.screencastFrame", value);
            }

            /// <summary>
            /// Fired when the page with currently enabled screencast was shown or hidden `.
            /// </summary>
            public event Func<Protocol.Page.ScreencastVisibilityChangedEvent, Task> ScreencastVisibilityChanged
            {
                add => InspectorClient.AddEventHandlerCore("Page.screencastVisibilityChanged", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.screencastVisibilityChanged", value);
            }

            /// <summary>
            /// Fired when a new window is going to be opened, via window.open(), link click, form submission,
            /// etc.
            /// </summary>
            public event Func<Protocol.Page.WindowOpenEvent, Task> WindowOpen
            {
                add => InspectorClient.AddEventHandlerCore("Page.windowOpen", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.windowOpen", value);
            }

            /// <summary>
            /// Issued for every compilation cache generated. Is only available
            /// if Page.setGenerateCompilationCache is enabled.
            /// </summary>
            public event Func<Protocol.Page.CompilationCacheProducedEvent, Task> CompilationCacheProduced
            {
                add => InspectorClient.AddEventHandlerCore("Page.compilationCacheProduced", value);
                remove => InspectorClient.RemoveEventHandlerCore("Page.compilationCacheProduced", value);
            }

            /// <summary />
            public Task<Protocol.Page.DomContentEventFiredEvent> DomContentEventFiredEvent(Func<Protocol.Page.DomContentEventFiredEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.domContentEventFired", until);
            }

            /// <summary>
            /// Fired when frame has been attached to its parent.
            /// </summary>
            public Task<Protocol.Page.FrameAttachedEvent> FrameAttachedEvent(Func<Protocol.Page.FrameAttachedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.frameAttached", until);
            }

            /// <summary>
            /// Fired when frame no longer has a scheduled navigation.
            /// </summary>
            public Task<Protocol.Page.FrameClearedScheduledNavigationEvent> FrameClearedScheduledNavigationEvent(Func<Protocol.Page.FrameClearedScheduledNavigationEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.frameClearedScheduledNavigation", until);
            }

            /// <summary>
            /// Fired when frame has been detached from its parent.
            /// </summary>
            public Task<Protocol.Page.FrameDetachedEvent> FrameDetachedEvent(Func<Protocol.Page.FrameDetachedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.frameDetached", until);
            }

            /// <summary>
            /// Fired once navigation of the frame has completed. Frame is now associated with the new loader.
            /// </summary>
            public Task<Protocol.Page.FrameNavigatedEvent> FrameNavigatedEvent(Func<Protocol.Page.FrameNavigatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.frameNavigated", until);
            }

            /// <summary />
            public Task<Protocol.Page.FrameResizedEvent> FrameResizedEvent(Func<Protocol.Page.FrameResizedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.frameResized", until);
            }

            /// <summary>
            /// Fired when frame schedules a potential navigation.
            /// </summary>
            public Task<Protocol.Page.FrameScheduledNavigationEvent> FrameScheduledNavigationEvent(Func<Protocol.Page.FrameScheduledNavigationEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.frameScheduledNavigation", until);
            }

            /// <summary>
            /// Fired when frame has started loading.
            /// </summary>
            public Task<Protocol.Page.FrameStartedLoadingEvent> FrameStartedLoadingEvent(Func<Protocol.Page.FrameStartedLoadingEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.frameStartedLoading", until);
            }

            /// <summary>
            /// Fired when frame has stopped loading.
            /// </summary>
            public Task<Protocol.Page.FrameStoppedLoadingEvent> FrameStoppedLoadingEvent(Func<Protocol.Page.FrameStoppedLoadingEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.frameStoppedLoading", until);
            }

            /// <summary>
            /// Fired when interstitial page was hidden
            /// </summary>
            public Task<Protocol.Page.InterstitialHiddenEvent> InterstitialHiddenEvent(Func<Protocol.Page.InterstitialHiddenEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.interstitialHidden", until);
            }

            /// <summary>
            /// Fired when interstitial page was shown
            /// </summary>
            public Task<Protocol.Page.InterstitialShownEvent> InterstitialShownEvent(Func<Protocol.Page.InterstitialShownEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.interstitialShown", until);
            }

            /// <summary>
            /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) has been
            /// closed.
            /// </summary>
            public Task<Protocol.Page.JavascriptDialogClosedEvent> JavascriptDialogClosedEvent(Func<Protocol.Page.JavascriptDialogClosedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.javascriptDialogClosed", until);
            }

            /// <summary>
            /// Fired when a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload) is about to
            /// open.
            /// </summary>
            public Task<Protocol.Page.JavascriptDialogOpeningEvent> JavascriptDialogOpeningEvent(Func<Protocol.Page.JavascriptDialogOpeningEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.javascriptDialogOpening", until);
            }

            /// <summary>
            /// Fired for top level page lifecycle events such as navigation, load, paint, etc.
            /// </summary>
            public Task<Protocol.Page.LifecycleEventEvent> LifecycleEventEvent(Func<Protocol.Page.LifecycleEventEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.lifecycleEvent", until);
            }

            /// <summary />
            public Task<Protocol.Page.LoadEventFiredEvent> LoadEventFiredEvent(Func<Protocol.Page.LoadEventFiredEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.loadEventFired", until);
            }

            /// <summary>
            /// Fired when same-document navigation happens, e.g. due to history API usage or anchor navigation.
            /// </summary>
            public Task<Protocol.Page.NavigatedWithinDocumentEvent> NavigatedWithinDocumentEvent(Func<Protocol.Page.NavigatedWithinDocumentEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.navigatedWithinDocument", until);
            }

            /// <summary>
            /// Compressed image data requested by the `startScreencast`.
            /// </summary>
            public Task<Protocol.Page.ScreencastFrameEvent> ScreencastFrameEvent(Func<Protocol.Page.ScreencastFrameEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.screencastFrame", until);
            }

            /// <summary>
            /// Fired when the page with currently enabled screencast was shown or hidden `.
            /// </summary>
            public Task<Protocol.Page.ScreencastVisibilityChangedEvent> ScreencastVisibilityChangedEvent(Func<Protocol.Page.ScreencastVisibilityChangedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.screencastVisibilityChanged", until);
            }

            /// <summary>
            /// Fired when a new window is going to be opened, via window.open(), link click, form submission,
            /// etc.
            /// </summary>
            public Task<Protocol.Page.WindowOpenEvent> WindowOpenEvent(Func<Protocol.Page.WindowOpenEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.windowOpen", until);
            }

            /// <summary>
            /// Issued for every compilation cache generated. Is only available
            /// if Page.setGenerateCompilationCache is enabled.
            /// </summary>
            public Task<Protocol.Page.CompilationCacheProducedEvent> CompilationCacheProducedEvent(Func<Protocol.Page.CompilationCacheProducedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Page.compilationCacheProduced", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Performance.
        /// </summary>
        public class PerformanceInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal PerformanceInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disable collecting and reporting metrics.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Performance.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enable collecting and reporting metrics.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Performance.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets time domain to use for collecting and reporting duration metrics.
            /// Note that this must be called before enabling metrics collection. Calling
            /// this method while metrics collection is enabled returns an error.
            /// </summary>
            /// <param name="timeDomain">
            /// Time domain
            /// </param>
            /// <param name="cancellation" />
            public Task SetTimeDomain
            (
                string @timeDomain, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Performance.SetTimeDomainCommand
                    {
                        TimeDomain = @timeDomain,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Retrieve current values of run-time metrics.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Performance.GetMetricsResponse> GetMetrics
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Performance.GetMetricsCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Current values of the metrics.
            /// </summary>
            public event Func<Protocol.Performance.MetricsEvent, Task> Metrics
            {
                add => InspectorClient.AddEventHandlerCore("Performance.metrics", value);
                remove => InspectorClient.RemoveEventHandlerCore("Performance.metrics", value);
            }

            /// <summary>
            /// Current values of the metrics.
            /// </summary>
            public Task<Protocol.Performance.MetricsEvent> MetricsEvent(Func<Protocol.Performance.MetricsEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Performance.metrics", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Security.
        /// </summary>
        public class SecurityInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal SecurityInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disables tracking security state changes.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Security.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables tracking security state changes.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Security.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enable/disable whether all certificate errors should be ignored.
            /// </summary>
            /// <param name="ignore">
            /// If true, all certificate errors will be ignored.
            /// </param>
            /// <param name="cancellation" />
            public Task SetIgnoreCertificateErrors
            (
                bool @ignore, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Security.SetIgnoreCertificateErrorsCommand
                    {
                        Ignore = @ignore,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Handles a certificate error that fired a certificateError event.
            /// </summary>
            /// <param name="eventId">
            /// The ID of the event.
            /// </param>
            /// <param name="action">
            /// The action to take on the certificate error.
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task HandleCertificateError
            (
                long @eventId, 
                Protocol.Security.CertificateErrorAction @action, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Security.HandleCertificateErrorCommand
                    {
                        EventId = @eventId,
                        Action = @action,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enable/disable overriding certificate errors. If enabled, all certificate error events need to
            /// be handled by the DevTools client and should be answered with `handleCertificateError` commands.
            /// </summary>
            /// <param name="override">
            /// If true, certificate errors will be overridden.
            /// </param>
            /// <param name="cancellation" />
            [Obsolete]
            public Task SetOverrideCertificateErrors
            (
                bool @override, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Security.SetOverrideCertificateErrorsCommand
                    {
                        Override = @override,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// There is a certificate error. If overriding certificate errors is enabled, then it should be
            /// handled with the `handleCertificateError` command. Note: this event does not fire if the
            /// certificate error has been allowed internally. Only one client per target should override
            /// certificate errors at the same time.
            /// </summary>
            [Obsolete]
            public event Func<Protocol.Security.CertificateErrorEvent, Task> CertificateError
            {
                add => InspectorClient.AddEventHandlerCore("Security.certificateError", value);
                remove => InspectorClient.RemoveEventHandlerCore("Security.certificateError", value);
            }

            /// <summary>
            /// The security state of the page changed.
            /// </summary>
            public event Func<Protocol.Security.SecurityStateChangedEvent, Task> SecurityStateChanged
            {
                add => InspectorClient.AddEventHandlerCore("Security.securityStateChanged", value);
                remove => InspectorClient.RemoveEventHandlerCore("Security.securityStateChanged", value);
            }

            /// <summary>
            /// There is a certificate error. If overriding certificate errors is enabled, then it should be
            /// handled with the `handleCertificateError` command. Note: this event does not fire if the
            /// certificate error has been allowed internally. Only one client per target should override
            /// certificate errors at the same time.
            /// </summary>
            [Obsolete]
            public Task<Protocol.Security.CertificateErrorEvent> CertificateErrorEvent(Func<Protocol.Security.CertificateErrorEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Security.certificateError", until);
            }

            /// <summary>
            /// The security state of the page changed.
            /// </summary>
            public Task<Protocol.Security.SecurityStateChangedEvent> SecurityStateChangedEvent(Func<Protocol.Security.SecurityStateChangedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Security.securityStateChanged", until);
            }
        }

        /// <summary>
        /// Inspector client for domain ServiceWorker.
        /// </summary>
        public class ServiceWorkerInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal ServiceWorkerInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary />
            /// <param name="origin" />
            /// <param name="registrationId" />
            /// <param name="data" />
            /// <param name="cancellation" />
            public Task DeliverPushMessage
            (
                string @origin, 
                string @registrationId, 
                string @data, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.DeliverPushMessageCommand
                    {
                        Origin = @origin,
                        RegistrationId = @registrationId,
                        Data = @data,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="origin" />
            /// <param name="registrationId" />
            /// <param name="tag" />
            /// <param name="lastChance" />
            /// <param name="cancellation" />
            public Task DispatchSyncEvent
            (
                string @origin, 
                string @registrationId, 
                string @tag, 
                bool @lastChance, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.DispatchSyncEventCommand
                    {
                        Origin = @origin,
                        RegistrationId = @registrationId,
                        Tag = @tag,
                        LastChance = @lastChance,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="versionId" />
            /// <param name="cancellation" />
            public Task InspectWorker
            (
                string @versionId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.InspectWorkerCommand
                    {
                        VersionId = @versionId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="forceUpdateOnPageLoad" />
            /// <param name="cancellation" />
            public Task SetForceUpdateOnPageLoad
            (
                bool @forceUpdateOnPageLoad, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.SetForceUpdateOnPageLoadCommand
                    {
                        ForceUpdateOnPageLoad = @forceUpdateOnPageLoad,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="scopeURL" />
            /// <param name="cancellation" />
            public Task SkipWaiting
            (
                string @scopeURL, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.SkipWaitingCommand
                    {
                        ScopeURL = @scopeURL,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="scopeURL" />
            /// <param name="cancellation" />
            public Task StartWorker
            (
                string @scopeURL, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.StartWorkerCommand
                    {
                        ScopeURL = @scopeURL,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task StopAllWorkers
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.StopAllWorkersCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="versionId" />
            /// <param name="cancellation" />
            public Task StopWorker
            (
                string @versionId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.StopWorkerCommand
                    {
                        VersionId = @versionId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="scopeURL" />
            /// <param name="cancellation" />
            public Task Unregister
            (
                string @scopeURL, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.UnregisterCommand
                    {
                        ScopeURL = @scopeURL,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="scopeURL" />
            /// <param name="cancellation" />
            public Task UpdateRegistration
            (
                string @scopeURL, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.ServiceWorker.UpdateRegistrationCommand
                    {
                        ScopeURL = @scopeURL,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.ServiceWorker.WorkerErrorReportedEvent, Task> WorkerErrorReported
            {
                add => InspectorClient.AddEventHandlerCore("ServiceWorker.workerErrorReported", value);
                remove => InspectorClient.RemoveEventHandlerCore("ServiceWorker.workerErrorReported", value);
            }

            /// <summary />
            public event Func<Protocol.ServiceWorker.WorkerRegistrationUpdatedEvent, Task> WorkerRegistrationUpdated
            {
                add => InspectorClient.AddEventHandlerCore("ServiceWorker.workerRegistrationUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("ServiceWorker.workerRegistrationUpdated", value);
            }

            /// <summary />
            public event Func<Protocol.ServiceWorker.WorkerVersionUpdatedEvent, Task> WorkerVersionUpdated
            {
                add => InspectorClient.AddEventHandlerCore("ServiceWorker.workerVersionUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("ServiceWorker.workerVersionUpdated", value);
            }

            /// <summary />
            public Task<Protocol.ServiceWorker.WorkerErrorReportedEvent> WorkerErrorReportedEvent(Func<Protocol.ServiceWorker.WorkerErrorReportedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("ServiceWorker.workerErrorReported", until);
            }

            /// <summary />
            public Task<Protocol.ServiceWorker.WorkerRegistrationUpdatedEvent> WorkerRegistrationUpdatedEvent(Func<Protocol.ServiceWorker.WorkerRegistrationUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("ServiceWorker.workerRegistrationUpdated", until);
            }

            /// <summary />
            public Task<Protocol.ServiceWorker.WorkerVersionUpdatedEvent> WorkerVersionUpdatedEvent(Func<Protocol.ServiceWorker.WorkerVersionUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("ServiceWorker.workerVersionUpdated", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Storage.
        /// </summary>
        public class StorageInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal StorageInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Clears storage for origin.
            /// </summary>
            /// <param name="origin">
            /// Security origin.
            /// </param>
            /// <param name="storageTypes">
            /// Comma separated list of StorageType to clear.
            /// </param>
            /// <param name="cancellation" />
            public Task ClearDataForOrigin
            (
                string @origin, 
                string @storageTypes, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Storage.ClearDataForOriginCommand
                    {
                        Origin = @origin,
                        StorageTypes = @storageTypes,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns usage and quota in bytes.
            /// </summary>
            /// <param name="origin">
            /// Security origin.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Storage.GetUsageAndQuotaResponse> GetUsageAndQuota
            (
                string @origin, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Storage.GetUsageAndQuotaCommand
                    {
                        Origin = @origin,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Registers origin to be notified when an update occurs to its cache storage list.
            /// </summary>
            /// <param name="origin">
            /// Security origin.
            /// </param>
            /// <param name="cancellation" />
            public Task TrackCacheStorageForOrigin
            (
                string @origin, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Storage.TrackCacheStorageForOriginCommand
                    {
                        Origin = @origin,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Registers origin to be notified when an update occurs to its IndexedDB.
            /// </summary>
            /// <param name="origin">
            /// Security origin.
            /// </param>
            /// <param name="cancellation" />
            public Task TrackIndexedDBForOrigin
            (
                string @origin, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Storage.TrackIndexedDBForOriginCommand
                    {
                        Origin = @origin,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Unregisters origin from receiving notifications for cache storage.
            /// </summary>
            /// <param name="origin">
            /// Security origin.
            /// </param>
            /// <param name="cancellation" />
            public Task UntrackCacheStorageForOrigin
            (
                string @origin, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Storage.UntrackCacheStorageForOriginCommand
                    {
                        Origin = @origin,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Unregisters origin from receiving notifications for IndexedDB.
            /// </summary>
            /// <param name="origin">
            /// Security origin.
            /// </param>
            /// <param name="cancellation" />
            public Task UntrackIndexedDBForOrigin
            (
                string @origin, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Storage.UntrackIndexedDBForOriginCommand
                    {
                        Origin = @origin,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// A cache's contents have been modified.
            /// </summary>
            public event Func<Protocol.Storage.CacheStorageContentUpdatedEvent, Task> CacheStorageContentUpdated
            {
                add => InspectorClient.AddEventHandlerCore("Storage.cacheStorageContentUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Storage.cacheStorageContentUpdated", value);
            }

            /// <summary>
            /// A cache has been added/deleted.
            /// </summary>
            public event Func<Protocol.Storage.CacheStorageListUpdatedEvent, Task> CacheStorageListUpdated
            {
                add => InspectorClient.AddEventHandlerCore("Storage.cacheStorageListUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Storage.cacheStorageListUpdated", value);
            }

            /// <summary>
            /// The origin's IndexedDB object store has been modified.
            /// </summary>
            public event Func<Protocol.Storage.IndexedDBContentUpdatedEvent, Task> IndexedDBContentUpdated
            {
                add => InspectorClient.AddEventHandlerCore("Storage.indexedDBContentUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Storage.indexedDBContentUpdated", value);
            }

            /// <summary>
            /// The origin's IndexedDB database list has been modified.
            /// </summary>
            public event Func<Protocol.Storage.IndexedDBListUpdatedEvent, Task> IndexedDBListUpdated
            {
                add => InspectorClient.AddEventHandlerCore("Storage.indexedDBListUpdated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Storage.indexedDBListUpdated", value);
            }

            /// <summary>
            /// A cache's contents have been modified.
            /// </summary>
            public Task<Protocol.Storage.CacheStorageContentUpdatedEvent> CacheStorageContentUpdatedEvent(Func<Protocol.Storage.CacheStorageContentUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Storage.cacheStorageContentUpdated", until);
            }

            /// <summary>
            /// A cache has been added/deleted.
            /// </summary>
            public Task<Protocol.Storage.CacheStorageListUpdatedEvent> CacheStorageListUpdatedEvent(Func<Protocol.Storage.CacheStorageListUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Storage.cacheStorageListUpdated", until);
            }

            /// <summary>
            /// The origin's IndexedDB object store has been modified.
            /// </summary>
            public Task<Protocol.Storage.IndexedDBContentUpdatedEvent> IndexedDBContentUpdatedEvent(Func<Protocol.Storage.IndexedDBContentUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Storage.indexedDBContentUpdated", until);
            }

            /// <summary>
            /// The origin's IndexedDB database list has been modified.
            /// </summary>
            public Task<Protocol.Storage.IndexedDBListUpdatedEvent> IndexedDBListUpdatedEvent(Func<Protocol.Storage.IndexedDBListUpdatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Storage.indexedDBListUpdated", until);
            }
        }

        /// <summary>
        /// Inspector client for domain SystemInfo.
        /// </summary>
        public class SystemInfoInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal SystemInfoInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Returns information about the system.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.SystemInfo.GetInfoResponse> GetInfo
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.SystemInfo.GetInfoCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns information about all running processes.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.SystemInfo.GetProcessInfoResponse> GetProcessInfo
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.SystemInfo.GetProcessInfoCommand
                    {
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Target.
        /// </summary>
        public class TargetInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal TargetInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Activates (focuses) the target.
            /// </summary>
            /// <param name="targetId" />
            /// <param name="cancellation" />
            public Task ActivateTarget
            (
                Protocol.Target.TargetID @targetId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.ActivateTargetCommand
                    {
                        TargetId = @targetId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Attaches to the target with given id.
            /// </summary>
            /// <param name="targetId" />
            /// <param name="flatten">
            /// Enables "flat" access to the session via specifying sessionId attribute in the commands.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Target.AttachToTargetResponse> AttachToTarget
            (
                Protocol.Target.TargetID @targetId, 
                bool? @flatten = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.AttachToTargetCommand
                    {
                        TargetId = @targetId,
                        Flatten = @flatten,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Attaches to the browser target, only uses flat sessionId mode.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Target.AttachToBrowserTargetResponse> AttachToBrowserTarget
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.AttachToBrowserTargetCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Closes the target. If the target is a page that gets closed too.
            /// </summary>
            /// <param name="targetId" />
            /// <param name="cancellation" />
            public Task<Protocol.Target.CloseTargetResponse> CloseTarget
            (
                Protocol.Target.TargetID @targetId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.CloseTargetCommand
                    {
                        TargetId = @targetId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Inject object to the target's main frame that provides a communication
            /// channel with browser target.
            /// 
            /// Injected object will be available as `window[bindingName]`.
            /// 
            /// The object has the follwing API:
            /// - `binding.send(json)` - a method to send messages over the remote debugging protocol
            /// - `binding.onmessage = json =&gt; handleMessage(json)` - a callback that will be called for the protocol notifications and command responses.
            /// </summary>
            /// <param name="targetId" />
            /// <param name="bindingName">
            /// Binding name, 'cdp' if not specified.
            /// </param>
            /// <param name="cancellation" />
            public Task ExposeDevToolsProtocol
            (
                Protocol.Target.TargetID @targetId, 
                string @bindingName = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.ExposeDevToolsProtocolCommand
                    {
                        TargetId = @targetId,
                        BindingName = @bindingName,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Creates a new empty BrowserContext. Similar to an incognito profile but you can have more than
            /// one.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Target.CreateBrowserContextResponse> CreateBrowserContext
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.CreateBrowserContextCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns all browser contexts created with `Target.createBrowserContext` method.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Target.GetBrowserContextsResponse> GetBrowserContexts
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.GetBrowserContextsCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Creates a new page.
            /// </summary>
            /// <param name="url">
            /// The initial URL the page will be navigated to.
            /// </param>
            /// <param name="width">
            /// Frame width in DIP (headless chrome only).
            /// </param>
            /// <param name="height">
            /// Frame height in DIP (headless chrome only).
            /// </param>
            /// <param name="browserContextId">
            /// The browser context to create the page in.
            /// </param>
            /// <param name="enableBeginFrameControl">
            /// Whether BeginFrames for this target will be controlled via DevTools (headless chrome only,
            /// not supported on MacOS yet, false by default).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Target.CreateTargetResponse> CreateTarget
            (
                string @url, 
                long? @width = default, 
                long? @height = default, 
                Protocol.Target.BrowserContextID @browserContextId = default, 
                bool? @enableBeginFrameControl = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.CreateTargetCommand
                    {
                        Url = @url,
                        Width = @width,
                        Height = @height,
                        BrowserContextId = @browserContextId,
                        EnableBeginFrameControl = @enableBeginFrameControl,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Detaches session with given id.
            /// </summary>
            /// <param name="sessionId">
            /// Session to detach.
            /// </param>
            /// <param name="targetId">
            /// Deprecated.
            /// </param>
            /// <param name="cancellation" />
            public Task DetachFromTarget
            (
                Protocol.Target.SessionID @sessionId = default, 
                Protocol.Target.TargetID @targetId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.DetachFromTargetCommand
                    {
                        SessionId = @sessionId,
                        TargetId = @targetId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Deletes a BrowserContext. All the belonging pages will be closed without calling their
            /// beforeunload hooks.
            /// </summary>
            /// <param name="browserContextId" />
            /// <param name="cancellation" />
            public Task DisposeBrowserContext
            (
                Protocol.Target.BrowserContextID @browserContextId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.DisposeBrowserContextCommand
                    {
                        BrowserContextId = @browserContextId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns information about a target.
            /// </summary>
            /// <param name="targetId" />
            /// <param name="cancellation" />
            public Task<Protocol.Target.GetTargetInfoResponse> GetTargetInfo
            (
                Protocol.Target.TargetID @targetId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.GetTargetInfoCommand
                    {
                        TargetId = @targetId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Retrieves a list of available targets.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Target.GetTargetsResponse> GetTargets
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.GetTargetsCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sends protocol message over session with given id.
            /// </summary>
            /// <param name="message" />
            /// <param name="sessionId">
            /// Identifier of the session.
            /// </param>
            /// <param name="targetId">
            /// Deprecated.
            /// </param>
            /// <param name="cancellation" />
            public Task SendMessageToTarget
            (
                string @message, 
                Protocol.Target.SessionID @sessionId = default, 
                Protocol.Target.TargetID @targetId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.SendMessageToTargetCommand
                    {
                        Message = @message,
                        SessionId = @sessionId,
                        TargetId = @targetId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Controls whether to automatically attach to new targets which are considered to be related to
            /// this one. When turned on, attaches to all existing related targets as well. When turned off,
            /// automatically detaches from all currently attached targets.
            /// </summary>
            /// <param name="autoAttach">
            /// Whether to auto-attach to related targets.
            /// </param>
            /// <param name="waitForDebuggerOnStart">
            /// Whether to pause new targets when attaching to them. Use `Runtime.runIfWaitingForDebugger`
            /// to run paused targets.
            /// </param>
            /// <param name="flatten">
            /// Enables "flat" access to the session via specifying sessionId attribute in the commands.
            /// </param>
            /// <param name="cancellation" />
            public Task SetAutoAttach
            (
                bool @autoAttach, 
                bool @waitForDebuggerOnStart, 
                bool? @flatten = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.SetAutoAttachCommand
                    {
                        AutoAttach = @autoAttach,
                        WaitForDebuggerOnStart = @waitForDebuggerOnStart,
                        Flatten = @flatten,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Controls whether to discover available targets and notify via
            /// `targetCreated/targetInfoChanged/targetDestroyed` events.
            /// </summary>
            /// <param name="discover">
            /// Whether to discover available targets.
            /// </param>
            /// <param name="cancellation" />
            public Task SetDiscoverTargets
            (
                bool @discover, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.SetDiscoverTargetsCommand
                    {
                        Discover = @discover,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables target discovery for the specified locations, when `setDiscoverTargets` was set to
            /// `true`.
            /// </summary>
            /// <param name="locations">
            /// List of remote locations.
            /// </param>
            /// <param name="cancellation" />
            public Task SetRemoteLocations
            (
                Protocol.Target.RemoteLocation[] @locations, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Target.SetRemoteLocationsCommand
                    {
                        Locations = @locations,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Issued when attached to target because of auto-attach or `attachToTarget` command.
            /// </summary>
            public event Func<Protocol.Target.AttachedToTargetEvent, Task> AttachedToTarget
            {
                add => InspectorClient.AddEventHandlerCore("Target.attachedToTarget", value);
                remove => InspectorClient.RemoveEventHandlerCore("Target.attachedToTarget", value);
            }

            /// <summary>
            /// Issued when detached from target for any reason (including `detachFromTarget` command). Can be
            /// issued multiple times per target if multiple sessions have been attached to it.
            /// </summary>
            public event Func<Protocol.Target.DetachedFromTargetEvent, Task> DetachedFromTarget
            {
                add => InspectorClient.AddEventHandlerCore("Target.detachedFromTarget", value);
                remove => InspectorClient.RemoveEventHandlerCore("Target.detachedFromTarget", value);
            }

            /// <summary>
            /// Notifies about a new protocol message received from the session (as reported in
            /// `attachedToTarget` event).
            /// </summary>
            public event Func<Protocol.Target.ReceivedMessageFromTargetEvent, Task> ReceivedMessageFromTarget
            {
                add => InspectorClient.AddEventHandlerCore("Target.receivedMessageFromTarget", value);
                remove => InspectorClient.RemoveEventHandlerCore("Target.receivedMessageFromTarget", value);
            }

            /// <summary>
            /// Issued when a possible inspection target is created.
            /// </summary>
            public event Func<Protocol.Target.TargetCreatedEvent, Task> TargetCreated
            {
                add => InspectorClient.AddEventHandlerCore("Target.targetCreated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Target.targetCreated", value);
            }

            /// <summary>
            /// Issued when a target is destroyed.
            /// </summary>
            public event Func<Protocol.Target.TargetDestroyedEvent, Task> TargetDestroyed
            {
                add => InspectorClient.AddEventHandlerCore("Target.targetDestroyed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Target.targetDestroyed", value);
            }

            /// <summary>
            /// Issued when a target has crashed.
            /// </summary>
            public event Func<Protocol.Target.TargetCrashedEvent, Task> TargetCrashed
            {
                add => InspectorClient.AddEventHandlerCore("Target.targetCrashed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Target.targetCrashed", value);
            }

            /// <summary>
            /// Issued when some information about a target has changed. This only happens between
            /// `targetCreated` and `targetDestroyed`.
            /// </summary>
            public event Func<Protocol.Target.TargetInfoChangedEvent, Task> TargetInfoChanged
            {
                add => InspectorClient.AddEventHandlerCore("Target.targetInfoChanged", value);
                remove => InspectorClient.RemoveEventHandlerCore("Target.targetInfoChanged", value);
            }

            /// <summary>
            /// Issued when attached to target because of auto-attach or `attachToTarget` command.
            /// </summary>
            public Task<Protocol.Target.AttachedToTargetEvent> AttachedToTargetEvent(Func<Protocol.Target.AttachedToTargetEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Target.attachedToTarget", until);
            }

            /// <summary>
            /// Issued when detached from target for any reason (including `detachFromTarget` command). Can be
            /// issued multiple times per target if multiple sessions have been attached to it.
            /// </summary>
            public Task<Protocol.Target.DetachedFromTargetEvent> DetachedFromTargetEvent(Func<Protocol.Target.DetachedFromTargetEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Target.detachedFromTarget", until);
            }

            /// <summary>
            /// Notifies about a new protocol message received from the session (as reported in
            /// `attachedToTarget` event).
            /// </summary>
            public Task<Protocol.Target.ReceivedMessageFromTargetEvent> ReceivedMessageFromTargetEvent(Func<Protocol.Target.ReceivedMessageFromTargetEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Target.receivedMessageFromTarget", until);
            }

            /// <summary>
            /// Issued when a possible inspection target is created.
            /// </summary>
            public Task<Protocol.Target.TargetCreatedEvent> TargetCreatedEvent(Func<Protocol.Target.TargetCreatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Target.targetCreated", until);
            }

            /// <summary>
            /// Issued when a target is destroyed.
            /// </summary>
            public Task<Protocol.Target.TargetDestroyedEvent> TargetDestroyedEvent(Func<Protocol.Target.TargetDestroyedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Target.targetDestroyed", until);
            }

            /// <summary>
            /// Issued when a target has crashed.
            /// </summary>
            public Task<Protocol.Target.TargetCrashedEvent> TargetCrashedEvent(Func<Protocol.Target.TargetCrashedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Target.targetCrashed", until);
            }

            /// <summary>
            /// Issued when some information about a target has changed. This only happens between
            /// `targetCreated` and `targetDestroyed`.
            /// </summary>
            public Task<Protocol.Target.TargetInfoChangedEvent> TargetInfoChangedEvent(Func<Protocol.Target.TargetInfoChangedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Target.targetInfoChanged", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Tethering.
        /// </summary>
        public class TetheringInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal TetheringInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Request browser port binding.
            /// </summary>
            /// <param name="port">
            /// Port number to bind.
            /// </param>
            /// <param name="cancellation" />
            public Task Bind
            (
                long @port, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Tethering.BindCommand
                    {
                        Port = @port,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Request browser port unbinding.
            /// </summary>
            /// <param name="port">
            /// Port number to unbind.
            /// </param>
            /// <param name="cancellation" />
            public Task Unbind
            (
                long @port, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Tethering.UnbindCommand
                    {
                        Port = @port,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Informs that port was successfully bound and got a specified connection id.
            /// </summary>
            public event Func<Protocol.Tethering.AcceptedEvent, Task> Accepted
            {
                add => InspectorClient.AddEventHandlerCore("Tethering.accepted", value);
                remove => InspectorClient.RemoveEventHandlerCore("Tethering.accepted", value);
            }

            /// <summary>
            /// Informs that port was successfully bound and got a specified connection id.
            /// </summary>
            public Task<Protocol.Tethering.AcceptedEvent> AcceptedEvent(Func<Protocol.Tethering.AcceptedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Tethering.accepted", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Tracing.
        /// </summary>
        public class TracingInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal TracingInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Stop trace events collection.
            /// </summary>
            /// <param name="cancellation" />
            public Task End
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Tracing.EndCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Gets supported tracing categories.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Tracing.GetCategoriesResponse> GetCategories
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Tracing.GetCategoriesCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Record a clock sync marker in the trace.
            /// </summary>
            /// <param name="syncId">
            /// The ID of this clock sync marker
            /// </param>
            /// <param name="cancellation" />
            public Task RecordClockSyncMarker
            (
                string @syncId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Tracing.RecordClockSyncMarkerCommand
                    {
                        SyncId = @syncId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Request a global memory dump.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Tracing.RequestMemoryDumpResponse> RequestMemoryDump
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Tracing.RequestMemoryDumpCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Start trace events collection.
            /// </summary>
            /// <param name="categories">
            /// Category/tag filter
            /// </param>
            /// <param name="options">
            /// Tracing options
            /// </param>
            /// <param name="bufferUsageReportingInterval">
            /// If set, the agent will issue bufferUsage events at this interval, specified in milliseconds
            /// </param>
            /// <param name="transferMode">
            /// Whether to report trace events as series of dataCollected events or to save trace to a
            /// stream (defaults to `ReportEvents`).
            /// </param>
            /// <param name="streamCompression">
            /// Compression format to use. This only applies when using `ReturnAsStream`
            /// transfer mode (defaults to `none`)
            /// </param>
            /// <param name="traceConfig" />
            /// <param name="cancellation" />
            public Task Start
            (
                string @categories = default, 
                string @options = default, 
                double? @bufferUsageReportingInterval = default, 
                string @transferMode = default, 
                Protocol.Tracing.StreamCompression @streamCompression = default, 
                Protocol.Tracing.TraceConfig @traceConfig = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Tracing.StartCommand
                    {
                        Categories = @categories,
                        Options = @options,
                        BufferUsageReportingInterval = @bufferUsageReportingInterval,
                        TransferMode = @transferMode,
                        StreamCompression = @streamCompression,
                        TraceConfig = @traceConfig,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.Tracing.BufferUsageEvent, Task> BufferUsage
            {
                add => InspectorClient.AddEventHandlerCore("Tracing.bufferUsage", value);
                remove => InspectorClient.RemoveEventHandlerCore("Tracing.bufferUsage", value);
            }

            /// <summary>
            /// Contains an bucket of collected trace events. When tracing is stopped collected events will be
            /// send as a sequence of dataCollected events followed by tracingComplete event.
            /// </summary>
            public event Func<Protocol.Tracing.DataCollectedEvent, Task> DataCollected
            {
                add => InspectorClient.AddEventHandlerCore("Tracing.dataCollected", value);
                remove => InspectorClient.RemoveEventHandlerCore("Tracing.dataCollected", value);
            }

            /// <summary>
            /// Signals that tracing is stopped and there is no trace buffers pending flush, all data were
            /// delivered via dataCollected events.
            /// </summary>
            public event Func<Protocol.Tracing.TracingCompleteEvent, Task> TracingComplete
            {
                add => InspectorClient.AddEventHandlerCore("Tracing.tracingComplete", value);
                remove => InspectorClient.RemoveEventHandlerCore("Tracing.tracingComplete", value);
            }

            /// <summary />
            public Task<Protocol.Tracing.BufferUsageEvent> BufferUsageEvent(Func<Protocol.Tracing.BufferUsageEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Tracing.bufferUsage", until);
            }

            /// <summary>
            /// Contains an bucket of collected trace events. When tracing is stopped collected events will be
            /// send as a sequence of dataCollected events followed by tracingComplete event.
            /// </summary>
            public Task<Protocol.Tracing.DataCollectedEvent> DataCollectedEvent(Func<Protocol.Tracing.DataCollectedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Tracing.dataCollected", until);
            }

            /// <summary>
            /// Signals that tracing is stopped and there is no trace buffers pending flush, all data were
            /// delivered via dataCollected events.
            /// </summary>
            public Task<Protocol.Tracing.TracingCompleteEvent> TracingCompleteEvent(Func<Protocol.Tracing.TracingCompleteEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Tracing.tracingComplete", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Testing.
        /// </summary>
        public class TestingInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal TestingInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Generates a report for testing.
            /// </summary>
            /// <param name="message">
            /// Message to be displayed in the report.
            /// </param>
            /// <param name="group">
            /// Specifies the endpoint group to deliver the report to.
            /// </param>
            /// <param name="cancellation" />
            public Task GenerateTestReport
            (
                string @message, 
                string @group = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Testing.GenerateTestReportCommand
                    {
                        Message = @message,
                        Group = @group,
                    }
                    , cancellation
                )
                ;
            }
        }

        /// <summary>
        /// Inspector client for domain Fetch.
        /// </summary>
        public class FetchInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal FetchInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Disables the fetch domain.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Fetch.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables issuing of requestPaused events. A request will be paused until client
            /// calls one of failRequest, fulfillRequest or continueRequest/continueWithAuth.
            /// </summary>
            /// <param name="patterns">
            /// If specified, only requests matching any of these patterns will produce
            /// fetchRequested event and will be paused until clients response. If not set,
            /// all requests will be affected.
            /// </param>
            /// <param name="handleAuthRequests">
            /// If true, authRequired events will be issued and requests will be paused
            /// expecting a call to continueWithAuth.
            /// </param>
            /// <param name="cancellation" />
            public Task Enable
            (
                Protocol.Fetch.RequestPattern[] @patterns = default, 
                bool? @handleAuthRequests = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Fetch.EnableCommand
                    {
                        Patterns = @patterns,
                        HandleAuthRequests = @handleAuthRequests,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Causes the request to fail with specified reason.
            /// </summary>
            /// <param name="requestId">
            /// An id the client received in requestPaused event.
            /// </param>
            /// <param name="errorReason">
            /// Causes the request to fail with the given reason.
            /// </param>
            /// <param name="cancellation" />
            public Task FailRequest
            (
                Protocol.Fetch.RequestId @requestId, 
                Protocol.Network.ErrorReason @errorReason, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Fetch.FailRequestCommand
                    {
                        RequestId = @requestId,
                        ErrorReason = @errorReason,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Provides response to the request.
            /// </summary>
            /// <param name="requestId">
            /// An id the client received in requestPaused event.
            /// </param>
            /// <param name="responseCode">
            /// An HTTP response code.
            /// </param>
            /// <param name="responseHeaders">
            /// Response headers.
            /// </param>
            /// <param name="body">
            /// A response body.
            /// </param>
            /// <param name="responsePhrase">
            /// A textual representation of responseCode.
            /// If absent, a standard phrase mathcing responseCode is used.
            /// </param>
            /// <param name="cancellation" />
            public Task FulfillRequest
            (
                Protocol.Fetch.RequestId @requestId, 
                long @responseCode, 
                Protocol.Fetch.HeaderEntry[] @responseHeaders, 
                string @body = default, 
                string @responsePhrase = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Fetch.FulfillRequestCommand
                    {
                        RequestId = @requestId,
                        ResponseCode = @responseCode,
                        ResponseHeaders = @responseHeaders,
                        Body = @body,
                        ResponsePhrase = @responsePhrase,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Continues the request, optionally modifying some of its parameters.
            /// </summary>
            /// <param name="requestId">
            /// An id the client received in requestPaused event.
            /// </param>
            /// <param name="url">
            /// If set, the request url will be modified in a way that's not observable by page.
            /// </param>
            /// <param name="method">
            /// If set, the request method is overridden.
            /// </param>
            /// <param name="postData">
            /// If set, overrides the post data in the request.
            /// </param>
            /// <param name="headers">
            /// If set, overrides the request headrts.
            /// </param>
            /// <param name="cancellation" />
            public Task ContinueRequest
            (
                Protocol.Fetch.RequestId @requestId, 
                string @url = default, 
                string @method = default, 
                string @postData = default, 
                Protocol.Fetch.HeaderEntry[] @headers = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Fetch.ContinueRequestCommand
                    {
                        RequestId = @requestId,
                        Url = @url,
                        Method = @method,
                        PostData = @postData,
                        Headers = @headers,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Continues a request supplying authChallengeResponse following authRequired event.
            /// </summary>
            /// <param name="requestId">
            /// An id the client received in authRequired event.
            /// </param>
            /// <param name="authChallengeResponse">
            /// Response to  with an authChallenge.
            /// </param>
            /// <param name="cancellation" />
            public Task ContinueWithAuth
            (
                Protocol.Fetch.RequestId @requestId, 
                Protocol.Fetch.AuthChallengeResponse @authChallengeResponse, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Fetch.ContinueWithAuthCommand
                    {
                        RequestId = @requestId,
                        AuthChallengeResponse = @authChallengeResponse,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Causes the body of the response to be received from the server and
            /// returned as a single string. May only be issued for a request that
            /// is paused in the Response stage and is mutually exclusive with
            /// takeResponseBodyForInterceptionAsStream. Calling other methods that
            /// affect the request or disabling fetch domain before body is received
            /// results in an undefined behavior.
            /// </summary>
            /// <param name="requestId">
            /// Identifier for the intercepted request to get body for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Fetch.GetResponseBodyResponse> GetResponseBody
            (
                Protocol.Fetch.RequestId @requestId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Fetch.GetResponseBodyCommand
                    {
                        RequestId = @requestId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns a handle to the stream representing the response body.
            /// The request must be paused in the HeadersReceived stage.
            /// Note that after this command the request can't be continued
            /// as is -- client either needs to cancel it or to provide the
            /// response body.
            /// The stream only supports sequential read, IO.read will fail if the position
            /// is specified.
            /// This method is mutually exclusive with getResponseBody.
            /// Calling other methods that affect the request or disabling fetch
            /// domain before body is received results in an undefined behavior.
            /// </summary>
            /// <param name="requestId" />
            /// <param name="cancellation" />
            public Task<Protocol.Fetch.TakeResponseBodyAsStreamResponse> TakeResponseBodyAsStream
            (
                Protocol.Fetch.RequestId @requestId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Fetch.TakeResponseBodyAsStreamCommand
                    {
                        RequestId = @requestId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Issued when the domain is enabled and the request URL matches the
            /// specified filter. The request is paused until the client responds
            /// with one of continueRequest, failRequest or fulfillRequest.
            /// The stage of the request can be determined by presence of responseErrorReason
            /// and responseStatusCode -- the request is at the response stage if either
            /// of these fields is present and in the request stage otherwise.
            /// </summary>
            public event Func<Protocol.Fetch.RequestPausedEvent, Task> RequestPaused
            {
                add => InspectorClient.AddEventHandlerCore("Fetch.requestPaused", value);
                remove => InspectorClient.RemoveEventHandlerCore("Fetch.requestPaused", value);
            }

            /// <summary>
            /// Issued when the domain is enabled with handleAuthRequests set to true.
            /// The request is paused until client responds with continueWithAuth.
            /// </summary>
            public event Func<Protocol.Fetch.AuthRequiredEvent, Task> AuthRequired
            {
                add => InspectorClient.AddEventHandlerCore("Fetch.authRequired", value);
                remove => InspectorClient.RemoveEventHandlerCore("Fetch.authRequired", value);
            }

            /// <summary>
            /// Issued when the domain is enabled and the request URL matches the
            /// specified filter. The request is paused until the client responds
            /// with one of continueRequest, failRequest or fulfillRequest.
            /// The stage of the request can be determined by presence of responseErrorReason
            /// and responseStatusCode -- the request is at the response stage if either
            /// of these fields is present and in the request stage otherwise.
            /// </summary>
            public Task<Protocol.Fetch.RequestPausedEvent> RequestPausedEvent(Func<Protocol.Fetch.RequestPausedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Fetch.requestPaused", until);
            }

            /// <summary>
            /// Issued when the domain is enabled with handleAuthRequests set to true.
            /// The request is paused until client responds with continueWithAuth.
            /// </summary>
            public Task<Protocol.Fetch.AuthRequiredEvent> AuthRequiredEvent(Func<Protocol.Fetch.AuthRequiredEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Fetch.authRequired", until);
            }
        }
    }
}
