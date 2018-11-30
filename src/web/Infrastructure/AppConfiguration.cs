using Microsoft.Extensions.Configuration;

namespace web.Infrastructure
{
    public class AppConfiguration : IAppConfiguration
    {
        private readonly IConfiguration configuration;
        public AppConfiguration(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public string ConnectionString => configuration.GetValue<string>("ConnectionString");
    }
}