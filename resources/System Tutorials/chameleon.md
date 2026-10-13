# Chameleon Tutorial 
`Author`: Mattia Fiore
## GUI Tutorial 
For the GUI tutorial refer to [pdf](./Chameleon.pdf) (Gently provided by Chiara Camerota) or to the [chameleon link](https://chameleoncloud.readthedocs.io/en/v1.0/technical/reservations.html)

## CLI Tutorial 

### Getting started 

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
You have provided a username. In the V3 identity API a username is only unique within a domain so you must also provide either a user_domain_id or user_domain_name.
```

### Reserving a machine 