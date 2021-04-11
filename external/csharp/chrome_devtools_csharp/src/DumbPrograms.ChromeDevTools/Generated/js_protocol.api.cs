using System;
using System.Threading;
using System.Threading.Tasks;

namespace DumbPrograms.ChromeDevTools
{
    partial class InspectorClient
    {

        /// <summary>
        /// This domain is deprecated - use Runtime or Log instead.
        /// </summary>
        [Obsolete]
        public ConsoleInspectorClient Console => __Console__ ?? (__Console__ = new ConsoleInspectorClient(this));
        [Obsolete]
        private ConsoleInspectorClient __Console__;

        /// <summary>
        /// Debugger domain exposes JavaScript debugging capabilities. It allows setting and removing
        /// breakpoints, stepping through execution, exploring stack traces, etc.
        /// </summary>
        public DebuggerInspectorClient Debugger => __Debugger__ ?? (__Debugger__ = new DebuggerInspectorClient(this));
        private DebuggerInspectorClient __Debugger__;

        /// <summary />
        public HeapProfilerInspectorClient HeapProfiler => __HeapProfiler__ ?? (__HeapProfiler__ = new HeapProfilerInspectorClient(this));
        private HeapProfilerInspectorClient __HeapProfiler__;

        /// <summary />
        public ProfilerInspectorClient Profiler => __Profiler__ ?? (__Profiler__ = new ProfilerInspectorClient(this));
        private ProfilerInspectorClient __Profiler__;

        /// <summary>
        /// Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror objects.
        /// Evaluation results are returned as mirror object that expose object type, string representation
        /// and unique identifier that can be used for further object reference. Original objects are
        /// maintained in memory unless they are either explicitly released or are released along with the
        /// other objects in their object group.
        /// </summary>
        public RuntimeInspectorClient Runtime => __Runtime__ ?? (__Runtime__ = new RuntimeInspectorClient(this));
        private RuntimeInspectorClient __Runtime__;

        /// <summary>
        /// This domain is deprecated.
        /// </summary>
        [Obsolete]
        public SchemaInspectorClient Schema => __Schema__ ?? (__Schema__ = new SchemaInspectorClient(this));
        [Obsolete]
        private SchemaInspectorClient __Schema__;

        /// <summary>
        /// Inspector client for domain Console.
        /// </summary>
        [Obsolete]
        public class ConsoleInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal ConsoleInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Does nothing.
            /// </summary>
            /// <param name="cancellation" />
            public Task ClearMessages
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Console.ClearMessagesCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables console domain, prevents further console messages from being reported to the client.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Console.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables console domain, sends the messages collected so far to the client by means of the
            /// `messageAdded` notification.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Console.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Issued when new console message is added.
            /// </summary>
            public event Func<Protocol.Console.MessageAddedEvent, Task> MessageAdded
            {
                add => InspectorClient.AddEventHandlerCore("Console.messageAdded", value);
                remove => InspectorClient.RemoveEventHandlerCore("Console.messageAdded", value);
            }

