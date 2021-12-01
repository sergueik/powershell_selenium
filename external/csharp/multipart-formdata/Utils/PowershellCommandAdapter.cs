using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;

// origin: https://www.codeproject.com/Articles/5318610/One-More-Solution-to-Calling-PowerShell-from-Cshar
// with few tweaks so covert to C# 4 syntax
namespace Utils
{
    public static class PowershellCommandAdapter
    {
        public static Exception LastException = null;

        public static PSDataCollection<ErrorRecord> LastErrors = 
                                                    new PSDataCollection<ErrorRecord>();

        public static bool HasError
        {
            get
            {
                return LastException != null;
            }
            set
            {
                if(!value)
                {
                    LastException = null;
                    LastErrors = new PSDataCollection<ErrorRecord>();
                }
            }
        }

        public static int ErrorCode
        {
            get
            {
                if (HasError) return int.Parse(LastException.Message.Substring(1, 4));
                return 0;
            }
        }

        public static bool RunPS(PowerShell ps, string psCommand, out Collection<PSObject> outs)
        {
            outs = new Collection<PSObject>();
            HasError = false;
            ps.Commands.Clear();
            ps.Streams.ClearStreams();

            ps.AddScript(psCommand);
            outs = ExecutePS(ps);

            return !HasError;
        }

        public static bool RunPS(PowerShell ps, string psCommand, 
               out Collection<PSObject> outs, params ParameterPair[] parameters)
        {
            outs = new Collection<PSObject>();
            HasError = false;
           
            if (!psCommand.Contains(' '))
            {
                ps.Commands.Clear();
                ps.Streams.ClearStreams();

                ps.AddCommand(psCommand);

                foreach (ParameterPair PP in parameters)
                {
                	if (String.IsNullOrEmpty(PP.Name))
                    {
                        LastException = new Exception("E1008:Parameter cannot be unnamed");
                        return false;
                    }

                    if (PP.Value == null) ps.AddParameter(PP.Name);
                    else ps.AddParameter(PP.Name, PP.Value);
                }

                outs = ExecutePS(ps);
            }			
            else LastException = new Exception("E1007:Only one command  with no parameters is allowed");
            return !HasError;
        }

        private static Collection<PSObject> ExecutePS(PowerShell ps) {
            Collection<PSObject> retVal = new Collection<PSObject>();

            try
            {
                retVal = ps.Invoke();

                if (ps.Streams.Error.Count > 0)
                {
                    LastException = new Exception
                                    ("E0002:Errors were detected during execution");
                    LastErrors = new PSDataCollection<ErrorRecord>(ps.Streams.Error);
                }
            }
            catch (Exception ex)
            {
                LastException = new Exception("E0001:" + ex.Message);
            }

            return retVal;
        }
    }
    public class ParameterPair
    {
    	private string name  = string.Empty;
        public string Name { get; set; }
    	private object data  = null;
    	public object Value { get {return data;} set {data = value;} }
    }
}

