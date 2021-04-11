namespace DumbPrograms.ChromeDevTools.Protocol
{
    /// <summary>
    /// Wraps a native type as a new type, so you have documents &amp; strong typings.
    /// </summary>
    /// <typeparam name="TNative"></typeparam>
    public class JSAlias<TNative>
    {
        /// <summary>
        /// The actual value.
        /// </summary>
        public TNative Value { get; protected set; }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        public JSAlias(TNative value)
        {
            Value = value;
        }

        /// <summary>
        /// Avoid me. This is used to protect.
        /// </summary>
        protected JSAlias() { }

        /// <summary>
        /// Avoid me. Used in generated enum classes that only have default constructors.
        /// </summary>
        /// <typeparam name="TAlias"></typeparam>
        /// <param name="value"></param>
        /// <returns></returns>
        public static TAlias New<TAlias>(TNative value) where TAlias : JSAlias<TNative>, new()
        {
            return new TAlias { Value = value };
        }
    }
}
