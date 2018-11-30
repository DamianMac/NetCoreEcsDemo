using web.Domain;
using web.Infrastructure;

namespace web.Data
{
    public class ProductRepository : IProductRepository
    {
        private string connectionString;
        public ProductRepository(IAppConfiguration config)
        {
            connectionString = config.ConnectionString;
        }

        public Product Load(int id)
        {
            throw new System.NotImplementedException();
        }
    }
}