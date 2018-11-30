using web.Domain;

namespace web.Data
{
    public interface IProductRepository
    {
         Product Load(int id);
    }
}