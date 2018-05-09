# tehama_gateway_agent_install

On May 10, 2018, Support for agent.sh will end
The new version 'get-gateway.sh' is now found on Tehama.io

'get-agent.sh' customers will no longer receive updates or critical patches to the legacy 'Tehama Gateway Agent'
The new 'Tehama Gateway' now supports easier updates through the tehama.io webpage!

For more information, please visit the support site at - https://app.tehama.io/docs/gateway/
Do you have questions or concenrs?  Please email, suppport@tehama.io

To install the latest version of the Tehama Gatway please use the following command:
wget https://tehama.io/get-gateway.sh



Minimum requirements: 

Linux Host:
Minimum OS:  Ubuntu 14.04, CentOS 7.3, Amazon AMI 2017.3, Red Hat Enterprise Server 7.3 or Fedora 25 
Minimum hardware/VM config:  Dual Core CPU, 4GB Ram, 1GB HDD 
Wired network connectivity

Firewall Exception (outbound)

TCP ports: 22, 80 and 443
UDP:  ICMP outbound 

-=Instructions=-

Create a folder for the Tehama Gateway Agent (ensure folder is not in the /tmp directory), type:   <b>mkdir tehama</b>

Enter the tehama folder, type:   <b>cd tehama</b>

Download the install script, type:   
<b>wget https://raw.githubusercontent.com/pythian/tehama_gateway_agent_install/master/get-agent.sh</b>
after May 10, 2018:  <b>https://tehama.io/get-gateway.sh</b>

Set permissions:   <b>chmod 755 get-agent.sh</b>

Run the install script as root:   <b>sudo ./get-agent.sh -d</b>

Paste in the key when prompted and press enter.  The key can be found on the Connection Tab on the Tehama website

Press "Y" to confirm

To check the progress of the agent connectivity, return to a command (press enter twice) type:   <b>tail -f nohup.out</b>

Agent connectivity can also be viewed on the Tehama website in the Connection tab
