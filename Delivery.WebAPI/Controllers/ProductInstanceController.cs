using System.Collections.Generic;
using System.Threading.Tasks;
using Delivery.DataAccess.Entities;
using Delivery.DataAccess.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Delivery.API.Controllers
{
    [ApiController]
    [Route("product-instance")]
    public class ProductInstanceController : ControllerBase
    {
        private readonly ProductInstanceRepository _repository;

        public ProductInstanceController(ProductInstanceRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ProductInstance>>> GetAllWarehouses()
        {
            var productInstances = await _repository.GetAllProductInstances();
            return Ok(productInstances);
        }
    }
}