using Fileo.Extensions;
using System.Collections.Generic;
using System.Linq;

namespace Fileo.Tests.Base
{
    public class ImportResult<T>
    {
        public IList<string> Errors { get; }
        public bool HasErrors { get { return !Errors.IsNullOrEmpty() && Errors.Any(); } }
        public IList<T> Objects { get; private set; }

        public ImportResult(IList<T> objects, IList<string> errors)
        {
            Objects = objects;
            Errors = errors;
        }
    }
}
