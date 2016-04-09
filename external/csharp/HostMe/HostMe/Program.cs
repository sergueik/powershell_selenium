using System;
using System.IO;
using System.Linq;
using System.Reflection;
using log4net;
using MicroService4Net;
using Newtonsoft.Json;

namespace HostMe
{
    class Program
    {
        const int DEFAULT_PORT = 80;
        private const string CONFIG_FILE_NAME = "HostMe.config.json";
        private static readonly ILog Logger = HostMe.Logger.GetLogger();

        static void Main(string[] args)
        {
            WritePassedArgsToLog(args);

            var configuration = GetConfiguration() ?? new Configuration { Port = DEFAULT_PORT };

            StaticContentController.SiteRootPath = PathNormalizer.NormalizePath(configuration.Path);
            var port = configuration.Port;

            Logger.InfoFormat("Starting...\r\nPort = {0}\r\nPath = {1}",port,StaticContentController.SiteRootPath);

            var serviceName = Assembly.GetEntryAssembly().GetName().Name + "_Port_" + port;
            var microService = new MicroService(port, serviceName, serviceName);
            microService.Run(args);
        }

        private static Configuration GetConfiguration()
        {
            Configuration configuration = null;
            var configFilePath = PathNormalizer.NormalizePath(CONFIG_FILE_NAME);

            if (!File.Exists(configFilePath))
                return null;

            var jsonConfig = GetConfigAsJson(configFilePath);

            try
            {
                configuration = JsonConvert.DeserializeObject<Configuration>(jsonConfig);
                Logger.Info("Configuration parsed");

                if (configuration.Port == 0)
                {
                    Logger.Info("No configuration port found. using port " + DEFAULT_PORT);
                    configuration.Port = DEFAULT_PORT;
                }
            }
            catch (Exception exception)
            {
                Logger.Error("Exception occured in configuratin parsing", exception);
            }

            return configuration;
        }

        private static string GetConfigAsJson(string configFilePath)
        {
            Logger.Info("Config found in " + configFilePath);
            var jsonConfig = File.ReadAllText(configFilePath);
            Logger.Info("The Config is: \r\n" + jsonConfig);
            return jsonConfig;
        }

        private static void WritePassedArgsToLog(string[] args)
        {
            if (args.Count() != 0)
            {
                var argsString = args.Aggregate((arg, current) => current + "," + arg);
                Logger.Info("Args = " + argsString);
            }
            else
                Logger.Info("No args passed");
        }
    }
}
