# Code carbon tutorial 

`Author`: Mattia Fiore 

In order to measure the energy consumption of AI models, either training or inference [code carbon library](https://codecarbon.io/) is very simple and useful. Here are the two tools that you can use to measure your python code consumption: 

## Decorator usage
```python 
from codecarbon import track_emissions

...
@track_emissions
def function(...): 
    ...
```

Using the decorator is very simle but it gets a lot of informations which may not be needed depending on the application. After running it will generate a csv file with the information of your system architecture and the consumptions. 

## Emission Tracker 
It is also possible to use the Online or Offline emission tracker. 
```bash
from codecarbon import OfflineEmissionsTracker 
...
tracker = OfflineEmissionsTracker(tracking_mode = "machine")
tracker.start_task("load_model")
model = load_model("NX-AI/TiRex-2", device="cuda")  # use `device="cuda"` if cuda is available
emissions_1 = tracker.stop_task()

print(f"CPU Consumed: {emissions_1.cpu_energy} KWh")
print(f"GPU Consumed: {emissions_1.gpu_energy} KWh")
print(f"RAM Consumed: {emissions_1.ram_energy} KWh")
```
There are many other statistics that it is possible to extract, just check the documentaiton. 

`Note`: You may need to run the following command to allow the program the permission to verify these information.
```bash 
sudo chmod -R a+r /sys/class/powercap/*
```