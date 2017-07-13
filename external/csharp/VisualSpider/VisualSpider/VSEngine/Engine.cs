using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using VSEngine.Data;
using VSEngine.Integration;

namespace VSEngine
{
    /// <summary>
    /// The engine that runs the Visual Spider main loop
    /// </summary>
    public class Engine
    {
        Config Configs = new Config();

        Init Initilization = new Init();
        NavLoop NavigationLoop = new NavLoop();
        PostReporting CleanupAndReporting = new PostReporting();

        DBAccess Database = new DBAccess();

        public Engine()
        {
            Configs.GenerateConfig();
            Initilization.LoadConfigs(Configs);
            Initilization.CreateDB(Database);
            Initilization.FirstTimeURLStore(Configs, Database);
            NavigationLoop.Loop(Database, Configs);
        }
    }
}
