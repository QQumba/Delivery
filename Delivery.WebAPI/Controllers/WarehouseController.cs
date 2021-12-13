using System.Collections.Generic;
using System.Threading.Tasks;
using Delivery.DataAccess.Entities;
using Delivery.DataAccess.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Delivery.API.Controllers
{
    [ApiController]
    [Route("warehouse")]
    public class WarehouseController : ControllerBase
    {
        private readonly WarehouseRepository _repository;

        public WarehouseController(WarehouseRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Warehouse>>> GetAllWarehouses()
        {
            var warehouses = await _repository.GetAllWarehouses();
            return Ok(warehouses);
        }
    }
}