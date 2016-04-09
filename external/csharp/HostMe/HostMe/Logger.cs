using System;
using System.IO;
using log4net;
using log4net.Appender;
using log4net.Core;
using log4net.Layout;
using log4net.Repository.Hierarchy;

namespace HostMe
{
    public static class Logger
    {
        public static ILog GetLogger()
        {
            return LogManager.GetLogger("logger");
        }

        static Logger()
        {
            var patternLayout = new PatternLayout { ConversionPattern = "%d [%t] %-5p %m%n" };
            patternLayout.ActivateOptions();

            var hierarchy = (Hierarchy)LogManager.GetRepository();
            hierarchy.Root.Level = Level.All;
            hierarchy.Configured = true;

            var rollingFileAppender = CreateRollingFileAppender(patternLayout);
            hierarchy.Root.AddAppender(rollingFileAppender);

            if (!Environment.UserInteractive)
                return;

            var consoleAppender = CreateColoredConsoleAppender(patternLayout);
            hierarchy.Root.AddAppender(consoleAppender);
        }

        private static IAppender CreateColoredConsoleAppender(ILayout layout)
        {
            var consoleAppender = new ColoredConsoleAppender { Layout = layout };

            consoleAppender.AddMapping(
                new ColoredConsoleAppender.LevelColors
                { Level = Level.Warn, ForeColor = ColoredConsoleAppender.Colors.Yellow });

            consoleAppender.AddMapping(
                new ColoredConsoleAppender.LevelColors
                { Level = Level.Error, ForeColor = ColoredConsoleAppender.Colors.Red });

            consoleAppender.AddMapping(
                new ColoredConsoleAppender.LevelColors
                { Level = Level.Fatal, ForeColor = ColoredConsoleAppender.Colors.Red });

            consoleAppender.ActivateOptions();
            return consoleAppender;
        }

        private static IAppender CreateRollingFileAppender(ILayout layout)
        {
            var logsFolder = PathNormalizer.NormalizePath("logs");

            if (!Directory.Exists(logsFolder))
                Directory.CreateDirectory(logsFolder);

            var rollingFileAppender = new RollingFileAppender
            {
                Layout = layout,
                AppendToFile = true,
                RollingStyle = RollingFileAppender.RollingMode.Size,
                PreserveLogFileNameExtension = true,
                MaxSizeRollBackups = 1,
                MaximumFileSize = "10MB",
                StaticLogFileName = true,
                File = Path.Combine(logsFolder, DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".txt")
        };
            rollingFileAppender.ActivateOptions();
            return rollingFileAppender;
        }
    }
}
