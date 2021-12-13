using System.Collections.Generic;
using System.Threading.Tasks;
using Delivery.DataAccess.Entities;
using Delivery.DataAccess.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Delivery.API.Controllers
{
    [ApiController]
    [Route("product")]
    public class ProductController : ControllerBase
    {
        private readonly ProductRepository _repository;

        public ProductController(ProductRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Product>>> GetAllProducts()
        {
            var products = await _repository.GetAllProducts();
            return Ok(products);
        }
    }
}