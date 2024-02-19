using System;
using System.IO;
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
                    Log.Information("Oldest data removed successfully.");
                    Console.WriteLine("Oldest data removed successfully.");
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
            string query = $"DELETE FROM {config.DBName}.{config.TableName} WHERE {config.ColumnName} < DATE_ADD(@base_date, INTERVAL -@months_before MONTH)";
            using (MySqlCommand command = new MySqlCommand(query, connection))
            {
                command.Parameters.AddWithValue("@base_date", config.BaseDate.ToString("yyyy-MM-dd"));
                command.Parameters.AddWithValue("@months_before", config.MonthsBefore);
                command.ExecuteNonQuery();
            }
        }

        static string GetConnectionString(Config config)
        {
            return $"Server=localhost;Database={config.DBName};Uid=root;Pwd=QtX4300;";
        }
    }

    class Config
    {
        public string? DBName { get; set; }
        public string? TableName { get; set; }
        public string? ColumnName { get; set; }
        public DateTime BaseDate { get; set; }
        public int MonthsBefore { get; set; }
    }
}
