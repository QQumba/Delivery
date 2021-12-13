using System.Collections.Generic;
using System.Threading.Tasks;
using Delivery.DataAccess.Entities;
using Delivery.DataAccess.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Delivery.API.Controllers
{
    [ApiController]
    [Route("cargo")]
    public class CargoController : ControllerBase
    {
    private readonly CargoRepository _repository;

    public CargoController(CargoRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Cargo>>> GetAllWarehouses()
    {
        var cargoes = await _repository.GetAllCargoes();
        return Ok(cargoes);
    }
    }
}