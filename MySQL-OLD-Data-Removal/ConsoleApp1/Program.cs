using System;
using System.IO;
using Google.Protobuf;
using Microsoft.Extensions.Configuration;
using MySql.Data.MySqlClient;
using Serilog;

namespace DataRemovalApp
{
    class Program
    {
        
        static void Main(string[] args)
        {
            
            // Load configuration from JSON file
            var configuration = new ConfigurationBuilder()
                .AddJsonFile("config.json", optional: false, reloadOnChange: true)
                .Build();

            // Configure Serilog
            Log.Logger = new LoggerConfiguration()
                .ReadFrom.Configuration(configuration)
                .CreateLogger();

            var dbConfig = configuration.GetSection("DBConfig").Get<Config>();

            using (MySqlConnection connection = new MySqlConnection(GetConnectionString(dbConfig)))
            {
                try
                {
                    connection.Open();
                    RemoveOldestData(connection, dbConfig);
                    Log.Information($"Data Older than {dbConfig.MonthsBefore} Month/s from {DateTime.Now} has been Deleted!");
                    Console.WriteLine($"Data Older than {dbConfig.MonthsBefore} Month/s from {DateTime.Now} has been Deleted!");
                }
                catch (Exception ex)
                {
                    Log.Error(ex, "Error occurred while removing oldest data.");
                    Console.WriteLine($"Error occurred while removing oldest data: {ex}");
                }
            }

            Log.CloseAndFlush();
            Console.ReadLine();
            
        }

        static void RemoveOldestData(MySqlConnection connection, Config config)
        {

            DateTime CurrentDate = DateTime.Now;
            //DateTime CurrentDate = ConvertStringToDateTime("2005-07-30");

            DateTime formattedDate = FormatDateTime(CurrentDate);

                string query = $"DELETE FROM {config.DBName}.{config.TableName} WHERE {config.ColumnName} < DATE_ADD(@base_date, INTERVAL -@months_before MONTH)";
                using (MySqlCommand command = new MySqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@base_date", formattedDate);
                    command.Parameters.AddWithValue("@months_before", config.MonthsBefore);
                    command.ExecuteNonQuery();
                }
            
        }

        public static DateTime ConvertStringToDateTime(string dateString)
        {
            
            string format = "yyyy-MM-dd";

            
            DateTime dateTime = DateTime.ParseExact(dateString, format, System.Globalization.CultureInfo.InvariantCulture);

            return dateTime;
        }

        public static DateTime FormatDateTime(DateTime dateTime)
        {
            string formattedDateStr = dateTime.ToString("yyyy-MM-dd HH:mm:ss");

            DateTime formattedDate = DateTime.ParseExact(formattedDateStr, "yyyy-MM-dd HH:mm:ss", System.Globalization.CultureInfo.InvariantCulture);

            return formattedDate;
        }

        static string GetConnectionString(Config config)
        {
            return $"Server={config.MySQLServerName};Database={config.DBName};Uid={config.MySQLUsername};Pwd={config.MySQLPassword};";
        }
    }

    class Config
    {
        public string? MySQLServerName { get; set; }
        public string? MySQLUsername { get; set; }
        public string? MySQLPassword { get; set; }
        public string? DBName { get; set; }
        public string? TableName { get; set; }
        public string? ColumnName { get; set; }
        public int MonthsBefore { get; set; }

        
    }
}
