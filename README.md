# docker-debian

When invoked as "./dh.sh build", this script will build and run debootstrap inside an ephemeral container then build the Debian image we use at Oriaks. This image is quite similar to the official Docker Debian image, but it uses clish (http://libcode.org/projects/klish/) as the default shell instead of bash. clish is the command-line interface (CLI) we use with our other images to configure services.

When invoked as "./dh.sh shell", this script will run a shell (clish) inside an ephemeral container.
