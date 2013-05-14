# It would sync the bahmni-environment/packages directory to /packages on the dest machine.
# Pass the IP address of the destination machine 
rsync -rh --progress -i --itemize-changes --update --delete --chmod=Du=r,Dg=rwx,Do=rwx,Fu=rwx,Fg=rwx,Fo=rwx -p packages -e ssh root@$1:/