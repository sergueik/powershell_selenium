using System;
using System.ComponentModel;
using System.Threading;

namespace Wait {
	public static class Wait {
		//Mininum time in mSec waited before execution
		public const int MinIntervalMills = 1;
		//Maximum time in mSec waited before next execution
		public const int MaxIntervalMills = 100;

		//Maxium time to be waited before timeout
		public const int TimeoutInMills = 10 * 1000;
		public static TimeSpan Timeout = TimeSpan.FromMilliseconds(TimeoutInMills);

		/// <summary>
		/// This method execute any commands wrapped as a Predicate periodically until it is timeout.
		/// If the command execution is success (when predicate returns true), then it would return immediately.
		/// Otherwise, all exepections except the last one due to the command execution would be discarded considering
		/// that they are identical; and the last exception would be throw when command execution is not success when
		/// timeout happens.
		/// </summary>
		/// <param name="predicate">Wrapper of the execution codes that might throw exceptions.</param>
		/// <param name="timeoutMills">Time waited before draw conclusion that the command cannnot succeed.</param>
		public static void Until(Func<bool> predicate, int timeoutMills = TimeoutInMills) {
			if (timeoutMills <= 0)
				throw new InvalidEnumArgumentException("The timeout must be a positive value");

			//Get the moment when the execution is considered to be timeout
			DateTime timeoutMoment = DateTime.Now + TimeSpan.FromMilliseconds(timeoutMills);

			int interval = MinIntervalMills;
			Exception lastException = null;

			do {
				try {
					//If something happen as expected, return immediately and ignore the previous exception
					if (predicate())
						return;
				} catch (Exception ex) {
					// Intentionally record only the last Exception due to the fact that usually it is due to same reason
					lastException = ex;
				}

				//Waiting for a period before execution codes within predicate()
				Thread.Sleep(interval);

				//The waiting time is extended, but no more than that defined by MaxIntervalMills
				interval = Math.Min(interval * 2, MaxIntervalMills);

			} while (DateTime.Now < timeoutMoment);

			//Exected only when timeout before expected event happen

			//If there is some exception during the past executions, throw it for debugging purposes
			if (lastException != null)
				throw lastException;
			else {
				throw new TimeoutException();
			}
		}

		/// <summary>
		/// This method keep executing any function that a string as result by using the mechnism of Until()
		/// until timeout or the result is exactly as "expectedString".
		/// </summary>
		/// <param name="getStringFunc">Any function returning string.
		///  For functions with parameters, for example: 
		///     public string someFunc(int param), 
		///  This method can be called with assitance of LINQ as below:
		///     UntilString(()=>someFunc(param), expectedString)
		/// </param>
		/// <param name="expectedString">string expected that cannot be null.</param>
		/// <param name="timeoutMills">Time waited before draw conclusion that the command cannnot succeed.</param>
		/// <returns>The final result of calling getStringFunc().</returns>
		public static string UntilString(Func<string> getStringFunc, string expectedString, int timeoutMills = TimeoutInMills) {
			if (expectedString == null)
				throw new ArgumentNullException();

			string result = null;
			Func<bool> predicate = () => {
				result = getStringFunc();
				return result == expectedString;
			};

			Until(predicate, timeoutMills);
			return result;
		}

		/// <summary>
		/// This method keep executing any function that a string as result by using the mechnism of Until()
		/// until timeout or the result contains the "expectedString".
		/// </summary>
		/// <param name="getStringFunc">Any function returning string.
		///  For functions with parameters, for example: 
		///     public string someFunc(int param), 
		///  This method can be called with assitance of LINQ as below:
		///     UntilString(()=>someFunc(param), expectedString)
		/// </param>
		/// <param name="expectedString">string expected to be contained by calling getStringFunc().</param>
		/// <param name="timeoutMills">Time waited before draw conclusion that the command cannnot succeed.</param>
		/// <returns>The final result of calling getStringFunc().</returns>
		public static string UntilContains(Func<string> getStringFunc, string expectedString, int timeoutMills = TimeoutInMills)
		{
			if (expectedString == null)
				throw new ArgumentNullException();

			string result = null;
			Func<bool> predicate = () => {
				result = getStringFunc();
				return result.Contains(expectedString);
			};

			Until(predicate, timeoutMills);
			return result;
		}
	}
}
