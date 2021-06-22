# loylogic_problem_statement

I have created 3 seperate folders for 3 problem statements.

(I)problem_statement1 folder has the terraform code to provision the infrastructure asked
The files used here are:
1) vpc.tf - the actual infrastructure of the vpc
2) variables.tf - the variables used in the creation of vpc
3) private_ec2.sh - the user data script for the private subnet ec2
4) public_ec2.sh - the user data script for the public subnet ec2

(II)problem_statement2 folder has the solution for the second problem
It has the pom.xml of the spring-petclinic project provided by you. I have added the internal repo /mnt/artefact in pom.xml at line 18 to deploy the jar file to the same.
I used a freestyle project in Jenkins to deploy the artefact. 
I integrated the git repository to this freestyle project and in the build triggers I triggered the command "mvn clean deploy" which will deploy the artefact to /mnt/artefact.

(III)problem_statement3 folder has the ansible commands
It has the inventory file "hostsfile" which has the destination IP of the private subnet ec2 machine.
And the file ansible_command has the ansible adhoc command to depoy the artefact to the same private subnet ec2 machine.
