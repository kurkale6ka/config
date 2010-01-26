# awk tips

ls files_list | awk '{print "mv "$1" "$1".new"}' | sh
