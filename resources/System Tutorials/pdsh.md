# Parallel Distributed Shell short tutorial 
 
`Author`: Mattia Fiore 

Running multiple commands on different machines when connected through multiple ssh is slow and inefficient if you want to run the same program. This may happen when running client side applications that need to start "concurrently". 
Running with different terminals creates too much variance. For this reason it is helpful to use `pdsh` also known as Parallel distribute shell. 

## Tutorial 
1. Make sure to have a user in the machine 
2. Make sure that the device has `pdsh` installed. If not: 
```bash
sudo apt update 
sudo apt install pdsh  
```
3. From the list of all your hosts that is present in `~/.ssh/config` run: 
```bash 
ssh-keygen -t ed25519 #Run it once 
ssh-copy-id [server_name] #Once per host
```
4. Create the string with all the hosts
```bash 
HOSTS="aldo,giovanni,giacomo"
```
5. Run your command in the following way: 
```bash 
pdsh -R ssh -l [username] -w "$HOSTS" [command]
```
`Note`: If you forgot your username Mattia's convention is to use the first letter of the first name and then the surname (Ex: Mattia Fiore -> mfiore)