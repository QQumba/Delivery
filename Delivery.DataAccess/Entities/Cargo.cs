using System;

namespace Delivery.DataAccess.Entities
{
    public class Cargo
    {
        public int Id { get; set; }
        public int DestinationWarehouseId { get; set; }
        public int ProductInstanceId { get; set; }
        public DateTime DeliveryDate { get; set; }
    }
}