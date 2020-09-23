#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char* argv[])
{
   char help[] =
      "Usage: nodes cluster [[-exclude] ...]\n"
      "-xa, would remove any line matching this litteral (xa,)";

   if (argc == 1) puts (help);

   // char *cluster, exclusions[];

   for (int i = 1; i < argc; i++)
   {
      if (argv[i][0] == '-')
         puts (argv[i]);
   }

   char* config = getenv ("XDG_CONFIG_HOME");
   strcat (config, "/clustershell/groups.d/cluster.yaml");

   FILE* clusters = fopen (config, "r");

   char buff[255];

   while (fgets(buff, sizeof(buff), clusters))
   {
      printf ("%s", buff);
   }

   fclose (clusters);

   return 0;
}
