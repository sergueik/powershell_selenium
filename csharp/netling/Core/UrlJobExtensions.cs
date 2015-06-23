using System;
using System.Linq;
using System.Data.SQLite;
using SQLite.Utils;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Collections.Generic;
using System.Windows.Controls;
using System.Windows.Threading;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.IO;
using Core;
using Core.Models;

namespace Client
{
    public partial class MainWindow : Window
    {
        private bool running = false;
        private CancellationTokenSource cancellationTokenSource;
        private Task<JobResult<UrlResult>> task;
        private static string tableName = "";
        private static string dataFolderPath;
        private static string database;
        private static string dataSource;

        public MainWindow()
        {
            InitializeComponent();


            dataFolderPath = Directory.GetCurrentDirectory();
            database = String.Format("{0}\\data.db", dataFolderPath);
            dataSource = "data source=" + database;
            tableName = "product";
            createTable();

        }

        private void StartButton_Click(object sender, RoutedEventArgs e)
        {
            if (!running)
            {
                var timeLimited = false;
                TimeSpan duration = default(TimeSpan);
                int runs = 0;
                TestConnection();
                var threads = Convert.ToInt32(Threads.SelectionBoxItem);
                var durationText = (string)((ComboBoxItem)Duration.SelectedItem).Content;
                StatusProgressbar.IsIndeterminate = false;

                switch (durationText)
                {
                    case "1 run":
                        runs = 1;
                        break;
                    case "10 runs":
                        runs = 10;
                        break;
                    case "100 runs":
                        runs = 100;
                        break;
                    case "10 seconds":
                        duration = TimeSpan.FromSeconds(10);
                        timeLimited = true;
                        break;
                    case "20 seconds":
                        duration = TimeSpan.FromSeconds(20);
                        timeLimited = true;
                        break;
                    case "1 minute":
                        duration = TimeSpan.FromMinutes(1);
                        timeLimited = true;
                        break;
                    case "10 minutes":
                        duration = TimeSpan.FromMinutes(10);
                        timeLimited = true;
                        break;
                    case "1 hour":
                        duration = TimeSpan.FromHours(1);
                        timeLimited = true;
                        break;
                    case "Until canceled":
                        duration = TimeSpan.MaxValue;
                        timeLimited = true;
                        StatusProgressbar.IsIndeterminate = true;
                        break;

                }

                var urls = Regex.Split(Urls.Text, "\r\n").Where(u => !string.IsNullOrWhiteSpace(u)).Select(u => u.Trim());

                if (!urls.Any())
                    return;

                Threads.IsEnabled = false;
                Duration.IsEnabled = false;
                Urls.IsEnabled = false;

                cancellationTokenSource = new CancellationTokenSource();
                var cancellationToken = cancellationTokenSource.Token;
                var job = new Job<UrlResult>();

                StatusProgressbar.Value = 0;
                StatusProgressbar.Visibility = Visibility.Visible;
                job.OnProgress += OnProgress;

                MemoryStream args = new MemoryStream();
                DataContractJsonSerializer ser =
                  new DataContractJsonSerializer(typeof(InvocationArgs));
                ser.WriteObject(args, new InvocationArgs() { threads = threads, runs = runs, duration = duration });

                task = Task.Run(() => job.ProcessUrls((Stream)args, urls, cancellationToken));

                // TaskAwaiter Structure
                System.Runtime.CompilerServices.TaskAwaiter<JobResult<UrlResult>> awaiter = task.GetAwaiter();
                awaiter.OnCompleted(JobCompleted);

                StartButton.Content = "Cancel";
                running = true;
            }
            else
            {
                if (cancellationTokenSource != null && !cancellationTokenSource.IsCancellationRequested)
                    cancellationTokenSource.Cancel();
            }
        }

        private void OnProgress(double amount)
        {
            Dispatcher.InvokeAsync(() => StatusProgressbar.Value = amount, DispatcherPriority.Background);
        }

        private void JobCompleted()
        {
            Threads.IsEnabled = true;
            Duration.IsEnabled = true;
            Urls.IsEnabled = true;
            StartButton.Content = "Run";
            StatusProgressbar.Visibility = Visibility.Hidden;
            cancellationTokenSource = null;
            running = false;

            var result = new ResultWindow(task.Result);
            task = null;
            result.Show();
        }


        public static void createTable()
        {
            using (SQLiteConnection conn = new SQLiteConnection(dataSource))
            {
                using (SQLiteCommand cmd = new SQLiteCommand())
                {
                    cmd.Connection = conn;
                    conn.Open();
                    SQLiteHelper sh = new SQLiteHelper(cmd);
                    sh.DropTable(tableName);

                    SQLiteTable tb = new SQLiteTable(tableName);
                    tb.Columns.Add(new SQLiteColumn("id", true)); // auto increment 
                    tb.Columns.Add(new SQLiteColumn("count"));
                    tb.Columns.Add(new SQLiteColumn("responsetime", ColType.Decimal));
                    sh.CreateTable(tb);
                    conn.Close();
                }
            }
        }

        bool TestConnection()
        {
            Console.WriteLine(String.Format("Testing database connection {0}...", database));
            try
            {
                using (SQLiteConnection conn = new SQLiteConnection(dataSource))
                {
                    conn.Open();
                    conn.Close();
                }
                return true;
            }

            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return false;
            }
        }


    }
}
