using System.Reflection.Metadata.Ecma335;

namespace Delivery.DataAccess.Entities
{
    public class ProductInstance
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public int WarehouseId { get; set; }
        public int Quantity { get; set; }
    }
}