            /// <summary>
            /// Issued when new console message is added.
            /// </summary>
            public Task<Protocol.Console.MessageAddedEvent> MessageAddedEvent(Func<Protocol.Console.MessageAddedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Console.messageAdded", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Debugger.
        /// </summary>
        public class DebuggerInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal DebuggerInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Continues execution until specific location is reached.
            /// </summary>
            /// <param name="location">
            /// Location to continue to.
            /// </param>
            /// <param name="targetCallFrames" />
            /// <param name="cancellation" />
            public Task ContinueToLocation
            (
                Protocol.Debugger.Location @location, 
                string @targetCallFrames = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.ContinueToLocationCommand
                    {
                        Location = @location,
                        TargetCallFrames = @targetCallFrames,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables debugger for given page.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables debugger for the given page. Clients should not assume that the debugging has been
            /// enabled until the result for this command is received.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.EnableResponse> Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Evaluates expression on a given call frame.
            /// </summary>
            /// <param name="callFrameId">
            /// Call frame identifier to evaluate on.
            /// </param>
            /// <param name="expression">
            /// Expression to evaluate.
            /// </param>
            /// <param name="objectGroup">
            /// String object group name to put result into (allows rapid releasing resulting object handles
            /// using `releaseObjectGroup`).
            /// </param>
            /// <param name="includeCommandLineAPI">
            /// Specifies whether command line API should be available to the evaluated expression, defaults
            /// to false.
            /// </param>
            /// <param name="silent">
            /// In silent mode exceptions thrown during evaluation are not reported and do not pause
            /// execution. Overrides `setPauseOnException` state.
            /// </param>
            /// <param name="returnByValue">
            /// Whether the result is expected to be a JSON object that should be sent by value.
            /// </param>
            /// <param name="generatePreview">
            /// Whether preview should be generated for the result.
            /// </param>
            /// <param name="throwOnSideEffect">
            /// Whether to throw an exception if side effect cannot be ruled out during evaluation.
            /// </param>
            /// <param name="timeout">
            /// Terminate execution after timing out (number of milliseconds).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.EvaluateOnCallFrameResponse> EvaluateOnCallFrame
            (
                Protocol.Debugger.CallFrameId @callFrameId, 
                string @expression, 
                string @objectGroup = default, 
                bool? @includeCommandLineAPI = default, 
                bool? @silent = default, 
                bool? @returnByValue = default, 
                bool? @generatePreview = default, 
                bool? @throwOnSideEffect = default, 
                Protocol.Runtime.TimeDelta @timeout = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.EvaluateOnCallFrameCommand
                    {
                        CallFrameId = @callFrameId,
                        Expression = @expression,
                        ObjectGroup = @objectGroup,
                        IncludeCommandLineAPI = @includeCommandLineAPI,
                        Silent = @silent,
                        ReturnByValue = @returnByValue,
                        GeneratePreview = @generatePreview,
                        ThrowOnSideEffect = @throwOnSideEffect,
                        Timeout = @timeout,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns possible locations for breakpoint. scriptId in start and end range locations should be
            /// the same.
            /// </summary>
            /// <param name="start">
            /// Start of range to search possible breakpoint locations in.
            /// </param>
            /// <param name="end">
            /// End of range to search possible breakpoint locations in (excluding). When not specified, end
            /// of scripts is used as end of range.
            /// </param>
            /// <param name="restrictToFunction">
            /// Only consider locations which are in the same (non-nested) function as start.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.GetPossibleBreakpointsResponse> GetPossibleBreakpoints
            (
                Protocol.Debugger.Location @start, 
                Protocol.Debugger.Location @end = default, 
                bool? @restrictToFunction = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.GetPossibleBreakpointsCommand
                    {
                        Start = @start,
                        End = @end,
                        RestrictToFunction = @restrictToFunction,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns source for the script with given id.
            /// </summary>
            /// <param name="scriptId">
            /// Id of the script to get source for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.GetScriptSourceResponse> GetScriptSource
            (
                Protocol.Runtime.ScriptId @scriptId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.GetScriptSourceCommand
                    {
                        ScriptId = @scriptId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns stack trace with given `stackTraceId`.
            /// </summary>
            /// <param name="stackTraceId" />
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.GetStackTraceResponse> GetStackTrace
            (
                Protocol.Runtime.StackTraceId @stackTraceId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.GetStackTraceCommand
                    {
                        StackTraceId = @stackTraceId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Stops on the next JavaScript statement.
            /// </summary>
            /// <param name="cancellation" />
            public Task Pause
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.PauseCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="parentStackTraceId">
            /// Debugger will pause when async call with given stack trace is started.
            /// </param>
            /// <param name="cancellation" />
            public Task PauseOnAsyncCall
            (
                Protocol.Runtime.StackTraceId @parentStackTraceId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.PauseOnAsyncCallCommand
                    {
                        ParentStackTraceId = @parentStackTraceId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Removes JavaScript breakpoint.
            /// </summary>
            /// <param name="breakpointId" />
            /// <param name="cancellation" />
            public Task RemoveBreakpoint
            (
                Protocol.Debugger.BreakpointId @breakpointId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.RemoveBreakpointCommand
                    {
                        BreakpointId = @breakpointId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Restarts particular call frame from the beginning.
            /// </summary>
            /// <param name="callFrameId">
            /// Call frame identifier to evaluate on.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.RestartFrameResponse> RestartFrame
            (
                Protocol.Debugger.CallFrameId @callFrameId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.RestartFrameCommand
                    {
                        CallFrameId = @callFrameId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Resumes JavaScript execution.
            /// </summary>
            /// <param name="cancellation" />
            public Task Resume
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.ResumeCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Searches for given string in script content.
            /// </summary>
            /// <param name="scriptId">
            /// Id of the script to search in.
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
            public Task<Protocol.Debugger.SearchInContentResponse> SearchInContent
            (
                Protocol.Runtime.ScriptId @scriptId, 
                string @query, 
                bool? @caseSensitive = default, 
                bool? @isRegex = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SearchInContentCommand
                    {
                        ScriptId = @scriptId,
                        Query = @query,
                        CaseSensitive = @caseSensitive,
                        IsRegex = @isRegex,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables or disables async call stacks tracking.
            /// </summary>
            /// <param name="maxDepth">
            /// Maximum depth of async call stacks. Setting to `0` will effectively disable collecting async
            /// call stacks (default).
            /// </param>
            /// <param name="cancellation" />
            public Task SetAsyncCallStackDepth
            (
                long @maxDepth, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetAsyncCallStackDepthCommand
                    {
                        MaxDepth = @maxDepth,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Replace previous blackbox patterns with passed ones. Forces backend to skip stepping/pausing in
            /// scripts with url matching one of the patterns. VM will try to leave blackboxed script by
            /// performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
            /// </summary>
            /// <param name="patterns">
            /// Array of regexps that will be used to check script url for blackbox state.
            /// </param>
            /// <param name="cancellation" />
            public Task SetBlackboxPatterns
            (
                string[] @patterns, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetBlackboxPatternsCommand
                    {
                        Patterns = @patterns,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Makes backend skip steps in the script in blackboxed ranges. VM will try leave blacklisted
            /// scripts by performing 'step in' several times, finally resorting to 'step out' if unsuccessful.
            /// Positions array contains positions where blackbox state is changed. First interval isn't
            /// blackboxed. Array should be sorted.
            /// </summary>
            /// <param name="scriptId">
            /// Id of the script.
            /// </param>
            /// <param name="positions" />
            /// <param name="cancellation" />
            public Task SetBlackboxedRanges
            (
                Protocol.Runtime.ScriptId @scriptId, 
                Protocol.Debugger.ScriptPosition[] @positions, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetBlackboxedRangesCommand
                    {
                        ScriptId = @scriptId,
                        Positions = @positions,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets JavaScript breakpoint at a given location.
            /// </summary>
            /// <param name="location">
            /// Location to set breakpoint in.
            /// </param>
            /// <param name="condition">
            /// Expression to use as a breakpoint condition. When specified, debugger will only stop on the
            /// breakpoint if this expression evaluates to true.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.SetBreakpointResponse> SetBreakpoint
            (
                Protocol.Debugger.Location @location, 
                string @condition = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetBreakpointCommand
                    {
                        Location = @location,
                        Condition = @condition,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets JavaScript breakpoint at given location specified either by URL or URL regex. Once this
            /// command is issued, all existing parsed scripts will have breakpoints resolved and returned in
            /// `locations` property. Further matching script parsing will result in subsequent
            /// `breakpointResolved` events issued. This logical breakpoint will survive page reloads.
            /// </summary>
            /// <param name="lineNumber">
            /// Line number to set breakpoint at.
            /// </param>
            /// <param name="url">
            /// URL of the resources to set breakpoint on.
            /// </param>
            /// <param name="urlRegex">
            /// Regex pattern for the URLs of the resources to set breakpoints on. Either `url` or
            /// `urlRegex` must be specified.
            /// </param>
            /// <param name="scriptHash">
            /// Script hash of the resources to set breakpoint on.
            /// </param>
            /// <param name="columnNumber">
            /// Offset in the line to set breakpoint at.
            /// </param>
            /// <param name="condition">
            /// Expression to use as a breakpoint condition. When specified, debugger will only stop on the
            /// breakpoint if this expression evaluates to true.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.SetBreakpointByUrlResponse> SetBreakpointByUrl
            (
                long @lineNumber, 
                string @url = default, 
                string @urlRegex = default, 
                string @scriptHash = default, 
                long? @columnNumber = default, 
                string @condition = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetBreakpointByUrlCommand
                    {
                        LineNumber = @lineNumber,
                        Url = @url,
                        UrlRegex = @urlRegex,
                        ScriptHash = @scriptHash,
                        ColumnNumber = @columnNumber,
                        Condition = @condition,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Sets JavaScript breakpoint before each call to the given function.
            /// If another function was created from the same source as a given one,
            /// calling it will also trigger the breakpoint.
            /// </summary>
            /// <param name="objectId">
            /// Function object id.
            /// </param>
            /// <param name="condition">
            /// Expression to use as a breakpoint condition. When specified, debugger will
            /// stop on the breakpoint if this expression evaluates to true.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.SetBreakpointOnFunctionCallResponse> SetBreakpointOnFunctionCall
            (
                Protocol.Runtime.RemoteObjectId @objectId, 
                string @condition = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetBreakpointOnFunctionCallCommand
                    {
                        ObjectId = @objectId,
                        Condition = @condition,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Activates / deactivates all breakpoints on the page.
            /// </summary>
            /// <param name="active">
            /// New value for breakpoints active state.
            /// </param>
            /// <param name="cancellation" />
            public Task SetBreakpointsActive
            (
                bool @active, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetBreakpointsActiveCommand
                    {
                        Active = @active,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Defines pause on exceptions state. Can be set to stop on all exceptions, uncaught exceptions or
            /// no exceptions. Initial pause on exceptions state is `none`.
            /// </summary>
            /// <param name="state">
            /// Pause on exceptions mode.
            /// </param>
            /// <param name="cancellation" />
            public Task SetPauseOnExceptions
            (
                string @state, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetPauseOnExceptionsCommand
                    {
                        State = @state,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Changes return value in top frame. Available only at return break position.
            /// </summary>
            /// <param name="newValue">
            /// New return value.
            /// </param>
            /// <param name="cancellation" />
            public Task SetReturnValue
            (
                Protocol.Runtime.CallArgument @newValue, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetReturnValueCommand
                    {
                        NewValue = @newValue,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Edits JavaScript source live.
            /// </summary>
            /// <param name="scriptId">
            /// Id of the script to edit.
            /// </param>
            /// <param name="scriptSource">
            /// New content of the script.
            /// </param>
            /// <param name="dryRun">
            /// If true the change will not actually be applied. Dry run may be used to get result
            /// description without actually modifying the code.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Debugger.SetScriptSourceResponse> SetScriptSource
            (
                Protocol.Runtime.ScriptId @scriptId, 
                string @scriptSource, 
                bool? @dryRun = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetScriptSourceCommand
                    {
                        ScriptId = @scriptId,
                        ScriptSource = @scriptSource,
                        DryRun = @dryRun,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Makes page not interrupt on any pauses (breakpoint, exception, dom exception etc).
            /// </summary>
            /// <param name="skip">
            /// New value for skip pauses state.
            /// </param>
            /// <param name="cancellation" />
            public Task SetSkipAllPauses
            (
                bool @skip, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetSkipAllPausesCommand
                    {
                        Skip = @skip,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Changes value of variable in a callframe. Object-based scopes are not supported and must be
            /// mutated manually.
            /// </summary>
            /// <param name="scopeNumber">
            /// 0-based number of scope as was listed in scope chain. Only 'local', 'closure' and 'catch'
            /// scope types are allowed. Other scopes could be manipulated manually.
            /// </param>
            /// <param name="variableName">
            /// Variable name.
            /// </param>
            /// <param name="newValue">
            /// New variable value.
            /// </param>
            /// <param name="callFrameId">
            /// Id of callframe that holds variable.
            /// </param>
            /// <param name="cancellation" />
            public Task SetVariableValue
            (
                long @scopeNumber, 
                string @variableName, 
                Protocol.Runtime.CallArgument @newValue, 
                Protocol.Debugger.CallFrameId @callFrameId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.SetVariableValueCommand
                    {
                        ScopeNumber = @scopeNumber,
                        VariableName = @variableName,
                        NewValue = @newValue,
                        CallFrameId = @callFrameId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Steps into the function call.
            /// </summary>
            /// <param name="breakOnAsyncCall">
            /// Debugger will issue additional Debugger.paused notification if any async task is scheduled
            /// before next pause.
            /// </param>
            /// <param name="cancellation" />
            public Task StepInto
            (
                bool? @breakOnAsyncCall = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.StepIntoCommand
                    {
                        BreakOnAsyncCall = @breakOnAsyncCall,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Steps out of the function call.
            /// </summary>
            /// <param name="cancellation" />
            public Task StepOut
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.StepOutCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Steps over the statement.
            /// </summary>
            /// <param name="cancellation" />
            public Task StepOver
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Debugger.StepOverCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Fired when breakpoint is resolved to an actual script and location.
            /// </summary>
            public event Func<Protocol.Debugger.BreakpointResolvedEvent, Task> BreakpointResolved
            {
                add => InspectorClient.AddEventHandlerCore("Debugger.breakpointResolved", value);
                remove => InspectorClient.RemoveEventHandlerCore("Debugger.breakpointResolved", value);
            }

            /// <summary>
            /// Fired when the virtual machine stopped on breakpoint or exception or any other stop criteria.
            /// </summary>
            public event Func<Protocol.Debugger.PausedEvent, Task> Paused
            {
                add => InspectorClient.AddEventHandlerCore("Debugger.paused", value);
                remove => InspectorClient.RemoveEventHandlerCore("Debugger.paused", value);
            }

            /// <summary>
            /// Fired when the virtual machine resumed execution.
            /// </summary>
            public event Func<Protocol.Debugger.ResumedEvent, Task> Resumed
            {
                add => InspectorClient.AddEventHandlerCore("Debugger.resumed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Debugger.resumed", value);
            }

            /// <summary>
            /// Fired when virtual machine fails to parse the script.
            /// </summary>
            public event Func<Protocol.Debugger.ScriptFailedToParseEvent, Task> ScriptFailedToParse
            {
                add => InspectorClient.AddEventHandlerCore("Debugger.scriptFailedToParse", value);
                remove => InspectorClient.RemoveEventHandlerCore("Debugger.scriptFailedToParse", value);
            }

            /// <summary>
            /// Fired when virtual machine parses script. This event is also fired for all known and uncollected
            /// scripts upon enabling debugger.
            /// </summary>
            public event Func<Protocol.Debugger.ScriptParsedEvent, Task> ScriptParsed
            {
                add => InspectorClient.AddEventHandlerCore("Debugger.scriptParsed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Debugger.scriptParsed", value);
            }

            /// <summary>
            /// Fired when breakpoint is resolved to an actual script and location.
            /// </summary>
            public Task<Protocol.Debugger.BreakpointResolvedEvent> BreakpointResolvedEvent(Func<Protocol.Debugger.BreakpointResolvedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Debugger.breakpointResolved", until);
            }

            /// <summary>
            /// Fired when the virtual machine stopped on breakpoint or exception or any other stop criteria.
            /// </summary>
            public Task<Protocol.Debugger.PausedEvent> PausedEvent(Func<Protocol.Debugger.PausedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Debugger.paused", until);
            }

            /// <summary>
            /// Fired when the virtual machine resumed execution.
            /// </summary>
            public Task<Protocol.Debugger.ResumedEvent> ResumedEvent(Func<Protocol.Debugger.ResumedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Debugger.resumed", until);
            }

            /// <summary>
            /// Fired when virtual machine fails to parse the script.
            /// </summary>
            public Task<Protocol.Debugger.ScriptFailedToParseEvent> ScriptFailedToParseEvent(Func<Protocol.Debugger.ScriptFailedToParseEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Debugger.scriptFailedToParse", until);
            }

            /// <summary>
            /// Fired when virtual machine parses script. This event is also fired for all known and uncollected
            /// scripts upon enabling debugger.
            /// </summary>
            public Task<Protocol.Debugger.ScriptParsedEvent> ScriptParsedEvent(Func<Protocol.Debugger.ScriptParsedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Debugger.scriptParsed", until);
            }
        }

        /// <summary>
        /// Inspector client for domain HeapProfiler.
        /// </summary>
        public class HeapProfilerInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal HeapProfilerInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Enables console to refer to the node with given id via $x (see Command Line API for more details
            /// $x functions).
            /// </summary>
            /// <param name="heapObjectId">
            /// Heap snapshot object id to be accessible by means of $x command line API.
            /// </param>
            /// <param name="cancellation" />
            public Task AddInspectedHeapObject
            (
                Protocol.HeapProfiler.HeapSnapshotObjectId @heapObjectId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.AddInspectedHeapObjectCommand
                    {
                        HeapObjectId = @heapObjectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task CollectGarbage
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.CollectGarbageCommand
                    {
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
                    new Protocol.HeapProfiler.DisableCommand
                    {
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
                    new Protocol.HeapProfiler.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="objectId">
            /// Identifier of the object to get heap object id for.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.HeapProfiler.GetHeapObjectIdResponse> GetHeapObjectId
            (
                Protocol.Runtime.RemoteObjectId @objectId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.GetHeapObjectIdCommand
                    {
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="objectId" />
            /// <param name="objectGroup">
            /// Symbolic group name that can be used to release multiple objects.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.HeapProfiler.GetObjectByHeapObjectIdResponse> GetObjectByHeapObjectId
            (
                Protocol.HeapProfiler.HeapSnapshotObjectId @objectId, 
                string @objectGroup = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.GetObjectByHeapObjectIdCommand
                    {
                        ObjectId = @objectId,
                        ObjectGroup = @objectGroup,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task<Protocol.HeapProfiler.GetSamplingProfileResponse> GetSamplingProfile
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.GetSamplingProfileCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="samplingInterval">
            /// Average sample interval in bytes. Poisson distribution is used for the intervals. The
            /// default value is 32768 bytes.
            /// </param>
            /// <param name="cancellation" />
            public Task StartSampling
            (
                double? @samplingInterval = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.StartSamplingCommand
                    {
                        SamplingInterval = @samplingInterval,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="trackAllocations" />
            /// <param name="cancellation" />
            public Task StartTrackingHeapObjects
            (
                bool? @trackAllocations = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.StartTrackingHeapObjectsCommand
                    {
                        TrackAllocations = @trackAllocations,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task<Protocol.HeapProfiler.StopSamplingResponse> StopSampling
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.StopSamplingCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="reportProgress">
            /// If true 'reportHeapSnapshotProgress' events will be generated while snapshot is being taken
            /// when the tracking is stopped.
            /// </param>
            /// <param name="cancellation" />
            public Task StopTrackingHeapObjects
            (
                bool? @reportProgress = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.StopTrackingHeapObjectsCommand
                    {
                        ReportProgress = @reportProgress,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="reportProgress">
            /// If true 'reportHeapSnapshotProgress' events will be generated while snapshot is being taken.
            /// </param>
            /// <param name="cancellation" />
            public Task TakeHeapSnapshot
            (
                bool? @reportProgress = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.HeapProfiler.TakeHeapSnapshotCommand
                    {
                        ReportProgress = @reportProgress,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.HeapProfiler.AddHeapSnapshotChunkEvent, Task> AddHeapSnapshotChunk
            {
                add => InspectorClient.AddEventHandlerCore("HeapProfiler.addHeapSnapshotChunk", value);
                remove => InspectorClient.RemoveEventHandlerCore("HeapProfiler.addHeapSnapshotChunk", value);
            }

            /// <summary>
            /// If heap objects tracking has been started then backend may send update for one or more fragments
            /// </summary>
            public event Func<Protocol.HeapProfiler.HeapStatsUpdateEvent, Task> HeapStatsUpdate
            {
                add => InspectorClient.AddEventHandlerCore("HeapProfiler.heapStatsUpdate", value);
                remove => InspectorClient.RemoveEventHandlerCore("HeapProfiler.heapStatsUpdate", value);
            }

            /// <summary>
            /// If heap objects tracking has been started then backend regularly sends a current value for last
            /// seen object id and corresponding timestamp. If the were changes in the heap since last event
            /// then one or more heapStatsUpdate events will be sent before a new lastSeenObjectId event.
            /// </summary>
            public event Func<Protocol.HeapProfiler.LastSeenObjectIdEvent, Task> LastSeenObjectId
            {
                add => InspectorClient.AddEventHandlerCore("HeapProfiler.lastSeenObjectId", value);
                remove => InspectorClient.RemoveEventHandlerCore("HeapProfiler.lastSeenObjectId", value);
            }

            /// <summary />
            public event Func<Protocol.HeapProfiler.ReportHeapSnapshotProgressEvent, Task> ReportHeapSnapshotProgress
            {
                add => InspectorClient.AddEventHandlerCore("HeapProfiler.reportHeapSnapshotProgress", value);
                remove => InspectorClient.RemoveEventHandlerCore("HeapProfiler.reportHeapSnapshotProgress", value);
            }

            /// <summary />
            public event Func<Protocol.HeapProfiler.ResetProfilesEvent, Task> ResetProfiles
            {
                add => InspectorClient.AddEventHandlerCore("HeapProfiler.resetProfiles", value);
                remove => InspectorClient.RemoveEventHandlerCore("HeapProfiler.resetProfiles", value);
            }

            /// <summary />
            public Task<Protocol.HeapProfiler.AddHeapSnapshotChunkEvent> AddHeapSnapshotChunkEvent(Func<Protocol.HeapProfiler.AddHeapSnapshotChunkEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("HeapProfiler.addHeapSnapshotChunk", until);
            }

            /// <summary>
            /// If heap objects tracking has been started then backend may send update for one or more fragments
            /// </summary>
            public Task<Protocol.HeapProfiler.HeapStatsUpdateEvent> HeapStatsUpdateEvent(Func<Protocol.HeapProfiler.HeapStatsUpdateEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("HeapProfiler.heapStatsUpdate", until);
            }

            /// <summary>
            /// If heap objects tracking has been started then backend regularly sends a current value for last
            /// seen object id and corresponding timestamp. If the were changes in the heap since last event
            /// then one or more heapStatsUpdate events will be sent before a new lastSeenObjectId event.
            /// </summary>
            public Task<Protocol.HeapProfiler.LastSeenObjectIdEvent> LastSeenObjectIdEvent(Func<Protocol.HeapProfiler.LastSeenObjectIdEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("HeapProfiler.lastSeenObjectId", until);
            }

            /// <summary />
            public Task<Protocol.HeapProfiler.ReportHeapSnapshotProgressEvent> ReportHeapSnapshotProgressEvent(Func<Protocol.HeapProfiler.ReportHeapSnapshotProgressEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("HeapProfiler.reportHeapSnapshotProgress", until);
            }

            /// <summary />
            public Task<Protocol.HeapProfiler.ResetProfilesEvent> ResetProfilesEvent(Func<Protocol.HeapProfiler.ResetProfilesEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("HeapProfiler.resetProfiles", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Profiler.
        /// </summary>
        public class ProfilerInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal ProfilerInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
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
                    new Protocol.Profiler.DisableCommand
                    {
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
                    new Protocol.Profiler.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Collect coverage data for the current isolate. The coverage data may be incomplete due to
            /// garbage collection.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Profiler.GetBestEffortCoverageResponse> GetBestEffortCoverage
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.GetBestEffortCoverageCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Changes CPU profiler sampling interval. Must be called before CPU profiles recording started.
            /// </summary>
            /// <param name="interval">
            /// New sampling interval in microseconds.
            /// </param>
            /// <param name="cancellation" />
            public Task SetSamplingInterval
            (
                long @interval, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.SetSamplingIntervalCommand
                    {
                        Interval = @interval,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task Start
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.StartCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enable precise code coverage. Coverage data for JavaScript executed before enabling precise code
            /// coverage may be incomplete. Enabling prevents running optimized code and resets execution
            /// counters.
            /// </summary>
            /// <param name="callCount">
            /// Collect accurate call counts beyond simple 'covered' or 'not covered'.
            /// </param>
            /// <param name="detailed">
            /// Collect block-based coverage.
            /// </param>
            /// <param name="cancellation" />
            public Task StartPreciseCoverage
            (
                bool? @callCount = default, 
                bool? @detailed = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.StartPreciseCoverageCommand
                    {
                        CallCount = @callCount,
                        Detailed = @detailed,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enable type profile.
            /// </summary>
            /// <param name="cancellation" />
            public Task StartTypeProfile
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.StartTypeProfileCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="cancellation" />
            public Task<Protocol.Profiler.StopResponse> Stop
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.StopCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disable precise code coverage. Disabling releases unnecessary execution count records and allows
            /// executing optimized code.
            /// </summary>
            /// <param name="cancellation" />
            public Task StopPreciseCoverage
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.StopPreciseCoverageCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disable type profile. Disabling releases type profile data collected so far.
            /// </summary>
            /// <param name="cancellation" />
            public Task StopTypeProfile
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.StopTypeProfileCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Collect coverage data for the current isolate, and resets execution counters. Precise code
            /// coverage needs to have started.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Profiler.TakePreciseCoverageResponse> TakePreciseCoverage
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.TakePreciseCoverageCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Collect type profile.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Profiler.TakeTypeProfileResponse> TakeTypeProfile
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Profiler.TakeTypeProfileCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            public event Func<Protocol.Profiler.ConsoleProfileFinishedEvent, Task> ConsoleProfileFinished
            {
                add => InspectorClient.AddEventHandlerCore("Profiler.consoleProfileFinished", value);
                remove => InspectorClient.RemoveEventHandlerCore("Profiler.consoleProfileFinished", value);
            }

            /// <summary>
            /// Sent when new profile recording is started using console.profile() call.
            /// </summary>
            public event Func<Protocol.Profiler.ConsoleProfileStartedEvent, Task> ConsoleProfileStarted
            {
                add => InspectorClient.AddEventHandlerCore("Profiler.consoleProfileStarted", value);
                remove => InspectorClient.RemoveEventHandlerCore("Profiler.consoleProfileStarted", value);
            }

            /// <summary />
            public Task<Protocol.Profiler.ConsoleProfileFinishedEvent> ConsoleProfileFinishedEvent(Func<Protocol.Profiler.ConsoleProfileFinishedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Profiler.consoleProfileFinished", until);
            }

            /// <summary>
            /// Sent when new profile recording is started using console.profile() call.
            /// </summary>
            public Task<Protocol.Profiler.ConsoleProfileStartedEvent> ConsoleProfileStartedEvent(Func<Protocol.Profiler.ConsoleProfileStartedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Profiler.consoleProfileStarted", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Runtime.
        /// </summary>
        public class RuntimeInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal RuntimeInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Add handler to promise with given promise object id.
            /// </summary>
            /// <param name="promiseObjectId">
            /// Identifier of the promise.
            /// </param>
            /// <param name="returnByValue">
            /// Whether the result is expected to be a JSON object that should be sent by value.
            /// </param>
            /// <param name="generatePreview">
            /// Whether preview should be generated for the result.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.AwaitPromiseResponse> AwaitPromise
            (
                Protocol.Runtime.RemoteObjectId @promiseObjectId, 
                bool? @returnByValue = default, 
                bool? @generatePreview = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.AwaitPromiseCommand
                    {
                        PromiseObjectId = @promiseObjectId,
                        ReturnByValue = @returnByValue,
                        GeneratePreview = @generatePreview,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Calls function with given declaration on the given object. Object group of the result is
            /// inherited from the target object.
            /// </summary>
            /// <param name="functionDeclaration">
            /// Declaration of the function to call.
            /// </param>
            /// <param name="objectId">
            /// Identifier of the object to call function on. Either objectId or executionContextId should
            /// be specified.
            /// </param>
            /// <param name="arguments">
            /// Call arguments. All call arguments must belong to the same JavaScript world as the target
            /// object.
            /// </param>
            /// <param name="silent">
            /// In silent mode exceptions thrown during evaluation are not reported and do not pause
            /// execution. Overrides `setPauseOnException` state.
            /// </param>
            /// <param name="returnByValue">
            /// Whether the result is expected to be a JSON object which should be sent by value.
            /// </param>
            /// <param name="generatePreview">
            /// Whether preview should be generated for the result.
            /// </param>
            /// <param name="userGesture">
            /// Whether execution should be treated as initiated by user in the UI.
            /// </param>
            /// <param name="awaitPromise">
            /// Whether execution should `await` for resulting value and return once awaited promise is
            /// resolved.
            /// </param>
            /// <param name="executionContextId">
            /// Specifies execution context which global object will be used to call function on. Either
            /// executionContextId or objectId should be specified.
            /// </param>
            /// <param name="objectGroup">
            /// Symbolic group name that can be used to release multiple objects. If objectGroup is not
            /// specified and objectId is, objectGroup will be inherited from object.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.CallFunctionOnResponse> CallFunctionOn
            (
                string @functionDeclaration, 
                Protocol.Runtime.RemoteObjectId @objectId = default, 
                Protocol.Runtime.CallArgument[] @arguments = default, 
                bool? @silent = default, 
                bool? @returnByValue = default, 
                bool? @generatePreview = default, 
                bool? @userGesture = default, 
                bool? @awaitPromise = default, 
                Protocol.Runtime.ExecutionContextId @executionContextId = default, 
                string @objectGroup = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.CallFunctionOnCommand
                    {
                        FunctionDeclaration = @functionDeclaration,
                        ObjectId = @objectId,
                        Arguments = @arguments,
                        Silent = @silent,
                        ReturnByValue = @returnByValue,
                        GeneratePreview = @generatePreview,
                        UserGesture = @userGesture,
                        AwaitPromise = @awaitPromise,
                        ExecutionContextId = @executionContextId,
                        ObjectGroup = @objectGroup,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Compiles expression.
            /// </summary>
            /// <param name="expression">
            /// Expression to compile.
            /// </param>
            /// <param name="sourceURL">
            /// Source url to be set for the script.
            /// </param>
            /// <param name="persistScript">
            /// Specifies whether the compiled script should be persisted.
            /// </param>
            /// <param name="executionContextId">
            /// Specifies in which execution context to perform script run. If the parameter is omitted the
            /// evaluation will be performed in the context of the inspected page.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.CompileScriptResponse> CompileScript
            (
                string @expression, 
                string @sourceURL, 
                bool @persistScript, 
                Protocol.Runtime.ExecutionContextId @executionContextId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.CompileScriptCommand
                    {
                        Expression = @expression,
                        SourceURL = @sourceURL,
                        PersistScript = @persistScript,
                        ExecutionContextId = @executionContextId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Disables reporting of execution contexts creation.
            /// </summary>
            /// <param name="cancellation" />
            public Task Disable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.DisableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Discards collected exceptions and console API calls.
            /// </summary>
            /// <param name="cancellation" />
            public Task DiscardConsoleEntries
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.DiscardConsoleEntriesCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables reporting of execution contexts creation by means of `executionContextCreated` event.
            /// When the reporting gets enabled the event will be sent immediately for each existing execution
            /// context.
            /// </summary>
            /// <param name="cancellation" />
            public Task Enable
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.EnableCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Evaluates expression on global object.
            /// </summary>
            /// <param name="expression">
            /// Expression to evaluate.
            /// </param>
            /// <param name="objectGroup">
            /// Symbolic group name that can be used to release multiple objects.
            /// </param>
            /// <param name="includeCommandLineAPI">
            /// Determines whether Command Line API should be available during the evaluation.
            /// </param>
            /// <param name="silent">
            /// In silent mode exceptions thrown during evaluation are not reported and do not pause
            /// execution. Overrides `setPauseOnException` state.
            /// </param>
            /// <param name="contextId">
            /// Specifies in which execution context to perform evaluation. If the parameter is omitted the
            /// evaluation will be performed in the context of the inspected page.
            /// </param>
            /// <param name="returnByValue">
            /// Whether the result is expected to be a JSON object that should be sent by value.
            /// </param>
            /// <param name="generatePreview">
            /// Whether preview should be generated for the result.
            /// </param>
            /// <param name="userGesture">
            /// Whether execution should be treated as initiated by user in the UI.
            /// </param>
            /// <param name="awaitPromise">
            /// Whether execution should `await` for resulting value and return once awaited promise is
            /// resolved.
            /// </param>
            /// <param name="throwOnSideEffect">
            /// Whether to throw an exception if side effect cannot be ruled out during evaluation.
            /// </param>
            /// <param name="timeout">
            /// Terminate execution after timing out (number of milliseconds).
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.EvaluateResponse> Evaluate
            (
                string @expression, 
                string @objectGroup = default, 
                bool? @includeCommandLineAPI = default, 
                bool? @silent = default, 
                Protocol.Runtime.ExecutionContextId @contextId = default, 
                bool? @returnByValue = default, 
                bool? @generatePreview = default, 
                bool? @userGesture = default, 
                bool? @awaitPromise = default, 
                bool? @throwOnSideEffect = default, 
                Protocol.Runtime.TimeDelta @timeout = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.EvaluateCommand
                    {
                        Expression = @expression,
                        ObjectGroup = @objectGroup,
                        IncludeCommandLineAPI = @includeCommandLineAPI,
                        Silent = @silent,
                        ContextId = @contextId,
                        ReturnByValue = @returnByValue,
                        GeneratePreview = @generatePreview,
                        UserGesture = @userGesture,
                        AwaitPromise = @awaitPromise,
                        ThrowOnSideEffect = @throwOnSideEffect,
                        Timeout = @timeout,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the isolate id.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.GetIsolateIdResponse> GetIsolateId
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.GetIsolateIdCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns the JavaScript heap usage.
            /// It is the total usage of the corresponding isolate not scoped to a particular Runtime.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.GetHeapUsageResponse> GetHeapUsage
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.GetHeapUsageCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns properties of a given object. Object group of the result is inherited from the target
            /// object.
            /// </summary>
            /// <param name="objectId">
            /// Identifier of the object to return properties for.
            /// </param>
            /// <param name="ownProperties">
            /// If true, returns properties belonging only to the element itself, not to its prototype
            /// chain.
            /// </param>
            /// <param name="accessorPropertiesOnly">
            /// If true, returns accessor properties (with getter/setter) only; internal properties are not
            /// returned either.
            /// </param>
            /// <param name="generatePreview">
            /// Whether preview should be generated for the results.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.GetPropertiesResponse> GetProperties
            (
                Protocol.Runtime.RemoteObjectId @objectId, 
                bool? @ownProperties = default, 
                bool? @accessorPropertiesOnly = default, 
                bool? @generatePreview = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.GetPropertiesCommand
                    {
                        ObjectId = @objectId,
                        OwnProperties = @ownProperties,
                        AccessorPropertiesOnly = @accessorPropertiesOnly,
                        GeneratePreview = @generatePreview,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Returns all let, const and class variables from global scope.
            /// </summary>
            /// <param name="executionContextId">
            /// Specifies in which execution context to lookup global scope variables.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.GlobalLexicalScopeNamesResponse> GlobalLexicalScopeNames
            (
                Protocol.Runtime.ExecutionContextId @executionContextId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.GlobalLexicalScopeNamesCommand
                    {
                        ExecutionContextId = @executionContextId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="prototypeObjectId">
            /// Identifier of the prototype to return objects for.
            /// </param>
            /// <param name="objectGroup">
            /// Symbolic group name that can be used to release the results.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.QueryObjectsResponse> QueryObjects
            (
                Protocol.Runtime.RemoteObjectId @prototypeObjectId, 
                string @objectGroup = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.QueryObjectsCommand
                    {
                        PrototypeObjectId = @prototypeObjectId,
                        ObjectGroup = @objectGroup,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Releases remote object with given id.
            /// </summary>
            /// <param name="objectId">
            /// Identifier of the object to release.
            /// </param>
            /// <param name="cancellation" />
            public Task ReleaseObject
            (
                Protocol.Runtime.RemoteObjectId @objectId, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.ReleaseObjectCommand
                    {
                        ObjectId = @objectId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Releases all remote objects that belong to a given group.
            /// </summary>
            /// <param name="objectGroup">
            /// Symbolic object group name.
            /// </param>
            /// <param name="cancellation" />
            public Task ReleaseObjectGroup
            (
                string @objectGroup, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.ReleaseObjectGroupCommand
                    {
                        ObjectGroup = @objectGroup,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Tells inspected instance to run if it was waiting for debugger to attach.
            /// </summary>
            /// <param name="cancellation" />
            public Task RunIfWaitingForDebugger
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.RunIfWaitingForDebuggerCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Runs script with given id in a given context.
            /// </summary>
            /// <param name="scriptId">
            /// Id of the script to run.
            /// </param>
            /// <param name="executionContextId">
            /// Specifies in which execution context to perform script run. If the parameter is omitted the
            /// evaluation will be performed in the context of the inspected page.
            /// </param>
            /// <param name="objectGroup">
            /// Symbolic group name that can be used to release multiple objects.
            /// </param>
            /// <param name="silent">
            /// In silent mode exceptions thrown during evaluation are not reported and do not pause
            /// execution. Overrides `setPauseOnException` state.
            /// </param>
            /// <param name="includeCommandLineAPI">
            /// Determines whether Command Line API should be available during the evaluation.
            /// </param>
            /// <param name="returnByValue">
            /// Whether the result is expected to be a JSON object which should be sent by value.
            /// </param>
            /// <param name="generatePreview">
            /// Whether preview should be generated for the result.
            /// </param>
            /// <param name="awaitPromise">
            /// Whether execution should `await` for resulting value and return once awaited promise is
            /// resolved.
            /// </param>
            /// <param name="cancellation" />
            public Task<Protocol.Runtime.RunScriptResponse> RunScript
            (
                Protocol.Runtime.ScriptId @scriptId, 
                Protocol.Runtime.ExecutionContextId @executionContextId = default, 
                string @objectGroup = default, 
                bool? @silent = default, 
                bool? @includeCommandLineAPI = default, 
                bool? @returnByValue = default, 
                bool? @generatePreview = default, 
                bool? @awaitPromise = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.RunScriptCommand
                    {
                        ScriptId = @scriptId,
                        ExecutionContextId = @executionContextId,
                        ObjectGroup = @objectGroup,
                        Silent = @silent,
                        IncludeCommandLineAPI = @includeCommandLineAPI,
                        ReturnByValue = @returnByValue,
                        GeneratePreview = @generatePreview,
                        AwaitPromise = @awaitPromise,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Enables or disables async call stacks tracking.
            /// </summary>
            /// <param name="maxDepth">
            /// Maximum depth of async call stacks. Setting to `0` will effectively disable collecting async
            /// call stacks (default).
            /// </param>
            /// <param name="cancellation" />
            public Task SetAsyncCallStackDepth
            (
                long @maxDepth, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.SetAsyncCallStackDepthCommand
                    {
                        MaxDepth = @maxDepth,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="enabled" />
            /// <param name="cancellation" />
            public Task SetCustomObjectFormatterEnabled
            (
                bool @enabled, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.SetCustomObjectFormatterEnabledCommand
                    {
                        Enabled = @enabled,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary />
            /// <param name="size" />
            /// <param name="cancellation" />
            public Task SetMaxCallStackSizeToCapture
            (
                long @size, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.SetMaxCallStackSizeToCaptureCommand
                    {
                        Size = @size,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Terminate current or next JavaScript execution.
            /// Will cancel the termination when the outer-most script execution ends.
            /// </summary>
            /// <param name="cancellation" />
            public Task TerminateExecution
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.TerminateExecutionCommand
                    {
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// If executionContextId is empty, adds binding with the given name on the
            /// global objects of all inspected contexts, including those created later,
            /// bindings survive reloads.
            /// If executionContextId is specified, adds binding only on global object of
            /// given execution context.
            /// Binding function takes exactly one argument, this argument should be string,
            /// in case of any other input, function throws an exception.
            /// Each binding function call produces Runtime.bindingCalled notification.
            /// </summary>
            /// <param name="name" />
            /// <param name="executionContextId" />
            /// <param name="cancellation" />
            public Task AddBinding
            (
                string @name, 
                Protocol.Runtime.ExecutionContextId @executionContextId = default, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.AddBindingCommand
                    {
                        Name = @name,
                        ExecutionContextId = @executionContextId,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// This method does not remove binding function from global object but
            /// unsubscribes current runtime agent from Runtime.bindingCalled notifications.
            /// </summary>
            /// <param name="name" />
            /// <param name="cancellation" />
            public Task RemoveBinding
            (
                string @name, 
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Runtime.RemoveBindingCommand
                    {
                        Name = @name,
                    }
                    , cancellation
                )
                ;
            }

            /// <summary>
            /// Notification is issued every time when binding is called.
            /// </summary>
            public event Func<Protocol.Runtime.BindingCalledEvent, Task> BindingCalled
            {
                add => InspectorClient.AddEventHandlerCore("Runtime.bindingCalled", value);
                remove => InspectorClient.RemoveEventHandlerCore("Runtime.bindingCalled", value);
            }

            /// <summary>
            /// Issued when console API was called.
            /// </summary>
            public event Func<Protocol.Runtime.ConsoleAPICalledEvent, Task> ConsoleAPICalled
            {
                add => InspectorClient.AddEventHandlerCore("Runtime.consoleAPICalled", value);
                remove => InspectorClient.RemoveEventHandlerCore("Runtime.consoleAPICalled", value);
            }

            /// <summary>
            /// Issued when unhandled exception was revoked.
            /// </summary>
            public event Func<Protocol.Runtime.ExceptionRevokedEvent, Task> ExceptionRevoked
            {
                add => InspectorClient.AddEventHandlerCore("Runtime.exceptionRevoked", value);
                remove => InspectorClient.RemoveEventHandlerCore("Runtime.exceptionRevoked", value);
            }

            /// <summary>
            /// Issued when exception was thrown and unhandled.
            /// </summary>
            public event Func<Protocol.Runtime.ExceptionThrownEvent, Task> ExceptionThrown
            {
                add => InspectorClient.AddEventHandlerCore("Runtime.exceptionThrown", value);
                remove => InspectorClient.RemoveEventHandlerCore("Runtime.exceptionThrown", value);
            }

            /// <summary>
            /// Issued when new execution context is created.
            /// </summary>
            public event Func<Protocol.Runtime.ExecutionContextCreatedEvent, Task> ExecutionContextCreated
            {
                add => InspectorClient.AddEventHandlerCore("Runtime.executionContextCreated", value);
                remove => InspectorClient.RemoveEventHandlerCore("Runtime.executionContextCreated", value);
            }

            /// <summary>
            /// Issued when execution context is destroyed.
            /// </summary>
            public event Func<Protocol.Runtime.ExecutionContextDestroyedEvent, Task> ExecutionContextDestroyed
            {
                add => InspectorClient.AddEventHandlerCore("Runtime.executionContextDestroyed", value);
                remove => InspectorClient.RemoveEventHandlerCore("Runtime.executionContextDestroyed", value);
            }

            /// <summary>
            /// Issued when all executionContexts were cleared in browser
            /// </summary>
            public event Func<Protocol.Runtime.ExecutionContextsClearedEvent, Task> ExecutionContextsCleared
            {
                add => InspectorClient.AddEventHandlerCore("Runtime.executionContextsCleared", value);
                remove => InspectorClient.RemoveEventHandlerCore("Runtime.executionContextsCleared", value);
            }

            /// <summary>
            /// Issued when object should be inspected (for example, as a result of inspect() command line API
            /// call).
            /// </summary>
            public event Func<Protocol.Runtime.InspectRequestedEvent, Task> InspectRequested
            {
                add => InspectorClient.AddEventHandlerCore("Runtime.inspectRequested", value);
                remove => InspectorClient.RemoveEventHandlerCore("Runtime.inspectRequested", value);
            }

            /// <summary>
            /// Notification is issued every time when binding is called.
            /// </summary>
            public Task<Protocol.Runtime.BindingCalledEvent> BindingCalledEvent(Func<Protocol.Runtime.BindingCalledEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Runtime.bindingCalled", until);
            }

            /// <summary>
            /// Issued when console API was called.
            /// </summary>
            public Task<Protocol.Runtime.ConsoleAPICalledEvent> ConsoleAPICalledEvent(Func<Protocol.Runtime.ConsoleAPICalledEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Runtime.consoleAPICalled", until);
            }

            /// <summary>
            /// Issued when unhandled exception was revoked.
            /// </summary>
            public Task<Protocol.Runtime.ExceptionRevokedEvent> ExceptionRevokedEvent(Func<Protocol.Runtime.ExceptionRevokedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Runtime.exceptionRevoked", until);
            }

            /// <summary>
            /// Issued when exception was thrown and unhandled.
            /// </summary>
            public Task<Protocol.Runtime.ExceptionThrownEvent> ExceptionThrownEvent(Func<Protocol.Runtime.ExceptionThrownEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Runtime.exceptionThrown", until);
            }

            /// <summary>
            /// Issued when new execution context is created.
            /// </summary>
            public Task<Protocol.Runtime.ExecutionContextCreatedEvent> ExecutionContextCreatedEvent(Func<Protocol.Runtime.ExecutionContextCreatedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Runtime.executionContextCreated", until);
            }

            /// <summary>
            /// Issued when execution context is destroyed.
            /// </summary>
            public Task<Protocol.Runtime.ExecutionContextDestroyedEvent> ExecutionContextDestroyedEvent(Func<Protocol.Runtime.ExecutionContextDestroyedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Runtime.executionContextDestroyed", until);
            }

            /// <summary>
            /// Issued when all executionContexts were cleared in browser
            /// </summary>
            public Task<Protocol.Runtime.ExecutionContextsClearedEvent> ExecutionContextsClearedEvent(Func<Protocol.Runtime.ExecutionContextsClearedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Runtime.executionContextsCleared", until);
            }

            /// <summary>
            /// Issued when object should be inspected (for example, as a result of inspect() command line API
            /// call).
            /// </summary>
            public Task<Protocol.Runtime.InspectRequestedEvent> InspectRequestedEvent(Func<Protocol.Runtime.InspectRequestedEvent, Task<bool>> until = null)
            {
                return InspectorClient.SubscribeUntilCore("Runtime.inspectRequested", until);
            }
        }

        /// <summary>
        /// Inspector client for domain Schema.
        /// </summary>
        [Obsolete]
        public class SchemaInspectorClient
        {
            private readonly InspectorClient InspectorClient;

            internal SchemaInspectorClient(InspectorClient inspectionClient)
            {
                InspectorClient = inspectionClient;
            }

            /// <summary>
            /// Returns supported domains.
            /// </summary>
            /// <param name="cancellation" />
            public Task<Protocol.Schema.GetDomainsResponse> GetDomains
            (
                CancellationToken cancellation = default
            )
            {
                return InspectorClient.InvokeCommandCore
                (
                    new Protocol.Schema.GetDomainsCommand
                    {
                    }
                    , cancellation
                )
                ;
            }
        }
    }
}
