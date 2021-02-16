using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Wait {
	public static class GenericWait<T> {
		/// <summary>
		/// This method execute func() continuously by calling Wait.Until() until timeout or expected condition is met.
		/// </summary>
		/// <param name="func">
		/// Any function returning T as result.
		/// For functions whose signature has one or more parameters, for example: 
		///     public T someFunc(int param), 
		///  This method can be called with assitance of LINQ as below:
		///     Until(()=>someFunc(param), isExpected)
		/// </param>
		/// <param name="isExpected">Predicate to judge if the result returned by func() is expected</param>
		/// <param name="timeoutMills">Time waited before draw conclusion that the command cannnot succeed.</param>
		/// <returns>The last result returned by func().</returns>
		public static T Until(Func<T> func, Func<T, bool> isExpected, int timeoutMills = Wait.TimeoutInMills) {
			if (func == null || isExpected == null)
				throw new ArgumentNullException();

			T result = default(T);
			Func<bool> predicate = () => {
				result = func();
				return isExpected(result);
			};

			Wait.Until(predicate, timeoutMills);
			return result;
		}
	}
}
