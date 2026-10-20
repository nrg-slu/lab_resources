# Chameleon Tutorial 
`Author`: Mattia Fiore
## GUI Tutorial 
For the GUI tutorial refer to [pdf](./Chameleon.pdf) (Gently provided by Chiara Camerota) or to the [chameleon link](https://chameleoncloud.readthedocs.io/en/v1.0/technical/reservations.html)

## CLI Tutorial 

### Getting started (Just the first time)

Install the libraries before starting: 
```bash 
python3 -m venv ~/chameleon
source ~/chameleon/bin/activate
pip install git+https://github.com/ChameleonCloud/python-blazarclient.git@chameleoncloud/xena
pip install python-openstackclient
```
Create your user credentials: 
- log into [chameleon.org](https://chameleoncloud.org/)
- go to `Identity` -> `Application Credentials`
- Create application credential and download the `openrc` file 
- run the `openrc` file with: 

```bash 
source app-cred-mattia-openrc.sh
```
You can verify that everything is correct by running the following command: 
```bash 
openstack token issue 
```
Which should results in the following output
```bash 
+------------+-----------------------------------------------------------------------+
| Field      | Value                                                                 |
+------------+-----------------------------------------------------------------------+
| expires    |                   Something                                           |
| id         |                                                                       |
|            |                                                                       |
|            |                                                                       |
|            |                                                                       |
|            |                                                                       |
|            |                                                                       |
| project_id |                                                                       |
| user_id    |                                                                       |
+------------+-------------------------------------------------------------
```

### Reserving a machine 
Run this: 
```bash 
source app-cred-mattia-openrc.sh
```

`NOTE`: Chameleon cloud is +5 over Saint Louis time. 
```bash 
openstack reservation lease create \
  --reservation min=1,max=1,resource_type=physical:host,resource_properties='["=", "$node_type", "compute_cascadelake_r"]' \
  --start-date "2026-10-13 15:10" \
  --end-date "2026-10-19 15:00" \
    test
```
### Creating the instance 
After you create the lease you can crate the instance. First check the lease id: 
```bash 
openstack reservation lease show test
```
There are many IDs so check the one next to `reservations`. Then check for your key: 
```bash 
openstack keypair list
```
then take the one next to id and write the following command: 
```bash 
openstack server create   --flavor baremetal   --image CC-Ubuntu22.04   --key-name <key>   --network sharednet1   --hint reservation=<id>   <node_name>
```
### Assigning Floating IP 

Check if floating IP is free and not assigned to any machine: 
```bash 
openstack floating ip list
```
Then assign: 
```bash 
openstack server add floating ip <node_name> <FLOATING_IP>
```

### Connecting to the machine 

Remove IP if the machine has changed 
```bash 
ssh-keygen -f ~/.ssh/known_hosts -R <IP>
```
Connect with: 
```bash 
ssh -i <key> cc@<FLOATING-IP>
```
