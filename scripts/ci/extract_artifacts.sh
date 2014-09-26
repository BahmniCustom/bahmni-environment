IMPLEMENTATION_NAME=$1

if [ Z${IMPLEMENTATION_NAME} = "Z" ] 
then
	echo "Argument required"
	exit 1
fi

mv -f deployables/mrs/* /packages/build/
mv -f deployables/erp/* /packages/build/
mv -f deployables/elis/* /packages/build/
mv -f deployables/referencedata/* /packages/build/
mv -f deployables/environment/* /packages/build/
mv -f deployables/${IMPLEMENTATION_NAME}_config.zip /packages/build

rm -rf deployables

unzip -qo /packages/build/bahmni-environment.zip -d /packages/build/

rm -f /packages/build/*_md5.checksum