using Autofac;

namespace web.Modules
{
    public class DataModule : Module
    {

        protected override void Load(ContainerBuilder builder)
        {
            builder.RegisterAssemblyTypes(typeof(DataModule).Assembly)
                .Where(t => t.Name.EndsWith("Repository") && t.IsClass)
                .AsImplementedInterfaces().InstancePerLifetimeScope();
        }
    

        
    }
}