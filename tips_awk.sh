# awk tips

ls files_list | awk '{print "mv "$1" "$1".new"}' | sh

ls *old|sed 's/\(.*\)\.old/mv \1.old  \1.new/'|sh

for file in *; do mv $file $file.bak; done
