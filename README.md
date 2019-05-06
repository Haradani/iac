
This is a basic example on how to use packer.

Steps to run packer:

- Ensure your credentials are set into the profile "iac".

- Change *build.json*:
    Change the prefix in line 3 to your typical username. \
    (Do not use any special characters or spaces.)

- Run packer with the following command: \
    **AWS_PROFILE=iac packer build build.json**

- Packer will build the requested AMI

- When the build is finished, Packer will print the create AMI-ID. \
    Run the AMI with following command: \
    **AWS_PROFILE=iac run_ami.sh -a *AMI-ID* -u *USERNAME***

- This script creates a instance of the AMI and prints the IP address to connect to.
