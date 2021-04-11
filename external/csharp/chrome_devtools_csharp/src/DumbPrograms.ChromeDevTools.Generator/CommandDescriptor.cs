using System.Text;

namespace DumbPrograms.ChromeDevTools.Generator
{
    public class CommandDescriptor
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public bool Experimental { get; set; }
        public bool Deprecated { get; set; }
        public PropertyDescriptor[] Parameters { get; set; }
        public PropertyDescriptor[] Returns { get; set; }

        public override string ToString()
        {
            var sb = new StringBuilder(Name);

            sb.Append(" (");

            if (Parameters != null)
            {
                foreach (var pd in Parameters)
                {
                    sb.Append(pd.Name);
                    if (pd.Optional)
                    {
                        sb.Append('?');
                    }
                    sb.Append(", ");
                }
                sb.Length -= 2;
            }

            sb.Append(") => ");

            if (Returns != null)
            {
                sb.Append('{');

                foreach (var pd in Returns)
                {
                    sb.Append(pd.Name).Append(", ");
                }
                sb.Length -= 2;

                sb.Append('}');
            }
            else
            {
                sb.Append("void");
            }

            return sb.ToString();
        }
    }
}