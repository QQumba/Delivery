using System.Data;
using System.Data.SqlClient;
using Npgsql;

namespace Delivery.DataAccess.Repositories
{
    public class SqlConnectionProvider
    {
        private const string ConnectionString = "Server=localhost;Port=5432;Database=kis;User Id=postgres;Password=rootservgeevich;";
        public IDbConnection Connection => new NpgsqlConnection(ConnectionString);
    }
}