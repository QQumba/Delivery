using System.Collections.Generic;
using System.Threading.Tasks;
using Dapper;
using Delivery.DataAccess.Entities;

namespace Delivery.DataAccess.Repositories
{
    public class CargoRepository
    {
        private readonly SqlConnectionProvider _provider;

        public CargoRepository(SqlConnectionProvider provider)
        {
            _provider = provider;
        }

        public async Task<IEnumerable<Cargo>> GetAllCargoes()
        {
            using var connection = _provider.Connection;
            const string query = "SELECT * FROM cargo";

            var cargoes = await connection.QueryAsync<Cargo>(query);
            return cargoes;
        }
    }
}