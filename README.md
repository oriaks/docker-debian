# docker-debian

The build.sh script will build and run debootstrap inside an ephemeral container then build the Debian image we use at Oriaks. This image is quite similar to the official Docker Debian image, but it uses clish (http://libcode.org/projects/klish/) as the default shell instead of bash. clish is the command-line interface (CLI) we use with our other images to configure services.

The run.sh script will run a shell (clish) inside an ephemeral container.
