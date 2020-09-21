#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char* argv[])
{
   char help[] =
      "Usage: nodes cluster [[-exclude] ...]\n"
      "-xa, would remove any line matching this litteral (xa,)";

   if (argc == 1) puts (help);

   char* config = getenv ("XDG_CONFIG_HOME");
   strcat (config, "/clustershell/groups.d/cluster.yaml");

   puts (config);

   FILE* clusters = fopen (config, "r");

   char cluster[100];
   fscanf (clusters, "%s", cluster);
   puts (cluster);

   fclose (clusters);

   return 0;
}
